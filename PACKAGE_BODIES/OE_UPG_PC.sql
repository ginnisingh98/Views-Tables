--------------------------------------------------------
--  DDL for Package Body OE_UPG_PC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPG_PC" AS
/* $Header: OEXIUPCB.pls 120.0 2005/05/31 23:36:52 appldev noship $ */

TYPE condn_rec IS RECORD
   (validation_entity_id			NUMBER
   ,validation_tmplt_id			NUMBER
   );
TYPE condn_table IS TABLE of condn_rec INDEX BY BINARY_INTEGER;
TYPE scope_rec IS RECORD
   (validation_entity_id			NUMBER
   ,scope_op					VARCHAR2(3)
   ,record_set_id			NUMBER
   );
TYPE scope_table IS TABLE of scope_rec INDEX BY BINARY_INTEGER;

 PROCEDURE get_new_entity
	    (p_object_id			IN NUMBER
,x_entity_id OUT NOCOPY NUMBER

,x_condn_table OUT NOCOPY condn_table

	    )
    IS
    I		NUMBER := 1;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
    BEGIN

    -- Order Header
    IF p_object_id IN (10000,1000000) THEN
	    x_entity_id := 1;
    -- Order Line
    ELSIF p_object_id IN (20000,21000,30000,31000,40000,41000
			    ,50000,51000,1010000) THEN
	    x_entity_id := 2;
    -- Order Price Adjustment
    ELSIF p_object_id IN (11000,1001000) THEN
        x_entity_id := 6;
    -- Order Sales Credit
    ELSIF p_object_id IN (12000,1002000) THEN
	    x_entity_id := 5;
    -- Line Price Adjustment
    ELSIF p_object_id IN (22000,32000,42000,52000,1011000) THEN
	    x_entity_id := 8;
    -- Line Sales Credit
    ELSIF p_object_id IN (23000,43000,1012000) THEN
	    x_entity_id := 7;
    END IF;

    i := 1;
    -- Regular Order
    IF p_object_id IN (10000,11000,12000) THEN
	    x_condn_table(i).validation_entity_id := 1;
	    x_condn_table(i).validation_tmplt_id := 28;
	    i := i+1;
    END IF;
    -- Return Order
    IF p_object_id IN (1000000,1001000,1002000) THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 27;
	    i := i+1;
    END IF;
    -- Regular Line
    IF p_object_id IN (20000,21000,22000,23000,30000,31000,32000
		    ,40000,41000,42000,43000,50000,51000,52000) THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 29;
	    i := i+1;
    END IF;
    -- Return Line
    IF p_object_id IN (1010000,1011000,1012000) THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 12;
	    i := i+1;
    END IF;
    -- Option Line
    IF p_object_id IN (30000,31000,32000,50000,51000) THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 6;
	    i := i+1;
    END IF;

    END get_new_entity;

    PROCEDURE get_new_condn
	    (p_condition_code		IN VARCHAR2
,x_condn_table OUT NOCOPY condn_table

	    )
    IS
    i		NUMBER := 1;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
    BEGIN

    IF p_condition_code = 'ATO COMPONENT' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 18;
	    i := i+1;
    ELSIF p_condition_code = 'ATO CONFIGURATION ITEM' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 19;
	    i := i+1;
    ELSIF p_condition_code = 'ATO MODEL' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 20;
	    i := i+1;
    ELSIF p_condition_code = 'SCHEDULE GROUP' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 23;
	    i := i+1;
    ELSIF p_condition_code = 'SCHEDULING' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 21;
	    i := i+1;
    ELSIF p_condition_code = 'SUPPLY RESERVATION' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 22;
	    i := i+1;
    ELSIF p_condition_code = 'LINE CLOSED' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 4;
	    i := i+1;
	    /*
    ELSIF p_condition_code = 'PRORATED PRICES' THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 20;
	    i := i+1;
	    */
    ELSIF p_condition_code = 'ORDER CLOSED' THEN
	    x_condn_table(i).validation_entity_id := 1;
	    x_condn_table(i).validation_tmplt_id := 3;
	    i := i+1;
	    /*
    ELSIF p_condition_code = 'INTERNAL REQUISITION' THEN
	    x_condn_table(i).validation_entity_id := 1;
	    x_condn_table(i).validation_tmplt_id := 20;
	    i := i+1;
	    */
    END IF;

 END get_new_condn;

 PROCEDURE get_new_action
	    (p_action_id		     IN NUMBER
	    ,p_result_id			IN NUMBER
,x_condn_table OUT NOCOPY condn_table

	    )
    IS
    i				NUMBER := 1;
    l_vtmplt_id		NUMBER;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
    BEGIN

    -- Demand Interface: Demanded
    IF p_action_id = 12 and p_result_id = 14 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 24;
	    i := i+1;
    -- Order booked
    ELSIF p_action_id = 1 and p_result_id = 1 THEN
	    x_condn_table(i).validation_entity_id := 1;
	    x_condn_table(i).validation_tmplt_id := 1;
	    i := i+1;
    -- Purchase Release: Confirmed
    ELSIF p_action_id = 17 and p_result_id = 6 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 25;
	    i := i+1;
    -- Purchase Release: Interfaced
    ELSIF p_action_id = 17 and p_result_id = 14 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 26;
	    i := i+1;
    -- RMA Approval: Fail
    ELSIF p_action_id = 14 and p_result_id = 3 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 14;
	    i := i+1;
    -- RMA Approval: Pass
    ELSIF p_action_id = 14 and p_result_id = 2 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 13;
	    i := i+1;
    -- Cancel Order: Complete
    ELSIF p_action_id = 5 and p_result_id = 11 THEN
	    x_condn_table(i).validation_entity_id := 1;
	    x_condn_table(i).validation_tmplt_id := 30;
	    i := i+1;
    -- Cancel Line: Complete
    ELSIF p_action_id = 6 and p_result_id = 11 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 31;
	    i := i+1;
    -- Ship Confirm: Confirmed
    ELSIF p_action_id = 3 and p_result_id = 6 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 32;
	    i := i+1;
    -- Pick Release: Released
    ELSIF p_action_id = 2 and p_result_id = 4 THEN
	    x_condn_table(i).validation_entity_id := 2;
	    x_condn_table(i).validation_tmplt_id := 33;
	    i := i+1;
    -- Custom Actions
    ELSIF p_action_id > 1000 THEN

	   BEGIN
	    select validation_tmplt_id
	    into l_vtmplt_id
	    from oe_pc_vtmplts vt
	    where vt.validation_type = 'WF'
	      and vt.activity_name = 'UPG_AN_'||to_char(p_action_id)
	      and nvl(vt.activity_result_code,'NO_RESULT')
			= decode(p_result_id,NULL,'NO_RESULT',
					'UPG_RC_'||to_char(p_result_id));
	    x_condn_table(i).validation_entity_id := null;
	    x_condn_table(i).validation_tmplt_id := l_vtmplt_id;
	    i := i+1;
	    EXCEPTION
	    WHEN no_data_found THEN
		null;
	    END;

    END IF;

 END get_new_action;

 PROCEDURE populate_table
		    (p_old_object_id			IN NUMBER
		    ,p_condition_code		IN VARCHAR2
		    ,p_action_id			IN NUMBER
		    ,p_result_id			IN NUMBER
		    ,p_group_number			IN NUMBER
		    ,p_entity_id			IN NUMBER
		    ,p_condn_table			IN condn_table
		    )
    IS
    I			NUMBER;
    l_vtmplt_id	NUMBER;
    updated		BOOLEAN := FALSE;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
    BEGIN

	    SELECT vtmplt_id
	    INTO l_vtmplt_id
	    FROM oe_upgrade_pc_condns
	    WHERE condition_code = p_condition_code
         AND old_object_id = p_old_object_id
         AND NVL(action_id,FND_API.G_MISS_NUM) = NVL(p_action_id,FND_API.G_MISS_NUM)
         AND NVL(result_id,FND_API.G_MISS_NUM) = NVL(p_result_id,FND_API.G_MISS_NUM)
         AND rownum = 1;

		    IF l_vtmplt_id IS NOT NULL THEN
			    updated := TRUE;
		    END IF;

	         FOR I IN 1..p_condn_table.COUNT LOOP
			    IF NOT updated THEN
				UPDATE oe_upgrade_pc_condns
				SET new_entity_id = p_entity_id
				, validation_entity_id = nvl(p_condn_table(I).validation_entity_id
										,p_entity_id)
				, vtmplt_id = p_condn_table(I).validation_tmplt_id
				, group_number = p_group_number
				WHERE old_object_id = p_old_object_id
				AND NVL(action_id,FND_API.G_MISS_NUM)
						= NVL(p_action_id,FND_API.G_MISS_NUM)
				AND NVL(result_id,FND_API.G_MISS_NUM)
						= NVL(p_result_id,FND_API.G_MISS_NUM)
				AND condition_code = p_condition_code;
				updated := TRUE;
			ELSE
				INSERT INTO oe_upgrade_pc_condns
				(condition_code
				,vtmplt_id
				,OLD_OBJECT_ID
				,ACTION_ID
				,RESULT_ID
				,NEW_ENTITY_ID
				,GROUP_NUMBER
				,VALIDATION_ENTITY_ID
				,USER_MESSAGE
				)
				VALUES
				(p_condition_code
				,p_condn_table(I).validation_tmplt_id
				,p_old_object_id
				,p_action_id
				,p_result_id
				,p_entity_id
				,p_group_number
				,p_condn_table(I).validation_entity_id
				,NULL);
			END IF;
		END LOOP;

  END populate_table;

  PROCEDURE Upgrade_insert_condns IS
     CURSOR old_condns IS
       SELECT distinct OLD_OBJECT_ID, CONDITION_CODE, ACTION_ID, RESULT_ID
       FROM oe_upgrade_pc_condns
       ORDER BY OLD_OBJECT_ID, CONDITION_CODE, ACTION_ID, RESULT_ID;
     l_condn_table			condn_table;
	l_entity_condn_table	condn_table;
     l_entity_id			NUMBER;
     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
  BEGIN

          -- set all the columns in R11i to null
	     update oe_upgrade_pc_condns
	     set vtmplt_id = null
		     , new_entity_id = null
		     , validation_entity_id = null
		     , group_number = null;

	     -- restore the table such that it contains rows only for
	     -- columns in R11 that need to be upgraded. This will delete
	     -- duplicate rows for the old conditions that may have been
	     -- created when this data was populated previously using
	     -- this script
          delete from oe_upgrade_pc_condns
	     where rowid not in (
		     select min(rowid) from oe_upgrade_pc_condns
		     group by old_object_id, condition_code, action_id, result_id
					     ) ;


	     FOR c IN old_condns LOOP

		     -- get the new validation templates for the old conditions
		     -- if condition was based on cycle action
		     IF c.action_id IS NOT NULL THEN
			     get_new_action(c.action_id
					     ,c.result_id
					     ,l_condn_table);
		     -- if condition was based on a hardcoded condition
		     ELSE
			     get_new_condn(c.condition_code
					     ,l_condn_table);

		     END IF;

			-- Map condition only if new condition exists
		     IF l_condn_table.COUNT > 0 THEN

			     -- Check if the old entity is transformed to a condition
			     -- on another entity in R11i
		           get_new_entity(c.old_object_id
				     ,l_entity_id
				     ,l_entity_condn_table);

			     -- Add condition for entity
		           populate_table(c.old_object_id
					     ,c.condition_code
					     ,c.action_id
					     ,c.result_id
					     ,1
					     ,l_entity_id
					     ,l_entity_condn_table);

			     -- Populate the table for the new condition
		          populate_table(c.old_object_id
					     ,c.condition_code
					     ,c.action_id
					     ,c.result_id
					     ,1
					     ,l_entity_id
					     ,l_condn_table);

		     END IF;

	     END LOOP;

  END Upgrade_insert_condns;

  PROCEDURE get_new_scope
	     (p_scope_code		IN VARCHAR2
		,p_object_id		IN NUMBER
,x_scope_table OUT NOCOPY scope_table

	     )
     IS
     I	NUMBER := 1;
     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
     BEGIN

	IF p_scope_code = 'NO_SCOPE' THEN
       IF p_object_id IN (10000,1000000) THEN
	     x_scope_table(I).scope_op := 'ANY';
	     x_scope_table(I).validation_entity_id := 1;
	     x_scope_table(I).record_set_id := 1;
       ELSIF p_object_id IN (20000,21000,30000,31000,40000,41000
			    ,50000,51000,1010000) THEN
	     x_scope_table(I).scope_op := 'ANY';
	     x_scope_table(I).validation_entity_id := 2;
	     x_scope_table(I).record_set_id := 2;
	  END IF;
     ELSIF p_scope_code = 'ORDER' THEN
	     x_scope_table(I).scope_op := 'ANY';
	     x_scope_table(I).validation_entity_id := 1;
	     x_scope_table(I).record_set_id := 1;
     ELSIF p_scope_code = 'LINE' THEN
	     x_scope_table(I).scope_op := 'ANY';
	     x_scope_table(I).validation_entity_id := 2;
	     x_scope_table(I).record_set_id := 2;
     ELSIF p_scope_code = 'ATO CONFIGURATION' THEN
	     x_scope_table(I).scope_op := 'ANY';
	     x_scope_table(I).validation_entity_id := 2;
	     x_scope_table(I).record_set_id := 3;
     ELSIF p_scope_code = 'CONFIGURATION' THEN
	     x_scope_table(I).scope_op := 'ANY';
	     x_scope_table(I).validation_entity_id := 2;
	     x_scope_table(I).record_set_id := 4;
     ELSIF p_scope_code = 'SHIP SET' THEN
	     x_scope_table(I).scope_op := 'ANY';
	     x_scope_table(I).validation_entity_id := 2;
	     x_scope_table(I).record_set_id := 5;
     END IF;

  END get_new_scope;

  PROCEDURE Upgrade_insert_scope IS
     CURSOR old_scope IS
       SELECT distinct SCOPE_CODE, old_object_id
       FROM oe_upgrade_pc_scope
       ORDER BY SCOPE_CODE;
     l_scope_table		scope_table;
     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
     BEGIN

      FOR S IN old_scope LOOP

	     get_new_scope(s.scope_code
					,s.old_object_id
				     ,l_scope_table);

	     IF l_scope_table.COUNT > 0 THEN
	     UPDATE oe_upgrade_pc_scope
	     SET scope_op = l_scope_table(1).scope_op
	     , record_set_id = l_scope_table(1).record_set_id
	     , new_entity_id = l_scope_table(1).validation_entity_id
	     WHERE scope_code = s.scope_code
		  AND old_object_id = s.old_object_id;
	     END IF;

      END LOOP;

  END Upgrade_insert_scope;

END oe_upg_pc;

/
