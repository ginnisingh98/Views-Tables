--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_WF" AS
/* $Header: OEXVVWFB.pls 120.4 2008/02/15 15:03:50 vbkapoor ship $ */

--  Global constant holding the package name
    G_PKG_NAME            CONSTANT VARCHAR2(30) := 'OE_VALIDATE_WF';

--  Global variables used in the package
    G_all_activity_tbl           OE_VALIDATE_WF.Activities_Tbl_Type;
    G_loop_tbl                   NumberTable;
    G_exit_from_loop             VARCHAR2(3) := 'NO';
/*----------------------------------------------------------------
  Function Display_Name
  A function returning Display name of a process name.

  This program is called by:
  1. OE_VALIDATE_WF.Validate_Order_Flow() API
  2. OE_VALIDATE_WF.Validate_Line_Flow() API
  3. OE_VALIDATE_WF.Out_Transitions() API
  4. OE_VALIDATE_WF.Check_Sync() API
  5. OE_VALIDATE_WF.Line_Flow_Assignment() API
  6. OE_VALIDATE_WF.Wait_And_Loops() API
------------------------------------------------------------------*/
FUNCTION Display_Name
( P_process                           IN OUT NOCOPY VARCHAR2
, P_item_type                         IN VARCHAR2
) RETURN VARCHAR2
IS

-- Local Variable Decleration
  l_process                          VARCHAR2(150);  -- Bug#4600129
  l_item_type                        VARCHAR2(30);   -- #4617652
  l_process_name                     VARCHAR2(110);
  l_display_name                     VARCHAR2(80);

BEGIN
  -- Copying passed into locals
  l_process := P_process;
  l_item_type := P_item_type;

  BEGIN

    oe_debug_pub.add('Entering Display_Name for process : '||l_process,5);

    SELECT DISTINCT wa.name, wa.display_name
    INTO   l_process_name, l_display_name
    FROM   wf_activities_tl wa
    WHERE  wa.item_type = l_item_type
    AND    wa.name = l_process
    AND    wa.language = userenv('LANG')
    AND    wa.version =
           ( SELECT MAX(p1.version)
	     FROM   wf_activities_tl p1
	     WHERE  p1.item_type = wa.item_type
	     AND    p1.name = wa.name
	     AND    p1.language = wa.language
	   );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      oe_debug_pub.add('NO_DATA_FOUND in Display_Name',1);
      l_process_name := NULL;
      l_display_name := NULL;
  END;

  IF l_process_name IS NOT NULL AND l_display_name IS NOT NULL THEN
    l_process := l_process_name||' ( '||l_display_name||' )';
  END IF;

  oe_debug_pub.add('Exiting Display_Name for process : '||l_process,5);
  RETURN l_process;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Display_Name : '||Sqlerrm,5);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Display_Name;

/*----------------------------------------------------------------
  Function In_Loop
  A function returning Boolean.

  This program is called by:
  1. OE_VALIDATE_WF.Wait_And_Loops() API
------------------------------------------------------------------*/
FUNCTION In_Loop
( activity1                           IN NUMBER
, activity2                           IN NUMBER
) RETURN BOOLEAN
IS

-- Cursor Decleration
CURSOR c_process_activity(c_activity_id NUMBER) IS
SELECT to_process_activity
FROM   wf_activity_transitions
WHERE  from_process_activity = c_activity_id;

-- Local Variable Decleration
  l_return_status                          BOOLEAN := FALSE;
  l_act_in_table                           BOOLEAN;
  l_activity_id1                           NUMBER;
  l_activity_id2                           NUMBER;

BEGIN

  oe_debug_pub.add('Entering Function OE_VALIDATE_WF.In_Loop '||to_char(activity1)||' '||to_char(activity2), 1);

  -- Copying passed into locals
  l_activity_id1 := activity1;
  l_activity_id2 := activity2;

  IF l_activity_id1 = l_activity_id2 THEN
    G_loop_tbl.DELETE;
  END IF;

  FOR processing_act in c_process_activity(l_activity_id2) LOOP
    oe_debug_pub.add('processing_act.to_process_activity, activity1 '||to_char(processing_act.to_process_activity) ||' '||to_char(activity1), 5);

    IF processing_act.to_process_activity = l_activity_id1 THEN
      l_return_status := TRUE;
      EXIT;
    ELSE
      IF G_loop_tbl.COUNT > 0 THEN
        l_act_in_table := FALSE;
        FOR i in G_loop_tbl.FIRST .. G_loop_tbl.LAST LOOP
          IF G_loop_tbl(i) = processing_act.to_process_activity THEN
            l_act_in_table := TRUE;
            EXIT;
          END IF;
        END LOOP;
      ELSE
        l_act_in_table := FALSE;
      END IF;

      IF NOT l_act_in_table THEN
        -- processing_act.to_process_activity is encountered
	-- for the first time
        G_loop_tbl(G_loop_tbl.count + 1) := processing_act.to_process_activity;
        l_return_status :=
          In_Loop
          ( activity1  => l_activity_id1
          , activity2  => processing_act.to_process_activity
          );
      END IF;
    END IF; -- processing_act.to_process_activity
  END LOOP; -- processing_act

  IF l_return_status THEN
    oe_debug_pub.add('Exiting Function OE_VALIDATE_WF.In_Loop TRUE', 1);
  ELSE
    oe_debug_pub.add('Exiting Function OE_VALIDATE_WF.In_Loop FALSE', 1);
  END IF;

  RETURN l_return_status;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in In_Loop : '||Sqlerrm,5);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END In_Loop;

/*----------------------------------------------------------------
  Function Has_Activity
  Determines whether a workflow process contains a particular
  activity (or subprocess) at any level. A function returning
  Boolean.

  This program is called by:
  1. OE_VALIDATE_WF.Validate_Order_Flow() API
  2. OE_VALIDATE_WF.Validate_Line_Flow() API
------------------------------------------------------------------*/
FUNCTION Has_Activity
(  P_process                          IN VARCHAR2
,  P_process_item_type                IN VARCHAR2
,  P_activity                         IN VARCHAR2
,  P_activity_item_type               IN VARCHAR2
)  RETURN BOOLEAN
IS
-- Cursor Decleration
CURSOR c_direct( l_process_item_type VARCHAR2
               , l_process VARCHAR2
	       , l_activity_item_type VARCHAR2
	       , l_activity VARCHAR2) IS
SELECT p.instance_id
FROM   wf_process_activities p
WHERE  p.process_item_type = l_process_item_type
AND    p.process_name = l_process
AND    p.activity_item_type = l_activity_item_type
AND    p.activity_name = l_activity
AND    p.process_version =
           ( SELECT MAX(p1.process_version)
	     FROM   wf_process_activities p1
	     WHERE  p1.process_item_type = p.process_item_type
	     AND    p1.process_name = p.process_name
	   );

CURSOR c_recursion( l_process_item_type VARCHAR2
                   , l_process VARCHAR2) IS
SELECT p.activity_name
     , p.activity_item_type
FROM   wf_process_activities p
     , wf_activities wa
WHERE  p.process_item_type = l_process_item_type
AND    p.process_name = l_process
AND    p.activity_item_type = wa.item_type
AND    p.activity_name = wa.name
AND    wa.type = 'PROCESS'
AND    p.process_version =
           ( SELECT MAX(p1.process_version)
	     FROM   wf_process_activities p1
	     WHERE  p1.process_item_type = p.process_item_type
	     AND    p1.process_name = p.process_name
	   )
AND    wa.version = ( SELECT MAX(wa1.version)
                      FROM   wf_activities wa1
		      WHERE  wa1.item_type = wa.item_type
		      AND    wa1.name = wa.name
		     );

-- Local Variable Decleration
  l_recursion_rec                 c_recursion%ROWTYPE;
  l_process                       VARCHAR2(30);
  l_process_item_type             VARCHAR2(8);
  l_activity                      VARCHAR2(200);
  l_activity_item_type            VARCHAR2(8);
  l_instance_id                   NUMBER;
  l_return_status                 BOOLEAN;
  l_start_time                    NUMBER;
  l_end_time                      NUMBER;

BEGIN
  oe_debug_pub.add('Entering Function OE_VALIDATE_WF.Has_Activity', 1);
  -- l_start_time := dbms_utility.get_time;

  -- Copying passed into locals
  l_process              := P_process;
  l_process_item_type    := P_process_item_type;
  l_activity             := P_activity;
  l_activity_item_type   := P_activity_item_type;

  oe_debug_pub.add('In H.A. Process '||l_process, 5);
  oe_debug_pub.add('In H.A. Activity '||l_activity, 5);

  OPEN c_direct( l_process_item_type, l_process
               , l_activity_item_type, l_activity) ;
  FETCH c_direct INTO l_instance_id;

  IF c_direct%FOUND THEN
    CLOSE c_direct;
    oe_debug_pub.add('Return Status TRUE', 1);
    oe_debug_pub.add('Exiting Function OE_VALIDATE_WF.Has_Activity', 1);
    --    l_end_time := dbms_utility.get_time;
    --    oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);
    RETURN TRUE;
  ELSE
    CLOSE c_direct;
  END IF;

  l_return_status := FALSE;

  FOR l_recursion_rec in c_recursion( l_process_item_type
                                    , l_process) LOOP
    IF HAS_ACTIVITY
       ( P_process            => l_recursion_rec.activity_name
       , P_process_item_type  => l_recursion_rec.activity_item_type
       , P_activity           => l_activity  -- act
       , P_activity_item_type => l_activity_item_type -- acttype
       ) THEN

       l_return_status := TRUE;
       EXIT;
    END IF;
  END LOOP;

  oe_debug_pub.add('Exiting Function OE_VALIDATE_WF.Has_Activity', 1);
  --  l_end_time := dbms_utility.get_time;
  --  oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);
  RETURN l_return_status;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Has_Activity : '||Sqlerrm,5);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Has_Activity;

/*----------------------------------------------------------------
  Procedure Get_Activities
  Determines all the activities or a particular activity in a
  workflow process (and subprocess) at any level.

  This program is called by:
  1. OE_VALIDATE_WF.Check_Sync() API
  2. OE_VALIDATE_WF.Out_Transitions() API
  3. OE_VALIDATE_WF.Validate_Line_Flow() API
  4. OE_VALIDATE_WF.Validate_Order_Flow() API
------------------------------------------------------------------*/
PROCEDURE Get_Activities
(  P_process                          IN VARCHAR2
,  P_process_item_type                IN VARCHAR2
,  P_instance_label                   IN VARCHAR2 DEFAULT NULL
,  P_activity_item_type               IN VARCHAR2 DEFAULT NULL
)
IS
-- Cursor Decleration
CURSOR c_direct_act1( l_process_item_type VARCHAR2
               , l_process VARCHAR2
	       , l_activity_item_type VARCHAR2
	       , l_instance_label VARCHAR2
	       , l_process_act_version NUMBER) IS
SELECT  p.activity_name
      , p.process_name
      , p.activity_item_type
      , p.instance_id
      , w.type
      , w.function
      , p.instance_label
      , p.start_end
FROM   wf_process_activities p , wf_activities w
WHERE  p.process_item_type = l_process_item_type
AND    p.process_name = l_process
AND    p.activity_item_type = w.item_type
AND    p.activity_name = w.name
AND    p.activity_item_type = l_activity_item_type
AND    p.activity_name = l_instance_label
AND    p.process_version = l_process_act_version
AND    SYSDATE >= w.begin_date
AND    SYSDATE <= nvl(w.end_date, SYSDATE);

CURSOR c_direct_act2( l_process_item_type VARCHAR2
               , l_process VARCHAR2
	       , l_process_act_version NUMBER) IS
SELECT  p.activity_name
      , p.process_name
      , p.activity_item_type
      , p.instance_id
      , w.type
      , w.function
      , p.instance_label
      , p.start_end
FROM   wf_process_activities p , wf_activities w
WHERE  p.process_item_type = l_process_item_type
AND    p.process_name = l_process
AND    p.activity_item_type = w.item_type
AND    p.activity_name = w.name
AND    p.process_version = l_process_act_version
AND    SYSDATE >= w.begin_date
AND    SYSDATE <= nvl(w.end_date, SYSDATE);

CURSOR c_recursion_act( l_process_item_type VARCHAR2
                   , l_process VARCHAR2
		   , l_process_act_version NUMBER) IS
SELECT p.activity_name
     , p.activity_item_type
FROM   wf_process_activities p
     , wf_activities wa
WHERE  p.process_item_type = l_process_item_type
AND    p.process_name = l_process
AND    p.activity_item_type = wa.item_type
AND    p.activity_name = wa.name
AND    wa.type = 'PROCESS'
AND    p.process_version = l_process_act_version
AND    SYSDATE >= wa.begin_date
AND    SYSDATE <= nvl(wa.end_date, SYSDATE);

  -- Local Variable Decleration
  l_recursion_rec                 c_recursion_act%ROWTYPE;
  l_process                       VARCHAR2(30);
  l_process_item_type             VARCHAR2(8);
  l_instance_label                VARCHAR2(200);
  l_activity_item_type            VARCHAR2(8);
  l_instance_id                   NUMBER;
  l_return_status                 BOOLEAN;
  l_start_time                    NUMBER;
  l_end_time                      NUMBER;
  l_process_act_version           NUMBER;

BEGIN

  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Get_Activities', 5);
  --  l_start_time := dbms_utility.get_time;

  -- Copying passed into locals
  l_process              := P_process;
  l_process_item_type    := P_process_item_type;
  l_instance_label       := P_instance_label;
  l_activity_item_type   := P_activity_item_type;

  oe_debug_pub.add('In G.A. process '||l_process, 5);
  oe_debug_pub.add('In G.A. Instance_Label '||l_instance_label, 5);

  SELECT MAX(process_version)
  INTO   l_process_act_version
  FROM   wf_process_activities p1
  WHERE  process_item_type = l_process_item_type
  AND    process_name = l_process;

  IF (l_instance_label IS NOT NULL) AND (l_activity_item_type IS NOT NULL) THEN

    OPEN c_direct_act1( l_process_item_type, l_process
                      , l_activity_item_type, l_instance_label, l_process_act_version) ;
    FETCH c_direct_act1
    INTO G_all_activity_tbl(G_all_activity_tbl.COUNT + 1);
      IF c_direct_act1%FOUND THEN
        G_exit_from_loop := 'YES';
	-- Setting the variable to not to execute the recursion loop further
      END IF;
    CLOSE c_direct_act1;

  ELSIF (l_instance_label IS NULL) AND (l_activity_item_type IS NULL) THEN

    OPEN c_direct_act2( l_process_item_type, l_process, l_process_act_version);
    LOOP
    FETCH c_direct_act2
    INTO G_all_activity_tbl(G_all_activity_tbl.COUNT + 1);
    EXIT WHEN c_direct_act2%NOTFOUND;
    END LOOP;
    CLOSE c_direct_act2;

  END IF;

  IF G_exit_from_loop <> 'YES' THEN
    FOR l_recursion_rec in c_recursion_act( l_process_item_type, l_process, l_process_act_version) LOOP
      Get_Activities
      ( P_process            => l_recursion_rec.activity_name
      , P_process_item_type  => l_recursion_rec.activity_item_type
      , P_instance_label     => l_instance_label  -- act
      , P_activity_item_type => l_activity_item_type -- acttype
      );

      IF G_exit_from_loop = 'YES' THEN
        oe_debug_pub.add('In G.A. Exiting from sub-recursion',5);
        EXIT;
      END IF;

    END LOOP;
  ELSE
    oe_debug_pub.add('In G.A. Calling NO recursion',5);
  END IF;
    oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Get_Activities', 5);
    -- l_end_time := dbms_utility.get_time;
    --  oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Get_Activities : '||Sqlerrm,5);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Activities;

/*----------------------------------------------------------------
  Procedure Wait_And_Loops

  This program is called by:
  1. OE_VALIDATE_WF.Validate_Order_Flow() API
  2. OE_VALIDATE_WF.Validate_Line_Flow() API
------------------------------------------------------------------*/
PROCEDURE Wait_And_Loops
(  P_process                          IN VARCHAR2
,  P_process_item_type	              IN VARCHAR2
,  P_activity_id                      IN NUMBER
,  P_activity_label                   IN VARCHAR2
,  P_api                              IN VARCHAR2
,  X_return_status                    OUT NOCOPY VARCHAR2
)
IS

-- Local Variable Decleration
  l_api                       VARCHAR2(100);
  l_process                   VARCHAR2(30);
  l_activity_id               NUMBER;
  l_activity_label            VARCHAR2(30);
  l_process_item_type         VARCHAR2(8);
  l_text_value                VARCHAR2(100);
  l_number_value              NUMBER := 0;
  l_text_value_relative       VARCHAR2(100);
  l_start_time                NUMBER;
  l_end_time                  NUMBER;
  l_wait_mode_name            VARCHAR2(30);
  l_mode_name                 VARCHAR2(30);
  l_mode_text_value           VARCHAR2(100);

BEGIN
  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Wait_And_Loops', 1);
  --  l_start_time := dbms_utility.get_time;

  X_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Copying passed into locals
  l_api               := p_api;
  l_process           := P_process;
  l_activity_id       := P_activity_id;
  l_activity_label    := P_activity_label;
  l_process_item_type := P_process_item_type;

  IF l_api = 'WF_STANDARD.WAIT' THEN

    -- Getting the attribute Wait Mode of activity p_activity_id
    -- and the attributes of Wait Mode
    BEGIN
      SELECT text_value, name
      INTO   l_text_value, l_wait_mode_name
      FROM   wf_activity_attr_values
      WHERE  process_activity_id = l_activity_id
      AND    name = 'WAIT_MODE';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_text_value := NULL;
       l_wait_mode_name := NULL;
       oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for WAIT_MODE', 1);
   END;

   IF l_text_value = 'ABSOLUTE' THEN
     BEGIN
       SELECT text_value, name
       INTO   l_mode_text_value, l_mode_name
       FROM   wf_activity_attr_values
       WHERE  process_activity_id = l_activity_id
       AND    value_type = 'CONSTANT'
       AND    name                = 'WAIT_ABSOLUTE_DATE';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_mode_text_value := NULL;
	 oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for ABSOLUTE DATE', 1);
     END;

   ELSIF l_text_value = 'DAY_OF_MONTH' THEN
     BEGIN
       SELECT text_value, name
       INTO   l_mode_text_value, l_mode_name
       FROM   wf_activity_attr_values
       WHERE  process_activity_id = l_activity_id
       AND    value_type = 'CONSTANT'
       AND    name                = 'WAIT_DAY_OF_MONTH';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_mode_text_value := NULL;
	 oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for DAY OF MONTH', 1);
     END;

   ELSIF l_text_value = 'DAY_OF_WEEK' THEN
     BEGIN
       SELECT text_value, name
       INTO   l_mode_text_value, l_mode_name
       FROM   wf_activity_attr_values
       WHERE  process_activity_id = l_activity_id
       AND    value_type = 'CONSTANT'
      AND    name                = 'WAIT_DAY_OF_WEEK';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_mode_text_value := NULL;
	 oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for DAY OF WEEK', 1);
     END;

   ELSIF l_text_value = 'RELATIVE' THEN
     BEGIN
       SELECT text_value, name
       INTO   l_mode_text_value, l_mode_name
       FROM   wf_activity_attr_values
       WHERE  process_activity_id = l_activity_id
       AND    value_type = 'CONSTANT'
       AND    name                = 'WAIT_RELATIVE_TIME';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_mode_text_value := NULL;
	 oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for RELATIVE TIME', 1);
     END;

   ELSIF l_text_value = 'TIME' THEN
     BEGIN
       SELECT text_value, name
       INTO   l_mode_text_value, l_mode_name
       FROM   wf_activity_attr_values
       WHERE  process_activity_id = l_activity_id
       AND    value_type = 'CONSTANT'
       AND    name                = 'WAIT_TIME';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_mode_text_value := NULL;
	 oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for WAIT TIME', 1);
     END;
   END IF;

   IF l_wait_mode_name = 'WAIT_MODE' AND l_text_value = 'ABSOLUTE' THEN
     -- Warning the user to check the value for absolute date
     FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_WAIT_ABS');
     FND_MESSAGE.SET_TOKEN('ACTIVITY',l_activity_label);
     FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_process,l_process_item_type));
     OE_MSG_PUB.Add;
     oe_debug_pub.add('LOG 1 : Added OE_WFVAL_WAIT_ABS',5);
     oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Wait_And_Loops', 1);
     --   l_end_time := dbms_utility.get_time;
     --  oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);
     RETURN;

   ELSIF (l_text_value = 'ABSOLUTE'  AND l_mode_text_value > SYSDATE)  OR
         (l_text_value = 'DAY_OF_MONTH' AND l_mode_text_value IS NOT NULL) OR
         (l_text_value = 'DAY_OF_WEEK' AND l_mode_text_value IS NOT NULL) OR
          l_text_value NOT IN ('ABSOLUTE', 'DAY_OF_MONTH', 'DAY_OF_WEEK', 'RELATIVE')  THEN -- not applicable

     -- Presently it is Not Applicable
     oe_debug_pub.add('Presently not applicable');
     oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Wait_And_Loops', 1);
     -- l_end_time := dbms_utility.get_time;
     -- oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);
     RETURN;
   END IF;
 END IF; -- IF l_api

 -- Here, it is assumed that the assigned api is [DEFER] or
 -- [WAIT WITH RELATIVE TIME].

 oe_debug_pub.add('In W.A.L. : l_text_value '||l_text_value,5);
 oe_debug_pub.add('In W.A.L. : l_wait_mode_name '||l_wait_mode_name,5);

 IF IN_LOOP
    ( activity1 => l_activity_id
    , activity2 => l_activity_id
    ) THEN

   IF l_api = 'WF_STANDARD.WAIT' THEN
     BEGIN
       SELECT text_value
       INTO   l_text_value_relative
       FROM   wf_activity_attr_values
       WHERE  process_activity_id = l_activity_id
       AND    name = 'WAIT_MODE';
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_text_value_relative := NULL;
	 oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for WAIT_MODE with activity_id '||l_activity_id, 1);
     END;


     IF l_text_value_relative = 'RELATIVE' THEN
       BEGIN
         SELECT number_value
	 INTO   l_number_value
         FROM   wf_activity_attr_values
         WHERE  process_activity_id = l_activity_id
         AND    name = 'WAIT_RELATIVE_TIME';
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_number_value := NULL;
	   oe_debug_pub.add('NO_DATA_FOUND in Wait_And_Loops for RELATIVE TIME with activity_id '||l_activity_id, 1);
       END;
     END IF; -- l_text_value_relative
   END IF; -- l_api

   oe_debug_pub.add('In W.A.L. : l_api '||l_api,5);
   oe_debug_pub.add('In W.A.L. : l_test_value_relative '||l_text_value_relative,5);
   oe_debug_pub.add('In W.A.L. : l_number_value '||l_number_value,5);
   oe_debug_pub.add('In W.A.L. : l_text_value '||l_text_value,5);
   oe_debug_pub.add('In W.A.L. : l_wait_mode_name '||l_wait_mode_name,5);
   -- l_api = 'WF_STANDARD.WAIT' AND Relative Time is > 0

   IF  (l_api = 'WF_STANDARD.WAIT')
     AND (l_text_value_relative = 'RELATIVE')
     AND (l_number_value > 0) THEN

     -- Warning user that wait time should be >= average
     -- WorkFlow BackGround Engine duration
     FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_LOOP_WNG');
     FND_MESSAGE.SET_TOKEN('ACTIVITY',l_activity_label);
     FND_MESSAGE.SET_TOKEN('PROCESS',Display_Name(l_process,l_process_item_type));
     OE_MSG_PUB.Add;
     oe_debug_pub.add('LOG 2 : Added OE_WFVAL_LOOP_WNG' ,1);

   ELSE

     -- The same code will get called even if the process is in
     -- loop with DEFER type having no sigificance for relative
     -- time.
     FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_LOOP_ERR');
     FND_MESSAGE.SET_TOKEN('ACTIVITY',l_activity_label);
     FND_MESSAGE.SET_TOKEN('PROCESS',Display_Name(l_process,l_process_item_type));
     OE_MSG_PUB.Add;
     oe_debug_pub.add('LOG 3 : Added OE_WFVAL_LOOP_ERR' ,1);
     -- Error for WAIT with Relative Time = 0 or DEFER
     X_return_status := FND_API.G_RET_STS_ERROR;

   END IF; -- l_number_value

 oe_debug_pub.add('In W.A.L. : Not in Loop ',5);
 END IF; -- in_loop

 oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Wait_And_Loops', 1);
 -- l_end_time := dbms_utility.get_time;
 -- oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Wait_And_Loops : '||Sqlerrm,5);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Wait_And_Loops;

/*----------------------------------------------------------------
  Procedure Line_Flow_Assignment
  Checks if a particular seeded workflow is incompatible with the
  OM item type to which it is assigned. If so, returns error and
  puts a message on the error stack. Determines  if a customized
  flow might be incompatible with the OM item type to which it is
  assigned. If yes, returns a warning message and puts it on the
  message stack.

  This program is called by:
  1. OE_VALIDATE_WF.Validate() API
  2. Transaction Types form (OEXDTTYP.fmb, OEXTRTYP.pld)
------------------------------------------------------------------*/
PROCEDURE Line_Flow_Assignment
(  P_name	                      IN VARCHAR2
,  P_item_type	                      IN VARCHAR2
,  X_return_status	              OUT NOCOPY VARCHAR2
,  X_msg_count		              OUT NOCOPY NUMBER
)
IS
-- Local Variable Decleration
 l_return_status               VARCHAR2(1);
 l_name                        VARCHAR2(30);
 l_item_type                   VARCHAR2(30);
 l_msg_count                   NUMBER;
 l_start_time                  NUMBER;
 l_end_time                    NUMBER;

BEGIN
  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Line_Flow_Assignment', 1);
  --l_start_time := dbms_utility.get_time;

  -- Copying passed into locals
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_msg_count     := 0;
  l_name          := P_name;
  l_item_type     := P_item_type;

  oe_debug_pub.add(' In L.F.A. : l_name: '||l_name,5);
  oe_debug_pub.add(' In L.F.A. : l_item_type: '||l_item_type,5);

  IF  ( l_name = 'R_ATO_ITEM_LINE' )
    AND ( l_item_type IS NULL OR l_item_type <> 'ATO_ITEM') THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    l_msg_count := l_msg_count + 1;

  ELSIF ( l_name like '%ATO_ITEM%' )
    AND   ( l_item_type IS NULL OR l_item_type <> 'ATO_ITEM') THEN
    l_msg_count := l_msg_count + 1;

  ELSIF ( l_name = 'R_ATO_MODEL_LINE' )
    AND   ( l_item_type IS NULL OR l_item_type <> 'ATO_MODEL') THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    l_msg_count := l_msg_count + 1;

  ELSIF ( l_name like '%ATO_MODEL%' )
    AND   ( l_item_type IS NULL OR l_item_type <> 'ATO_MODEL') THEN
    l_msg_count := l_msg_count + 1;

  ELSIF ( l_name = 'R_CONFIGURATION_LINE' )
    AND   ( l_item_type IS NULL
       OR l_item_type <> 'CONFIGURATION') THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    l_msg_count := l_msg_count + 1;

  ELSIF ( l_name like '%CONFIG%' )
    AND   ( l_item_type IS NULL
       OR l_item_type <> 'CONFIGURATION') THEN
    l_msg_count := l_msg_count + 1;

  ELSIF ( l_name = 'R_OTA_LINE' )
    AND   ( l_item_type IS NULL
       OR l_item_type <> 'EDUCATION_ITEM') THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    l_msg_count := l_msg_count + 1;

  ELSIF ( l_name like '%OTA%' )
    AND   ( l_item_type IS NULL
       OR l_item_type <> 'EDUCATION_ITEM') THEN
    l_msg_count := l_msg_count + 1;

  END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_ASSGN_ERR');
    FND_MESSAGE.SET_TOKEN('PROCESS', Display_Name(l_name,OE_GLOBALS.G_WFI_LIN));
    FND_MESSAGE.SET_TOKEN( 'ITEM_TYPE', NVL(l_item_type, 'STANDARD'));
    OE_MSG_PUB.Add;
    oe_debug_pub.add('LOG 4 : Added OE_WFVAL_ASSGN_ERR' ,1);

  ELSIF l_msg_count > 0 THEN
    FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_ASSGN_WNG');
    FND_MESSAGE.SET_TOKEN('PROCESS',Display_Name(l_name,OE_GLOBALS.G_WFI_LIN));
--    FND_MESSAGE.SET_TOKEN('PROCESS',Display_Name(l_name,l_item_type));   #4617652
    FND_MESSAGE.SET_TOKEN( 'ITEM_TYPE', NVL(l_item_type, 'STANDARD'));
    OE_MSG_PUB.Add;
    oe_debug_pub.add('LOG 5 : Added OE_WFVAL_ASSGN_WNG', 1);

  END IF;

  X_return_status := l_return_status;
  X_msg_count := l_msg_count;
  oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Line_Flow_Assignment', 1);
  -- l_end_time := dbms_utility.get_time;
  --oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Line_Flow_Assignment : '||Sqlerrm,5);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Line_Flow_Assignment;


/*----------------------------------------------------------------
  Procedure Check_Sync
  Checks if continue/wait p_activity in OEOH/OEOL process
  p_process has a corresponding wait/continue activity in the
  OEOL/OEOH flow(s) assigned to p_order_type.

  This program is called by:
  1. OE_VALIDATE_WF.Validate_Order_Flow() API
  2. OE_VALIDATE_WF.Validate_Line_Flow() API
------------------------------------------------------------------*/
PROCEDURE Check_Sync
(  P_process                          IN VARCHAR2
,  P_process_item_type                IN VARCHAR2
,  P_order_type_id                    IN NUMBER
,  P_order_flow                       IN VARCHAR2 DEFAULT NULL
,  P_instance_label                   IN VARCHAR2
,  P_act_item_type                    IN VARCHAR2
,  P_function                         IN VARCHAR2 --Vaibhav
,  P_type                             IN VARCHAR2 --Vaibhav
,  P_instance_id                      IN NUMBER --Vaibhav
,  X_return_status                    OUT NOCOPY VARCHAR2
)
IS
-- Cursor Decleration
CURSOR c_all_line_flows(c_type_id NUMBER) IS
  SELECT process_name,
         item_type_code /* Bug # 4908592 */
  FROM   oe_workflow_assignments
  WHERE  order_type_id = c_type_id
  AND    line_type_id IS NOT NULL
  AND    NVL(wf_item_type,'OEOL') = 'OEOL'
  AND    SYSDATE >= start_date_active
  AND    TRUNC(SYSDATE) <= nvl(end_date_active, SYSDATE);

 -- Local Variable Decleration
 l_process                           VARCHAR2(30);
 l_instance_label                    VARCHAR2(30);
 l_act_item_type                     VARCHAR2(8);
 l_process_item_type                 VARCHAR2(8);
 l_order_type_id                     NUMBER;
 l_instance                          NUMBER;
 l_line_instance                     NUMBER;
 l_hdr_instance                      NUMBER;
 l_line_process                      VARCHAR2(30);
 l_item_type                         VARCHAR2(30); /* Bug # 4908592 */
 l_flow_name                         VARCHAR2(30);
 l_wait_text_default                 VARCHAR2(30);
 l_cont_text_default                 VARCHAR2(30);
 l_matching_activity                 VARCHAR2(30);
 l_w_c                               VARCHAR2(30);
 l_coresp_wait_act                   VARCHAR2(5);
 l_coresp_cont_act                   VARCHAR2(5);
 l_wait_flow_type                    VARCHAR2(30);
 l_coresp_continue_act               VARCHAR2(30);
 l_order_flow                        VARCHAR2(30);
 l_activity_name                     VARCHAR2(30);
 l_wfval_out_of_sync                 VARCHAR2(4);

 l_all_activity_tbl              OE_VALIDATE_WF.Activities_Tbl_Type;
 l_line_activity_tbl             OE_VALIDATE_WF.Activities_Tbl_Type;
 l_header_activity_tbl           OE_VALIDATE_WF.Activities_Tbl_Type;

 l_start_time                        NUMBER;
 l_end_time                          NUMBER;

 l_function                          VARCHAR2(240);
 l_type                              VARCHAR2(8);
 l_instance_id                       NUMBER;

BEGIN
  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Check_Sync', 1);
   -- l_start_time := dbms_utility.get_time;

  X_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Copying passed into locals
  l_process := P_process;
  l_instance_label := p_instance_label;
  l_act_item_type := P_act_item_type;
  l_order_flow := P_order_flow;
  l_process_item_type := P_process_item_type;
  l_order_type_id := P_order_type_id;
  l_coresp_wait_act := 'NO';
  l_coresp_cont_act := 'NO';
  l_wfval_out_of_sync := NULL;
  l_coresp_continue_act := 'NO';
  l_function := P_function; --Vaibhav
  l_type := P_type; --Vaibhav
  l_instance_id := P_instance_id; --Vaibhav
  l_matching_activity := NULL;

  IF l_function = 'WF_STANDARD.CONTINUEFLOW' THEN

    BEGIN
      SELECT text_value
      INTO   l_wait_text_default
      FROM   wf_activity_attr_values waa
      WHERE  waa.name = 'WAITING_ACTIVITY'
      AND    process_activity_id = l_instance_id;
       -- l_all_activity_tbl(l_instance).instance_id;
       -- The above sql determines the WAITING_ACTIVITY of the
       -- passed activity with CONTINUEFLOW function
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_wait_text_default := NULL;
	oe_debug_pub.add('NO_DATA_FOUND in Check Sync for Waiting Activity',1);
        NULL;
      WHEN OTHERS THEN
	oe_debug_pub.add('Check Sync WAITING ACTIVITY',1);
	oe_debug_pub.add('Check Sync : Line_process : '||l_process,1);
	oe_debug_pub.add('Check Sync : Header_process : '||l_order_flow,1);
	oe_debug_pub.add('Check Sync : Activity Name : '||l_instance_label,1);
	oe_debug_pub.add('Check Sync : Error : '||sqlerrm,1);
	NULL;
    END;

    BEGIN
      SELECT 'YES'
      INTO   l_coresp_cont_act
      FROM   wf_activities wa
      WHERE  wa.function = 'WF_STANDARD.WAITFORFLOW'
      AND    wa.name = l_wait_text_default
      AND    wa.item_type IN ('OEOH','OEOL')
      AND    wa.version = ( SELECT MAX(version)
                            FROM   wf_activities wa1
	                    WHERE  wa1.item_type = wa.item_type
	    		    AND    wa1.name = wa.name );
      -- The above sql ensures that the WAITING_ACTIVITY given by
      -- the previous sql has a function of type WAITFORFLOW
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_coresp_cont_act := 'NO';
	oe_debug_pub.add('NO_DATA_FOUND in Check Sync for l_coresp_cont_act',1);
        NULL;
      WHEN OTHERS THEN
	oe_debug_pub.add('Check Sync l_coresp_cont_act',1);
	oe_debug_pub.add('Check Sync : Line_process : '||l_process,1);
	oe_debug_pub.add('Check Sync : Header_process : '||l_order_flow,1);
	oe_debug_pub.add('Check Sync : l_wait_text_default : '||l_wait_text_default,1);
	oe_debug_pub.add('Check Sync : Error : '||sqlerrm,1);
	NULL;
    END;

    BEGIN
      SELECT text_value
      INTO   l_flow_name
      FROM   wf_activity_attr_values waa
      WHERE  waa.name = 'WAITING_FLOW'
      AND    process_activity_id = l_instance_id;
      -- l_all_activity_tbl(l_instance).instance_id
      -- This sql determines the corresponding waiting flow type
      -- [MASTER/DETAIL]
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_flow_name := NULL;
	oe_debug_pub.add('NO_DATA_FOUND in Check Sync for Waiting Flow',1);
        NULL;
      WHEN OTHERS THEN
	oe_debug_pub.add('Check Sync WAITING_FLOW',1);
	oe_debug_pub.add('Check Sync : Line_process : '||l_process,1);
	oe_debug_pub.add('Check Sync : Header_process : '||l_order_flow,1);
	oe_debug_pub.add('Check Sync : Activity Name : '||l_instance_label,1);
	oe_debug_pub.add('Check Sync : Error : '||sqlerrm,1);
	NULL;
    END;
    -- Assigning Act attributes WAITING_ACTIVITY to matching
    -- activity. Assigning 'WAIT' to l_w_c, to determine the
    -- corresponding activity is WAITFORFLOW
    l_matching_activity := l_wait_text_default;
    l_w_c := 'WAIT';
    -- determines the corresponding activity is WAITFORFLOW
    IF l_process_item_type = OE_GLOBALS.G_WFI_HDR THEN
      IF (NVL(l_flow_name,'MASTER') <> 'DETAIL') THEN
        FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
        FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_instance_label);
        FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_process,l_process_item_type));
        OE_MSG_PUB.Add;
        oe_debug_pub.add('LOG 6 : Added OE_WFVAL_SYNC_DEF' ,1);
        -- incorrect synchronization activity definition
	X_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    ELSIF l_process_item_type = OE_GLOBALS.G_WFI_LIN THEN
      IF (NVL(l_flow_name,'DETAIL') <> 'MASTER') THEN
        FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
        FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_instance_label);
        --l_all_activity_tbl(l_instance).instance_label
        FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_process,l_process_item_type));
        OE_MSG_PUB.Add;
        oe_debug_pub.add('LOG 7 : Added OE_WFVAL_SYNC_DEF', 1);
        -- Added message OE_WFVAL_SYNC_DEF;
	X_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF; -- l_process_item_type

  ELSIF l_function = 'WF_STANDARD.WAITFORFLOW' THEN
    -- l_all_activity_tbl(l_instance).function
    BEGIN
      SELECT text_value
      INTO   l_cont_text_default
      FROM   wf_activity_attr_values waa
      WHERE  waa.name = 'CONTINUATION_ACTIVITY'
      AND    process_activity_id = l_instance_id;
      -- The above sql determines the CONTINUATION_ACTIVITY of the
      -- passed activity with WAITFORFLOW function
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_cont_text_default := NULL;
	oe_debug_pub.add('NO_DATA_FOUND in Check Sync for Continue Flow',1);
        NULL;
      WHEN OTHERS THEN
        oe_debug_pub.add('Check Sync CONTINUATION_ACTIVITY ',1);
	oe_debug_pub.add('Check Sync : Line_process : '||l_process,1);
	oe_debug_pub.add('Check Sync : Header_process : '||l_order_flow,1);
	oe_debug_pub.add('Check Sync : Activity Name : '||l_instance_label,1);
	oe_debug_pub.add('Check Sync : Error : '||sqlerrm,1);
	NULL;
    END;

    BEGIN
      SELECT 'YES'
      INTO   l_coresp_wait_act
      FROM   wf_activities wa
      WHERE  wa.function = 'WF_STANDARD.CONTINUEFLOW'
      AND    wa.name = l_cont_text_default
      AND    wa.item_type IN ('OEOH','OEOL')
      AND    wa.version = ( SELECT MAX(version)
                            FROM   wf_activities wa1
	                    WHERE  wa1.item_type = wa.item_type
	    		    AND    wa1.name = wa.name );
      -- The above sql ensures that the CONTINUATION_ACTIVITY
      -- given by the previous sql has a function of type CONTINUEFLOW
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_coresp_wait_act := 'NO';
	oe_debug_pub.add('NO_DATA_FOUND in Check Sync for l_coresp_wait_act',1);
        NULL;
      WHEN OTHERS THEN
        oe_debug_pub.add('Check Sync l_coresp_wait_act',1);
	oe_debug_pub.add('Check Sync : Line_process : '||l_process,1);
	oe_debug_pub.add('Check Sync : Header_process : '||l_order_flow,1);
	oe_debug_pub.add('Check Sync : l_cont_text_default : '||l_cont_text_default,1);
        oe_debug_pub.add('Check Sync : Error : '||sqlerrm,1);
	NULL;
    END;

    BEGIN
      SELECT text_value
      INTO   l_flow_name
      FROM   wf_activity_attr_values waa
      WHERE  waa.name = 'CONTINUATION_FLOW'
      AND    process_activity_id = l_instance_id;
      -- This sql determines the corresponding continue flow type
      -- [MASTER/DETAIL]
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_flow_name := NULL;
	oe_debug_pub.add('NO_DATA_FOUND in Check Sync for Continue Flow',1);
        NULL;
      WHEN OTHERS THEN
	oe_debug_pub.add('Check Sync CONTINUATION_FLOW',1);
	oe_debug_pub.add('Check Sync : Line_process : '||l_process,1);
	oe_debug_pub.add('Check Sync : Header_process : '||l_order_flow,1);
	oe_debug_pub.add('Check Sync : Activity Name : '||l_instance_label,1);
	oe_debug_pub.add('Check Sync : Error : '||sqlerrm,1);
	NULL;
    END;

    -- Assigning Act attributes CONTINUATION_ACTIVITY to matching
    -- activity. Assigning 'CONTINUE' to l_w_c, to determine the
    -- corresponding activity is CONTINUEFLOW
    l_matching_activity := l_cont_text_default;
    l_w_c := 'CONTINUE';

    IF l_process_item_type = OE_GLOBALS.G_WFI_HDR THEN
      IF (NVL(l_flow_name,'MASTER') <> 'DETAIL') THEN
        FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
        FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_instance_label);
        FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_process,l_process_item_type));
        OE_MSG_PUB.Add;
        oe_debug_pub.add('LOG 8 : Added OE_WFVAL_SYNC_DEF',1);
        X_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    ELSIF l_process_item_type = OE_GLOBALS.G_WFI_LIN THEN
      IF  (NVL(l_flow_name,'DETAIL') <> 'MASTER') THEN
        FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
        FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_instance_label);
        FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_process,l_process_item_type));
        OE_MSG_PUB.Add;
        oe_debug_pub.add('LOG 9 : Added OE_WFVAL_SYNC_DEF' ,1);
        X_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF; -- l_process_item_type

  END IF; -- l_all_activity_tbl(l_instance).API assignment

  IF l_matching_activity IS NOT NULL THEN

    oe_debug_pub.add('In C.S. Matching Activity is not null',1);
    IF l_process_item_type = OE_GLOBALS.G_WFI_HDR THEN
      -- Selecting distinct order line workflow processes assigned
      -- to p_order_type
      OPEN c_all_line_flows(l_order_type_id);
      LOOP
      FETCH c_all_line_flows
      INTO l_line_process,
           l_item_type; /* Bug # 4908592 */
      EXIT WHEN c_all_line_flows%NOTFOUND;

      /* The following IF added for 4908592. Do not enforce OEOH/OEOL sync on booking for configuration items */
      IF l_matching_activity = 'BOOK_WAIT_FOR_H' AND
         l_item_type = 'CONFIGURATION' THEN
         GOTO c_all_line_flows_end;
      END IF;

      G_all_activity_tbl.DELETE;
      G_exit_from_loop := 'NO';

      Get_Activities
      ( P_process              => l_line_process
      , P_process_item_type    => OE_GLOBALS.G_WFI_LIN
      , P_instance_label       => l_matching_activity
      , P_activity_item_type   => OE_GLOBALS.G_WFI_LIN
      );

      l_line_activity_tbl := G_all_activity_tbl;

      oe_debug_pub.add('C.S. Line Act tbl COUNT : '||l_line_activity_tbl.COUNT,1);

      IF l_line_activity_tbl.COUNT = 0 THEN
        FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_MISS');
        FND_MESSAGE.SET_TOKEN('PROCESS1',Display_Name(l_line_process,OE_GLOBALS.G_WFI_LIN));
        FND_MESSAGE.SET_TOKEN('ACTIVITY1',l_matching_activity);
        FND_MESSAGE.SET_TOKEN('ACTIVITY2', l_instance_label);
        FND_MESSAGE.SET_TOKEN('PROCESS2',Display_Name(l_process,l_process_item_type));
        OE_MSG_PUB.Add;
        oe_debug_pub.add('Check_Sync : LOG 10i : Added OE_WFVAL_SYNC_MISS',1);
        X_return_status := FND_API.G_RET_STS_ERROR;

      ELSE
        -- Important: If with the above cases, there exists no activity in a
        -- line process then the above count=0 can still display the correct
        -- message

        l_wfval_out_of_sync := NULL;
        FOR l_line_instance IN l_line_activity_tbl.FIRST .. l_line_activity_tbl.LAST
          LOOP
	  IF (l_line_activity_tbl(l_line_instance).instance_label
                                         <> l_matching_activity) THEN
            IF l_wfval_out_of_sync IS NULL THEN
               l_wfval_out_of_sync := 'YES';
            END IF;
          ELSE
            l_wfval_out_of_sync := 'NO';
          END IF;
        END LOOP;

        oe_debug_pub.add('In C.S. l_wfval_out_of_sync is : '||l_wfval_out_of_sync,5);
        IF l_wfval_out_of_sync = 'YES' THEN
          -- IF NOT Each selected process contains, on some level,
          -- instance_label = l_matching_activity THEN
          FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_MISS');
          FND_MESSAGE.SET_TOKEN('PROCESS1',Display_Name(l_line_process,OE_GLOBALS.G_WFI_LIN));
          FND_MESSAGE.SET_TOKEN('ACTIVITY1',l_matching_activity);
          FND_MESSAGE.SET_TOKEN('ACTIVITY2', l_instance_label);
          FND_MESSAGE.SET_TOKEN('PROCESS2',Display_Name(l_process,l_process_item_type));
          OE_MSG_PUB.Add;
          oe_debug_pub.add('LOG 10 : Added OE_WFVAL_SYNC_MISS',1);
          -- synchronization activity missing its counterpart
          -- activity
          X_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Important : The above changes are done keeping in mind that for
        -- one activity name, we can have many instance labels, with
        -- atleast one correct. In such a case even, error message is not
        -- liable. Moreover if the COUNT = 0 then it means there is no
        -- activity defined, where message is liable.
	FOR l_line_instance IN l_line_activity_tbl.FIRST .. l_line_activity_tbl.LAST
	  LOOP
          IF (l_line_activity_tbl(l_line_instance).instance_label
                                         = l_matching_activity) THEN
            IF l_w_c = 'CONTINUE' THEN
              IF NOT( l_coresp_wait_act = 'YES'
                AND l_matching_activity = l_line_activity_tbl(l_line_instance).instance_label)
                AND  (NVL(l_flow_name,'MASTER') <> 'DETAIL') THEN
                -- Matching activity must be assigned API
                -- WF_STANDARD.CONTINUEFLOW, matching activity attr
                -- WAITING_ACTIVITY must equal to Act.instance_label,
                -- and matching activity attribute WAITING_FLOW
                -- must be 'MASTER', else it will be an error.

                FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
                FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_matching_activity);
                FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_line_process,OE_GLOBALS.G_WFI_LIN));
                OE_MSG_PUB.Add;
                oe_debug_pub.add('LOG 11 : Added OE_WFVAL_SYNC_DEF',1);
                X_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

            ELSIF l_w_c = 'WAIT' THEN
              IF NOT( l_coresp_cont_act = 'YES'
                AND l_matching_activity = l_line_activity_tbl(l_line_instance).instance_label)
                AND (NVL(l_flow_name,'MASTER') <> 'DETAIL' ) THEN
                -- Matching activity must be assigned API
                -- WF_STANDARD.WAITFORFLOW, matching activity attr
                -- CONTINUATION_FLOW must equal to Act.instance_label,
                -- and matching activity attribute CONTINUATION_FLOW
                -- must be 'MASTER', else it will be an error.
                FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
                FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_matching_activity);
                FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_line_process,OE_GLOBALS.G_WFI_LIN));
                OE_MSG_PUB.Add;
                oe_debug_pub.add('LOG 12 : Added OE_WFVAL_SYNC_DEF',1 );
                X_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            END IF; -- l_w_c
	  END IF; -- l_matching_activity
        END LOOP; -- l_line_instance
      END IF; -- IF COUNT = 0
      <<c_all_line_flows_end>> /* Bug # 4908592 */
      NULL;                    /* Bug # 4908592 */
    END LOOP; -- c_all_line_flows
    CLOSE c_all_line_flows;

    ELSIF l_process_item_type = OE_GLOBALS.G_WFI_LIN THEN
      IF l_order_flow IS NOT NULL THEN

	G_all_activity_tbl.DELETE;
	G_exit_from_loop := 'NO';

        Get_Activities
        ( P_process              => l_order_flow
        , P_process_item_type    => OE_GLOBALS.G_WFI_HDR
        , P_instance_label       => l_matching_activity
        , P_activity_item_type   => OE_GLOBALS.G_WFI_HDR
        );

	l_header_activity_tbl := G_all_activity_tbl;
        oe_debug_pub.add('C.S. Hdr Act tbl COUNT : '||l_header_activity_tbl.COUNT,1);
        l_wfval_out_of_sync := NULL;

        IF l_header_activity_tbl.COUNT = 0 THEN
          FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_MISS');
          FND_MESSAGE.SET_TOKEN('PROCESS1',Display_Name(l_order_flow,OE_GLOBALS.G_WFI_HDR));
          FND_MESSAGE.SET_TOKEN('ACTIVITY1',l_matching_activity);
          FND_MESSAGE.SET_TOKEN('ACTIVITY2', l_instance_label);
          FND_MESSAGE.SET_TOKEN('PROCESS2',Display_Name(l_process,l_process_item_type));
          OE_MSG_PUB.Add;
          oe_debug_pub.add('Check_Sync : LOG 13i : Added OE_WFVAL_SYNC_MISS',1);
          -- synchronization activity missing its counterpart activity;
          X_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF l_header_activity_tbl.COUNT > 0 THEN

	  FOR l_hdr_instance IN l_header_activity_tbl.FIRST .. l_header_activity_tbl.LAST
	    LOOP
 	    IF NOT(l_header_activity_tbl(l_hdr_instance).instance_label
                                         = l_matching_activity) THEN
              IF l_wfval_out_of_sync IS NULL THEN
                 l_wfval_out_of_sync := 'YES';
              END IF;
            ELSE
              l_wfval_out_of_sync := 'NO';
            END IF;
          END LOOP;
        END IF; -- l_header_activity_tbl

        oe_debug_pub.add('In C.S. l_wfval_out_of_sync is : '||l_wfval_out_of_sync,5);
        IF l_wfval_out_of_sync = 'YES' THEN
          -- IF NOT l_order_flow contains instance_label =
          -- l_matching_activity THEN
          FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_MISS');
          FND_MESSAGE.SET_TOKEN('PROCESS1',Display_Name(l_order_flow,OE_GLOBALS.G_WFI_HDR));
          FND_MESSAGE.SET_TOKEN('ACTIVITY1',l_matching_activity);
          FND_MESSAGE.SET_TOKEN('ACTIVITY2', l_instance_label);
          FND_MESSAGE.SET_TOKEN('PROCESS2',Display_Name(l_process,l_process_item_type));
          OE_MSG_PUB.Add;
          oe_debug_pub.add('LOG 13 : Added OE_WFVAL_SYNC_MISS' ,1);
          -- synchronization activity missing its counterpart activity;
          X_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        IF l_header_activity_tbl.COUNT > 0 THEN
          FOR l_hdr_instance IN l_header_activity_tbl.FIRST .. l_header_activity_tbl.LAST
	    LOOP
            IF (l_header_activity_tbl(l_hdr_instance).instance_label
                                         = l_matching_activity) THEN
              IF l_w_c = 'CONTINUE' THEN
                IF NOT( l_coresp_wait_act = 'YES'
                  AND l_matching_activity = l_header_activity_tbl(l_hdr_instance).instance_label)
                  AND (NVL(l_flow_name,'DETAIL') <> 'MASTER') THEN
                  -- Matching activity must be assigned API
                  -- WF_STANDARD.CONTINUEFLOW, matching activity attr
                  -- WAITING_ACTIVITY must equal to Act.instance_label,
                  -- and matching activity attribute WAITING_FLOW must
                  -- be 'DETAIL', else it will be an error.
                  FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
                  FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL',l_matching_activity);
                  FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_order_flow,OE_GLOBALS.G_WFI_HDR));
                  OE_MSG_PUB.Add;
                  oe_debug_pub.add('LOG 14 : Added OE_WFVAL_SYNC_DEF' ,1);
                  X_return_status := FND_API.G_RET_STS_ERROR;
                END IF;

              ELSIF l_w_c = 'WAIT' THEN
                IF NOT( l_coresp_cont_act = 'YES'
                  AND l_matching_activity = l_header_activity_tbl(l_hdr_instance).instance_label)
                  AND (NVL(l_flow_name,'DETAIL') <>  'MASTER') THEN
                  -- Matching activity must be assigned API
                  -- WF_STANDARD.WAITFORFLOW, matching activity attr
                  -- CONTINUATION_FLOW must equal to Act.instance_label,
                  -- and matching activity attribute CONTINUATION_FLOW
                  -- must be 'DETAIL', else it will be an error. */
                  FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_DEF');
                  FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_matching_activity);
                  FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_order_flow,OE_GLOBALS.G_WFI_HDR));
                  OE_MSG_PUB.Add;
                  oe_debug_pub.add('LOG 15 : Added OE_WFVAL_SYNC_DEF',1 );
                  X_return_status := FND_API.G_RET_STS_ERROR;
                END IF;
              END IF; -- l_w_c

            END IF; -- instance_label = l_matching_activity
          END LOOP; -- l_hdr_instance
        END IF; -- l_header_activity_tbl.COUNT
      END IF; -- l_order_flow
    END IF;  -- l_process_item_type
  END IF; -- l_matching_activity

  oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Check_Sync', 1);
  -- l_end_time := dbms_utility.get_time;
  -- oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Check Sync : '||Sqlerrm,5);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Sync;

/*----------------------------------------------------------------
  Procedure Out_Transitions
  Looks for any activity or subprocess in process p_name that has
  no OUT transition defined. If any are found, error status is
  returned and appropriate error messages logged.

  This program is called by:
  1. OE_VALIDATE_WF.Validate_Order_Flow() API
  2. OE_VALIDATE_WF.Validate_Line_Flow() API
------------------------------------------------------------------*/
PROCEDURE Out_Transitions
(  P_name                             IN VARCHAR2
,  P_type                             IN VARCHAR2
,  X_return_status                    OUT NOCOPY VARCHAR2
)
IS
  -- Local Variable Decleration
  l_instance                     NUMBER;
  l_name                         VARCHAR2(30);
  l_type                         VARCHAR2(8);
  l_from_process_activity_exists VARCHAR2(1);
  l_all_activity_tbl             OE_VALIDATE_WF.Activities_Tbl_Type;
  l_start_time                  NUMBER;
  l_end_time                    NUMBER;
  -- l_start_end                    VARCHAR2(8);

BEGIN
  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Out_Transitions', 1);
  -- l_start_time := dbms_utility.get_time;
  X_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Copying passed into locals
  l_name    := P_name;
  l_type    := P_type;
  l_from_process_activity_exists := 'N';
  -- For every activity/subprocesses Act in process p_name
  -- FOR all_activities IN c_all_activities(l_name, l_type) LOOP
  -- Commented for the performance reasons.
  G_all_activity_tbl.DELETE;
  G_exit_from_loop := 'NO';

  Get_Activities
  ( P_process              => l_name
  , P_process_item_type    => l_type
  , P_instance_label       => NULL
  , P_activity_item_type   => NULL
  );
  l_all_activity_tbl := G_all_activity_tbl;

  oe_debug_pub.add(' In O.T. l_all_activity_tbl.COUNT is : '||l_all_activity_tbl.COUNT ,5);
  IF l_all_activity_tbl.COUNT > 0 THEN
    FOR l_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
      IF NOT (NVL(l_all_activity_tbl(l_instance).start_end, 'N') = WF_ENGINE.ENG_END) THEN
        oe_debug_pub.add(' In O.T. Instance_Label is : '||l_all_activity_tbl(l_instance).instance_label,5);
	oe_debug_pub.add(' In O.T. Activity start_end : '||l_all_activity_tbl(l_instance).start_end,5);
        BEGIN
          SELECT 'Y'
          INTO l_from_process_activity_exists
          FROM   wf_activity_transitions
          WHERE  from_process_activity =
                          l_all_activity_tbl(l_instance).instance_id
          AND    ROWNUM = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_from_process_activity_exists := 'N';
            oe_debug_pub.add('O.T. Process Activity do not exists',1);
            oe_debug_pub.add('O.T. Activity Name : '||l_all_activity_tbl(l_instance).activity_name,1);
            oe_debug_pub.add('O.T. From instance_id : '||l_all_activity_tbl(l_instance).instance_id,1);
	    NULL;
          WHEN OTHERS THEN
            oe_debug_pub.add('Error O.T. '||sqlerrm,1);
	    NULL;
        END;

        IF (l_from_process_activity_exists = 'N') THEN
          FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_NO_OUT_TRANS');
          FND_MESSAGE.SET_TOKEN('ACTIVITY_LABEL', l_all_activity_tbl(l_instance).instance_label);
          FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,l_type));
          OE_MSG_PUB.Add;
          oe_debug_pub.add('LOG 16 : Added OE_WFVAL_NO_OUT_TRANS',1 );
          X_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF; -- IF start_end <> WF_ENGINE.ENG_END
    END LOOP;
  END IF; -- COUNT > 0

  oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Out_Transitions', 1);
  -- l_end_time := dbms_utility.get_time;
  -- oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    oe_debug_pub.add('Error in Out_Transitions : '||Sqlerrm);
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Out_Transitions;

/*----------------------------------------------------------------
  Procedure Validate_Line_Flow
  << Description >>

  This program is called by:
  1. OE_VALIDATE_WF.Validate() API
  2. Transaction Types form (OEXDTTYP.fmb, OEXTRTYP.pld)
------------------------------------------------------------------*/
PROCEDURE Validate_Line_Flow
(  P_name                             IN VARCHAR2
,  P_order_flow                       IN VARCHAR2
,  p_quick_val                        IN BOOLEAN DEFAULT TRUE
,  X_return_status                    OUT NOCOPY VARCHAR2
,  X_msg_count                        OUT NOCOPY NUMBER
,  X_msg_data                         OUT NOCOPY VARCHAR2
,  p_item_type                        IN VARCHAR2 /* Bug # 4908592 */
)
IS
-- Cursor Decleration
CURSOR c_fulfill_attributes(c_instance_id NUMBER) IS
select TEXT_VALUE FulfillAttr
from   wf_activity_attr_values
where  process_activity_id = c_instance_id
and    NAME IN ( 'FULFILLMENT_ACTIVITY'
               , 'INBOUND_FULFILLMENT_ACTIVITY');

 -- Local Variable Decleration
 l_instance                    NUMBER;
 l_all_instance                NUMBER;
 l_return_status               VARCHAR2(1);
 l_name                        VARCHAR2(30);
 l_order_flow                  VARCHAR2(30);
 l_msg_data                    VARCHAR2(2000);
 l_errors_only                 BOOLEAN := TRUE;
 l_continue_further            BOOLEAN := FALSE;
 l_msg_count                   NUMBER;
 l_fulfill_act_exists          VARCHAR2(1);
 l_type                        VARCHAR2(8);
 l_attr_first_time             VARCHAR2(2000);
 l_line_process_name           VARCHAR2(30);
 l_hdr_activity_tbl            OE_VALIDATE_WF.Activities_Tbl_Type;
 l_all_activity_tbl            OE_VALIDATE_WF.Activities_Tbl_Type;
 l_start_time                  NUMBER;
 l_end_time                    NUMBER;
 testing_instance              NUMBER;
 hdr_instance                  NUMBER;
 l_activity                    VARCHAR2(30);
 matching_activity_exists      BOOLEAN := FALSE;

BEGIN
  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Validate_Line_Flow', 1);
  -- l_start_time := dbms_utility.get_time;
  X_return_status := FND_API.G_RET_STS_SUCCESS;
  l_msg_count := OE_MSG_PUB.count_msg;

  -- Copying passed into locals
  l_name        := P_name;
  l_type        := OE_GLOBALS.G_WFI_LIN;
  l_order_flow  := P_order_flow;
  l_errors_only := p_quick_val;
  l_fulfill_act_exists := 'N';

  oe_debug_pub.add('Calling Out Transitions from Validate Line Flow',5);
  OE_VALIDATE_WF.OUT_TRANSITIONS
  ( P_name                       => l_name
  , P_type                       => OE_GLOBALS.G_WFI_LIN
  , X_return_status              => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    X_return_status := l_return_status;
  END IF;
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  G_all_activity_tbl.DELETE;
  G_exit_from_loop := 'NO';
  l_attr_first_time := NULL;

  oe_debug_pub.add('Calling Get Activities for Lines from Validate Line Flow',5);
  Get_Activities
  ( P_process              => l_name
  , P_process_item_type    => l_type
  , P_instance_label       => NULL
  , P_activity_item_type   => NULL
  );

  l_all_activity_tbl := G_all_activity_tbl;
  IF l_all_activity_tbl.COUNT > 0 THEN
    FOR l_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
      IF l_all_activity_tbl(l_instance).activity_name = 'FULFILL_LINE' THEN
        l_fulfill_act_exists := 'Y';
        -- Setting Fulfill activity exists.
        FOR fulfill_attributes IN c_fulfill_attributes(l_all_activity_tbl(l_instance).instance_id)
	  LOOP
          -- Getting the value (FulfillAttr) of attributes
          -- FULFILLMENT_ACTIVITY and INBOUND_FULFILLMENT_ACTIVITY.
  	  -- AND is selected for the first time - using variable
	  -- 'l_attr_first_time' and 'l_continue_further'
          IF fulfill_attributes.FulfillAttr IS NOT NULL THEN
            IF l_attr_first_time IS NULL THEN
              l_attr_first_time := ''''||fulfill_attributes.FulfillAttr||'''';
	      l_continue_further := TRUE;
            ELSE -- l_attr_first_time IS NOT NULL
              IF fulfill_attributes.FulfillAttr NOT IN (l_attr_first_time) THEN
                l_attr_first_time := l_attr_first_time||','||''''||fulfill_attributes.FulfillAttr||'''';
  	        l_continue_further := TRUE;
              ELSE
                l_continue_further := FALSE;
              END IF;
            END IF; -- l_attr_first_time

            IF l_continue_further THEN
              IF NOT OE_VALIDATE_WF.HAS_ACTIVITY
                    ( P_process                => l_name
                    , P_process_item_type      => OE_GLOBALS.G_WFI_LIN
                    , P_activity               => fulfill_attributes.FulfillAttr
                    , P_activity_item_type     => OE_GLOBALS.G_WFI_LIN
                    ) THEN

                FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_NO_FULFILL_ACT');
                FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,l_type));
                FND_MESSAGE.SET_TOKEN('FULFILLMENT_ACTIVITY'
                                  , fulfill_attributes.FulfillAttr);
                FND_MESSAGE.SET_TOKEN('FULFILL_LINE'
                  , l_all_activity_tbl(l_instance).instance_label);
                OE_MSG_PUB.Add;
                oe_debug_pub.add('LOG 17: Add OE_WFVAL_NO_FULFILL_ACT',1);
                X_return_status := FND_API.G_RET_STS_ERROR;

              ELSIF NOT l_errors_only THEN
                FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_ACT_ORDER');
                FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,l_type));
                FND_MESSAGE.SET_TOKEN('ACTIVITY1'
                                  , fulfill_attributes.FulfillAttr);
                FND_MESSAGE.SET_TOKEN('ACTIVITY2'
                   , l_all_activity_tbl(l_instance).instance_label);
                OE_MSG_PUB.Add;
                oe_debug_pub.add('LOG 18 : Added OE_WFVAL_ACT_ORDER' ,1);
              END IF; -- HAS_ACTIVITY
            END IF; -- l_continue_further
          END IF; -- fulfill_attributes.FulfillAttr

        END LOOP; -- fulfill_attributes
	oe_debug_pub.add('Fulfill attributes are : '||l_attr_first_time,5);

      END IF; -- l_all_activity_tbl = FULFILL_LINE
    END LOOP; -- l_instance
  END IF; -- COUNT > 0
  -- IF no FULFILL_LINE activity was detected in the above step AND
  -- NOT l_errors_only then adding message OE_WFVAL_MISSING_ACTIVITY

  oe_debug_pub.add('Fulfill Activity Exists (Y/N) : '||l_fulfill_act_exists,5);

  IF l_fulfill_act_exists = 'N' AND NOT l_errors_only THEN
    FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_MISSING_ACTIVITY');
    FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,l_type));
    FND_MESSAGE.SET_TOKEN('ACTIVITY_NAME','FULFILL_LINE');
    OE_MSG_PUB.Add;
    oe_debug_pub.add('LOG 19 : Added OE_WFVAL_MISSING_ACTIVITY',1);
  END IF;

  IF l_errors_only THEN

    BEGIN

      G_all_activity_tbl.DELETE;
      G_exit_from_loop := 'NO';
      oe_debug_pub.add('Calling Get Activities for Header in Validate Order Line',5);

      Get_Activities
      ( P_process              => l_order_flow
      , P_process_item_type    => OE_GLOBALS.G_WFI_HDR
      , P_instance_label       => NULL
      , P_activity_item_type   => NULL
      );

      l_hdr_activity_tbl := G_all_activity_tbl;

      IF l_hdr_activity_tbl.COUNT > 0 THEN
        FOR hdr_instance IN l_hdr_activity_tbl.FIRST .. l_hdr_activity_tbl.LAST LOOP
          IF l_hdr_activity_tbl(hdr_instance).activity_name IN ('FULFILLMENT_WAIT_FOR_L'
                                                               ,'INVOICING_CONT_L'
                                                               /*, Commented for #6818912 'APPROVE_CONT_L' Bug 6411686 */
                                                               /* ,'BOOK_CONT_L'  Bug # 4908592 */
                                                               ,'CLOSE_WAIT_FOR_L') OR
                                                               /* Bug # 4908592 Start */
                                                               (NVL(p_item_type, 'NULL') <> 'CONFIGURATION' AND
                                                               l_hdr_activity_tbl(hdr_instance).activity_name = 'BOOK_CONT_L') THEN
                                                               /* Bug # 4908592 End */
        oe_debug_pub.add('In VLF : for Act '||l_hdr_activity_tbl(hdr_instance).activity_name,5);
	    oe_debug_pub.add('In VLF : for function '||l_hdr_activity_tbl(hdr_instance).function,5);
	    oe_debug_pub.add('In VLF : for instance_id '||l_hdr_activity_tbl(hdr_instance).instance_id,5);

            IF l_hdr_activity_tbl(hdr_instance).function = 'WF_STANDARD.CONTINUEFLOW' THEN
              BEGIN
                SELECT text_value
                INTO   l_activity
                FROM   wf_activity_attr_values waa
                WHERE  waa.name = 'WAITING_ACTIVITY'
                AND    process_activity_id = l_hdr_activity_tbl(hdr_instance).instance_id;
                -- The above sql determines the WAITING_ACTIVITY of the
                -- passed activity with CONTINUEFLOW function
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_activity := NULL;
		  oe_debug_pub.add(' In No Data Found for WAITING_ACTIVITY',1);
                  NULL;
                WHEN OTHERS THEN
	          oe_debug_pub.add('Validate_Line_Flow WAITING ACTIVITY',1);
	          oe_debug_pub.add('Validate_Line_Flow : Header_process : '||l_order_flow,1);
	          oe_debug_pub.add('Validate_Line_Flow : Activity Name : '||l_hdr_activity_tbl(hdr_instance).instance_label,1);
		  oe_debug_pub.add('Validate_Line_Flow : Error : '||sqlerrm,1);
	          NULL;
              END;

            ELSIF l_hdr_activity_tbl(hdr_instance).function = 'WF_STANDARD.WAITFORFLOW' THEN
              BEGIN
                SELECT text_value
                INTO   l_activity
                FROM   wf_activity_attr_values waa
                WHERE  waa.name = 'CONTINUATION_ACTIVITY'
                AND    process_activity_id = l_hdr_activity_tbl(hdr_instance).instance_id;
                -- The above sql determines the CONTINUATION_ACTIVITY of the
                -- passed activity with WAITFORFLOW function
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_activity := NULL;
		  oe_debug_pub.add(' In No Data Found for CONTINUATION_ACTIVITY',1);
                  NULL;
                WHEN OTHERS THEN
                  oe_debug_pub.add('Validate_Line_Flow CONTINUATION_ACTIVITY',1);
      	          oe_debug_pub.add('Validate_Line_Flow : Header_process : '||l_order_flow,1);
 	          oe_debug_pub.add('Validate_Line_Flow : Activity Name : '||l_hdr_activity_tbl(hdr_instance).instance_label,1);
	          oe_debug_pub.add('Validate_Line_Flow : Error : '||sqlerrm,1);
		  NULL;
              END;
  	    END IF;

	    oe_debug_pub.add('In VLF : Matching Activity is : '||l_activity,5);
            matching_activity_exists := FALSE;
            IF l_activity IS NOT NULL THEN
              IF l_all_activity_tbl.COUNT > 0 THEN
                FOR testing_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
                  IF ( l_all_activity_tbl(testing_instance).activity_name = l_activity ) THEN
                    matching_activity_exists := TRUE;
	            EXIT;
  	          END IF;
                END LOOP;
	      END IF;
            END IF;

	    IF (matching_activity_exists <> TRUE) THEN

	      oe_debug_pub.add('In VLF : Matching activity do not exists, logging message',1);

              FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_MISS');
              FND_MESSAGE.SET_TOKEN('PROCESS1',Display_Name(l_name,OE_GLOBALS.G_WFI_LIN));
              FND_MESSAGE.SET_TOKEN('ACTIVITY1',l_activity);
              FND_MESSAGE.SET_TOKEN('ACTIVITY2',l_hdr_activity_tbl(hdr_instance).activity_name);
              FND_MESSAGE.SET_TOKEN('PROCESS2',Display_Name(l_order_flow,OE_GLOBALS.G_WFI_HDR));
              OE_MSG_PUB.Add;
	      X_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
	  END IF;
	END LOOP;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;


    oe_debug_pub.add('In VLF : Done with a/c flows check',5);
    oe_debug_pub.add('In VLF : Starting check sync for quick validation TRUE',5);

    IF l_all_activity_tbl.COUNT > 0 THEN
      FOR testing_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
        IF l_all_activity_tbl(testing_instance).activity_name IN
	                    ('FULFILLMENT_CONT_H', 'INVOICING_WAIT_FOR_H','APPROVE_WAIT_FOR_H' /* Bug 6411686 */
			    ,'BOOK_WAIT_FOR_H', 'CLOSE_CONT_H') THEN
          oe_debug_pub.add('In VLF : For Instance Label '||l_all_activity_tbl(testing_instance).instance_label,5);
	  oe_debug_pub.add('In VLF : For Instance Id '||l_all_activity_tbl(testing_instance).instance_id,5);
	  oe_debug_pub.add('In VLF : For function '||l_all_activity_tbl(testing_instance).function,5);

	  OE_VALIDATE_WF.CHECK_SYNC
          ( P_process           => l_name
          , P_process_item_type => OE_GLOBALS.G_WFI_LIN
          , P_order_type_id     => NULL
          , P_order_flow        => l_order_flow
          , P_instance_label    => l_all_activity_tbl(testing_instance).instance_label
          , P_act_item_type     => OE_GLOBALS.G_WFI_LIN
          , P_function          => l_all_activity_tbl(testing_instance).function
          , P_type              => l_all_activity_tbl(testing_instance).type
          , P_instance_id       => l_all_activity_tbl(testing_instance).instance_id
          , X_return_status     => l_return_status
          );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            X_return_status := l_return_status;
          END IF;
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      END LOOP; -- testing_instance
    END IF; -- l_all_activity_tbl.COUNT
  END IF; -- l_errors_only

  oe_debug_pub.add('In VLF : Starting check sync for quick validation FALSE',5);
  IF NOT l_errors_only THEN
    IF l_all_activity_tbl.COUNT > 0 THEN --Vaibhav
      FOR testing_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
        IF l_all_activity_tbl(testing_instance).function IN
	       ('WF_STANDARD.CONTINUEFLOW', 'WF_STANDARD.WAITFORFLOW') THEN
          oe_debug_pub.add('In VLF : For Instance Label '||l_all_activity_tbl(testing_instance).instance_label,5);
	  oe_debug_pub.add('In VLF : For Instance Id '||l_all_activity_tbl(testing_instance).instance_id,5);
	  oe_debug_pub.add('In VLF : For function '||l_all_activity_tbl(testing_instance).function,5);

          OE_VALIDATE_WF.CHECK_SYNC
          ( P_process                    => l_name
          , P_process_item_type          => OE_GLOBALS.G_WFI_LIN
          , P_order_type_id              => NULL
          , P_order_flow                 => l_order_flow
          , P_instance_label             => l_all_activity_tbl(testing_instance).instance_label
          , P_act_item_type              => l_all_activity_tbl(testing_instance).activity_item_type
          , P_function                   => l_all_activity_tbl(testing_instance).function
          , P_type                       => l_all_activity_tbl(testing_instance).type
          , P_instance_id                => l_all_activity_tbl(testing_instance).instance_id
          , X_return_status              => l_return_status
          );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            X_return_status := l_return_status;
          END IF;
   	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      END LOOP;
    END IF;

    oe_debug_pub.add('In VLF : Calling Has Activity for CLOSE_LINE in process : '||l_name,5);
    IF NOT OE_VALIDATE_WF.HAS_ACTIVITY
           ( P_process                 => l_name
           , P_process_item_type       => OE_GLOBALS.G_WFI_LIN
           , P_activity                => 'CLOSE_LINE'
           , P_activity_item_type      => OE_GLOBALS.G_WFI_LIN
           ) THEN

      FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_MISSING_ACTIVITY');
      FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,OE_GLOBALS.G_WFI_LIN));
      FND_MESSAGE.SET_TOKEN('ACTIVITY_NAME','CLOSE_LINE');
      OE_MSG_PUB.Add;
      oe_debug_pub.add('LOG 20 : OE_WFVAL_MISSING_ACTIVITY',1);
    END IF;

    -- Activities in process p_name assigned APIs
    -- wf_standard.defer or wf_standard.wait */
    FOR l_all_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
      IF l_all_activity_tbl(l_all_instance).function= 'WF_STANDARD.DEFER'
        OR l_all_activity_tbl(l_all_instance).function = 'WF_STANDARD.WAIT'
        THEN

	oe_debug_pub.add('In VLF : Calling Wait And Loops for instance_label '||l_all_activity_tbl(l_all_instance).instance_label,5);
	oe_debug_pub.add('In VLF : Calling Wait And Loops for instance_id '||l_all_activity_tbl(l_all_instance).instance_id,5);

        OE_VALIDATE_WF.WAIT_AND_LOOPS
        ( P_process                => l_name
        , P_process_item_type      => OE_GLOBALS.G_WFI_LIN
        , P_activity_id            => l_all_activity_tbl(l_all_instance).instance_id
        , P_activity_label         => l_all_activity_tbl(l_all_instance).instance_label
        , P_api                    => l_all_activity_tbl(l_all_instance).function
        , X_return_status          => l_return_status
        );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          X_return_status := l_return_status;
        END IF;
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF; -- function = DEFER/WAIT
    END LOOP; -- l_all_instance

    oe_debug_pub.add('In VLF : Calling Has Activity for INVOICE_INTERFACE and SHIP_LINE in process : '||l_name,5);
    IF OE_VALIDATE_WF.HAS_ACTIVITY
       ( P_process                 => l_name
       , P_process_item_type       => OE_GLOBALS.G_WFI_LIN
       , P_activity                => 'SHIP_LINE'
       , P_activity_item_type      => OE_GLOBALS.G_WFI_LIN
       ) AND

       OE_VALIDATE_WF.HAS_ACTIVITY
       ( P_process                 => l_name
       , P_process_item_type       => OE_GLOBALS.G_WFI_LIN
       , P_activity                => 'INVOICE_INTERFACE'
       , P_activity_item_type      => OE_GLOBALS.G_WFI_LIN
       ) THEN

       FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_ACT_ORDER');
       FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,l_type));
       FND_MESSAGE.SET_TOKEN('ACTIVITY1','SHIP_LINE');
       FND_MESSAGE.SET_TOKEN('ACTIVITY2','INVOICE_INTERFACE');
       OE_MSG_PUB.Add;
       oe_debug_pub.add('LOG 21 : Added OE_WFVAL_ACT_ORDER' ,1) ;
    END IF;
  END IF; -- NOT l_errors_only

  X_msg_count :=   OE_MSG_PUB.count_msg - l_msg_count;
  oe_debug_pub.add('In VLF : msg count : '||X_msg_count,5);

  IF x_msg_count > 0 THEN
    X_msg_data := OE_MSG_PUB.get(l_msg_count + 1);
  END IF;

  oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Validate_Line_Flow', 1);
  --l_end_time := dbms_utility.get_time;
  --oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  --WHEN FND_API.G_EXC_ERROR THEN
  --  RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    oe_debug_pub.add('Error in Validate_Line_Flow : '||sqlerrm,5);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Line_Flow;

PROCEDURE Validate_Line_Flow /* Bug # 4908592 */
(  P_name                             IN VARCHAR2
,  P_order_flow                       IN VARCHAR2
,  p_quick_val                        IN BOOLEAN DEFAULT TRUE
,  X_return_status                    OUT NOCOPY VARCHAR2
,  X_msg_count                        OUT NOCOPY NUMBER
,  X_msg_data                         OUT NOCOPY VARCHAR2
)
IS

BEGIN
   Validate_Line_Flow
   (  P_name
   ,  P_order_flow
   ,  p_quick_val
   ,  X_return_status
   ,  X_msg_count
   ,  X_msg_data
   ,  NULL);
END Validate_Line_Flow;

/*----------------------------------------------------------------
  Procedure Validate_Order_flow
  << Description >>

  This program is called by:
  1. OE_VALIDATE_WF.Validate() API
  2. Transaction Types form (OEXDTTYP.fmb, OEXTRTYP.pld)
------------------------------------------------------------------*/
PROCEDURE Validate_Order_flow
(  P_name                             IN VARCHAR2
,  P_order_type_id                    IN NUMBER DEFAULT NULL
,  P_type                             IN VARCHAR2
,  p_quick_val                        IN BOOLEAN DEFAULT TRUE
,  X_return_status                    OUT NOCOPY VARCHAR2
,  X_msg_count                        OUT NOCOPY NUMBER
,  X_msg_data                         OUT NOCOPY VARCHAR2
)
IS

 -- Local Variable Decleration
 l_instance                    NUMBER;
 l_return_status               VARCHAR2(1);
 l_type                        VARCHAR2(8);
 l_name                        VARCHAR2(30);
 l_line_process_name           VARCHAR2(30);
 l_header_process_name         VARCHAR2(30);
 l_msg_data                    VARCHAR2(2000);
 l_quick_val                   BOOLEAN := TRUE;
 l_msg_count                   NUMBER;
 l_order_type_id               NUMBER := NULL;
 l_all_activity_tbl            OE_VALIDATE_WF.Activities_Tbl_Type;
 l_lin_activity_tbl            OE_VALIDATE_WF.Activities_Tbl_Type;
 l_start_time                  NUMBER;
 l_end_time                    NUMBER;
 testing_instance              NUMBER;
 testing_inst                  NUMBER;
 line_instance                 NUMBER;
 instance_count                NUMBER;
 l_activity                    VARCHAR2(30);
--  l_activity_sum                VARCHAR2(120);
 matching_activity_exists      BOOLEAN := FALSE;

BEGIN
  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Validate_Order_flow', 1);
  -- l_start_time := dbms_utility.get_time;
  X_return_status := FND_API.G_RET_STS_SUCCESS;
  l_msg_count := OE_MSG_PUB.count_msg;

  -- Copying passed into locals
  l_name          := P_name;
  l_type          := P_type;
  l_order_type_id := P_order_type_id;
  l_quick_val     := p_quick_val;

  oe_debug_pub.add('Calling Out Transition from Validate Order Flow',5);
  OE_VALIDATE_WF.OUT_TRANSITIONS
  ( p_name                    => l_name
  , p_type                    => l_type
  , x_return_status           => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    X_return_status := l_return_status;
  END IF;
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  G_all_activity_tbl.DELETE;
  G_exit_from_loop := 'NO';
  oe_debug_pub.add('Calling Get_activities for Header from Validate Order Flow '||l_name,5);

    Get_Activities
    ( P_process              => l_name
    , P_process_item_type    => l_type
    , P_instance_label       => NULL
    , P_activity_item_type   => NULL
    );

    l_all_activity_tbl := G_all_activity_tbl;

    IF l_quick_val AND l_type = OE_GLOBALS.G_WFI_HDR THEN

      BEGIN
        SELECT DISTINCT process_name
        INTO   l_line_process_name
        FROM   oe_workflow_assignments
        WHERE  order_type_id = l_order_type_id
        AND    line_type_id IS NOT NULL
        AND    NVL(wf_item_type,'OEOL') = 'OEOL'
        AND    SYSDATE >= start_date_active
        AND    TRUNC(SYSDATE) <= nvl(end_date_active, SYSDATE)
        AND    ROWNUM = 1;

        G_all_activity_tbl.DELETE;
	G_exit_from_loop := 'NO';
        oe_debug_pub.add('Calling Get Activities for Lines in Validate Order Flow '||l_line_process_name,5);

        Get_Activities
        ( P_process              => l_line_process_name
        , P_process_item_type    => OE_GLOBALS.G_WFI_LIN
        , P_instance_label       => NULL
        , P_activity_item_type   => NULL
        );

        l_lin_activity_tbl := G_all_activity_tbl;

        IF l_lin_activity_tbl.COUNT > 0 THEN
	  FOR line_instance IN l_lin_activity_tbl.FIRST .. l_lin_activity_tbl.LAST LOOP
            IF l_lin_activity_tbl(line_instance).activity_name IN
	                    ('FULFILLMENT_CONT_H', 'INVOICING_WAIT_FOR_H','APPROVE_WAIT_FOR_H' /* Bug 6411686 */
			    ,'BOOK_WAIT_FOR_H', 'CLOSE_CONT_H') THEN
              oe_debug_pub.add('In VOF : For Act '||l_lin_activity_tbl(line_instance).activity_name,5);
	      oe_debug_pub.add('In VOF : For function '||l_lin_activity_tbl(line_instance).function,5);
              oe_debug_pub.add('In VOF : For Instance_id '||l_lin_activity_tbl(line_instance).instance_id,5);

              IF l_lin_activity_tbl(line_instance).function = 'WF_STANDARD.CONTINUEFLOW' THEN
                BEGIN
                  SELECT text_value
                  INTO   l_activity
                  FROM   wf_activity_attr_values waa
                  WHERE  waa.name = 'WAITING_ACTIVITY'
                  AND    process_activity_id = l_lin_activity_tbl(line_instance).instance_id;
                  -- The above sql determines the WAITING_ACTIVITY of the
                  -- passed activity with CONTINUEFLOW function
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_activity := NULL;
		    oe_debug_pub.add(' In No Data Found for WAITING_ACTIVITY',1);
                    NULL;
                   WHEN OTHERS THEN
	            oe_debug_pub.add('Validate_Order_flow WAITING ACTIVITY',1);
	            oe_debug_pub.add('Validate_Order_flow : Line_process : '||l_line_process_name,1);
	            oe_debug_pub.add('Validate_Order_flow : Activity Name : '||l_lin_activity_tbl(line_instance).instance_label,1);
	            oe_debug_pub.add('Validate_Order_flow : Error : '||sqlerrm,1);
		    NULL;
                END;

              ELSIF l_lin_activity_tbl(line_instance).function = 'WF_STANDARD.WAITFORFLOW' THEN
                BEGIN
                  SELECT text_value
                  INTO   l_activity
                  FROM   wf_activity_attr_values waa
                  WHERE  waa.name = 'CONTINUATION_ACTIVITY'
                  AND    process_activity_id = l_lin_activity_tbl(line_instance).instance_id;
                  -- The above sql determines the CONTINUATION_ACTIVITY of the
                  -- passed activity with WAITFORFLOW function
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    l_activity := NULL;
	  	    oe_debug_pub.add(' In No Data Found for CONTINUATION_ACTIVITY',1);
                    NULL;
                  WHEN OTHERS THEN
                    oe_debug_pub.add('Validate_Order_flow CONTINUATION_ACTIVITY',1);
      	            oe_debug_pub.add('Validate_Order_flow : Line_process : '||l_line_process_name,1);
 	            oe_debug_pub.add('Validate_Order_flow : Activity Name : '||l_lin_activity_tbl(line_instance).instance_label,1);
	            oe_debug_pub.add('Validate_Order_flow : Error : '||sqlerrm,1);
		    NULL;
                END;
  	      END IF;

              oe_debug_pub.add('In VOF : matching activity is '||l_activity,5);
	      matching_activity_exists := FALSE;
              IF l_activity IS NOT NULL THEN
                IF l_all_activity_tbl.COUNT > 0 THEN
                  FOR testing_inst IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
                    IF ( l_all_activity_tbl(testing_inst).activity_name = l_activity ) THEN
		      oe_debug_pub.add('In VOF : matching activity Exists '||l_all_activity_tbl(testing_inst).activity_name,5);
	              matching_activity_exists := TRUE;
	  	      EXIT;
		    END IF;
		  END LOOP;
		END IF;
              END IF;

	      IF (matching_activity_exists <> TRUE) THEN

	        oe_debug_pub.add('In VOF : matching activity do not Exists, logging message',1);
                FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_SYNC_MISS');
                FND_MESSAGE.SET_TOKEN('PROCESS1',Display_Name(l_name,OE_GLOBALS.G_WFI_HDR));
                FND_MESSAGE.SET_TOKEN('ACTIVITY1',l_activity);
                FND_MESSAGE.SET_TOKEN('ACTIVITY2',l_lin_activity_tbl(line_instance).activity_name);
                FND_MESSAGE.SET_TOKEN('PROCESS2',Display_Name(l_line_process_name,OE_GLOBALS.G_WFI_LIN));
                OE_MSG_PUB.Add;
		X_return_status := FND_API.G_RET_STS_ERROR;
	      END IF;
	    END IF;
	  END LOOP;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          l_line_process_name := NULL;
          NULL;
      END;

      IF l_all_activity_tbl.COUNT > 0 THEN
        FOR testing_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
          IF l_all_activity_tbl(testing_instance).activity_name IN
	                   ('FULFILLMENT_WAIT_FOR_L', 'INVOICING_CONT_L' /*, Commented for #6818912 'APPROVE_CONT_L' Bug 6411686 */ ,'BOOK_CONT_L', 'CLOSE_WAIT_FOR_L') THEN

            oe_debug_pub.add('In VOF : For Instance_Label '||l_all_activity_tbl(testing_instance).instance_label,5);
	    oe_debug_pub.add('In VOF : For function '||l_all_activity_tbl(testing_instance).function,5);
            oe_debug_pub.add('In VOF : For Instance_id '||l_all_activity_tbl(testing_instance).instance_id,5);

	    OE_VALIDATE_WF.CHECK_SYNC
            ( P_process           => l_name
            , P_process_item_type => l_type
            , p_order_type_id     => l_order_type_id
            , P_instance_label    => l_all_activity_tbl(testing_instance).instance_label
            , P_act_item_type     => OE_GLOBALS.G_WFI_HDR
            , P_function          => l_all_activity_tbl(testing_instance).function
            , P_type              => l_all_activity_tbl(testing_instance).type
            , P_instance_id       => l_all_activity_tbl(testing_instance).instance_id
            , x_return_status     => l_return_status
            );

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              X_return_status := l_return_status;
            END IF;
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;

	END LOOP; -- testing_instance
      END IF; -- l_all_activity_tbl.COUNT
    END IF; -- l_quick_val

    IF NOT l_quick_val THEN
      IF l_type = OE_GLOBALS.G_WFI_HDR THEN
        IF l_all_activity_tbl.COUNT > 0 THEN
          FOR instance_count IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
            IF l_all_activity_tbl(instance_count).function
                IN ('WF_STANDARD.CONTINUEFLOW', 'WF_STANDARD.WAITFORFLOW') THEN

              oe_debug_pub.add('In VOF : For Instance_Label '||l_all_activity_tbl(instance_count).instance_label,5);
	      oe_debug_pub.add('In VOF : For function '||l_all_activity_tbl(instance_count).function,5);
              oe_debug_pub.add('In VOF : For Instance_id '||l_all_activity_tbl(instance_count).instance_id,5);

	      OE_VALIDATE_WF.CHECK_SYNC
              ( P_process           => l_name
              , P_process_item_type => l_type
              , p_order_type_id     => l_order_type_id
              , P_instance_label    => l_all_activity_tbl(instance_count).instance_label
              , P_act_item_type     => l_all_activity_tbl(instance_count).activity_item_type
              , P_function          => l_all_activity_tbl(instance_count).function
              , P_type              => l_all_activity_tbl(instance_count).type
              , P_instance_id       => l_all_activity_tbl(instance_count).instance_id
              , x_return_status     => l_return_status
              );

	      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                X_return_status := l_return_status;
              END IF;
              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;
          END LOOP; -- instance_count
        END IF; -- l_all_activity_tbl.COUNT

        oe_debug_pub.add('In VOF : Calling Has_Activity for BOOK_ORDER',5);
        IF NOT OE_VALIDATE_WF.HAS_ACTIVITY
   	       ( p_process                    => l_name
	       , p_process_item_type          => l_type
	       , p_activity                   => 'BOOK_ORDER'
	       , p_activity_item_type         => OE_GLOBALS.G_WFI_HDR
	       ) THEN

          FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_MISSING_ACTIVITY');
          FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,l_type));
          FND_MESSAGE.SET_TOKEN('ACTIVITY_NAME','BOOK_ORDER');
          OE_MSG_PUB.Add;
          oe_debug_pub.add('LOG 22 : Added OE_WFVAL_MISSING_ACTIVITY',1);
        END IF;

        oe_debug_pub.add('In VOF : Calling Has_Activity for CLOSE_HEADER',5);
        IF NOT OE_VALIDATE_WF.HAS_ACTIVITY
               ( p_process                    => l_name
               , p_process_item_type          => l_type
               , p_activity                   => 'CLOSE_HEADER'
               , p_activity_item_type         => OE_GLOBALS.G_WFI_HDR
               ) THEN

          FND_MESSAGE.SET_NAME('ONT','OE_WFVAL_MISSING_ACTIVITY');
          FND_MESSAGE.SET_TOKEN('PROCESS_NAME',Display_Name(l_name,l_type));
          FND_MESSAGE.SET_TOKEN('ACTIVITY_NAME','CLOSE_HEADER');
          OE_MSG_PUB.Add;
          oe_debug_pub.add('LOG 23 : Added OE_WFVAL_MISSING_ACTIVITY',1);
        END IF;
      END IF; -- only for l_type = OE_GLOBALS.G_WFI_HDR

      -- All activities in process p_name assigned APIs
      -- wf_standard.defer or wf_standard.wait

      FOR l_instance IN l_all_activity_tbl.FIRST .. l_all_activity_tbl.LAST LOOP
        IF l_all_activity_tbl(l_instance).function= 'WF_STANDARD.DEFER'
          OR l_all_activity_tbl(l_instance).function = 'WF_STANDARD.WAIT'
          THEN

	  oe_debug_pub.add('In VOF : Calling Wait And Loops for instance_label '||l_all_activity_tbl(l_instance).instance_label,5);
	  oe_debug_pub.add('In VOF : Calling Wait And Loops for instance_id '||l_all_activity_tbl(l_instance).instance_id,5);

          OE_VALIDATE_WF.WAIT_AND_LOOPS
          ( P_process           => l_name
          , P_process_item_type => l_type
          , P_activity_id       => l_all_activity_tbl(l_instance).instance_id
          , P_activity_label    => l_all_activity_tbl(l_instance).instance_label
          , P_api               => l_all_activity_tbl(l_instance).function
          , x_return_status     => l_return_status
          );

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            X_return_status := l_return_status;
          END IF;
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        END IF; -- function = DEFER/WAIT
      END LOOP; -- l_instance

    END IF; -- NOT l_quick_val

  X_msg_count := OE_MSG_PUB.count_msg - l_msg_count;
  oe_debug_pub.add('In VOF : msg count : '||X_msg_count,5);
  IF x_msg_count > 0 THEN
    X_msg_data := OE_MSG_PUB.get(l_msg_count + 1);
  END IF;

  oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Validate_Order_flow', 1);
  -- l_end_time := dbms_utility.get_time;
  -- oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    oe_debug_pub.add('Error in Validate_Order_Flow : '||sqlerrm,5);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.CHECK_MSG_LEVEL(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'Validate');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Order_flow;

/*----------------------------------------------------------------
  Procedure Validate
  Validates all order/blanket header, negotiation and line
  workflow processes assigned to order type p_order_type_id.
  If p_order_type_id is NULL, runs the validation for all active
  order types.

  This program is called by:
  1. Validate OM Workflow (OEXVWF) concurrent program

  The program calls the following other programs:
  1. OE_VALIDATE_WF.validate_order_flow()
  2. OE_VALIDATE_WF.validate_line_flow()
------------------------------------------------------------------*/
PROCEDURE Validate
(  Errbuf	                      OUT NOCOPY VARCHAR2  -- AOL standard
,  retcode	                      OUT NOCOPY VARCHAR2  -- AOL standard
,  P_order_type_id                    IN NUMBER DEFAULT NULL
)
IS

-- Cursor Decleration
CURSOR c_all_process IS
  SELECT sales_document_type_code
       , transaction_type_id
       , transaction_type_code
       , order_category_code
       , start_date_active
       , end_date_active
  FROM   oe_transaction_types_vl
  WHERE  transaction_type_code  = 'ORDER'
  AND    SYSDATE >= start_date_active
  AND    TRUNC(SYSDATE) <= NVL(end_date_active, SYSDATE);

CURSOR c_line_item_process(c_type_id NUMBER) IS
  SELECT DISTINCT process_name, item_type_code
  FROM   oe_workflow_assignments
  WHERE  order_type_id = c_type_id
  AND    line_type_id IS NOT NULL
  AND    NVL(wf_item_type, 'OEOL') = 'OEOL'
  AND    SYSDATE >= start_date_active
  AND    TRUNC(SYSDATE) <= nvl(end_date_active, SYSDATE);

CURSOR c_line_process(c_type_id NUMBER) IS
  SELECT DISTINCT process_name
  FROM   oe_workflow_assignments
  WHERE  order_type_id = c_type_id
  AND    line_type_id IS NOT NULL
  AND    NVL(wf_item_type,'OEOL') = 'OEOL'
  AND    SYSDATE >= start_date_active
  AND    TRUNC(SYSDATE) <= nvl(end_date_active, SYSDATE);

CURSOR c_other_process(c_type_id NUMBER, c_item_type VARCHAR2) IS
  SELECT DISTINCT process_name
  FROM   oe_workflow_assignments
  WHERE  order_type_id = c_type_id
  AND    wf_item_type = c_item_type
  AND    SYSDATE >= start_date_active
  AND    TRUNC(SYSDATE) <= nvl(end_date_active, SYSDATE);

 -- Local Variable Decleration
 l_return_status               VARCHAR2(1);
 l_process_name                VARCHAR2(30);
 l_msg_data                    VARCHAR2(2000);
 l_msg_count                   NUMBER;
 l_header_process_index        NUMBER := 0;
 l_record_count                NUMBER := 0;
 l_order_type_id               NUMBER := NULL;
 l_validating_flow             VARCHAR2(100);
 l_transaction_rec c_all_process%ROWTYPE;
 TYPE l_order_types IS TABLE OF c_all_process%ROWTYPE
                                            INDEX BY BINARY_INTEGER;
 l_transaction_tbl l_order_types;
 l_start_time                  NUMBER;
 l_end_time                    NUMBER;
 l_msg_total                   NUMBER;

BEGIN
  oe_debug_pub.add('Entering Procedure OE_VALIDATE_WF.Validate', 1);
   -- l_start_time := dbms_utility.get_time;
  Retcode := 0;
  Errbuf := NULL;
  l_validating_flow := 'No Name Mentioned';

  IF p_order_type_id IS NOT NULL THEN

    -- Copying passed into locals
    l_order_type_id := p_order_type_id;

    SELECT sales_document_type_code
         , transaction_type_id
         , transaction_type_code
         , order_category_code
         , start_date_active
         , end_date_active
    INTO   l_transaction_tbl(1).sales_document_type_code
         , l_transaction_tbl(1).transaction_type_id
         , l_transaction_tbl(1).transaction_type_code
         , l_transaction_tbl(1).order_category_code
         , l_transaction_tbl(1).start_date_active
         , l_transaction_tbl(1).end_date_active
    FROM   oe_transaction_types_all
    WHERE  transaction_type_id = l_order_type_id;

  ELSE

    OPEN c_all_process;
    LOOP
    FETCH c_all_process
    INTO l_transaction_tbl(l_transaction_tbl.COUNT + 1);
    EXIT WHEN c_all_process%NOTFOUND;
    END LOOP;
    CLOSE c_all_process;
    -- Getting the entire cursor record in table type.

  END IF;  -- IF p_order_type_id

  FND_FILE.put_line(FND_FILE.output,'Please correct the following reported Errors/Warnings, if any -'); --, in the respective Order Types -'); Changed for bug 4438936
  IF l_transaction_tbl.COUNT > 0 THEN
    FOR l_record_count IN l_transaction_tbl.First .. l_transaction_tbl.Last LOOP

      OE_MSG_PUB.Initialize;
      l_msg_total := 0;

      BEGIN
        SELECT name
        INTO   l_validating_flow
        FROM oe_transaction_types_vl
        WHERE TRANSACTION_TYPE_ID = l_transaction_tbl(l_record_count).transaction_type_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      FND_FILE.put_line(FND_FILE.output,' ');
      FND_FILE.put_line(FND_FILE.output,'Validating Order Type : '||l_validating_flow||' ('||l_transaction_tbl(l_record_count).transaction_type_id||')');
      FND_FILE.put_line(FND_FILE.output,rpad('-',(27+length(l_validating_flow)+length(l_transaction_tbl(l_record_count).transaction_type_id)),'-'));

      oe_debug_pub.add(' ');
      oe_debug_pub.add('Validating Order Type : '||l_validating_flow||' ('||l_transaction_tbl(l_record_count).transaction_type_id||')');
      oe_debug_pub.add(rpad('-',(27+length(l_validating_flow)+length(l_transaction_tbl(l_record_count).transaction_type_id)),'-'));

      IF l_transaction_tbl(l_record_count).sales_document_type_code='O' THEN
        -- Uunconditionally for pre-11.5.10 releases)
        -- Getting associated order header() internal workflow process name
        -- from oe_workflow_assignments;

        BEGIN
          SELECT process_name
          INTO   l_process_name
          FROM   oe_workflow_assignments
          WHERE  order_type_id = l_transaction_tbl(l_record_count).transaction_type_id
          AND    line_type_id IS NULL
          AND    wf_item_type = 'OEOH'
          AND    SYSDATE >= start_date_active
          AND    TRUNC(SYSDATE) <= NVL(end_date_active, SYSDATE);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_process_name := NULL;
        END;

        IF l_process_name IS NOT NULL THEN

          OE_VALIDATE_WF.VALIDATE_ORDER_FLOW
          ( p_name          => l_process_name
          , p_order_type_id => l_transaction_tbl(l_record_count).transaction_type_id
          , p_type          => OE_GLOBALS.G_WFI_HDR
          , p_quick_val     => FALSE
          , x_return_status => l_return_status
          , x_msg_count     => l_msg_count
          , x_msg_data      => l_msg_data
          );

          l_msg_total := l_msg_total + l_msg_count;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          /* Selecting from oe_workflow_assignments distinct order line
             (OEOL) internal workflow process names and OM item type
             combinations assigned to this order type */

          FOR line_item_processes IN c_line_item_process(l_transaction_tbl(l_record_count).transaction_type_id) LOOP

            OE_VALIDATE_WF.LINE_FLOW_ASSIGNMENT
            ( p_name          => line_item_processes.process_name
            , p_item_type     => line_item_processes.item_type_code
            , x_return_status => l_return_status
            , x_msg_count     => l_msg_count
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP; -- line_item_processes
          /* Selecting from oe_workflow_assignments distinct order line
             (OEOL) internal workflow process names assigned to this
             order type */

          FOR line_processes IN c_line_process(l_transaction_tbl(l_record_count).transaction_type_id) LOOP
            OE_VALIDATE_WF.VALIDATE_LINE_FLOW
	    ( p_name          => line_processes.process_name
 	    , p_order_flow    => l_process_name
 	    , p_quick_val     => FALSE
 	    , x_return_status => l_return_status
 	    , x_msg_count     => l_msg_count
	    , x_msg_data      => l_msg_data
	    );

            l_msg_total := l_msg_total + l_msg_count;
   	    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END LOOP;  -- End Loop line_processes

        END IF;

      ELSIF l_transaction_tbl(l_record_count).sales_document_type_code='B' THEN
        -- not applicable to pre-11.5.10 releases
        -- Getting associated blanket header (OEBH) internal workflow
        -- process name from oe_workflow_assignments
        FOR blanket_processes IN c_other_process(l_transaction_tbl(l_record_count).transaction_type_id, OE_GLOBALS.G_WFI_BKT) LOOP

          OE_VALIDATE_WF.VALIDATE_ORDER_FLOW
  	  ( p_name          => blanket_processes.process_name
  	  , p_type          => OE_GLOBALS.G_WFI_BKT
	  , p_quick_val     => FALSE
	  , x_return_status => l_return_status
	  , x_msg_count     => l_msg_count
	  , x_msg_data      => l_msg_data
	  );

          l_msg_total := l_msg_total + l_msg_count;
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END LOOP;  -- End Loop blanket_processes
      END IF;  -- IF sales_document_type_code = 'O'/'B'

      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
        /* Applicable for Release 11.5.10 + only: Getting the associated
           negotiation header (OENH) internal workflow process name from
           oe_workflow_assignments; */
        FOR negotiation_processes IN c_other_process(l_transaction_tbl(l_record_count).transaction_type_id, OE_GLOBALS.G_WFI_NGO) LOOP

          OE_VALIDATE_WF.VALIDATE_ORDER_FLOW
          ( p_name          => negotiation_processes.process_name
          , p_type          => OE_GLOBALS.G_WFI_NGO
          , p_quick_val     => FALSE
          , x_return_status => l_return_status
          , x_msg_count     => l_msg_count
          , x_msg_data      => l_msg_data
          );

          l_msg_total := l_msg_total + l_msg_count;
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END LOOP;  -- End Loop negotiation_processes
      END IF; -- End of Applicable for Release 11.5.10 + only

      IF NVL(FND_PROFILE.VALUE('CONC_REQUEST_ID'), 0) <> 0 THEN
        -- Called from concurrent request */
        IF l_msg_total > 0 THEN
          FOR I IN 1 .. l_msg_total LOOP
            l_msg_data := to_char(I)||'. '||OE_MSG_PUB.Get(I,FND_API.G_FALSE);   -- #4617652
            FND_FILE.put_line(FND_FILE.output, l_msg_data);
            -- Writing validation messages into the concurrent
            -- request output file
          END LOOP;
        ELSE
          FND_FILE.put_line(FND_FILE.output,' << No Errors/Warnings Reported >>'); -- For bug 4438936
        END IF;
      END IF;

    END LOOP;  -- End Loop l_record_count
  END IF;

  oe_debug_pub.add('Exiting Procedure OE_VALIDATE_WF.Validate', 1);
  -- l_end_time := dbms_utility.get_time;
  --oe_debug_pub.add(' Time taken = '||l_end_time- l_start_time);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    retcode := 2;
    errbuf := 'Please check the log file for error messages';
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    retcode := 2;
    errbuf := 'Please check the log file for error messages';
  WHEN OTHERS THEN
    retcode := 2;
    errbuf := sqlerrm;

END Validate;

END OE_VALIDATE_WF; --Package Ends

/
