--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_POSITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_POSITION_PVT" AS
/* $Header: PSBVMBPB.pls 120.3.12010000.3 2009/02/26 12:17:16 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30 ):=  'PSB_Budget_Position_Pvt';


/*-------------------- Global variables and declarations --------------------*/

  -- The flag determines whether to print debug information or not.
  g_debug_flag           VARCHAR2(1) := 'N' ;

  -- Record type to store a position_set_line and a position.
  TYPE position_rec_type IS RECORD
			 (  line_sequence_id NUMBER,
			    position_id      NUMBER
			    );

  -- Table type to store position_set_lines and positions for a position set.
  TYPE position_set_tbl_type IS TABLE OF position_rec_type
       INDEX BY BINARY_INTEGER;

  -- Global Table to store position_set_lines and positions for a position set.
  l_position_set_tbl           position_set_tbl_type ;

  -- Table type to store positions.
  TYPE position_tbl_type IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  -- To store current position set id.
  g_position_set_id
		   psb_account_position_sets.account_position_set_id%TYPE;

  --
  -- WHO columns variables
  --
  g_current_date           DATE   := sysdate                     ;
  g_current_user_id        NUMBER := NVL(Fnd_Global.User_Id , 0) ;
  g_current_login_id       NUMBER := NVL(Fnd_Global.Login_Id, 0) ;

/*----------------------- End Private variables -----------------------------*/



/* ---------------------- Private Routine prototypes  -----------------------*/

     PROCEDURE Init;
     --
     FUNCTION Populate_Budget_Position_Set
	      (
		 p_position_set_id           IN  NUMBER  ,
		 p_attribute_selection_type  IN  VARCHAR2
	       )
	      RETURN BOOLEAN ;

     PROCEDURE  pd
	      (
		 p_message                   IN  VARCHAR2
	       ) ;

/* ------------------ End Private Routines prototypes  ----------------------*/



/*===========================================================================+
 |                     PROCEDURE Populate_Budget_Positions                   |
 +===========================================================================*/
--
-- The Public API to maintain positions for position sets.
--
PROCEDURE Populate_Budget_Positions
(
  p_api_version       IN       NUMBER ,
  p_init_msg_list     IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit            IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level  IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status     OUT  NOCOPY      VARCHAR2 ,
  p_msg_count         OUT  NOCOPY      NUMBER ,
  p_msg_data          OUT  NOCOPY      VARCHAR2 ,
  --
  p_position_set_id   IN  psb_account_position_sets.account_position_set_id%TYPE
			  := FND_API.G_MISS_NUM ,

  p_data_extract_id   IN  psb_data_extracts.data_extract_id%TYPE
			  := FND_API.G_MISS_NUM
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Populate_Budget_Positions';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_attribute_selection_type
		     psb_account_position_sets.attribute_selection_type%TYPE ;
  l_data_extract_id  psb_data_extracts.data_extract_id%TYPE ;
  --
BEGIN
  --
  SAVEPOINT Populate_Budget_Positions_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- As FND_API.G_MISS_NUM is bigger than NUMBERR(15), now using a local
  -- variable to fis the bug #655442.
  --
  IF p_data_extract_id = FND_API.G_MISS_NUM THEN
    l_data_extract_id := NULL;
  ELSE
    l_data_extract_id := p_data_extract_id ;
  END IF;

  IF ( p_position_set_id = FND_API.G_MISS_NUM ) OR ( p_position_set_id IS NULL)
  THEN
    --
    -- As no parameter is supplied, we have to populate all the position
    -- sets in psb_account_position_sets table.
    --
    FOR l_set_rec IN
    (
      SELECT account_position_set_id ,
	     attribute_selection_type
      FROM   psb_account_position_sets
      WHERE  account_or_position_type = 'P'
      AND    data_extract_id = NVL( l_data_extract_id, data_extract_id )
    )
    LOOP
      --
      -- Perform initilization. To be done for each position set.
      --
      Init;

      --
      -- Call the Populate_Budget_Position_Set routine for each position set.
      --
      IF Populate_Budget_Position_Set
	 (
	    l_set_rec.account_position_set_id  ,
	    l_set_rec.attribute_selection_type
	 )
      THEN

    fnd_file.put_line(fnd_file.LOG,'Processed Account Position set::'||
                   l_set_rec.account_position_set_id||' for attribute selection type::'||
                   l_set_rec.attribute_selection_type); --6145715
	--
	-- The concurrent program is the only one which calls  the API
	-- without any argument. We need to release lock as soon as an
	-- position set is exploded. Committing will also ensure that
	-- rollback segments do not go out of bounds.
	--
	COMMIT WORK;
	--
	-- Re-establish the savepoint after the commit.
	SAVEPOINT Populate_Budget_Positions_Pvt ;
	--
      ELSE

    fnd_file.put_line(fnd_file.LOG,'Unexpected Error due to Account position set::'||
                      l_set_rec.account_position_set_id);--6145715
	--
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	--
      END IF;
      --
    END LOOP;
    --
  ELSE
    --
    -- Only the passed position set will be populated.
    -- Perform initilization for this set.
    --
    Init;

   fnd_file.put_line(fnd_file.LOG,'Processing the account position set passed::'||
                     p_position_set_id);--6145715
    --
    -- Find attribute_selection_type for the given set.
    --
    SELECT attribute_selection_type INTO l_attribute_selection_type
    FROM   psb_account_position_sets
    WHERE  account_position_set_id = p_position_set_id ;

    --
    -- Call Populate_Budget_Position_Set only for the given position set.
    --
    IF NOT Populate_Budget_Position_Set
	   (
	      p_position_set_id          ,
	      l_attribute_selection_type
	   )
    THEN
      fnd_file.put_line(fnd_file.LOG,'Exception due to the account position set passed::'||
                        p_position_set_id);--6145715
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
  END IF;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Populate_Budget_Positions_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Populate_Budget_Positions_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Populate_Budget_Positions_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
END Populate_Budget_Positions ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                    PROCEDURE Add_Position_To_Position_Sets                |
 +===========================================================================*/
--
-- This API finds all the position sets a position belongs to, and the adds
-- this information in psb_budget_positions table.
--
PROCEDURE Add_Position_To_Position_Sets
(
  p_api_version         IN    NUMBER ,
  p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE ,
  p_commit              IN    VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status       OUT  NOCOPY   VARCHAR2 ,
  p_msg_count           OUT  NOCOPY   NUMBER   ,
  p_msg_data            OUT  NOCOPY   VARCHAR2 ,
  --
  p_position_id         IN    psb_positions.position_id%TYPE,
  p_worksheet_id        IN    NUMBER,
  p_data_extract_id     IN    psb_data_extracts.data_extract_id%TYPE
)
IS
  --
  l_api_name             CONSTANT VARCHAR2(30):='Add_Position_To_Position_Sets';
  l_api_version          CONSTANT NUMBER      :=  1.0;
  --
  l_data_extract_id             psb_positions.data_extract_id%TYPE ;
--  l_business_group_id           psb_positions.data_extract_id%TYPE ;
--  l_match_found_in_set_flag     VARCHAR2(1) ;
--  l_matching_attributes_count   NUMBER ;
  --
  -- bug #5450510
  -- following variables defined to be used as bind parameters in sql
  l_account_or_position_type
    psb_account_position_sets.account_or_position_type%TYPE;
  l_attribute_selection_type_all
    psb_account_position_sets.attribute_selection_type%TYPE;
  l_attribute_selection_type_one
    psb_account_position_sets.attribute_selection_type%TYPE;
  l_assignment_type_attribute psb_position_assignments.assignment_type%TYPE;

BEGIN
  --
  SAVEPOINT Add_Position_To_Pos_Sets_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  /*Bug:5940448:start*/
   BEGIN

    delete from psb_budget_positions
    where position_id = p_position_id
    and   data_extract_id = p_data_extract_id;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     NULL;
   WHEN OTHERS THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
  /*Bug:5940448:end*/

  -- Start bug #5450510
  -- The sql populates psb_budget_positions with positions that belong to
  -- a given account/position set.
  -- For a given position we start with data extract id, from
  -- psb_account_position_sets table. We get all the account/position set
  -- for the data extract. Next we join with psb_account_position_set_lines
  -- to get all the set lines that belong to each set. Here on wards we join
  -- with tables psb_position_set_line_values and psb_position_assignments.
  -- Its the psb_position_assignments table where in we join with the input
  -- position_id, this is how positions and account/position sets are related.

  -- The following sql would take care of account/position sets with
  -- attribute_selection_type = 'O' (match at least one)

  l_account_or_position_type := 'P';
  l_attribute_selection_type_all := 'A';
  l_attribute_selection_type_one := 'O';
  l_assignment_type_attribute := 'ATTRIBUTE';

  INSERT INTO psb_budget_positions
  ( account_position_set_id,
    position_id,
    data_extract_id,
    business_group_id,
    last_update_date,
    last_update_login,
    last_updated_by,
    created_by,
    creation_date
  )
  /*bug:5933994:added distinct clause*/
  SELECT DISTINCT acc_pos_sets.account_position_set_id,
         pos_asgn.position_id,
         acc_pos_sets.data_extract_id,
         acc_pos_sets.business_group_id,
         g_current_date,
         g_current_login_id,
         g_current_user_id,
         g_current_user_id,
         g_current_date
  FROM psb_position_assignments pos_asgn,
       psb_position_set_line_values pos_slv,
       psb_account_position_set_lines pos_sl,
       psb_account_position_sets acc_pos_sets
  WHERE pos_asgn.position_id = p_position_id
  AND pos_slv.line_sequence_id = pos_sl.line_sequence_id
  AND pos_asgn.attribute_id = pos_sl.attribute_id
  AND pos_asgn.assignment_type = l_assignment_type_attribute
  AND pos_sl.account_position_set_id = acc_pos_sets.account_position_set_id
  AND acc_pos_sets.account_or_position_type = l_account_or_position_type
  AND acc_pos_sets.attribute_selection_type = l_attribute_selection_type_one
  AND acc_pos_sets.data_extract_id = p_data_extract_id
  AND (pos_asgn.attribute_value_id = pos_slv.attribute_value_id
       OR pos_asgn.attribute_value    = pos_slv.attribute_value)
  AND (pos_asgn.worksheet_id = p_worksheet_id
      OR (worksheet_id IS NULL
      AND NOT EXISTS
      ( SELECT 1
        FROM psb_position_assignments
        WHERE worksheet_id = p_worksheet_id
        AND attribute_id = pos_asgn.attribute_id
        AND position_id  = pos_asgn.position_id)))
  AND NOT EXISTS
      ( SELECT '1'
        FROM psb_budget_positions
        WHERE account_position_set_id = acc_pos_sets.account_position_set_id
        AND position_id  = p_position_id);

  -- The following sql would take care of account/position sets with
  -- attribute_selection_type = 'A' (match all)

  -- In the following query we have defined two sub queries. The first
  -- one would return the number of mattaching attributes for a given
  -- data extract, position, and account/position set. The second query
  -- would return the the total number of attributes that belong to the
  -- account/position set. And then we compare the count of matching
  -- attribute to the total number of attributes to see if all match
  -- condition is met.


  INSERT INTO psb_budget_positions
  ( account_position_set_id,
    position_id,
    data_extract_id,
    business_group_id,
    last_update_date,
    last_update_login,
    last_updated_by,
    created_by,
    creation_date
  )
  /*bug:5933994:added distinct clause*/
  SELECT DISTINCT matched_attr.account_position_set_id,
         matched_attr.position_id,
         matched_attr.data_extract_id,
         matched_attr.business_group_id,
         g_current_date,
         g_current_login_id,
         g_current_user_id,
         g_current_user_id,
         g_current_date
  FROM
  ( SELECT acc_pos_sets.account_position_set_id,
           p_position_id position_id,
           acc_pos_sets.data_extract_id,
           acc_pos_sets.business_group_id,
           count(*) matching_attr_count
    FROM psb_position_set_line_values pos_slv,
         psb_account_position_set_lines pos_sl,
         psb_account_position_sets acc_pos_sets
    WHERE pos_slv.line_sequence_id = pos_sl.line_sequence_id
    AND pos_sl.account_position_set_id = acc_pos_sets.account_position_set_id
    AND acc_pos_sets.account_or_position_type = l_account_or_position_type
    AND acc_pos_sets.data_extract_id = p_data_extract_id
    AND acc_pos_sets.attribute_selection_type = l_attribute_selection_type_all
    AND EXISTS
    ( SELECT 1
      FROM psb_position_assignments pos_asgn
      WHERE pos_asgn.position_id = p_position_id
      AND pos_asgn.assignment_type = l_assignment_type_attribute
      AND pos_asgn.attribute_id = pos_sl.attribute_id
      AND (pos_asgn.attribute_value_id = pos_slv.attribute_value_id
           OR pos_asgn.attribute_value = pos_slv.attribute_value)
      AND (pos_asgn.WORKSHEET_ID = p_worksheet_id
      OR (pos_asgn.WORKSHEET_ID IS NULL
          AND NOT EXISTS
          ( SELECT 1
            FROM psb_position_assignments
            WHERE worksheet_id = p_worksheet_id
            AND attribute_id = pos_asgn.attribute_id
            AND position_id  = pos_asgn.position_id))))
      GROUP BY acc_pos_sets.account_position_set_id,
               acc_pos_sets.data_extract_id,
               acc_pos_sets.business_group_id
  ) matched_attr,
  ( SELECT acc_pos_sets.account_position_set_id,
           count(*)  total_attr_count
    FROM psb_account_position_set_lines pos_sl,
         psb_account_position_sets acc_pos_sets
    WHERE pos_sl.account_position_set_id = acc_pos_sets.account_position_set_id
    AND acc_pos_sets.account_or_position_type = l_account_or_position_type
    AND acc_pos_sets.data_extract_id = p_data_extract_id
    AND acc_pos_sets.attribute_selection_type = l_attribute_selection_type_all
    GROUP BY acc_pos_sets.account_position_set_id
  ) total_attr
  WHERE matched_attr.account_position_set_id = total_attr.account_position_set_id
  AND matching_attr_count = total_attr_count
  AND NOT EXISTS
  ( SELECT '1'
    FROM psb_budget_positions
    WHERE account_position_set_id = matched_attr.account_position_set_id
    AND position_id  = p_position_id);


  -- End bug #5450510

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --

  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Add_Position_To_Pos_Sets_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Add_Position_To_Pos_Sets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Add_Position_To_Pos_Sets_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
END Add_Position_To_Position_Sets ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                     PROCEDURE Init (Private)                              |
 +===========================================================================*/
--
-- Private procedure to perform variable initilization.
--
PROCEDURE Init
IS
--
BEGIN
  --
  -- Re-initialize dates as the concurrent program may be run for days.
  --
  g_current_date := sysdate ;

END Init;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |            FUNCTION  Populate_Budget_Position_Set (Private)               |
 +===========================================================================*/
--
-- This Private function is to populate a given position set.
--
FUNCTION Populate_Budget_Position_Set
(
   p_position_set_id           IN  NUMBER   ,
   p_attribute_selection_type  IN  VARCHAR2
)
RETURN BOOLEAN
--
IS

  -- Table to store position_set_lines and positions for a position set.
  l_position_set_tbl                    position_set_tbl_type ;
  --
  l_data_extract_id                     NUMBER ;
  l_business_group_id                   NUMBER ;
  --
  l_attribute_value_id                  NUMBER ;
  l_attribute_value                     VARCHAR2(2000) ;
  --
  l_first_line_sequence_id              NUMBER ;
  l_second_set_line_index               NUMBER ;
  l_position_set_tbl_index              NUMBER ;
  --
  l_position_input_tbl                  position_tbl_type ;
  l_input_tbl_index                     NUMBER ;
  l_position_output_tbl                 position_tbl_type ;
  l_output_tbl_index                    NUMBER ;
  --
  l_position_exists_in_line_flag        VARCHAR2(1);
  l_position_exists_in_set_flag         VARCHAR2(1);
  l_current_position_id                 NUMBER ;
  l_current_set_line_id                 NUMBER ;
  l_position_set_index                  NUMBER ;
  l_tmp_index                           NUMBER ;
  l_count_set_line_positions            NUMBER ;
  l_tmp_count                           NUMBER ;
  --
  l_last_maintained_date                DATE;
  l_last_update_date                    DATE;
  --
BEGIN

  pd('The current set ' || p_position_set_id);


  -- Populate the global variable.
  g_position_set_id := p_position_set_id;

  -- Get various information for the position set.
  SELECT data_extract_id   ,
	 business_group_id
    INTO
	 l_data_extract_id ,
	 l_business_group_id
  FROM   psb_account_position_sets
  WHERE  account_position_set_id = p_position_set_id ;

  --
  -- Lock psb_account_position_sets table to prevent modifications.
  -- Also set maintain_status to 'C' so that database trigger wont fire.
  --
  UPDATE psb_account_position_sets
  SET    maintain_status = 'C'
  WHERE  account_position_set_id = p_position_set_id ;

  --
  -- Delete from psb_budget_positions. You must delete as everytime you run
  -- the program, some positions may have been created, modified or deleted.
  --
  DELETE psb_budget_positions
  WHERE  account_position_set_id = p_position_set_id ;


  -- Reset the table.
  l_position_set_tbl_index := 0 ;
  l_position_set_tbl.DELETE ;

  pd('DE ' || l_data_extract_id );

  --
  -- Get set_lines info for the given position set.
  --
  --
  FOR l_set_line_rec IN
  (
     SELECT line_sequence_id             ,
	    attribute_id                 ,
	    attribute_value_table_flag
     FROM   psb_acct_position_set_lines_v  lines
     WHERE  account_position_set_id = p_position_set_id
     ORDER  BY lines.line_sequence_id
  )
  LOOP

    --
    -- Reset variable. This variable stores total number of positions in
    -- the current set_line.
    --
    l_count_set_line_positions := 0 ;

    -- Check whether the attribute has been assigned values or not.
    SELECT COUNT(*) INTO l_tmp_count
    FROM   psb_position_set_line_values
    WHERE  line_sequence_id = l_set_line_rec.line_sequence_id ;

    IF l_tmp_count = 0 THEN

      --
      -- It means the attribute has not been assigned any values.  We will
      -- consider all the positions which are not associated with the attribute.
      -- Because it is like the positions are assigned the attribute with a
      -- null value. ( See details in the enhancement bug#661975.)
      --
      pd('Set Line attribute_id : ' ||  l_set_line_rec.attribute_id) ;

      FOR l_position_rec IN
      (
	 SELECT position_id
	 FROM   psb_positions
	 WHERE  data_extract_id = l_data_extract_id
	 MINUS
	 SELECT position_id
	 FROM   psb_position_assignments
	 WHERE  data_extract_id = l_data_extract_id
	 AND    attribute_id = l_set_line_rec.attribute_id
      )
      LOOP

	pd('Pos without attr assignment ' || l_position_rec.position_id );

	--
	l_count_set_line_positions := l_count_set_line_positions + 1 ;
	--
	l_position_set_tbl_index   := l_position_set_tbl_index + 1 ;
	--
	l_position_set_tbl(l_position_set_tbl_index).line_sequence_id :=
					    l_set_line_rec.line_sequence_id ;
	--
	l_position_set_tbl(l_position_set_tbl_index).position_id :=
					  l_position_rec.position_id ;
	--
      END LOOP;
      --

    ELSE

      --
      -- The attribute has been assigned values. We will pick up positions
      -- having the corresponding assignments.
      --
      FOR l_val_rec IN
      (
	 SELECT attribute_value_id  ,
		attribute_value
	 FROM   psb_position_set_line_values   vals
	 WHERE  line_sequence_id = l_set_line_rec.line_sequence_id
      )
      LOOP

	l_attribute_value_id := l_val_rec.attribute_value_id ;
	l_attribute_value    := l_val_rec.attribute_value    ;

	pd('Line Val Id ' || l_val_rec.attribute_value_id );
	pd('Line Val    ' || l_val_rec.attribute_value )   ;
	pd('Att id '      || l_set_line_rec.attribute_id );
	pd('Line id to put in main table:' || l_set_line_rec.line_sequence_id );

	--
	-- Find all the matching positions for the attribute values.
	-- ( Consider only base positions.)
	--
	FOR l_position_rec IN
	(
	   SELECT position_id
	   FROM   psb_position_assignments
	   WHERE  attribute_id    = l_set_line_rec.attribute_id
	   AND    data_extract_id = l_data_extract_id
	   AND    ( attribute_value_id = l_attribute_value_id
		    OR
		    attribute_value    = l_attribute_value
		   )
	)
	LOOP

	  pd('Pos ' || l_position_rec.position_id );

	  --
	  l_count_set_line_positions := l_count_set_line_positions + 1 ;
	  --
	  l_position_set_tbl_index   := l_position_set_tbl_index + 1 ;
	  --
	  l_position_set_tbl(l_position_set_tbl_index).line_sequence_id :=
					      l_set_line_rec.line_sequence_id ;
	  --
	  l_position_set_tbl(l_position_set_tbl_index).position_id :=
					    l_position_rec.position_id ;
	  --
	END LOOP;  /* To get matching positions for the current attribute_value
		    or attribute_value_id in the current set_line */

      END LOOP;  /* To get attribute values for the current set_line */

    END IF ;

    --
    -- If attribute selection type is 'A', we select only those positions
    -- which are present in each set line. The following condition states
    -- the intersection of positions in all the set_line will be null.
    --
    IF l_count_set_line_positions = 0 AND p_attribute_selection_type = 'A'
    THEN

      pd('Found a set_line with no positions');

      RETURN (TRUE);

    END IF ;

  END LOOP ; /* To get all the set_lines for the position set */


  pd('---------------------');
  pd('Sel Type ' || p_attribute_selection_type );


  --
  -- Process the l_position_set_tbl table as per the Attribute Selection
  -- method defined for the set.
  --

  IF p_attribute_selection_type = 'O' THEN
    --
    -- The p_attribute_selection_type 'O' means pick up all the positions
    -- matching at least one criteria. That means take union of positions
    -- in l_position_set_tbl table.
    --
    FOR i IN 1..l_position_set_tbl.COUNT
    LOOP
      --
      INSERT INTO psb_budget_positions
		  (
		     account_position_set_id         ,
		     position_id                     ,
		     data_extract_id                 ,
		     business_group_id               ,
		     last_update_date                ,
		     last_update_login               ,
		     last_updated_by                 ,
		     created_by                      ,
		     creation_date
		  )
	    SELECT   g_position_set_id                   ,
		     l_position_set_tbl(i).position_id   ,
		     l_data_extract_id                   ,
		     l_business_group_id                 ,
		     g_current_date                      ,
		     g_current_login_id                  ,
		     g_current_user_id                   ,
		     g_current_user_id                   ,
		     g_current_date
	    FROM     dual
	    WHERE    NOT EXISTS
		     (  SELECT '1'
			FROM   psb_budget_positions
			WHERE  account_position_set_id = g_position_set_id
			AND    position_id             =
					 l_position_set_tbl(i).position_id
		     ) ;
      --
    END LOOP;
    --
  ELSIF p_attribute_selection_type = 'A' THEN
    --
    -- The p_attribute_selection_type 'A' means pick up only those positions
    -- matching all the criteria. That means take intersection of positions
    -- in l_position_set_tbl table with respect to a set line.
    --

    --
    -- Find all the positions in the first set_line.
    --

    IF l_position_set_tbl.EXISTS(1) THEN
      l_first_line_sequence_id := l_position_set_tbl(1).line_sequence_id ;
    ELSE
      -- No set lines found. No assignments can be made.
      RETURN (TRUE) ;
    END IF;

    -- Reset table which stores all the positions found in l_position_set_tbl.
    l_input_tbl_index := 0 ;
    l_position_input_tbl.DELETE  ;

    --
    -- Finding all the positions in the very first set_line ( To implement
    -- intersection of positions in all the set_lines. )
    --
    FOR i IN 1..l_position_set_tbl.COUNT
    LOOP
      --
      IF l_position_set_tbl(i).line_sequence_id <> l_first_line_sequence_id
      THEN
	EXIT;
      ELSE
	l_input_tbl_index := l_input_tbl_index + 1 ;
	l_position_input_tbl(i) := l_position_set_tbl(i).position_id ;

	pd('Line:' || l_position_set_tbl(i).line_sequence_id ||
	   ' Pos:' || l_position_input_tbl(i) );

      END IF ;
      --
    END LOOP ;

    --
    -- Set variable which points to second line in l_position_set_tbl table.
    -- ( It may not exists though and that check it there.
    --
    l_second_set_line_index := l_input_tbl_index + 1 ;

    -- Reset table which stores positions found in all the set lines.
    l_output_tbl_index := 0 ;
    l_position_output_tbl.DELETE  ;

    --
    -- Process each position in l_input_tbl_index table and find whether
    -- the position is present in each set_line or not. Of course we will
    -- start from second set_line pointed to by l_position_set_index.
    --
    FOR i IN 1..l_position_input_tbl.COUNT
    LOOP   /* To process all the position in l_position_input_tbl */

      --
      -- Reset l_position_set_index so that it points to second set line
      -- in l_position_set_tbl table. We do it for each position.
      --
      l_position_set_index := l_second_set_line_index ;


      pd('Proc l_position_input_tbl Pos :' || l_position_input_tbl(i));

      -- Store the position being processed.
      l_current_position_id := l_position_input_tbl(i) ;

      -- Flag specifies whether the current position exist in all the lines
      -- ( hence set ) or not.
      l_position_exists_in_set_flag := 'Y' ;

      LOOP   /* Process all the set_lines to find the current position */

	IF l_position_set_tbl.EXISTS(l_position_set_index) THEN

	  -- l_current_set_line_id stores the current set_line.
	  l_current_set_line_id :=
	       l_position_set_tbl(l_position_set_index).line_sequence_id;

	  pd('Current Line :' || l_current_set_line_id );

	  -- Flag specifies whether the current position exists in the current
	  -- set_line or not.
	  l_position_exists_in_line_flag := 'N' ;

	  -- Process all the positions coming under the current set_line.
	  FOR j IN l_position_set_index..l_position_set_tbl.COUNT
	  LOOP

	    IF l_position_set_tbl(j).line_sequence_id <>
	       l_current_set_line_id
	    THEN
	      --
	      -- It means we all the positions in the current set_line
	      -- have been processed. Update l_position_set_index and exit.
	      --
	      l_position_set_index := j + 1 ;
	      EXIT ;
	    END IF ;

	    pd('Line:' || l_position_set_tbl(j).line_sequence_id||
		      ' Pos:' || l_position_set_tbl(j).position_id );

	    IF l_position_set_tbl(j).position_id = l_current_position_id THEN

	      -- We have found the current position in the current set_line.
	      l_position_exists_in_line_flag := 'Y' ;

	      --
	      -- First forward l_position_set_index so that it points to the
	      -- next set_line and then exit the loop.
	      --

	      -- Store the current value of the l_position_set_index.
	      l_tmp_index := j ;

	      WHILE l_position_set_tbl.EXISTS(l_tmp_index)
	      LOOP
		--
		IF l_position_set_tbl(l_tmp_index).line_sequence_id <>
		   l_current_set_line_id
		THEN
		  EXIT ;
		ELSE
		  l_tmp_index := l_tmp_index + 1 ;
		END IF ;
		--
	      END LOOP; /* To forward l_position_set_index to next set_line */

	      -- Set l_position_set_index index for l_position_set_tbl.
	      l_position_set_index := l_tmp_index ;

	      -- Exit the loop now.
	      EXIT ;

	    END IF ;
	    --
	  END LOOP;  /* To process positions in the current set_line */

	  pd('line flag:' || l_position_exists_in_line_flag);

	  --
	  -- If the current position is not found in the current set_line,
	  -- do not process rest of the lines as the current position need
	  -- to be there in every single set_line. Just exit the loop.
	  --
	  IF l_position_exists_in_line_flag <> 'Y' THEN
	    l_position_exists_in_set_flag := 'N' ;
	    EXIT ;
	  END IF ;
	  --
	ELSE

	  -- All the set_lines have been processed, so exit.
	  EXIT ;

	END IF ;  /* End of EXISTS clause for set_lines. */
	--
      END LOOP ; /* To process all the set_lines for the current position */

      --
      -- Make assignment if the current position was found in all set_lines.
      --
      IF l_position_exists_in_set_flag = 'Y' THEN
	--
	l_output_tbl_index := l_output_tbl_index + 1 ;
	l_position_output_tbl(l_output_tbl_index) := l_current_position_id ;
	--

	pd('insert output tbl Pos:'||l_current_position_id);

      END IF ;

    END LOOP ;  /* To process all the position in l_position_input_tbl */

    --
    -- Insert positions into psb_budget_positions from l_position_output_tbl.
    --
    FOR i in 1..l_position_output_tbl.COUNT
    LOOP
      --
      INSERT INTO psb_budget_positions
		  (
		     account_position_set_id         ,
		     position_id                     ,
		     data_extract_id                 ,
		     business_group_id               ,
		     last_update_date                ,
		     last_update_login               ,
		     last_updated_by                 ,
		     created_by                      ,
		     creation_date
		  )
	    SELECT   g_position_set_id               ,
		     l_position_output_tbl(i)        ,
		     l_data_extract_id               ,
		     l_business_group_id             ,
		     g_current_date                  ,
		     g_current_login_id              ,
		     g_current_user_id               ,
		     g_current_user_id               ,
		     g_current_date
	    FROM     dual
	    WHERE    NOT EXISTS
		     (  SELECT '1'
			FROM   psb_budget_positions
			WHERE  account_position_set_id = g_position_set_id
			AND    position_id             =
						   l_position_output_tbl(i)
		     ) ;
      --
    END LOOP;
    --
  END IF;  /* End of p_attribute_selection_type clause */

  --
  -- Update last_maintained_date column. Set maintain_status to 'C'
  -- ( meaning updated from PSBVMBAB module) so now the database trigger
  -- will not fire.
  --
  UPDATE psb_account_position_sets
  SET    maintain_status         = 'C' ,
	 last_maintained_date    = g_current_date
  WHERE  account_position_set_id = p_position_set_id;
  --
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    --
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME,
				 'Populate_Budget_Position_Set' );
    END if;
    --
    RETURN (FALSE);
    --
END Populate_Budget_Position_Set ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                   PROCEDURE Populate_Budget_Positions_CP                  |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Maintain Budget
-- Account Codes'.
--
PROCEDURE Populate_Budget_Positions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_data_extract_id           IN       NUMBER   := FND_API.G_MISS_NUM ,
  p_position_set_id           IN       NUMBER   := FND_API.G_MISS_NUM
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Populate_Budget_Positions_CP' ;
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  --
BEGIN
  --

/*Bug:6145715:Removed the savepoint Populate_Budget_Pos_CP_Pvt and all
  its references as commit is issued in the api - Populate_Budget_Positions*/

  --
  IF ( p_data_extract_id = FND_API.G_MISS_NUM OR p_data_extract_id IS NULL )
  THEN
    FND_FILE.Put_Line( FND_FILE.OUTPUT, 'Processing all the position sets.');
  ELSE
    --
    IF ( p_position_set_id = FND_API.G_MISS_NUM OR p_position_set_id IS NULL )
    THEN
      --
      FND_FILE.Put_Line( FND_FILE.OUTPUT,
			 'Processing position sets for data extract id : ' ||
			 p_data_extract_id );
      --
    ELSE
      --
      FND_FILE.Put_Line( FND_FILE.OUTPUT,
			 'Processing the given position set id : ' ||
			 p_position_set_id );
      --
    END IF;
    --
  END IF;

  --
  PSB_Budget_Position_Pvt.Populate_Budget_Positions
  (
     p_api_version       =>  1.0                         ,
     p_init_msg_list     =>  FND_API.G_TRUE              ,
     p_commit            =>  FND_API.G_FALSE             ,
     p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL  ,
     p_return_status     =>  l_return_status             ,
     p_msg_count         =>  l_msg_count                 ,
     p_msg_data          =>  l_msg_data                  ,
     p_data_extract_id   =>  p_data_extract_id           ,
     p_position_set_id   =>  p_position_set_id
  );

  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

  --
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success ;
    /* End Bug No. 2322856 */
  retcode := 0 ;
  --
  COMMIT WORK;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
  WHEN OTHERS THEN
    --

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Populate_Budget_Positions_CP ;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                     PROCEDURE pd (Private)                                |
 +===========================================================================*/
--
-- Private procedure to print debug info. The name is tried to keep as
-- short as possible for better documentaion.
--
PROCEDURE pd
(
   p_message                   IN   VARCHAR2
)
IS
--
BEGIN

  IF g_debug_flag = 'Y' THEN
    NULL;
    -- dbms_output.put_line(p_message) ;
  END IF;

END pd ;
/*---------------------------------------------------------------------------*/


END PSB_Budget_Position_Pvt;

/
