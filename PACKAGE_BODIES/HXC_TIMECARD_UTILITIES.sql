--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_UTILITIES" AS
/* $Header: hxctcutil.pkb 120.25.12010000.2 2008/11/13 12:20:37 bbayragi ship $ */

g_debug boolean := hr_utility.debug_enabled;
g_assignment_periods     periods;
g_past_date_limit        DATE;
g_future_date_limit      DATE;
g_rec_period_start_date  hxc_recurring_periods.start_date%TYPE;
g_period_type            hxc_recurring_periods.period_type%TYPE;
g_duration_in_days       hxc_recurring_periods.duration_in_days%TYPE;
g_num_past_entries       NUMBER := 10; --hardcoded
g_num_future_entries     NUMBER := 10; --hardcoded
g_separator              VARCHAR2(1) := '|';
g_date_format            VARCHAR2(20) := 'YYYY/MM/DD';
g_initialized            VARCHAR2(20) := 'N';
g_package                VARCHAR2(30) := 'hxc_timecard_utilities.';

PROCEDURE get_period_by_duration(
  p_rec_period_start_date IN DATE
 ,p_duration_in_days      IN NUMBER
 ,p_current_date          IN DATE
 ,p_start_date           OUT NOCOPY DATE
 ,p_end_date             OUT NOCOPY DATE
)
IS
  l_start_date DATE;
  l_end_date   DATE;
BEGIN
  --current period's start time
  p_start_date :=  p_rec_period_start_date +
    (p_duration_in_days *  FLOOR(((p_current_date - p_rec_period_start_date)/p_duration_in_days)));

  p_end_date := p_start_date + p_duration_in_days - 1;
END get_period_by_duration;

-- ----------------------------------------------------------------------------
-- |--------------------< get_more_period_value>----------------------|
-- this function is called from the get_periods procedure.. when the generate_periods
-- procedure is called for existing timecards in the time_building_blocks table, this
-- function helps in checking whether the particular period has to be flagged to
-- get displayed as More Periods in the timecard UI.
-- ----------------------------------------------------------------------------

FUNCTION get_more_period_value( p_periods in periods
			     ,p_start_date in date
			     ,p_end_date in date
			    ) RETURN varchar2 IS
l_period_index Number;

begin
    l_period_index := p_periods.first;

    WHILE p_periods.exists(l_period_index)
       LOOP
         if(trunc(p_periods(l_period_index).start_date) = trunc(p_start_date)) and
           (trunc(p_periods(l_period_index).end_date) = trunc(p_end_date)) then
	      return p_periods(l_period_index).p_set_more_period;
	 end if;
      l_period_index := p_periods.next(l_period_index);
    END LOOP;
    return NULL;
END get_more_period_value;


-- ----------------------------------------------------------------------------
-- |--------------------< check_period_archived>----------------------|
-- this function determines whether the timecard period has been archived or not.
-- ----------------------------------------------------------------------------

FUNCTION check_period_archived(p_stop_date IN date) RETURN BOOLEAN IS

CURSOR c_is_archived(p_stop_date IN date)
IS
  SELECT 'Y'
  FROM hxc_data_sets
  WHERE p_stop_date BETWEEN START_DATE AND END_DATE
  AND STATUS IN ( 'OFF_LINE', 'RESTORE_IN_PROGRESS', 'BACKUP_IN_PROGRESS' );

l_archived boolean;
l_dummy VARCHAR2(1);

BEGIN
l_archived := FALSE;

OPEN c_is_archived (p_stop_date);
Fetch c_is_archived into l_dummy;

IF (c_is_archived%FOUND) THEN
   l_archived := TRUE;
END IF;
CLOSE c_is_archived;
RETURN l_archived;
END check_period_archived;

FUNCTION check_assignments(
  p_period_start IN DATE
 ,p_period_end   IN DATE
) RETURN BOOLEAN
IS
  l_assignment_index NUMBER;

BEGIN
  l_assignment_index := g_assignment_periods.first;

  LOOP
    EXIT WHEN NOT g_assignment_periods.exists(l_assignment_index);

    IF p_period_start > g_assignment_periods(l_assignment_index).end_date
      OR p_period_end < g_assignment_periods(l_assignment_index).start_date
    THEN
      NULL;
    ELSE
      RETURN TRUE;
    END IF;

    l_assignment_index := g_assignment_periods.next(l_assignment_index);
  END LOOP;

  RETURN FALSE;
END check_assignments;

-- ----------------------------------------------------------------------------
-- |--------------------< find_period_already_exist >----------------------|
--  Returns the index position of the period if it already exists.
-- ----------------------------------------------------------------------------

FUNCTION find_period_already_exist( p_period IN periods , p_start_date in date, p_end_date in date)
RETURN NUMBER is
l_index NUMBER;
BEGIN
l_index := p_period.first;
loop
 EXIT WHEN NOT p_period.exists(l_index);
 if(( trunc(p_period(l_index).start_date) = trunc(p_start_date))
    AND
    (trunc(p_period(l_index).end_date) = trunc(p_end_date))) THEN
    return l_index;
 END IF;
 l_index := p_period.next(l_index);
END LOOP;
return -1;
END find_period_already_exist;

PROCEDURE process_assignments(
  p_period         IN time_period
 ,p_assignment_periods IN periods
 ,p_return_periods IN OUT NOCOPY periods
)
IS
  l_return_index NUMBER;
  l_found_index NUMBER;
  l_start_date date;
  l_end_date date;
BEGIN
  IF p_return_periods.count = 0
  THEN
    l_return_index := 0;
  ELSE
    l_return_index := p_return_periods.last + 1;
  END IF;

  IF (p_period.exist_flag = hxc_timecard.c_existing_period_indicator) THEN

    --Remove the entry if its already found. We need to keep the existing period
    --in the list, rather than a open period.
   l_found_index := find_period_already_exist(p_return_periods,
                    p_period.start_date,p_period.end_date);
    if (l_found_index > 0) then
       p_return_periods.delete(l_found_index);
    ELSE
    l_return_index := l_return_index + 1;
    END IF;

    p_return_periods(l_return_index).start_date := p_period.start_date;
    p_return_periods(l_return_index).end_date := p_period.end_date;
    p_return_periods(l_return_index).exist_flag := p_period.exist_flag;
    p_return_periods(l_return_index).p_set_more_period := p_period.p_set_more_period;

    IF (check_period_archived(p_period.end_date)) THEN
	p_return_periods(l_return_index).exist_flag := hxc_timecard.c_archived_period_indicator;
    ELSE
	p_return_periods(l_return_index).exist_flag := p_period.exist_flag;
    END IF;

    RETURN;
  END IF;


  FOR l_assign_index in p_assignment_periods.first .. p_assignment_periods.last
  LOOP

    IF p_assignment_periods(l_assign_index).start_date <= p_period.end_date
      AND p_assignment_periods(l_assign_index).end_date >= p_period.start_date
    THEN
      l_start_date := greatest(p_assignment_periods(l_assign_index).start_date,
                               p_period.start_date);
      l_end_date   := least(p_assignment_periods(l_assign_index).end_date, p_period.end_date);
      if (find_period_already_exist(p_return_periods,l_start_date,l_end_date) < 0) then
              l_return_index := l_return_index + 1;
	      p_return_periods(l_return_index).start_date
		:= l_start_date;
	      p_return_periods(l_return_index).end_date
		:= l_end_date;
	      p_return_periods(l_return_index).p_set_more_period := p_period.p_set_more_period;
	      p_return_periods(l_return_index).exist_flag := p_period.exist_flag;
      end if;
    END IF;
  END LOOP;

END process_assignments;



PROCEDURE generate_periods(
  p_periods           IN OUT NOCOPY periods
 ,p_start_date        IN     DATE
 ,p_end_date          IN     DATE
 ,p_last_period_end   IN     DATE
 ,p_past_date_limit   IN     DATE
 ,p_future_date_limit IN     DATE
 ,p_exists            IN     VARCHAR2
 ,p_show_existing_timecard IN VARCHAR2 DEFAULT 'Y'
 ,p_set_more_period   IN  VARCHAR2 DEFAULT NULL
)
IS
  l_index     NUMBER;
  l_new_start DATE;
  l_new_end   DATE;
  l_active    BOOLEAN;
BEGIN

  IF p_last_period_end IS NOT NULL
  THEN
    --find out if there is a transition period
    IF p_last_period_end + 1 < p_start_date
    THEN
       l_index := NVL(p_periods.last, 0) + 1;

       --we need to make sure a transition period is within an active
       --assignment
       l_new_start := p_last_period_end + 1;
       l_new_end := p_start_date - 1;
       l_active := check_assignments(l_new_start, l_new_end);
       IF l_new_start <= p_future_date_limit
         AND l_new_end >= p_past_date_limit
         AND l_active
       THEN
         p_periods(l_index).start_date := l_new_start;
         p_periods(l_index).end_date := l_new_end;
         p_periods(l_index).p_set_more_period := p_set_more_period;
       END IF;
    END IF;
  END IF;


  --add this period
  IF p_exists IS NULL
    AND (NOT check_assignments(p_start_date, p_end_date))
  THEN
    RETURN;
  END IF;

  IF (trunc(p_start_date) <= trunc(p_future_date_limit)
         AND trunc(p_end_date) >= trunc(p_past_date_limit))
  THEN
    l_index := NVL(p_periods.last, 0) + 1;
    p_periods(l_index).start_date := p_start_date;
    p_periods(l_index).end_date := p_end_date;
    p_periods(l_index).exist_flag := p_exists;
    p_periods(l_index).p_set_more_period := p_set_more_period;
  END IF;

END generate_periods;



FUNCTION add_period(
  p_periods           IN OUT NOCOPY periods
 ,p_start_date        IN     DATE
 ,p_end_date          IN     DATE
 ,p_position          IN     VARCHAR2 DEFAULT 'AFTER'
 ,p_future_date_limit IN     DATE DEFAULT NULL
 ,p_assignment_end    IN     DATE DEFAULT NULL
 ,p_set_more_period   IN     VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN
IS
 l_index NUMBER;

BEGIN


  IF g_debug THEN
  	hr_utility.trace('add_period start=' || to_char(p_start_date, 'YYYY/MM/DD'));
  	hr_utility.trace('add_period end=' || to_char(p_end_date, 'YYYY/MM/DD'));
  END IF;

  IF p_position = 'AFTER'
  THEN
    IF TRUNC(p_start_date) > TRUNC(p_future_date_limit)
        OR TRUNC(p_start_date) > TRUNC(p_assignment_end)
    THEN
      IF g_debug THEN
      	hr_utility.trace('not added');
      END IF;
      RETURN FALSE;
    END IF;

    l_index := NVL(p_periods.last, 0) + 1;
  ELSE
    l_index := NVL(p_periods.first, 0) - 1;
  END IF;

  p_periods(l_index).start_date := p_start_date;
  p_periods(l_index).end_date := p_end_date;
  p_periods(l_index).p_set_more_period := p_set_more_period;

  IF g_debug THEN
  	hr_utility.trace('added ok');
  END IF;
  RETURN TRUE;
END add_period;


PROCEDURE find_current_period(
  p_rec_period_start_date  IN DATE
 ,p_period_type            IN VARCHAR2
 ,p_duration_in_days       IN NUMBER
 ,p_current_date           IN DATE
 ,p_period_start           OUT NOCOPY DATE
 ,p_period_end             OUT NOCOPY DATE
)
IS
BEGIN
  IF p_period_type IS NULL
  THEN
    get_period_by_duration(
      p_rec_period_start_date => p_rec_period_start_date
     ,p_duration_in_days      => p_duration_in_days
     ,p_current_date          => p_current_date
     ,p_start_date            => p_period_start
     ,p_end_date              => p_period_end
    );
  ELSE
    hxc_period_evaluation.period_start_stop(
      p_current_date          => p_current_date
     ,p_rec_period_start_date => p_rec_period_start_date
     ,l_period_start          => p_period_start
     ,l_period_end            => p_period_end
     ,l_base_period_type      => p_period_type
    );
  END IF;
END find_current_period;


PROCEDURE find_empty_period(
  p_future        IN BOOLEAN
 ,p_periods       IN periods
 ,p_empty_period IN OUT NOCOPY VARCHAR2
 ,p_default_tc_period IN VARCHAR2
)
IS
  l_index NUMBER;
BEGIN


  p_empty_period := NULL;

  IF p_future
  THEN
    l_index := p_periods.first;
  ELSE
    l_index := p_periods.last;
  END IF;

  LOOP
    EXIT WHEN NOT p_periods.exists(l_index);

    IF g_debug THEN
    	hr_utility.trace('start=' || p_periods(l_index).start_date
    	               || ' end=' || p_periods(l_index).end_date
    	               || 'exists=' || NVL(p_periods(l_index).exist_flag, 'N'));
    END IF;

    IF NVL(p_periods(l_index).exist_flag, 'N') <> hxc_timecard.c_existing_period_indicator AND NVL(p_periods(l_index).exist_flag, 'N') <> hxc_timecard.c_archived_period_indicator
    THEN


       IF not p_future and p_default_tc_period = 'EARLIEST' AND
       TRUNC(SYSDATE) >= p_periods(l_index).start_date  THEN

            p_empty_period := TO_CHAR(p_periods(l_index).start_date, g_date_format)
                            || g_separator
                        || TO_CHAR(p_periods(l_index).end_date, g_date_format);
              --RETURN;
       END IF;

       IF not p_future and p_default_tc_period = 'CLOSEST' and
       TRUNC(SYSDATE) >= p_periods(l_index).start_date THEN

       		IF SYSDATE between p_periods(l_index).start_date and p_periods(l_index).end_date
       		THEN
       			null;
       		ELSE

                  p_empty_period := TO_CHAR(p_periods(l_index).start_date, g_date_format)
                                  || g_separator
                                || TO_CHAR(p_periods(l_index).end_date, g_date_format);
                    RETURN;
                END IF;

       END IF;

       IF( (p_future AND TRUNC(SYSDATE) <= p_periods(l_index).end_date) OR (NOT p_future))
       	 AND p_default_tc_period = 'FUTURE'
      THEN
        p_empty_period := TO_CHAR(p_periods(l_index).start_date, g_date_format)
                  || g_separator
                  || TO_CHAR(p_periods(l_index).end_date, g_date_format);
        RETURN;
      END IF;
    END IF;

    IF p_future
    THEN
      l_index := p_periods.next(l_index);
    ELSE
      l_index := p_periods.prior(l_index);
    END IF;

  END LOOP;

END find_empty_period;



FUNCTION get_periods(
  p_resource_id            IN NUMBER
 ,p_resource_type          IN VARCHAR2
 ,p_current_date           IN DATE
 ,p_show_existing_timecard IN VARCHAR2

)
RETURN periods
IS
  l_start_date            DATE;
  l_end_date              DATE;
  l_current_date          DATE;
  l_period_index          NUMBER;
  l_last_period_end       DATE;
  l_new_periods           periods;
  l_periods               periods;
  l_period_count          NUMBER;
  l_assignment_index      NUMBER;
  l_added                 BOOLEAN;
  l_processed_periods     periods;
  l_dummy		  varchar2(15);
  l_proc                  VARCHAR2(50);

  l_set_more_period       VARCHAR2(1);
  l_approval_status       HXC_TIME_BUILDING_BLOCKS.APPROVAL_STATUS%TYPE;

  -- New Fields.
  l_assignment_processed_periods periods;
  l_index           number;

  CURSOR c_timecards(
    p_resource_id       IN NUMBER
   ,p_resource_type     IN VARCHAR2
   ,p_first_start_date  IN DATE
   ,p_last_end_date     IN DATE
  )
  IS
    SELECT START_TIME,
           STOP_TIME,
	   APPROVAL_STATUS
      FROM hxc_time_building_blocks
     WHERE SCOPE = 'TIMECARD'
       AND DATE_TO = hr_general.end_of_time
       AND RESOURCE_ID = p_resource_id
       AND RESOURCE_TYPE = p_resource_type
       AND STOP_TIME >= p_first_start_date
       AND START_TIME <= p_last_end_date
  ORDER BY START_TIME;

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
  	l_proc := 'get_periods';
  	hr_utility.set_location (g_package||l_proc, 10);
  END IF;



  --get current period
  find_current_period(
    p_rec_period_start_date  => g_rec_period_start_date
   ,p_period_type            => g_period_type
   ,p_duration_in_days       => g_duration_in_days
   ,p_current_date           => p_current_date
   ,p_period_start           => l_start_date
   ,p_period_end             => l_end_date
  );

  IF g_debug THEN
  	hr_utility.set_location (g_package||l_proc, 20);
  END IF;


/* Aug 23 always add current period
  l_added := add_period(
    p_periods           => l_periods
   ,p_start_date        => l_start_date
   ,p_end_date          => l_end_date
   ,p_future_date_limit => g_future_date_limit
   ,p_assignment_end    => g_assignment_periods(g_assignment_periods.last).end_date
  );

  IF g_debug THEN
  	hr_utility.set_location (g_package||l_proc, 30);
  END IF;

  -- this case only happens when we are looking for an empty period
  -- in the future. Since we already know the period before the current
  -- on are not empty, if the current one is already out of future boundary
  -- (future date limit, assignment end date) it doesn't make sense to
  -- continue looking at other periods beyond this one.

  IF NOT l_added
  THEN
    RETURN l_periods;
  END IF;
*/

  l_periods(1).start_date := l_start_date;
  l_periods(1).end_date := l_end_date;

  IF g_debug THEN
  	hr_utility.set_location (g_package||l_proc, 40);
  END IF;
  --get past periods

  l_period_count := 0;
  l_current_date := l_start_date - 1;
  l_assignment_index := g_assignment_periods.last;

  IF g_debug THEN
  	hr_utility.trace('l_period_count=' || l_period_count);
  	hr_utility.trace('g_num_past_entries=' || g_num_past_entries);
  END IF;


  WHILE l_period_count <= g_num_past_entries
  LOOP
      IF g_debug THEN
      	hr_utility.set_location (g_package||l_proc, 50);
      END IF;

      find_current_period(
        p_rec_period_start_date  => g_rec_period_start_date
       ,p_period_type            => g_period_type
       ,p_duration_in_days       => g_duration_in_days
       ,p_current_date           => l_current_date
       ,p_period_start           => l_start_date
       ,p_period_end             => l_end_date
      );

      IF g_debug THEN
      	hr_utility.set_location (g_package||l_proc, 60);
      END IF;

      IF l_end_date < g_past_date_limit
      THEN
        EXIT;
      END IF;

      IF g_debug THEN
      	hr_utility.set_location (g_package||l_proc, 61);
      END IF;

      IF TRUNC(l_end_date) >= TRUNC(g_assignment_periods(l_assignment_index).start_date)
      THEN
	      -- only if there is atleast 1 period more than normally we show,
	      -- we will show the More Periods... option.
	IF trunc(l_start_date) >= trunc(g_past_date_limit) THEN
	      IF ((l_period_count = g_num_past_entries) AND (p_show_existing_timecard = 'Y')) THEN
		 l_added := add_period(
			p_periods           => l_periods
			,p_start_date        => l_start_date
			,p_end_date          => l_end_date
			,p_position          => 'BEFORE'
			,p_set_more_period   => hxc_timecard.c_more_period_indicator
			);
		ELSE
		  l_added := add_period(
			  p_periods           => l_periods
			 ,p_start_date        => l_start_date
			 ,p_end_date          => l_end_date
		         ,p_position          => 'BEFORE'
			);

		END IF;
	END IF;
        l_period_count := l_period_count + 1;
        l_current_date := l_start_date - 1;

        IF g_debug THEN
        	hr_utility.set_location (g_package||l_proc, 70);
        END IF;
      ELSE
        -- earlier than current assignment period, look at the assignment
        -- following this one
        l_assignment_index := g_assignment_periods.prior(l_assignment_index);

        IF g_assignment_periods.exists(l_assignment_index)
        THEN
          -- this check is to eliminate duplicate entries when the previous
          -- assignment end date is less than a period away from current
          -- period start_date
          IF g_assignment_periods(l_assignment_index).end_date <= l_end_date
          THEN
            IF g_debug THEN
            	hr_utility.set_location (g_package||l_proc, 80);
            END IF;

            l_current_date := g_assignment_periods(l_assignment_index).end_date;
          ELSE
            IF g_debug THEN
            	hr_utility.set_location (g_package||l_proc, 90);
            END IF;

            l_current_date := l_end_date;
          END IF;
        ELSE
          IF g_debug THEN
          	hr_utility.set_location (g_package||l_proc, 100);
          END IF;

          EXIT;
        END IF;
      END IF;
    END LOOP;



    IF g_debug THEN
    	hr_utility.set_location (g_package||l_proc, 120);
    END IF;

    --get future periods
    l_assignment_index := g_assignment_periods.last;

    l_period_count := 0;
    l_current_date := l_periods(1).end_date + 1;  -- need work
    WHILE l_period_count <= g_num_future_entries
    LOOP
      find_current_period(
        p_rec_period_start_date  => g_rec_period_start_date
       ,p_period_type            => g_period_type
       ,p_duration_in_days       => g_duration_in_days
       ,p_current_date           => l_current_date
       ,p_period_start           => l_start_date
       ,p_period_end             => l_end_date
      );

	IF ((l_period_count = g_num_future_entries) AND (p_show_existing_timecard = 'Y')) then
		 l_added := add_period(
		 	    p_periods           => l_periods
			   ,p_start_date        => l_start_date
			   ,p_end_date          => l_end_date
			   ,p_future_date_limit => g_future_date_limit
			   ,p_assignment_end    => g_assignment_periods(l_assignment_index).end_date
			   ,p_set_more_period    =>hxc_timecard.c_more_period_indicator
			             );
	ELSE
		 l_added := add_period(
		        p_periods           => l_periods
		       ,p_start_date        => l_start_date
		       ,p_end_date          => l_end_date
		       ,p_future_date_limit => g_future_date_limit
		       ,p_assignment_end    => g_assignment_periods(l_assignment_index).end_date
		      );
	END IF;
      IF NOT l_added
      THEN
        EXIT;
      END IF;

      l_period_count := l_period_count + 1;
      l_current_date := l_end_date + 1;

    END LOOP;

  IF l_periods.count = 0
  THEN
    RETURN l_periods;
  END IF;

  l_period_index := l_periods.first;
  l_last_period_end := l_periods(l_period_index).start_date - 1;

  OPEN c_timecards(
    p_resource_id      => p_resource_id
   ,p_resource_type    => p_resource_type
   ,p_first_start_date => l_periods(l_periods.first).start_date
   ,p_last_end_date    => l_periods(l_periods.last).end_date
  );

  LOOP
    FETCH c_timecards INTO l_start_date, l_end_date,l_approval_status;
    EXIT WHEN c_timecards%NOTFOUND;

    WHILE l_periods.exists(l_period_index)
        AND l_periods(l_period_index).end_date < l_end_date
    LOOP

   -- 115.34 change. To differentiate an archived time period from a normal period.


if(check_period_archived(l_periods(l_period_index).end_date)) then

      generate_periods(
        p_periods           => l_new_periods
       ,p_start_date        => l_periods(l_period_index).start_date
       ,p_end_date          => l_periods(l_period_index).end_date
       ,p_last_period_end   => l_last_period_end
       ,p_past_date_limit   => g_past_date_limit
       ,p_future_date_limit => g_future_date_limit
       ,p_exists            => hxc_timecard.c_archived_period_indicator
       ,p_show_existing_timecard => p_show_existing_timecard
       ,p_set_more_period   => l_periods(l_period_index).p_set_more_period
      );

ELSE
      generate_periods(
        p_periods           => l_new_periods
       ,p_start_date        => l_periods(l_period_index).start_date
       ,p_end_date          => l_periods(l_period_index).end_date
       ,p_last_period_end   => l_last_period_end
       ,p_past_date_limit   => g_past_date_limit
       ,p_future_date_limit => g_future_date_limit
       ,p_exists            => NULL
       ,p_set_more_period   => l_periods(l_period_index).p_set_more_period
      );
END IF;


      l_last_period_end := l_periods(l_period_index).end_date;
      l_period_index := l_periods.next(l_period_index);
    END LOOP;

    IF g_debug THEN
    	hr_utility.set_location (g_package||l_proc, 70);
    END IF;
    --  For this period we need not check whether its archived or not, as this is an existing period.
    --  Existing periods are found from hxc_time_building_blocks table, which means the data is
    --  present in the online tables.

    --add timecard row
    IF (l_approval_status NOT IN ('ERROR')) THEN
	    generate_periods(
		      p_periods           => l_new_periods
		     ,p_start_date        => l_start_date
		     ,p_end_date          => l_end_date
		     ,p_last_period_end   => l_last_period_end
		     ,p_past_date_limit   => g_past_date_limit
		     ,p_future_date_limit => g_future_date_limit
		     ,p_exists            => hxc_timecard.c_existing_period_indicator
		     ,p_show_existing_timecard => p_show_existing_timecard
		     ,p_set_more_period  =>  get_more_period_value(l_periods,l_start_date,l_end_date)
		    );
    END IF;

    l_last_period_end := l_end_date;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 80);
    END IF;

    -- ignore overlapping periods
    WHILE l_periods.exists(l_period_index)
         AND l_periods(l_period_index).start_date <= l_end_date
    LOOP
      l_period_index := l_periods.next(l_period_index);
    END LOOP;

    IF g_debug THEN
    	hr_utility.set_location ( g_package||l_proc, 90);
    END IF;

  END LOOP;

  CLOSE c_timecards;


  --add the rest of the periods
  WHILE l_periods.exists(l_period_index)
  LOOP
   -- 115.34 change. To differentiate an archived time period from a normal period.

if(check_period_archived(l_periods(l_period_index).end_date)) then
      generate_periods(
        p_periods           => l_new_periods
       ,p_start_date        => l_periods(l_period_index).start_date
       ,p_end_date          => l_periods(l_period_index).end_date
       ,p_last_period_end   => l_last_period_end
       ,p_past_date_limit   => g_past_date_limit
       ,p_future_date_limit => g_future_date_limit
       ,p_exists            => hxc_timecard.c_archived_period_indicator
       ,p_show_existing_timecard => p_show_existing_timecard
       ,p_set_more_period   => l_periods(l_period_index).p_set_more_period
      );
ELSE
      generate_periods(
        p_periods           => l_new_periods
       ,p_start_date        => l_periods(l_period_index).start_date
       ,p_end_date          => l_periods(l_period_index).end_date
       ,p_last_period_end   => l_last_period_end
       ,p_past_date_limit   => g_past_date_limit
       ,p_future_date_limit => g_future_date_limit
       ,p_exists            => NULL
       ,p_set_more_period   => l_periods(l_period_index).p_set_more_period
      );
END IF;


    l_last_period_end := NULL;
    l_period_index := l_periods.next(l_period_index);

  END LOOP;

  IF g_debug THEN
  	hr_utility.set_location ( g_package||l_proc, 100);
  END IF;

  --RETURN l_new_periods;


  --below is added for mid period hiring
  -- v115.31 changed to use indexed looping.
  -- Fix for bug no. 3401914


  l_period_index := l_new_periods.first;
   while l_period_index is not null
     loop
        process_assignments(
         l_new_periods(l_period_index)
        ,g_assignment_periods
        ,l_assignment_processed_periods -- changed here
	);
      l_period_index := l_new_periods.NEXT(l_period_index);
     end loop;

   --For import Timecard Page, only retain the open periods.
   l_index :=0;
   IF(p_show_existing_timecard = 'N') THEN
     l_period_index := l_assignment_processed_periods.first;
	while l_period_index is not null
	loop
	 if((l_assignment_processed_periods(l_period_index).exist_flag is null) or
	    ((l_assignment_processed_periods(l_period_index).exist_flag <> hxc_timecard.c_existing_period_indicator) AND
          (l_assignment_processed_periods(l_period_index).exist_flag <> hxc_timecard.c_archived_period_indicator))
	    ) then
	  l_processed_periods(l_index) := l_assignment_processed_periods(l_period_index);
	  l_index := l_index+1;
	 end if;
	  l_period_index := l_assignment_processed_periods.NEXT(l_period_index);
	end loop;
	RETURN l_processed_periods;
   END IF;
  RETURN l_assignment_processed_periods;

END get_periods;


PROCEDURE get_first_empty_period(
  p_resource_id            IN NUMBER
 ,p_resource_type          IN VARCHAR2
 ,p_current_date           IN DATE
 ,p_show_existing_timecard IN VARCHAR2
 ,p_periods               OUT NOCOPY VARCHAR2
)
IS
  l_current_date           DATE;
  l_index                  NUMBER;
  l_periods                periods;
  l_previous_period_end    DATE;
  l_previous_period_start  DATE;
  l_default_tc_period      VARCHAR2(20);
  l_pref_table  hxc_preference_evaluation.t_pref_table;

  l_empty_period VARCHAR2(50);

BEGIN

  hxc_preference_evaluation.resource_preferences(
                  p_resource_id   => p_resource_id
          ,       p_pref_code_list=> 'TC_W_TCRD_PERIOD'
          ,       p_pref_table    => l_pref_table
  	  ,	p_resp_id	=> -101
	);
--Get the Default Timecard period option from preference
If l_pref_table is not null then
       l_default_tc_period := l_pref_table(l_pref_table.FIRST).attribute2;
end if;

--User can save the preference with out selecting any value, in this case we
--should retain the existing behavior

If l_default_tc_period is null then
	l_default_tc_period := 'FUTURE';
end if;

--FUTURE - Period on or after system date - Current Behavior
--EARLIEST - Earliest Period prior to system date
--CLOSEST - Closest Period prior to system date

IF l_default_tc_period = 'EARLIEST' OR  l_default_tc_period = 'CLOSEST' THEN

-- look for empty period in the past
  l_current_date := p_current_date;
  WHILE TRUE LOOP

    l_periods :=
    get_periods(
      p_resource_id            => p_resource_id
     ,p_resource_type          => p_resource_type
     ,p_current_date           => l_current_date
     ,p_show_existing_timecard => p_show_existing_timecard
    );

    l_index := l_periods.first;

    IF l_periods.count = 0
      OR (l_previous_period_start IS NOT NULL
         AND l_previous_period_start = l_periods(l_index).start_date)
    THEN
      -- can't find anything in the past, do not RETURN, search in the future
      -- empty period
	      Exit;
    ELSE
      ----look for the empty period in the past
      find_empty_period(
        p_future       => FALSE
       ,p_periods      => l_periods
       ,p_empty_period => p_periods
       ,p_default_tc_period => l_default_tc_period
      );

     -- In the case of CLOSEST, you should return as and when an empty period is
     -- found in the past
     -- But in the case of EARLIEST, we should continue searching till the first
     -- period

      IF p_periods IS NOT NULL AND l_default_tc_period = 'CLOSEST'
      THEN
        -- found an empty period in the past, return result
        	RETURN;
      ELSIF p_periods IS NOT NULL
      THEN
        l_empty_period := p_periods;
        l_current_date := l_periods(l_index).start_date - 1;
        l_previous_period_start := l_periods(l_index).start_date;
      ELSE
        p_periods := l_empty_period;
        l_current_date := l_periods(l_index).start_date - 1;
        l_previous_period_start := l_periods(l_index).start_date;

      END IF;

    END IF;
  END LOOP;

  -- In the case of EARLIEST, we should return if any empty period found in the past
  -- Otherwise we should search in the past

  IF l_default_tc_period = 'EARLIEST' AND p_periods IS NOT NULL THEN
  	RETURN;
  END IF;

END IF;

-- Search in the Feature starts!!

l_default_tc_period := 'FUTURE';

l_current_date := p_current_date;

  WHILE TRUE LOOP

    l_periods :=
    get_periods(
      p_resource_id            => p_resource_id
     ,p_resource_type          => p_resource_type
     ,p_current_date           => l_current_date
     ,p_show_existing_timecard => p_show_existing_timecard
    );

    -- Now we are looking for an empty period. The idea is we look for the
    -- earliest empty period in the future, if we can't find one within the
    -- future date limit and/or assignment end date, we will look in the
    -- past to find the latest empty period. If we can't find one within the
    -- past date limit and/or assignment start date, we will return null

    IF l_periods.count = 0
      OR (l_previous_period_end IS NOT NULL
         AND l_previous_period_end = l_periods(l_periods.last).end_date)
    THEN
      -- can't find anything in the future
      EXIT;

    ELSE
      ----look for the empty period in the future
      find_empty_period(
        p_future       => TRUE
       ,p_periods      => l_periods
       ,p_empty_period => p_periods
       ,p_default_tc_period => l_default_tc_period
      );

      IF p_periods IS NOT NULL
      THEN
        -- found empty period in the future
        RETURN;
      ELSE
        l_index := l_periods.last;

        l_current_date := l_periods(l_index).end_date + 1;
        l_previous_period_end := l_periods(l_index).end_date;

      END IF;
    END IF;
  END LOOP;

-- You should search in the past only for scenario FUTURE,
-- for the remaining two cases, past search is already completed

IF l_default_tc_period = 'FUTURE' THEN
  -- look for empty period in the past
  l_current_date := SYSDATE;
  WHILE TRUE LOOP

    l_periods :=
    get_periods(
      p_resource_id            => p_resource_id
     ,p_resource_type          => p_resource_type
     ,p_current_date           => l_current_date
     ,p_show_existing_timecard => p_show_existing_timecard
    );

    l_index := l_periods.first;


    IF l_periods.count = 0
      OR (l_previous_period_start IS NOT NULL
         AND l_previous_period_start = l_periods(l_index).start_date)
    THEN
      -- can't find anything in the past
      RETURN;
    ELSE
      ----look for the empty period in the past
      find_empty_period(
        p_future       => FALSE
       ,p_periods      => l_periods
       ,p_empty_period => p_periods
       ,p_default_tc_period => l_default_tc_period
      );

      IF p_periods IS NOT NULL
      THEN
        -- found an empty period in the past, return result

        RETURN;
      ELSE
        l_current_date := l_periods(l_index).start_date - 1;
        l_previous_period_start := l_periods(l_index).start_date;
      END IF;

    END IF;
  END LOOP;
END IF;

END get_first_empty_period;

PROCEDURE periods_to_string(
  p_first_periods  IN periods
 ,p_second_periods IN periods
 ,p_periods        OUT NOCOPY VARCHAR2
)
IS
  l_index  NUMBER;
BEGIN

  l_index := p_first_periods.first;

  LOOP
    EXIT WHEN NOT p_first_periods.exists(l_index);

    p_periods := NVL(p_periods, '')
                  || g_separator
                  || NVL(p_first_periods(l_index).exist_flag, '')
                  || TO_CHAR(p_first_periods(l_index).start_date, g_date_format)
                  || g_separator
                  || TO_CHAR(p_first_periods(l_index).end_date, g_date_format)
		  || NVL(p_first_periods(l_index).p_set_more_period,'');

    l_index := p_first_periods.next(l_index);

  END LOOP;

  IF p_second_periods.count = 0
    OR p_second_periods(p_second_periods.last).start_date
       = p_first_periods(p_first_periods.last).start_date
  THEN
    RETURN;
  END IF;

  l_index := p_second_periods.first;
  LOOP
    EXIT WHEN NOT p_second_periods.exists(l_index);

    IF p_second_periods(l_index).start_date
       > p_first_periods(p_first_periods.last).start_date
    THEN
      p_periods := NVL(p_periods, '')
                  || g_separator
                  || NVL(p_second_periods(l_index).exist_flag, '')
                  || TO_CHAR(p_second_periods(l_index).start_date, g_date_format)
                  || g_separator
                  || TO_CHAR(p_second_periods(l_index).end_date, g_date_format)
		  || NVL(p_second_periods(l_index).p_set_more_period,'');

    END IF;

    l_index := p_second_periods.next(l_index);
  END LOOP;

END periods_to_string;

PROCEDURE get_period_list(
  p_resource_id            IN NUMBER
 ,p_resource_type          IN VARCHAR2
 ,p_current_date           IN DATE
 ,p_show_existing_timecard IN VARCHAR2
 ,p_periods                OUT NOCOPY VARCHAR2
)
IS
  l_index        NUMBER;
  l_periods      periods;
  l_temp_periods periods;
  l_current_date DATE;
  l_proc         VARCHAR2(500);
BEGIN
  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
  	l_proc := 'get_period_list';
  	hr_utility.set_location(g_package||l_proc, 10);
  END IF;

  l_current_date := p_current_date;

  WHILE TRUE LOOP
    l_temp_periods :=
    get_periods(
      p_resource_id            => p_resource_id
     ,p_resource_type          => p_resource_type
     ,p_current_date           => l_current_date
     ,p_show_existing_timecard => p_show_existing_timecard
    );

    IF g_debug THEN
    	hr_utility.set_location(g_package||l_proc, 20);
    END IF;

    IF l_temp_periods.count = 0
       OR l_periods.count > 0
    THEN
      IF g_debug THEN
      	hr_utility.set_location(g_package||l_proc, 30);
      END IF;

      --if this list is empty, or this is the second list,
      --combine this list with the first list and return
      periods_to_string(
        p_first_periods  => l_periods
       ,p_second_periods => l_temp_periods
       ,p_periods        => p_periods
      );
      IF g_debug THEN
      	hr_utility.set_location(g_package||l_proc, 40);
      END IF;
      RETURN;
    ELSE
      --this is the first list and it is not empty
      --if the last periods doesn't go beyong current date period, try
      --go forward one more day after current period. This is to avoid
      --the senario:

      IF g_debug THEN
      	hr_utility.set_location(g_package||l_proc, 50);
      END IF;

      IF l_temp_periods(l_temp_periods.last).start_date = p_current_date
      THEN
        IF g_debug THEN
        	hr_utility.set_location(g_package||l_proc, 60);
        END IF;

        l_current_date :=  l_temp_periods(l_temp_periods.last).end_date + 1;
        l_periods := l_temp_periods;
      ELSE
        --this list is ready to return
        periods_to_string(
          p_first_periods  => l_temp_periods
         ,p_second_periods => l_periods
         ,p_periods        => p_periods
        );

        IF g_debug THEN
        	hr_utility.trace('start=' || to_char(l_temp_periods(l_temp_periods.last).start_date, 'YYYY/MM/DD'));

        	hr_utility.set_location(g_package||l_proc, 70);
        END IF;

        RETURN;
      END IF;
    END IF;
  END LOOP;


END get_period_list;


FUNCTION get_assignment_periods(
    p_resource_id IN hxc_time_building_blocks.resource_id%TYPE
)
RETURN periods
IS
  l_assignment_index       NUMBER;
  l_start_date             DATE;
  l_end_date               DATE;
  l_assignment_id          PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
  l_current_assignment     PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
  l_assignment_periods     periods;
  l_assign_period_limit    NUMBER;   -- 5922228


  CURSOR c_assignments(
    p_resource_id       IN NUMBER,
    p_assign_period_limit IN NUMBER    -- 5922228
  )
  IS
    SELECT pas.ASSIGNMENT_ID,
           pas.EFFECTIVE_START_DATE,
           NVL(pas.EFFECTIVE_END_DATE, hr_general.end_of_time)
      FROM PER_ALL_ASSIGNMENTS_F pas,
           per_assignment_status_types typ
     WHERE pas.PERSON_ID = p_resource_id
       AND pas.ASSIGNMENT_TYPE in ('E','C')
       AND pas.PRIMARY_FLAG = 'Y'
       AND pas.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
  --   AND typ.PER_SYSTEM_STATUS IN ( 'ACTIVE_ASSIGN','ACTIVE_CWK')  -- 5922228
       AND DECODE(typ.PER_SYSTEM_STATUS,'ACTIVE_ASSIGN',1,
                                        'ACTIVE_CWK',   1,
    	 	                                        0 ) >= p_assign_period_limit
  --     AND pas.EFFECTIVE_START_DATE <= SYSDATE
  ORDER BY EFFECTIVE_START_DATE;


BEGIN

  -- get the all the primary assignment periods. We don't allow users
  -- to enter timecard for future assignment periods, thus we don't
  -- query up future assignment periods.
  l_assignment_index := 0;
  l_current_assignment := -1;


   -- 5922228 ( Fetching the preference for the given resource id for
   --           future time card periods )

  IF hxc_preference_evaluation.resource_preferences( p_resource_id,
                                                    'TC_W_TCRD_ST_ALW_EDITS',
                                                     10,
  		                                     sysdate
						     ,101
						     ) = 'FIN_ASSGN'
  THEN
      l_assign_period_limit := 0;
  ELSE
      l_assign_period_limit := 1;
  END IF;



  OPEN c_assignments(
    p_resource_id => p_resource_id,
    p_assign_period_limit => l_assign_period_limit    -- 5922228
  );

  LOOP
    FETCH c_assignments INTO l_assignment_id, l_start_date, l_end_date;
    EXIT WHEN c_assignments%NOTFOUND;
/* jxtan fixed Aug23
    IF l_current_assignment <> l_assignment_id
    THEN
      IF l_start_date <= SYSDATE
      THEN
        l_assignment_index := l_assignment_index + 1;
        g_assignment_periods(l_assignment_index).start_date := l_start_date;
        g_assignment_periods(l_assignment_index).end_date := l_end_date;
        l_current_assignment := l_assignment_id;

      ELSE
        EXIT;
      END IF;
    ELSE
      g_assignment_periods(l_assignment_index).end_date := l_end_date;
    END IF;
*/

    --possible fix for LGE
    IF l_current_assignment = l_assignment_id
        AND  TRUNC(l_assignment_periods(l_assignment_index).end_date) + 1 =
         TRUNC(l_start_date)
    THEN
      l_assignment_periods(l_assignment_index).end_date := l_end_date;
    ELSE
      IF l_current_assignment <> l_assignment_id
         AND l_start_date > SYSDATE
      THEN
        -- we don't allow user to enter time for future active assignment
        -- unless it is an assignment change
        EXIT;
      ELSE
        l_assignment_index := l_assignment_index + 1;
        l_assignment_periods(l_assignment_index).start_date := l_start_date;
        l_assignment_periods(l_assignment_index).end_date := l_end_date;
        l_current_assignment := l_assignment_id;
      END IF;
    END IF;


  END LOOP;

  RETURN l_assignment_periods;

END get_assignment_periods;



PROCEDURE init_globals(
  p_resource_id IN hxc_time_building_blocks.resource_id%TYPE
)
IS
  l_assignment_index       NUMBER;
  l_start_date             DATE;
  l_end_date               DATE;
  l_num_past_days          NUMBER;
  l_num_future_days        NUMBER;
  l_assignment_id          PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
  l_current_assignment     PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE;
  l_rec_period_id          VARCHAR2(50);

  l_index       BINARY_INTEGER;
  l_pref_table  hxc_preference_evaluation.t_pref_table;

/*
  CURSOR c_assignments(
    p_resource_id       IN NUMBER
  )
  IS
    SELECT pas.ASSIGNMENT_ID,
           pas.EFFECTIVE_START_DATE,
           NVL(pas.EFFECTIVE_END_DATE, hr_general.end_of_time)
      FROM PER_ALL_ASSIGNMENTS_F pas,
           per_assignment_status_types typ
     WHERE pas.PERSON_ID = p_resource_id
       AND pas.ASSIGNMENT_TYPE = 'E'
       AND pas.PRIMARY_FLAG = 'Y'
       AND pas.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS = 'ACTIVE_ASSIGN'
  --     AND pas.EFFECTIVE_START_DATE <= SYSDATE
  ORDER BY EFFECTIVE_START_DATE;
*/
/*
  CURSOR c_period_info(
    p_resource_id  IN NUMBER
  )
  IS
    SELECT rp.period_type,
           rp.duration_in_days,
           rp.start_date
      FROM hxc_recurring_periods rp,
           per_time_period_types p
     WHERE p.period_type (+) = rp.period_type
       AND hxc_preference_evaluation.resource_preferences(
             p_resource_id,'TC_W_TCRD_PERIOD|1|') = rp.recurring_period_id;
*/

  CURSOR c_period_info(p_recurring_period_id number)
   is
   select hrp.period_type,
          hrp.duration_in_days,
          hrp.start_date
     from hxc_recurring_periods hrp
    where hrp.recurring_period_id = p_recurring_period_id;

BEGIN

  g_debug := hr_utility.debug_enabled;

  g_assignment_periods.delete;

  g_assignment_periods := get_assignment_periods(p_resource_id);
-- Added check to see if there is atleast one Active Assignment
-- ver 115.32
	if(g_assignment_periods.COUNT<1)
	then
	    g_initialized := 'RETURN';
	    RETURN;
	end if;

-- call the preference

hxc_preference_evaluation.resource_preferences(
                p_resource_id   => p_resource_id
        ,       p_pref_code_list=> 'TC_W_TCRD_PERIOD,TC_W_TCRD_ST_ALW_EDITS'
        ,       p_pref_table    => l_pref_table
	,	p_resp_id	=> -101
	);

l_index := l_pref_table.FIRST;

WHILE ( l_index IS NOT NULL )
LOOP

  IF ( l_pref_table(l_index).preference_code = 'TC_W_TCRD_PERIOD' )
  THEN
     l_rec_period_id    := l_pref_table(l_index).attribute1;

  ELSIF ( l_pref_table(l_index).preference_code = 'TC_W_TCRD_ST_ALW_EDITS' )
  THEN
     l_num_future_days    := l_pref_table(l_index).attribute11;
     l_num_past_days	  := l_pref_table(l_index).attribute6;

  END IF;
  l_index := l_pref_table.NEXT(l_index);

END LOOP;



--  l_rec_period_id :=
--    hxc_preference_evaluation.resource_preferences(
--      p_resource_id,
--      'TC_W_TCRD_PERIOD|1|'
--    );

  --get the person's time period information
  OPEN c_period_info(
    p_recurring_period_id => TO_NUMBER(l_rec_period_id)
  );

  FETCH c_period_info INTO g_period_type, g_duration_in_days, g_rec_period_start_date;

  IF c_period_info%NOTFOUND
  THEN
    g_initialized := 'RETURN';
    RETURN;
  END IF;

  CLOSE c_period_info;


  IF g_debug THEN
  	hr_utility.trace('l_period_type=' || g_period_type);
  	hr_utility.trace('l_duration_in_days=' || g_duration_in_days);
  	hr_utility.trace('l_rec_period_start_date=' || g_rec_period_start_date);
  END IF;

--  l_num_past_days :=
--    hxc_preference_evaluation.resource_preferences(
--         p_resource_id,
--        'TC_W_TCRD_ST_ALW_EDITS',
--         6);

--  l_num_future_days :=
--    hxc_preference_evaluation.resource_preferences(
--         p_resource_id,
--         'TC_W_TCRD_ST_ALW_EDITS',
--         11);

  IF g_debug THEN
  	hr_utility.trace('l_num_past_days=' || l_num_past_days);
  	hr_utility.trace('l_num_future_days=' || l_num_future_days);
  END IF;

  IF l_num_past_days IS NOT NULL
  THEN
    g_past_date_limit := SYSDATE - TO_NUMBER(l_num_past_days);
  ELSE
    g_past_date_limit := hr_general.START_OF_TIME;
  END IF;

  IF l_num_future_days IS NOT NULL
  THEN
    g_future_date_limit := SYSDATE + TO_NUMBER(l_num_future_days);
  ELSE
    g_future_date_limit := hr_general.END_OF_TIME;
  END IF;
  g_initialized := 'Y';

  IF g_debug THEN
  	hr_utility.trace(' l_past_date_limit =' || to_char(g_past_date_limit, 'YYYY/MM/DD'));
  	hr_utility.trace(' l_future_date_limit=' ||to_char(g_future_date_limit, 'YYYY/MM/DD') );
  END IF;

END init_globals;


/*=========================================================================
 * this new procedure evaluates period related preferences on the server
 * side. It should be the one to be called by the middle tier from now on.
 * However we keep the old one to be compatible with existing middle tier
 * code.
 *========================================================================*/

PROCEDURE get_time_periods(
  p_resource_id            IN VARCHAR2
 ,p_resource_type          IN VARCHAR2
 ,p_current_date           IN VARCHAR2
 ,p_show_existing_timecard IN VARCHAR2
 ,p_first_empty_period     IN VARCHAR2
 ,p_periods               OUT NOCOPY VARCHAR2
)
IS
  l_assignment_index       NUMBER;
  l_start_date             DATE;
  l_end_date               DATE;
  l_resource_id            NUMBER := TO_NUMBER(p_resource_id);

BEGIN
  g_debug := hr_utility.debug_enabled;

/*
  IF l_resource_id = 10251
  THEN
      --hr_utility.trace_on(NULL, 'test');
  END IF;
*/
  -- mstewart 5/20/2002
  -- temporary fix to resolve pl/sql caching issues.  For now force
  -- initialization of the globals every procedure call - need to
  -- identify the entry points to properly fix this problem.
  g_initialized := 'N';

  IF g_initialized = 'N'
  THEN
    init_globals(
      p_resource_id => l_resource_id
    );
  END IF;

  IF g_initialized = 'RETURN'
  THEN
    RETURN;
  END IF;

  IF p_first_empty_period = 'Y'
  THEN

    IF g_debug THEN
    	hr_utility.trace('start empty');
    END IF;

    get_first_empty_period(
        p_resource_id            => l_resource_id
       ,p_resource_type          => p_resource_type
       ,p_current_date           => SYSDATE
       ,p_show_existing_timecard => 'Y'
       ,p_periods                => p_periods
    );
    IF g_debug THEN
    	hr_utility.trace('returned empty period=' || p_periods);
    END IF;
  ELSE
    IF g_debug THEN
    	hr_utility.trace('start getting list');
    END IF;

    get_period_list(
        p_resource_id            => l_resource_id
       ,p_resource_type          => p_resource_type
       ,p_current_date           => TO_DATE(p_current_date, g_date_format)
       ,p_show_existing_timecard => p_show_existing_timecard
       ,p_periods                => p_periods
    );

    IF g_debug THEN
    	hr_utility.trace('finished getting list');
    END IF;
  END IF;



END get_time_periods;



PROCEDURE get_time_periods(
  p_resource_id            IN VARCHAR2
 ,p_resource_type          IN VARCHAR2
 ,p_rec_period_start_date  IN VARCHAR2
 ,p_period_type            IN VARCHAR2
 ,p_duration_in_days       IN VARCHAR2
 ,p_current_date           IN VARCHAR2
 ,p_num_past_entries       IN VARCHAR2
 ,p_num_future_entries     IN VARCHAR2
 ,p_num_past_days          IN VARCHAR2
 ,p_num_future_days        IN VARCHAR2
 ,p_hire_date              IN VARCHAR2
 ,p_show_existing_timecard IN VARCHAR2
 ,p_first_empty_period     IN VARCHAR2
 ,p_periods                OUT NOCOPY VARCHAR2
)
IS
BEGIN
  get_time_periods(
    p_resource_id            => p_resource_id
   ,p_resource_type          => p_resource_type
   ,p_current_date           => p_current_date
   ,p_show_existing_timecard => p_show_existing_timecard
   ,p_first_empty_period     => p_first_empty_period
   ,p_periods                => p_periods
  );


END get_time_periods;

PROCEDURE get_current_period(
  p_rec_period_start_date  IN VARCHAR2
 ,p_period_type            IN VARCHAR2
 ,p_duration_in_days       IN VARCHAR2
 ,p_current_date           IN VARCHAR2
 ,p_period                OUT NOCOPY VARCHAR2
)
IS
  l_start_date            DATE;
  l_end_date              DATE;
  l_proc                  VARCHAR2(50);
BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
  	l_proc := 'get_current_period';
  	hr_utility.set_location(g_package||l_proc, 10);
  END IF;

  find_current_period(
    p_rec_period_start_date  => fnd_date.canonical_to_date
                                 (p_rec_period_start_date)
   ,p_period_type            => p_period_type
   ,p_duration_in_days       => p_duration_in_days
   ,p_current_date           => TO_DATE(p_current_date, g_date_format)
   ,p_period_start           => l_start_date
   ,p_period_end             => l_end_date
  );

  IF g_debug THEN
  	hr_utility.set_location(g_package||l_proc, 20);
  END IF;

  p_period := TO_CHAR(l_start_date, g_date_format)
           || g_separator
           || TO_CHAR(l_end_date, g_date_format);

  IF g_debug THEN
  	hr_utility.set_location(g_package||l_proc, 30);
  END IF;

END get_current_period;


FUNCTION get_pto_balance
   (p_resource_id          IN VARCHAR2
   ,p_assignment_id        IN VARCHAR2
   ,p_start_time           IN VARCHAR2
   ,p_plan_code            IN VARCHAR2
   )
RETURN VARCHAR2
IS
--
CURSOR csr_get_plan
   (p_assignment_id           NUMBER
   ,p_effective_date          DATE
   ,p_plan_name               VARCHAR2
   )
IS
SELECT pap.accrual_plan_id
  FROM pay_accrual_plans pap
      ,pay_element_types_f pet
      ,pay_element_links_f pel
      ,pay_element_entries_f pee
 WHERE pap.accrual_plan_element_type_id = pet.element_type_id
 AND   pet.element_type_id = pel.element_type_id
 AND   pee.effective_start_date BETWEEN pet.effective_start_date
                                    AND pet.effective_end_date
 AND   pel.element_link_id = pee.element_link_id
 AND   pee.effective_start_date BETWEEN pel.effective_start_date
                                    AND pel.effective_end_date
 AND   pee.assignment_id = p_assignment_id
 AND   p_effective_date BETWEEN pee.effective_start_date
                            AND pee.effective_end_date
 AND   pap.accrual_plan_name = p_plan_name;
/*
 AND   to_date(p_effective_date, 'YYYY/MM/DD HH24:MI:SS') BETWEEN pee.effective_start_date
                                                              AND pee.effective_end_date;
*/
l_pto_balance  NUMBER;
l_plan_id      NUMBER;
l_start_time   DATE;
l_plan_name    VARCHAR2(80);
--
BEGIN
   --
   l_start_time  := FND_DATE.CANONICAL_TO_DATE(p_start_time);
   --
   IF (p_plan_code = 'MONTHLY') THEN
      l_plan_name := 'LGE_TL_MonthlyLeave_AP';
   ELSE
      l_plan_name := 'LGE_TL_AnnualLeave_AP';
   END IF;
   --
   OPEN csr_get_plan(p_assignment_id, l_start_time, l_plan_name);
   --
   FETCH csr_get_plan INTO l_plan_id;
   --
   IF csr_get_plan%NOTFOUND THEN
      --
      CLOSE csr_get_plan;
      --
      l_plan_id := null;
      --
      RETURN '0|PTO';
      --
   ELSE
      --
      CLOSE csr_get_plan;
      --
      -- now call pay_us_pto_accrual.get_net_accrual to get the balance
      --
      l_pto_balance :=
         pay_us_pto_accrual.get_net_accrual
            (p_assignment_id
            ,l_start_time
            ,l_plan_id
            );
      --
      RETURN TO_CHAR(round(l_pto_balance, 2)) || '|PTO';
      --
   END IF;
   --
END get_pto_balance;


-- ----------------------------------------------------------------------------
-- |--------------------< cla_summary_alias_translation>----------------------|
-- this procedure is called in the cla project/payroll layout to alias translate
-- for a particular timecard_id the entire history of the timecard
-- ----------------------------------------------------------------------------
PROCEDURE cla_summary_alias_translation(
   p_timecard_id		IN NUMBER
  ,p_resource_id		IN NUMBER
  ,p_attributes	        IN OUT NOCOPY HXC_ATTRIBUTE_TABLE_TYPE
  ,p_blocks	        IN OUT NOCOPY HXC_BLOCK_TABLE_TYPE
  ,p_messages	        IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
 )IS


-- first we need to query the timecard info
cursor crs_timecard is
select
 TIME_BUILDING_BLOCK_ID
,TYPE
,MEASURE
,UNIT_OF_MEASURE
,START_TIME
,STOP_TIME
,PARENT_BUILDING_BLOCK_ID
,'N' PARENT_IS_NEW
,SCOPE
,OBJECT_VERSION_NUMBER
,APPROVAL_STATUS
,RESOURCE_ID
,RESOURCE_TYPE
,APPROVAL_STYLE_ID
,DATE_FROM
,DATE_TO
,COMMENT_TEXT
,PARENT_BUILDING_BLOCK_OVN
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,APPLICATION_SET_ID
,TRANSLATION_DISPLAY_KEY
FROM hxc_time_building_blocks
where time_building_block_id = p_timecard_id
and   resource_id = p_resource_id
and   scope = 'TIMECARD';
--and   date_to = hr_general.end_of_time;


CURSOR crs_day_info (
      p_resource_id                IN   NUMBER,
      p_parent_building_block_id   IN   NUMBER,
      p_parent_ovn                 IN   NUMBER
    )
IS
SELECT
 TIME_BUILDING_BLOCK_ID
,TYPE
,MEASURE
,UNIT_OF_MEASURE
,START_TIME
,STOP_TIME
,PARENT_BUILDING_BLOCK_ID
,'N' PARENT_IS_NEW
,SCOPE
,OBJECT_VERSION_NUMBER
,APPROVAL_STATUS
,RESOURCE_ID
,RESOURCE_TYPE
,APPROVAL_STYLE_ID
,DATE_FROM
,DATE_TO
,COMMENT_TEXT
,PARENT_BUILDING_BLOCK_OVN
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,APPLICATION_SET_ID
,TRANSLATION_DISPLAY_KEY
FROM hxc_time_building_blocks
WHERE resource_id = p_resource_id
AND parent_building_block_id = p_parent_building_block_id
AND parent_building_block_ovn = p_parent_ovn
AND SCOPE = 'DAY';

CURSOR crs_detail_info (
      p_resource_id                IN   NUMBER,
      p_parent_building_block_id   IN   NUMBER,
      p_parent_ovn                 IN   NUMBER
    )
IS
SELECT
 TIME_BUILDING_BLOCK_ID
,TYPE
,MEASURE
,UNIT_OF_MEASURE
,START_TIME
,STOP_TIME
,PARENT_BUILDING_BLOCK_ID
,'N' PARENT_IS_NEW
,SCOPE
,OBJECT_VERSION_NUMBER
,APPROVAL_STATUS
,RESOURCE_ID
,RESOURCE_TYPE
,APPROVAL_STYLE_ID
,DATE_FROM
,DATE_TO
,COMMENT_TEXT
,PARENT_BUILDING_BLOCK_OVN
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,APPLICATION_SET_ID
,TRANSLATION_DISPLAY_KEY
FROM hxc_time_building_blocks
WHERE resource_id = p_resource_id
AND parent_building_block_id = p_parent_building_block_id
AND parent_building_block_ovn = p_parent_ovn
AND SCOPE = 'DETAIL'
order by OBJECT_VERSION_NUMBER;
/*
cursor crs_detail_attribute
(timecard_id in number,timecard_ovn in number,l_resource_id in number) is
select
 a.time_attribute_id
,au.time_building_block_id
,bbit.bld_blk_info_type
,a.attribute_category
,a.attribute1
,a.attribute2
,a.attribute3
,a.attribute4
,a.attribute5
,a.attribute6
,a.attribute7
,a.attribute8
,a.attribute9
,a.attribute10
,a.attribute11
,a.attribute12
,a.attribute13
,a.attribute14
,a.attribute15
,a.attribute16
,a.attribute17
,a.attribute18
,a.attribute19
,a.attribute20
,a.attribute21
,a.attribute22
,a.attribute23
,a.attribute24
,a.attribute25
,a.attribute26
,a.attribute27
,a.attribute28
,a.attribute29
,a.attribute30
,a.bld_blk_info_type_id
,a.object_version_number
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,au.time_building_block_ovn BUILDING_BLOCK_OVN
from hxc_bld_blk_info_types bbit,
hxc_time_attribute_usages au,
hxc_time_attributes a
where 	a.time_attribute_id         = au.time_attribute_id
and	a.bld_blk_info_type_id	    = bbit.bld_blk_info_type_id
and  (au.time_building_block_id,au.time_building_block_ovn) in
(select detail.time_building_block_id,detail.object_version_number
from hxc_time_building_blocks detail,
     hxc_time_building_blocks day
where day.time_building_block_id = detail.parent_building_block_id
and   day.object_version_number  = detail.parent_building_block_ovn
and   day.scope			 = 'DAY'
and   detail.resource_id         = l_resource_id
and   detail.scope		 = 'DETAIL'
--and   day.date_to 		 = hr_general.end_of_time
--and   detail.date_to 		 = hr_general.end_of_time
and   day.parent_building_block_id  = timecard_id
and   day.parent_building_block_ovn = timecard_ovn
and   day.resource_id      	    = l_resource_id)
UNION
select
 a.time_attribute_id
,au.time_building_block_id
,bbit.bld_blk_info_type
,a.attribute_category
,a.attribute1
,a.attribute2
,a.attribute3
,a.attribute4
,a.attribute5
,a.attribute6
,a.attribute7
,a.attribute8
,a.attribute9
,a.attribute10
,a.attribute11
,a.attribute12
,a.attribute13
,a.attribute14
,a.attribute15
,a.attribute16
,a.attribute17
,a.attribute18
,a.attribute19
,a.attribute20
,a.attribute21
,a.attribute22
,a.attribute23
,a.attribute24
,a.attribute25
,a.attribute26
,a.attribute27
,a.attribute28
,a.attribute29
,a.attribute30
,a.bld_blk_info_type_id
,a.object_version_number
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,au.time_building_block_ovn BUILDING_BLOCK_OVN
from hxc_bld_blk_info_types bbit,
hxc_time_attribute_usages au,
hxc_time_attributes a
where 	a.time_attribute_id         = au.time_attribute_id
and	a.bld_blk_info_type_id	    = bbit.bld_blk_info_type_id
and    (au.time_building_block_id,au.time_building_block_ovn) in
(select day.time_building_block_id,day.object_version_number
from  hxc_time_building_blocks day
where  -- day.date_to 		 = hr_general.end_of_time
      day.scope			 = 'DAY'
and   day.parent_building_block_id  = timecard_id
and   day.parent_building_block_ovn = timecard_ovn
and   day.resource_id		    = l_resource_id)
UNION
select
 a.time_attribute_id
,au.time_building_block_id
,bbit.bld_blk_info_type
,a.attribute_category
,a.attribute1
,a.attribute2
,a.attribute3
,a.attribute4
,a.attribute5
,a.attribute6
,a.attribute7
,a.attribute8
,a.attribute9
,a.attribute10
,a.attribute11
,a.attribute12
,a.attribute13
,a.attribute14
,a.attribute15
,a.attribute16
,a.attribute17
,a.attribute18
,a.attribute19
,a.attribute20
,a.attribute21
,a.attribute22
,a.attribute23
,a.attribute24
,a.attribute25
,a.attribute26
,a.attribute27
,a.attribute28
,a.attribute29
,a.attribute30
,a.bld_blk_info_type_id
,a.object_version_number
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,au.time_building_block_ovn BUILDING_BLOCK_OVN
from hxc_bld_blk_info_types bbit,
hxc_time_attribute_usages au,
hxc_time_attributes a
where 	a.time_attribute_id         = au.time_attribute_id
and	a.bld_blk_info_type_id	    = bbit.bld_blk_info_type_id
and  (au.time_building_block_id,au.time_building_block_ovn) in
(select time_building_block_id,object_version_number
from  hxc_time_building_blocks htbb
where   --htbb.date_to 		 	= hr_general.end_of_time
        htbb.scope			= 'TIMECARD'
and     htbb.time_building_block_id     = timecard_id
and     htbb.object_version_number      = timecard_ovn
and     htbb.resource_id		= l_resource_id)
order by time_building_block_id;
*/

cursor crs_detail_attribute
(detail_id in number,detail_ovn in number,l_resource_id in number) is
select
 a.time_attribute_id
,au.time_building_block_id
,bbit.bld_blk_info_type
,a.attribute_category
,a.attribute1
,a.attribute2
,a.attribute3
,a.attribute4
,a.attribute5
,a.attribute6
,a.attribute7
,a.attribute8
,a.attribute9
,a.attribute10
,a.attribute11
,a.attribute12
,a.attribute13
,a.attribute14
,a.attribute15
,a.attribute16
,a.attribute17
,a.attribute18
,a.attribute19
,a.attribute20
,a.attribute21
,a.attribute22
,a.attribute23
,a.attribute24
,a.attribute25
,a.attribute26
,a.attribute27
,a.attribute28
,a.attribute29
,a.attribute30
,a.bld_blk_info_type_id
,a.object_version_number
,'N' NEW
,'N' CHANGED
,'N' PROCESS
,au.time_building_block_ovn BUILDING_BLOCK_OVN
from hxc_bld_blk_info_types bbit,
hxc_time_attribute_usages au,
hxc_time_attributes a,
hxc_time_building_blocks htbb
where 	a.time_attribute_id         = au.time_attribute_id
and	a.bld_blk_info_type_id	    = bbit.bld_blk_info_type_id
and  au.time_building_block_id = htbb.time_building_block_id
and  au.time_building_block_ovn = htbb.object_version_number
and  htbb.scope			= 'DETAIL'
and  htbb.time_building_block_id     = detail_id
and  htbb.object_version_number      = detail_ovn
and  htbb.resource_id		     = l_resource_id;


l_timecard_block 	HXC_BLOCK_TABLE_TYPE;
l_day_block	 	HXC_BLOCK_TABLE_TYPE;
l_detail_block 		HXC_BLOCK_TABLE_TYPE;
l_detail_attribute      HXC_ATTRIBUTE_TABLE_TYPE;

l_alias_block		HXC_BLOCK_TABLE_TYPE;

l_index		NUMBER := 1;
l_att_index	NUMBER := 1;

BEGIN


l_timecard_block       := HXC_BLOCK_TABLE_TYPE ();
l_day_block	       := HXC_BLOCK_TABLE_TYPE ();
l_detail_block         := HXC_BLOCK_TABLE_TYPE ();
l_detail_attribute     := HXC_ATTRIBUTE_TABLE_TYPE();

l_alias_block  := HXC_BLOCK_TABLE_TYPE ();

p_blocks       := HXC_BLOCK_TABLE_TYPE ();
p_attributes   := HXC_ATTRIBUTE_TABLE_TYPE();

--l_index := l_block.first;
--l_att_index := l_attribute.first;

FOR c_timecard in crs_timecard LOOP

   -- reset all the indexes
   -- and temporary table
   l_timecard_block.delete;
   --l_attribute.delete;
   --l_index := 1;
   --l_att_index := 1;

   l_timecard_block.extend;
   l_index := l_timecard_block.last;
   l_timecard_block(l_index) :=
        hxc_block_type (
        c_timecard.TIME_BUILDING_BLOCK_ID,
   	c_timecard.TYPE,
   	c_timecard.MEASURE,
   	c_timecard.UNIT_OF_MEASURE,
   	fnd_date.date_to_canonical(c_timecard.START_TIME),
   	fnd_date.date_to_canonical(c_timecard.STOP_TIME),
   	c_timecard.PARENT_BUILDING_BLOCK_ID,
   	c_timecard.PARENT_IS_NEW,
   	c_timecard.SCOPE,
   	c_timecard.OBJECT_VERSION_NUMBER,
   	c_timecard.APPROVAL_STATUS,
   	c_timecard.RESOURCE_ID,
   	c_timecard.RESOURCE_TYPE,
   	c_timecard.APPROVAL_STYLE_ID,
   	fnd_date.date_to_canonical(c_timecard.DATE_FROM),
   	fnd_date.date_to_canonical(c_timecard.DATE_TO),
   	c_timecard.COMMENT_TEXT,
   	c_timecard.PARENT_BUILDING_BLOCK_OVN,
   	c_timecard.NEW,
   	c_timecard.CHANGED,
   	c_timecard.PROCESS,
   	c_timecard.APPLICATION_SET_ID,
        c_timecard.TRANSLATION_DISPLAY_KEY
        );

   -- now we have a timecard block to work with
   -- we need to find the day attached
   FOR c_day_info in crs_day_info
                     (c_timecard.resource_id
                     ,c_timecard.TIME_BUILDING_BLOCK_ID
                     ,c_timecard.OBJECT_VERSION_NUMBER)  LOOP

        -- we are on a new day so we are deleting
        -- the table
        l_day_block.delete;

        l_day_block.extend;
	l_index := l_day_block.last;
	l_day_block(l_index) :=
	        hxc_block_type (
	        c_day_info.TIME_BUILDING_BLOCK_ID,
	   	c_day_info.TYPE,
	   	c_day_info.MEASURE,
	   	c_day_info.UNIT_OF_MEASURE,
	   	fnd_date.date_to_canonical(c_day_info.START_TIME),
	   	fnd_date.date_to_canonical(c_day_info.STOP_TIME),
	   	c_day_info.PARENT_BUILDING_BLOCK_ID,
	   	c_day_info.PARENT_IS_NEW,
	   	c_day_info.SCOPE,
	   	c_day_info.OBJECT_VERSION_NUMBER,
	   	c_day_info.APPROVAL_STATUS,
	   	c_day_info.RESOURCE_ID,
	   	c_day_info.RESOURCE_TYPE,
	   	c_day_info.APPROVAL_STYLE_ID,
	   	fnd_date.date_to_canonical(c_day_info.DATE_FROM),
	   	fnd_date.date_to_canonical(c_day_info.DATE_TO),
	   	c_day_info.COMMENT_TEXT,
	   	c_day_info.PARENT_BUILDING_BLOCK_OVN,
	   	c_day_info.NEW,
	   	c_day_info.CHANGED,
	   	c_day_info.PROCESS,
	   	c_day_info.APPLICATION_SET_ID,
                c_day_info.TRANSLATION_DISPLAY_KEY
                           );


        -- now we have a timecard block to work with
        -- we need to find the day attached
        FOR c_detail_info in crs_detail_info(c_timecard.resource_id
                     ,c_day_info.TIME_BUILDING_BLOCK_ID
                     ,c_day_info.OBJECT_VERSION_NUMBER) LOOP


           l_detail_block.delete;

	   l_detail_block.extend;
	   l_index := l_detail_block.last;
	   l_detail_block(l_index) :=
	        hxc_block_type (
	        c_detail_info.TIME_BUILDING_BLOCK_ID,
	   	c_detail_info.TYPE,
	   	c_detail_info.MEASURE,
	   	c_detail_info.UNIT_OF_MEASURE,
	   	fnd_date.date_to_canonical(c_detail_info.START_TIME),
	   	fnd_date.date_to_canonical(c_detail_info.STOP_TIME),
	   	c_detail_info.PARENT_BUILDING_BLOCK_ID,
	   	c_detail_info.PARENT_IS_NEW,
	   	c_detail_info.SCOPE,
	   	c_detail_info.OBJECT_VERSION_NUMBER,
	   	c_detail_info.APPROVAL_STATUS,
	   	c_detail_info.RESOURCE_ID,
	   	c_detail_info.RESOURCE_TYPE,
	   	c_detail_info.APPROVAL_STYLE_ID,
	   	fnd_date.date_to_canonical(c_detail_info.DATE_FROM),
	   	fnd_date.date_to_canonical(c_detail_info.DATE_TO),
	   	c_detail_info.COMMENT_TEXT,
	   	c_detail_info.PARENT_BUILDING_BLOCK_OVN,
	   	c_detail_info.NEW,
	   	c_detail_info.CHANGED,
	   	c_detail_info.PROCESS,
	   	c_detail_info.APPLICATION_SET_ID,
                c_detail_info.TRANSLATION_DISPLAY_KEY);

           -- now we are populating the attribute of this detail
           l_detail_attribute.delete;
           FOR c_detail_attribute in crs_detail_attribute
                     (c_detail_info.TIME_BUILDING_BLOCK_ID
                     ,c_detail_info.OBJECT_VERSION_NUMBER
                     ,c_detail_info.resource_id)  LOOP

		   l_detail_attribute.extend;
		   l_att_index := l_detail_attribute.last;
		   l_detail_attribute(l_att_index) :=
		        hxc_attribute_type (
		     c_detail_attribute.time_attribute_id,
		     c_detail_attribute.time_building_block_id,
		     c_detail_attribute.attribute_category,
		     c_detail_attribute.attribute1,
		     c_detail_attribute.attribute2,
		     c_detail_attribute.attribute3,
		     c_detail_attribute.attribute4,
		     c_detail_attribute.attribute5,
		     c_detail_attribute.attribute6,
		     c_detail_attribute.attribute7,
		     c_detail_attribute.attribute8,
		     c_detail_attribute.attribute9,
		     c_detail_attribute.attribute10,
		     c_detail_attribute.attribute11,
		     c_detail_attribute.attribute12,
		     c_detail_attribute.attribute13,
		     c_detail_attribute.attribute14,
		     c_detail_attribute.attribute15,
		     c_detail_attribute.attribute16,
		     c_detail_attribute.attribute17,
		     c_detail_attribute.attribute18,
		     c_detail_attribute.attribute19,
		     c_detail_attribute.attribute20,
		     c_detail_attribute.attribute21,
		     c_detail_attribute.attribute22,
		     c_detail_attribute.attribute23,
		     c_detail_attribute.attribute24,
		     c_detail_attribute.attribute25,
		     c_detail_attribute.attribute26,
		     c_detail_attribute.attribute27,
		     c_detail_attribute.attribute28,
		     c_detail_attribute.attribute29,
		     c_detail_attribute.attribute30,
		     c_detail_attribute.bld_blk_info_type_id,
		     c_detail_attribute.object_version_number,
		     c_detail_attribute.NEW,
		     c_detail_attribute.CHANGED,
	    	     c_detail_attribute.bld_blk_info_type,
		     c_detail_attribute.PROCESS,
		     c_detail_attribute.BUILDING_BLOCK_OVN);

	   END LOOP;

           -- before the next detail we are first calling the translator

           -- we build the block table to send to the translator
           -- only if we have an attribute
           IF l_detail_attribute.count <> 0 THEN

             l_alias_block.delete;

             l_alias_block := l_timecard_block;

             l_index := l_day_block.first;
             LOOP
	      EXIT WHEN
	       (NOT l_day_block.exists(l_index));

	         l_alias_block.extend;
 	         l_alias_block(l_alias_block.last) := l_day_block(l_index);

  	         l_index := l_day_block.next(l_index);

             END LOOP;

             l_index := l_detail_block.first;
             LOOP
	      EXIT WHEN
	       (NOT l_detail_block.exists(l_index));

	          l_alias_block.extend;
	          l_alias_block(l_alias_block.last) := l_detail_block(l_index);

  	          l_index := l_detail_block.next(l_index);

             END LOOP;


             hxc_alias_translator.do_retrieval_translation
              (p_attributes	=> l_detail_attribute
              ,p_blocks		=> l_alias_block
              ,p_start_time  	=> c_timecard.start_time
              ,p_stop_time   	=> c_timecard.stop_time
              ,p_resource_id 	=> c_timecard.resource_id
              ,p_processing_mode	=> hxc_alias_utility.c_ss_processing
              ,p_add_alias_display_value => true
              ,p_messages	        => p_messages
              );

            END IF;


        -- we need to append the
        -- block and attribute table that we want to return
        IF  p_attributes.count = 0 THEN
            p_attributes := l_detail_attribute;
        ELSE
            l_index := l_detail_attribute.first;
            LOOP
	    EXIT WHEN
	      (NOT l_detail_attribute.exists(l_index));

	        p_attributes.extend;
	        p_attributes(p_attributes.last) := l_detail_attribute(l_index);

	        l_index := l_detail_attribute.next(l_index);

	     END LOOP;
        END IF;

        -- populate the detail info
        IF  p_blocks.count = 0 THEN
          p_blocks := l_detail_block;
        ELSE
	   l_index := l_detail_block.first;
	   LOOP
	    EXIT WHEN
	     (NOT l_detail_block.exists(l_index));

	        p_blocks.extend;
	        p_blocks(p_blocks.last) := l_detail_block(l_index);

	        l_index := l_detail_block.next(l_index);

	     END LOOP;
        END IF;

    END LOOP; -- detail

    -- populate the day info
    IF  p_blocks.count = 0 THEN
        p_blocks := l_day_block;
    ELSE
        l_index := l_day_block.first;
    LOOP
        EXIT WHEN
	  (NOT l_day_block.exists(l_index));

	      p_blocks.extend;
	      p_blocks(p_blocks.last) := l_day_block(l_index);

	      l_index := l_day_block.next(l_index);

	   END LOOP;
    END IF;

  END LOOP; -- day

  -- populate the day info
  IF  p_blocks.count = 0 THEN
     p_blocks := l_timecard_block;
  ELSE
     l_index := l_timecard_block.first;
     LOOP
     EXIT WHEN
      (NOT l_timecard_block.exists(l_index));

	  p_blocks.extend;
	  p_blocks(p_blocks.last) := l_timecard_block(l_index);

	  l_index := l_timecard_block.next(l_index);

     END LOOP;
  END IF;

END LOOP; -- timecard

END cla_summary_alias_translation;

END hxc_timecard_utilities;

/
