--------------------------------------------------------
--  DDL for Package Body PER_POS_BGT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_POS_BGT_PKG" AS
/* $Header: pebgt03t.pkb 115.2 99/07/17 18:47:18 porting ship $ */
--
-- PROCEDURE GET_HOLDERS: Calculates the number of people holding
-- a position and returns the holders name and emp no if only one
-- else returns an appropriate message if number of holders is zero
-- or greater than one to X_HOLDER_NAME.
--
procedure get_holders(X_POSITION_ID NUMBER,
                      X_ORGANIZATION_ID   NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_NO_OF_HOLDERS    IN OUT VARCHAR2,
                      X_HOLDER_NAME      IN OUT VARCHAR2,
                      X_HOLDER_EMP_NO    IN OUT VARCHAR2) is
--
l_real_holder_name	varchar2 (240);
--
begin
  --
  hr_utility.set_message('801','HR_ALL_COUNT_HOLDERS');
  --
  -- Assume > 1 holder, so set string to "Holders"
  --
  X_HOLDER_NAME := hr_utility.get_message;
  --
  -- calculate the number of people holding a position and concatenate number
  -- with "Holders". Get the holder name and holder employee number at the
  -- same time - we have to use group functions for these, so we get the MAX
  -- name and number. If the count = 1, the name and number we get must be
  -- the correct ones; if count <> 1 we're not interested in which name and
  -- number we'll get, as we discard them anyway. This approach removes
  -- the need for a second cursor to get the name and number separately.
  -- RMF 15.11.94.
  --
  SELECT  COUNT(E.PERSON_ID),
	  '** ' || COUNT(E.PERSON_ID) ||' '|| X_HOLDER_NAME,
	  MAX(E.FULL_NAME),
	  MAX(E.EMPLOYEE_NUMBER)
  INTO	  X_NO_OF_HOLDERS,
	  X_HOLDER_NAME,
	  l_real_holder_name,
	  X_HOLDER_EMP_NO
  FROM    PER_ALL_PEOPLE E
  ,       PER_ALL_ASSIGNMENTS A
  WHERE   A.POSITION_ID       = X_POSITION_ID
  AND     A.BUSINESS_GROUP_ID = X_BUSINESS_GROUP_ID
  AND     A.ORGANIZATION_ID   = X_ORGANIZATION_ID
  AND     A.ASSIGNMENT_TYPE   = 'E'
  AND     A.PERSON_ID = E.PERSON_ID;
  --
  if X_NO_OF_HOLDERS = 0 then
    -- return the message no holders
    --
    hr_utility.set_message('801','HR_ALL_NO_HOLDERS');
    X_HOLDER_NAME := hr_utility.get_message;
    X_HOLDER_EMP_NO := NULL;
    --
  elsif X_NO_OF_HOLDERS = 1 then
    -- set X_HOLDER_NAME to the real holder name.
    --
    X_HOLDER_NAME := l_real_holder_name;
  else
    -- more than one holder, so clear the holder emp no. We've already set
    -- the holder name to "** n Holders **".
    --
    X_HOLDER_EMP_NO := NULL;
  end if;
  --
end get_holders;
--
-- PROCEDURE GET_BUDGET_VALUE: Returns the budgeted value for the position.
--
PROCEDURE GET_BUDGET_VALUE(X_BUDGET_VALUE IN OUT NUMBER,
                           X_BUDGET_VALUE_ID IN OUT NUMBER,
                           X_POSITION_ID NUMBER,
                           X_BUDGET_VERSION_ID NUMBER,
                           X_TIME_PERIOD_ID NUMBER) IS
CURSOR C IS
SELECT BV.VALUE, BV.BUDGET_VALUE_ID
FROM   PER_BUDGET_VALUES BV, PER_BUDGET_ELEMENTS BE
WHERE  BE.POSITION_ID       = X_POSITION_ID
AND    BE.BUDGET_VERSION_ID = X_BUDGET_VERSION_ID
AND    BV.BUDGET_ELEMENT_ID = BE.BUDGET_ELEMENT_ID
AND    BV.TIME_PERIOD_ID    = X_TIME_PERIOD_ID;
--
BEGIN
  OPEN C;
  FETCH C INTO X_BUDGET_VALUE, X_BUDGET_VALUE_ID;
  IF C%NOTFOUND THEN
    X_BUDGET_VALUE := NULL;
  END IF;
  CLOSE C;
END GET_BUDGET_VALUE;

--
-- PROCEDURE GET_PERIOD_START: Obtain the count as of the start date for the
--                             selected period.
--
-- Added join to per_assignment_status_types to filter out terminated
-- assignments. RMF 14.11.94.
--
--
--
-- Changed datatype from VARCHAR2 to DATE for X_START_DATE and removed call to TO_DATE()
-- function from Cursor.  PASHUN.  31-10-1997. BUG : 572545.
--
--
-- Added reference to effective dates on per_assignment_budget_values_f and changed name to
-- per_assignment_budget_values_f.
-- SASmith 31-MAR-1998.
--
PROCEDURE GET_PERIOD_START(X_PERIOD_START IN OUT NUMBER,
                           X_POSITION_ID NUMBER,
                           X_BUSINESS_GROUP_ID NUMBER,
                           X_START_DATE DATE,
                           X_UNIT VARCHAR2) IS
CURSOR C IS
SELECT NVL(SUM(ABV.VALUE),0)
FROM   PER_ASSIGNMENT_BUDGET_VALUES_F ABV,
       PER_ASSIGNMENT_STATUS_TYPES  AST,
       PER_ASSIGNMENTS_F A
WHERE  A.POSITION_ID			= X_POSITION_ID
AND    A.BUSINESS_GROUP_ID		= X_BUSINESS_GROUP_ID
AND    X_START_DATE 	BETWEEN A.EFFECTIVE_START_DATE AND
                	A.EFFECTIVE_END_DATE
AND    A.ASSIGNMENT_ID			= ABV.ASSIGNMENT_ID
AND    ABV.BUSINESS_GROUP_ID		= X_BUSINESS_GROUP_ID
AND    X_START_DATE 	BETWEEN ABV.EFFECTIVE_START_DATE AND
                	                ABV.EFFECTIVE_END_DATE
AND    X_UNIT				= ABV.UNIT
AND    A.ASSIGNMENT_STATUS_TYPE_ID	= AST.ASSIGNMENT_STATUS_TYPE_ID
AND    AST.PER_SYSTEM_STATUS		<> 'TERM_ASSIGN'
AND    A.ASSIGNMENT_TYPE		= 'E';
--
BEGIN
  hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_PERIOD_START' ,5  ) ;
  OPEN C;
  FETCH C INTO X_PERIOD_START;
  IF (C%NOTFOUND) THEN
    X_PERIOD_START := 0;
     hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_PERIOD_START' ,10  ) ;
  END IF;
  CLOSE C;

END GET_PERIOD_START;
--
-- PROCEDURE GET_PERIOD_END: Obtain the count as of the end date for the
--                           selected period.
--
-- Added join to per_assignment_status_types to filter out terminated
-- assignments. RMF 14.11.94.
--
--
--
-- Changed datatype from VARCHAR2 to DATE for X_END_DATE and removed call to TO_DATE()
-- function from Cursor.  PASHUN.  31-10-1997. BUG : 572545.
--
--
-- Added reference to effective dates on per_assignment_budget_values and changed name to
-- per_assignment_budget_values_f.
-- SASMITH 31-MAR-1998.
--

PROCEDURE GET_PERIOD_END(X_PERIOD_END IN OUT NUMBER,
                         X_POSITION_ID NUMBER,
                         X_BUSINESS_GROUP_ID NUMBER,
                         X_END_DATE DATE,
                         X_UNIT VARCHAR2) IS
CURSOR C IS
SELECT NVL(SUM(ABV.VALUE),0)
FROM   PER_ASSIGNMENT_BUDGET_VALUES_F ABV,
       PER_ASSIGNMENT_STATUS_TYPES  AST,
       PER_ASSIGNMENTS_F A
WHERE  A.POSITION_ID			= X_POSITION_ID
AND    A.BUSINESS_GROUP_ID		= X_BUSINESS_GROUP_ID
AND    X_END_DATE		BETWEEN A.EFFECTIVE_START_DATE AND
						A.EFFECTIVE_END_DATE
AND    ABV.UNIT				= X_UNIT
AND    A.ASSIGNMENT_ID			= ABV.ASSIGNMENT_ID
AND    X_END_DATE	       BETWEEN ABV.EFFECTIVE_START_DATE AND
					ABV.EFFECTIVE_END_DATE
AND    A.ASSIGNMENT_STATUS_TYPE_ID	= AST.ASSIGNMENT_STATUS_TYPE_ID
AND    AST.PER_SYSTEM_STATUS		<> 'TERM_ASSIGN'
AND    A.ASSIGNMENT_TYPE		= 'E';
--
BEGIN
 hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_PERIOD_END' ,5  ) ;

  OPEN C;
   FETCH C INTO X_PERIOD_END;
  IF (C%NOTFOUND) THEN
    X_PERIOD_END := 0;
    hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_PERIOD_END' ,10) ;
  END IF;
  CLOSE C;
END GET_PERIOD_END;
--
--
-- PROCEDURE GET_STARTERS: Obtain the number of assignments attaining a
--                         position within a period.
--
-- G1448: the cursor has an error in that it joins directly to the
--      per_assignments_f table, with the result that a value is counted
--      once for *each occurrence* of an assignment record. So, if an assgt
--      has 2 date effective updates, that results in three records for the
--      assgt. Hence the starters count is often too high. Recoded using the
--      following rules:
--
--      Starters
--      --------
--      Any assgt record where:
--        its pos id matches the pos id in question                       AND
--        its start date is within the time period we're interested in    AND
--        it's a new assgt, or the previous assgt was to a different pos
--
-- The date clauses below in the cursor ensure it picks up the date effective
-- assgt record ending immediately prior to the first one starting in the
-- period, even if the end date is the day before the start date of the period,
-- as well as all the date effective assgt records starting within the period.
-- This is because we need it to see if the position has changed.
--
--
--
-- Changed datatype from VARCHAR2 to DATE for X_END_DATE and X_START_DATE and removed
-- call to TO_DATE() function from Cursor.  PASHUN.  31-10-1997. BUG : 572545.
--
--
--
-- Added reference to effective dates on per_assignment_budget_values and changed name to
-- per_assignment_budget_values_f. Required due to the date tracking of per_assignment_budget_values.
-- Ensure that the correct assignment budget value is being picked up for the assignment as this may
-- be used further down to determine the number of starters (values).
-- NOTE : As this table is now date tracked there can be many ABV rows to one assignment row.
-- SASMITH 31-MAR-1998.
--
--

PROCEDURE GET_STARTERS(X_STARTERS IN OUT NUMBER,
                       X_POSITION_ID NUMBER,
                       X_BUSINESS_GROUP_ID NUMBER,
                       X_START_DATE DATE,
                       X_END_DATE DATE,
                       X_UNIT VARCHAR2) IS
CURSOR C IS
SELECT   A.ASSIGNMENT_ID, A.POSITION_ID,
         A.EFFECTIVE_START_DATE, A.EFFECTIVE_END_DATE, ABV.VALUE
FROM     PER_ASSIGNMENT_BUDGET_VALUES_F ABV,
         PER_ASSIGNMENTS_F A
WHERE    A.POSITION_ID          =  X_POSITION_ID
AND      A.BUSINESS_GROUP_ID    =  X_BUSINESS_GROUP_ID
AND      A.EFFECTIVE_START_DATE <= X_END_DATE
AND      A.EFFECTIVE_END_DATE   >= X_START_DATE - 1
AND      X_UNIT                 =  ABV.UNIT
AND      A.ASSIGNMENT_ID        =  ABV.ASSIGNMENT_ID

AND    (A.EFFECTIVE_START_DATE BETWEEN  ABV.EFFECTIVE_START_DATE AND ABV.EFFECTIVE_END_DATE)

AND      A.ASSIGNMENT_TYPE      =  'E'
ORDER BY A.ASSIGNMENT_ID, A.EFFECTIVE_START_DATE;
--
l_prev_assgt_id         number  := 0;
l_prev_assgt_end        date;
--
BEGIN
--
 hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_STARTERS' ,5  ) ;
  x_starters := 0;
  --
  FOR c_starters IN C LOOP
    --
    if c_starters.assignment_id <> l_prev_assgt_id then
      --
      -- First rec of an assignment. If its start date is within the period,
      -- increment the starter count. Otherwise, this record starts before the
      -- start of the period, so we only need it for comparisons - don't
      -- increment the counter.
      --
      --
      --
      -- Removed call to TO_DATE() function forh X_START_DATE.
      -- PASHUN.  31-OCT-1997. BUG : 572545.
      --
      --
        hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_STARTERS' ,10) ;
      if c_starters.effective_start_date >= x_start_date then
        x_starters := x_starters + c_starters.value;
        hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_STARTERS' ,15) ;
      end if;
      --
      -- Note assignment_id for comparison with the next rec.
      --
      l_prev_assgt_id  := c_starters.assignment_id;
    else
      --
      -- It's another record for the same assignment, so it must start within
      -- the budget period. Increment the counter if the assgt record does not
      -- follow on immediately from the previous one. As the cursor only picks
      -- up rows with one position_id, a gap in the dates means the position_id
      -- must have just changed.
      --
       hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_STARTERS' ,20) ;
      if c_starters.effective_start_date - 1 <> l_prev_assgt_end then
        x_starters := x_starters + c_starters.value;
         hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_STARTERS' ,25) ;
      end if;
    end if;
    --
    -- Note end date for comparison with the next rec.
    --
    l_prev_assgt_end := c_starters.effective_end_date;
    --
  END LOOP;
   hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_STARTERS' ,30) ;
END GET_STARTERS;
--
-- PROCEDURE GET_LEAVERS: Obtain the number of assignments leaving
--                        a position within a period.
--
-- G1448: the cursor has an error in that it joins directly to the
--      per_assignments_f table, with the result that a value is counted
--      once for *each occurrence* of an assignment record. So, if an assgt
--      has 2 date effective updates, that results in three records for the
--      assgt. Hence the starters count is often too high. Recoded using the
--      following rules:
--
--      Leavers
--      -------
--      Any assgt record where:
--        its pos id matches the pos id in question                     AND
--        its end date is within the time period we're interested in    AND
--        ( its status is not term_assign but the next assgt's status is
--								term_assign
--	    OR
--	    the next assgt's pos id has changed
--	  )
--
-- The date clauses in the cursor ensure that it picks up the date effective
-- assgt record which ends after the end of the period, even if the end date
-- of the previous record coincides wit hthe end of the period, as well as all
-- the date effective assgt records ending within the period.
-- This is because we may need it to see if the position has changed.
--
--
--
-- Changed datatype from VARCHAR2 to DATE for X_START_DATE and X_END_DATE
-- and removed calls to TO_DATE().  PASHUN.  31-OCT-1997. BUG : 572545.
--
--
--
--
-- Added reference to effective dates on per_assignment_budget_values and changed name to
-- per_assignment_budget_values_f. Required due to the date tracking of per_assignment_budget_values.
-- Ensure that the correct assignment budget value is being picked up for the assignment as this may
-- be used further down to determine the number of leavers (values).
-- NOTE : As this table is now date tracked there can be many ABV rows to one assignment row.
-- SASMITH 31-MAR-1998.
--
--
--
--

PROCEDURE GET_LEAVERS(X_LEAVERS IN OUT NUMBER,
                      X_POSITION_ID NUMBER,
                      X_BUSINESS_GROUP_ID NUMBER,
                      X_START_DATE DATE,
                      X_END_DATE DATE,
                      X_UNIT VARCHAR2) IS

CURSOR C IS
SELECT   A.ASSIGNMENT_ID, A.POSITION_ID, AST.PER_SYSTEM_STATUS,
         A.EFFECTIVE_START_DATE, A.EFFECTIVE_END_DATE, ABV.VALUE
FROM     PER_ASSIGNMENT_BUDGET_VALUES_F ABV,
         PER_ASSIGNMENT_STATUS_TYPES  AST,
         PER_ASSIGNMENTS_F	      A
WHERE    A.POSITION_ID               =  X_POSITION_ID
AND      A.BUSINESS_GROUP_ID         =  X_BUSINESS_GROUP_ID
AND      A.ASSIGNMENT_STATUS_TYPE_ID =  AST.ASSIGNMENT_STATUS_TYPE_ID
AND      A.EFFECTIVE_START_DATE      <= X_END_DATE + 1
AND      A.EFFECTIVE_END_DATE        >= X_START_DATE
AND      X_UNIT                      =  ABV.UNIT
AND      A.ASSIGNMENT_ID             =  ABV.ASSIGNMENT_ID

AND    (A.EFFECTIVE_START_DATE BETWEEN  ABV.EFFECTIVE_START_DATE AND ABV.EFFECTIVE_END_DATE)

AND      A.ASSIGNMENT_TYPE           =  'E'
ORDER BY A.ASSIGNMENT_ID, A.EFFECTIVE_START_DATE;
--
--
l_prev_assgt_id         number := 0;
l_prev_assgt_value      number := 0;
l_prev_assgt_status     varchar2(30);
l_prev_assgt_end        date;
--
BEGIN
--
   hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_LEAVERS',5) ;
  x_leavers := 0;
  --
  FOR c_leavers IN C LOOP
    --
    if c_leavers.assignment_id <> l_prev_assgt_id then
      --
      -- First rec of an assignment. Was the previously retrieved record a
      -- leaver (assuming there was a previous record)? It was a leaver if:
      -- its end date is not later than the end date of the period AND
      -- its status is NOT TERM_ASSIGN (because if it is TERM_ASSIGN, we've
      -- already counted it.
      --
      --
      -- BUG. 572545.  Removed call to TO_DATE() function for X_END_DATE.
      -- PASHUN.  31-OCT-1997.
      --
      --
       hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_LEAVERS',10) ;
      if (l_prev_assgt_id     <> 0			and
          l_prev_assgt_end    <= x_end_date	and
	  l_prev_assgt_status <> 'TERM_ASSIGN'
	 ) then
	x_leavers := x_leavers + c_leavers.value;
	 hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_LEAVERS',15) ;
      end if;
      --
      -- As for this assignment, we can't tell whether it's a leaver from
      -- this record alone - we have to get the next record and compare the
      -- two. Store the assgt_id.
      --
      l_prev_assgt_id      := c_leavers.assignment_id;
    else
      --
      -- It's another record for the same assignment. Compare it with the
      -- previous one: increment the counter if the assgt record does not
      -- follow on immediately from the previous one. As the cursor only picks
      -- up rows with one position_id, a gap in the dates means the position_id
      -- must have just changed in the meantime. Also increment the counter
      -- if the assgt status has changed to TERM_ASSIGN.
      --
       hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_LEAVERS',20) ;
      if (c_leavers.effective_start_date - 1 <> l_prev_assgt_end) or
	 (c_leavers.per_system_status = 'TERM_ASSIGN' and
				l_prev_assgt_status <> 'TERM_ASSIGN') then
        x_leavers := x_leavers + c_leavers.value;
         hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_LEAVERS',25) ;
      end if;
    end if;
    --
    -- Note end date and assgt status for comparison with the next rec. Also
    -- save the assgt's budget value, as we may need it outside the cursor loop.
    --
    l_prev_assgt_end     := c_leavers.effective_end_date;
    l_prev_assgt_status  := c_leavers.per_system_status;
    l_prev_assgt_value   := c_leavers.value;
    --
  END LOOP;

  --
  -- Now check the last record retrieved, in the same way we checked
  -- records when the assgt id changed.
  --
  --
  --
  -- BUG. 572545.  Removed call to TO_DATE() function for X_END_DATE.
  -- PASHUN.  31-OCT-1997.
  --
  --
  if (l_prev_assgt_id     <> 0                      and
      l_prev_assgt_end    <= x_end_date    and
      l_prev_assgt_status <> 'TERM_ASSIGN'
     ) then
    x_leavers := x_leavers + l_prev_assgt_value;
     hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_LEAVERS',30) ;
  end if;
   hr_utility.set_location ( 'PER_POS_BGT_PKG.GET_LEAVERS',35) ;
  --
END GET_LEAVERS;
--
--
-- PROCEDURE POPULATE_FIELDS: Calls all the other procedures within
--                            the package allowing for only one
--                            server side trip.
--
--
-- Changed datatype from VARCHAR2 to DATE for X_START_DATE and X_END_DATE.
-- PASHUN.  31-10-1997. BUG : 572545.
--
--

PROCEDURE POPULATE_FIELDS(X_VARIANCE		IN OUT NUMBER,
                          X_LEAVERS		IN OUT NUMBER,
                          X_STARTERS		IN OUT NUMBER,
                          X_PERIOD_END		IN OUT NUMBER,
                          X_PERIOD_START	IN OUT NUMBER,
                          X_BUDGET_VALUE	IN OUT NUMBER,
                          X_BUDGET_VALUE_ID	IN OUT NUMBER,
                          X_POSITION_ID		       NUMBER,
                          X_BUSINESS_GROUP_ID	       NUMBER,
                          X_START_DATE		       DATE,
                          X_END_DATE		       DATE,
                          X_UNIT		       VARCHAR2,
                          X_BUDGET_VERSION_ID	       NUMBER,
                          X_TIME_PERIOD_ID	       NUMBER) IS
--
BEGIN
  GET_LEAVERS(X_LEAVERS,
              X_POSITION_ID,
              X_BUSINESS_GROUP_ID ,
              X_START_DATE ,
              X_END_DATE ,
              X_UNIT );
  GET_STARTERS(X_STARTERS  ,
               X_POSITION_ID,
               X_BUSINESS_GROUP_ID ,
               X_START_DATE ,
               X_END_DATE ,
               X_UNIT );
  GET_PERIOD_START(X_PERIOD_START  ,
                   X_POSITION_ID,
                   X_BUSINESS_GROUP_ID ,
                   X_START_DATE ,
                   X_UNIT );
  GET_PERIOD_END(X_PERIOD_END  ,
                 X_POSITION_ID,
                 X_BUSINESS_GROUP_ID ,
                 X_END_DATE ,
                 X_UNIT );
  IF X_BUDGET_VERSION_ID IS NOT NULL THEN
-- Can only obtain a budget value if a budget has been selected
-- in the control block
--
    GET_BUDGET_VALUE(X_BUDGET_VALUE  ,
                     X_BUDGET_VALUE_ID  ,
                     X_POSITION_ID,
                     X_BUDGET_VERSION_ID ,
                     X_TIME_PERIOD_ID );
    X_VARIANCE := X_PERIOD_END - X_BUDGET_VALUE;
  END IF;
END POPULATE_FIELDS;
--
END PER_POS_BGT_PKG;

/
