--------------------------------------------------------
--  DDL for Package Body AMS_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_FORMULA_PVT" AS
/* $Header: amsvfmlb.pls 115.8 2002/12/05 19:53:43 feliu ship $*/
-- Start of Comments
--
-- NAME
--   AMS_FORMULA_PVT
--
-- PURPOSE
--   This Package provides procedures to allow  Insertion, Deletion,
--   Update and Locking of Marketing On-Line formulas and formula entries.
--
--   This Package also stores the seeded Functions which can be executed as
--   part of a formula entry.
--
--   This Package also provides functions to execute a formula.
--
--   Procedures:
--
--   Create_Formula.
--   Update_Formula.
--   Delete_Formula.
--   Lock_Formula.
--   Default_Formula.
--   Check_Req_Formula_Items.
--   Execute_Formula.
--   Perform_Computation.

--   Create_Formula_Entry.
--   Update_Formula_Entry.
--   Delete_Formula_Entry.
--   Lock_Formula_Entry.

-- NOTES
--
--
-- HISTORY
--   31-May-2000 tdonohoe created.
--   21-Jun-2000 tdonohoe update perform_computation to put a message on the stack when
--                        an invalid operator is specified.
--
-- End of Comments
--
-- Global variables and constants.

-- Name of the current package.
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_FORMULA_PVT';

G_DEBUG_FLAG 	     VARCHAR2(1)  := 'N';

-- Start of comments
-- NAME
--    Perform_Computation
--
--
-- PURPOSE
-- This Function will take two values and an operator and perform a compuation.
-- The result of the compuation is returned.
--
-- NOTES
-- This Function supports PLUS,MINUS,DIVIDE,MULTIPY,PERCENT.

-- HISTORY
-- 15/Jun/2000	tdonohoe  Created.
--
-- End of comments

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

PROCEDURE Perform_Computation(p_left_value     IN  NUMBER,
                              p_right_value    IN  NUMBER,
	 		      p_operator       IN  VARCHAR2,
			      x_return_status  OUT NOCOPY VARCHAR2,
                     	      x_result         OUT NOCOPY NUMBER)
IS

   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'PERFORM_COMPUTATION';
   L_FULL_NAME   	          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

   l_result NUMBER := 0;

BEGIN

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF(p_operator = 'PLUS')THEN
       l_result := (p_left_value + p_right_value);

   ELSIF(p_operator = 'MINUS')THEN
       l_result := (p_left_value - p_right_value);


   ELSIF(p_operator = 'MULTIPLY')THEN
       l_result := (p_left_value * p_right_value);


   ELSIF(p_operator = 'DIVIDE')THEN
       l_result := (p_left_value / p_right_value);


   ELSIF(p_operator = 'PERCENT')THEN
       l_result := ((p_left_value /100)* p_right_value);

   ELSE
       FND_MESSAGE.set_name('AMS', 'AMS_FML_ENT_INVALID_OP');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  -------------------------------------------
  --Assigning return value to OUT NOCOPY variable.--
  -------------------------------------------
  x_result := l_result;

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;


END Perform_Computation;

-- Start of comments
-- NAME
--    Execute_Formula
--
--
-- PURPOSE
--    This Procedure will Execute a Formula by processing all its formula entries
--    and returning the result in the X_RESULT variable.

--
-- NOTES
--    A Formula can have 1..N Formula Entries.

--    A Formula can have three sources which is stored in FORMULA_ENTRY_TYPE and taken from
--    the lookup AMS_FORMULA_ENT_TYPE.

--    1. CONSTANT     -> This value is User entered.
--    2. CALCULATION  -> The name of a PL\SQL function to be executed.
--    3. METRIC_VALUE -> The name of a column in the AMS_ACT_METRICS_ALL table,.
--                       the value in this column is used.

--    The result of each formula entry is grouped together by the value of ORDER_NUMBER
--    and calculated on this basis.

--    EXAMPLE.
--
--    FORMULA       A B C D E F G
--    ORDER_NUMBER  1 1 1 2 3 3 4     -> (A+B+C)*(C)\(E+F)-(G)
--    OPERATOR        + + * \ + (-)   ->
--
-- HISTORY
-- 12-Jun-2000	tdonohoe  Created.
--
-- End of comments

PROCEDURE Execute_Formula (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_result                     OUT NOCOPY NUMBER,

   p_formula_id                 IN  NUMBER,
   p_hierarchy_id               IN  NUMBER,
   p_parent_node_id             IN  NUMBER,
   p_node_id                    IN  NUMBER
)
IS

   --
   -- Standard API information constants.
   --
   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'EXECUTE_FORMULA';
   L_FULL_NAME   	          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

   ---------------------------------------------------------------------------------------
   --This variable indicates the success or failure of the perform_computation call     --
   ---------------------------------------------------------------------------------------
   l_return_status VARCHAR2(1);

   ---------------------------------------------------------------------------------------
   --This record type is used the result for a  formula entry                           --
   ---------------------------------------------------------------------------------------
   Type Formula_Entry_Result is record
   (formula_entry_id       NUMBER,
    result                 NUMBER,
    formula_entry_operator VARCHAR2(30),
    order_number           NUMBER);

   ---------------------------------------------------------------------------------------
   --This table stores the set of formula entries for a formula                         --
   ---------------------------------------------------------------------------------------
   TYPE Formula_Entry_Results IS TABLE OF Formula_Entry_Result INDEX BY binary_integer;

   ---------------------------------------------------------------------------------------
   --This program variable stores the set of formula entries for a formula              --
   ---------------------------------------------------------------------------------------
   l_formula_entry_results Formula_Entry_Results;

   ---------------------------------------------------------------------------------------
   --This variable stores the number of records in the Formula_Entry_Results table      --
   ---------------------------------------------------------------------------------------
    l_rec_counter binary_integer :=1;

   ---------------------------------------------------------------------------------------
   --These variables store the result and the level of the entries completely processed --
   ---------------------------------------------------------------------------------------
   l_processed_value NUMBER;
   l_processed_level NUMBER;

   ---------------------------------------------------------------------------------------
   --These variables store the result and the level of the current level                --
   ---------------------------------------------------------------------------------------
   l_current_value NUMBER;
   l_current_level NUMBER;
   l_current_flag  BOOLEAN := FALSE;
   l_current_operator VARCHAR2(30);


   ---------------------------------------------------------------------------------------
   --This variable stores the result of the most recent call to perform computation     --
   ---------------------------------------------------------------------------------------
   l_computation_result NUMBER := 0;

   ---------------------------------------------------------------------------------------
   --This Cursor queries the activity_metric_id field from the ams_act_metric_formulas  --
   --table, this is used to query the required value from the ams_act_metrics_all table --
   ---------------------------------------------------------------------------------------
   CURSOR C_Formula_Dets(p_formula_id IN NUMBER) IS
   SELECT activity_metric_id,parent_formula_id
   FROM   ams_act_metric_formulas
   WHERE  formula_id = p_formula_id;

   ---------------------------------------------------------------------------------------
   --This variable stores the value of the cursor c_formula_dets.                       --
   ---------------------------------------------------------------------------------------
   l_activity_metric_id NUMBER;

   ---------------------------------------------------------------------------------------
   --This variable stores the value of the parent_formula_id.                           --
   ---------------------------------------------------------------------------------------
   l_parent_formula_id NUMBER;

   ---------------------------------------------------------------------------------------
   --This Cursor queries all formula entries for a specified FORMULA_ID                 --
   --The Entries are processed in Ascending ORDER_NUMBER and FORMULA_ENTRY_ID.          --
   ---------------------------------------------------------------------------------------
   CURSOR C_Formula_Entry_Dets IS
   SELECT *
   FROM   ams_act_metric_form_ent
   WHERE  formula_id = p_formula_id
   ORDER BY formula_entry_id,order_number;


   ---------------------------------------------------------------------------------------
   --This Variable stores the result of the cursor C_Formula_Entry_Dets.                --
   ---------------------------------------------------------------------------------------
   l_formula_entry_dets C_Formula_Entry_Dets%ROWTYPE;


   ---------------------------------------------------------------------------------------
   --This Variable stores the SQL string to be executed natively.                       --
   ---------------------------------------------------------------------------------------
   l_sql_stmt VARCHAR2(4000);

BEGIN
   -- Initialize savepoint.
   --

   SAVEPOINT Execute_Formula_Pvt;

   IF G_DEBUG THEN
      AMS_Utility_PVT.Debug_Message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --


   OPEN  C_Formula_dets(p_formula_id);
   FETCH C_Formula_dets INTO l_activity_metric_id,l_parent_formula_id;

   IF(C_FORMULA_DETS%NOTFOUND)THEN

       CLOSE C_Formula_dets;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
              CLOSE C_Formula_dets;
   END IF;

   --------------------------------------------------------------------
   --Reading in the set of formula entries and performing dynamic    --
   --SQl if necessary to calculate the value for each entry          --
   --The results are stored into the l_formula_entry_results variable--
   --------------------------------------------------------------------
   OPEN  C_Formula_Entry_Dets;

   LOOP

       FETCH C_Formula_Entry_Dets INTO l_formula_entry_dets;

       EXIT  WHEN C_Formula_Entry_Dets%NOTFOUND;

       IF (l_formula_entry_dets.formula_entry_type = 'CALCULATION') THEN

	    l_sql_stmt := 'SELECT '||l_formula_entry_dets.formula_entry_value||'(:p1,:p2,:p3,:p4,:p5) FROM DUAL';


            EXECUTE IMMEDIATE l_sql_stmt INTO l_formula_entry_results(l_rec_counter).result USING p_hierarchy_id,p_parent_node_id,p_node_id,l_activity_metric_id,l_parent_formula_id;
            l_sql_stmt := NULL;

       ELSIF(l_formula_entry_dets.formula_entry_type = 'METRIC') THEN


	    l_sql_stmt := 'SELECT '||l_formula_entry_dets.formula_entry_value||' FROM AMS_ACT_METRICS_ALL WHERE ACTIVITY_METRIC_ID = :P1';

            EXECUTE IMMEDIATE l_sql_stmt INTO l_formula_entry_results(l_rec_counter).result USING l_activity_metric_id;

            l_sql_stmt := NULL;

       ELSIF(l_formula_entry_dets.formula_entry_type = 'CONSTANT') THEN

	    l_formula_entry_results(l_rec_counter).result := l_formula_entry_dets.formula_entry_value;
       ELSE

	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       l_formula_entry_results(l_rec_counter).formula_entry_id       := l_formula_entry_dets.formula_entry_id;
       l_formula_entry_results(l_rec_counter).formula_entry_operator := l_formula_entry_dets.formula_entry_operator;
       l_formula_entry_results(l_rec_counter).order_number           := l_formula_entry_dets.order_number;

       -----------------------------------------------------------------
       --Initializing the record variable for the next loop iteration.--
       -----------------------------------------------------------------
       l_formula_entry_dets := NULL;

       ------------------------------------
       --Incrementing the record counter.--
       ------------------------------------
       l_rec_counter := l_rec_counter + 1;

   END LOOP;

   CLOSE  C_Formula_Entry_Dets;

   --------------------------------------------------------------------------------------
   --End of Calculating Formula Entry values                                           --
   --------------------------------------------------------------------------------------

   --------------------------------------------------------------------------------------
   --Traversing Formula Entry values and performing the necessary OPERATOR computations--
   --------------------------------------------------------------------------------------
   FOR i IN l_formula_entry_results.FIRST .. l_formula_entry_results.LAST LOOP

      ----------------------------------------------------------------------------------------------
      --If this is the first entry result then always save this to the l_processed_value variable.--
      --Updating the l_processed_level variable.                                                  --
      ----------------------------------------------------------------------------------------------
      IF(i = l_formula_entry_results.FIRST) THEN

         l_processed_value      := l_formula_entry_results(i).result;
	 l_processed_level      := l_formula_entry_results(i).order_number;
         l_current_flag         := FALSE;


      -----------------------------------------------------------------------------------
      --The Current record has the same level as the processed result.                 --
      -----------------------------------------------------------------------------------
      ELSIF(l_formula_entry_results(i).order_number = l_processed_level)THEN
	 perform_computation(p_left_value    => l_processed_value,
	                     p_right_value   => l_formula_entry_results(i).result,
		    	     p_operator      => l_formula_entry_results(i).formula_entry_operator,
			     x_return_status => l_return_status,
			     x_result        => l_computation_result);

	 IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
            l_processed_value := l_computation_result;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      -----------------------------------------------------------------------------------
      --The Current record has a different level to the processed result.              --
      -----------------------------------------------------------------------------------
      ELSE
         --------------------------------------------------------------------------------
	 --The First Node of a new level has been detected.                            --
         --------------------------------------------------------------------------------
         IF(NOT(l_current_flag))THEN
            l_current_flag     := TRUE;
	    l_current_operator := l_formula_entry_results(i).formula_entry_operator;
	    l_current_value    := l_formula_entry_results(i).result;
	    l_current_level    := l_formula_entry_results(i).order_number;
         --------------------------------------------------------------------------------
	 --The Current record has the same level as the current_level_value            --
         --------------------------------------------------------------------------------
         ELSIF(l_formula_entry_results(i).order_number = l_current_level)THEN

	    perform_computation(p_left_value    => l_current_value,
	                        p_right_value   => l_formula_entry_results(i).result,
				p_operator      => l_formula_entry_results(i).formula_entry_operator,
				x_return_status => l_return_status,
				x_result        => l_computation_result);

	    IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
               l_current_value := l_computation_result;
            ELSE
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         -------------------------------------------------------------------------------------
	 --The Current record has a different level as the current_level_value.             --
	 --Perform the computation between the processed_level_value and current_level_value--
	 --Reset the Current Level program variables to the current record.                 --
         -------------------------------------------------------------------------------------
	 ELSE
            perform_computation(p_left_value    => l_processed_value,
	                        p_right_value   => l_current_value,
				p_operator      => l_current_operator,
				x_return_status => l_return_status,
				x_result        => l_computation_result);

	    IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
               l_processed_value := l_computation_result;
	       l_processed_level := l_current_level;
            ELSE
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            l_current_flag     := TRUE;
	    l_current_operator := l_formula_entry_results(i).formula_entry_operator;
	    l_current_value    := l_formula_entry_results(i).result;
	    l_current_level    := l_formula_entry_results(i).order_number;

	 END IF;
      END IF;


   END LOOP;


   IF(l_current_flag)THEN
        perform_computation(p_left_value    => l_processed_value,
	                    p_right_value   => l_current_value,
	    	            p_operator      => l_current_operator,
			    x_return_status => l_return_status,
			    x_result        => l_computation_result);

        IF(l_return_status = FND_API.G_RET_STS_SUCCESS)THEN
           l_processed_value := l_computation_result;
           l_processed_level := l_current_level;
        ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;

   -------------------------------------
   --Assigning result to OUT NOCOPY variable.--
   -------------------------------------
   x_result := l_processed_value;


   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN


      ROLLBACK TO Execute_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Execute_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN


      ROLLBACK TO Execute_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

END Execute_Formula ;




-- Start of comments
-- NAME
--    Default_Formula
--
--
-- PURPOSE
--    Defaults the Activity Metric Formula.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000	tdonohoe  Created.
--
-- End of comments

PROCEDURE Default_Formula(
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_formula_rec            IN  ams_formula_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_rec           OUT NOCOPY ams_formula_rec_type,
   x_return_status 	    OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS

BEGIN
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_complete_rec := p_formula_rec;

     -- Insert Mode
     IF ((p_validation_mode = JTF_PLSQL_API.g_create) OR (p_validation_mode = JTF_PLSQL_API.g_update)) THEN
            NULL;
     END IF;

END Default_Formula ;


-- Start of comments
-- NAME
--    Default_Formula_Entry
--
--
-- PURPOSE
--    Defaults the Activity Metric Formula Entry.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000	tdonohoe  Created.
--
-- End of comments

PROCEDURE Default_Formula_Entry(
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_formula_entry_rec      IN  ams_formula_entry_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_entry_rec     OUT NOCOPY ams_formula_entry_rec_type,
   x_return_status 	    OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS

BEGIN
   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_complete_entry_rec := p_formula_entry_rec;

     -- Insert Mode
     IF ((p_validation_mode = JTF_PLSQL_API.g_create) OR (p_validation_mode = JTF_PLSQL_API.g_update)) THEN

         NULL;
     END IF;

END Default_Formula_Entry ;



-- Start of comments.
--
-- NAME
--    Check_Req_Formula_Items
--
-- PURPOSE
--    Validate required activity metric formula items.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Check_Req_Formula_Items (
   p_formula_rec  IN ams_formula_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   --ACTIVITY_METRIC_ID

   IF p_formula_rec.activity_metric_id IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_FML_MISSING_ACT_METRIC_ID');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --LEVEL_DEPTH

   IF p_formula_rec.level_depth IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_FML_MISSING_LEVEL_DEPTH');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_Formula_Items;


-- Start of comments.
--
-- NAME
--    Check_Req_Formula_Entry_Items
--
-- PURPOSE
--    Validate required activity metric formula entry items.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Check_Req_Formula_Entry_Items (
   p_formula_entry_rec    IN ams_formula_entry_rec_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;



   --FORMULA_ID

   IF p_formula_entry_rec.formula_id IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_FML_MISSING_FORMULA_ID');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   --ORDER_NUMBER
   IF p_formula_entry_rec.order_number IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_FML_MISSING_ORDER_NUM');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

   -- FORMULA_ENTRY_TYPE
   IF p_formula_entry_rec.formula_entry_type IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_FML_MISSING_ENT_TYPE');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

      -- OBJECT_VERSION_NUMBER
   IF p_formula_entry_rec.object_version_number IS NULL
   THEN
      -- missing required fields
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
         FND_MESSAGE.Set_Name('AMS', 'AMS_FML_MISSING_OBJ_NUM');
         FND_MSG_PUB.Add;
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE;
END Check_Req_Formula_Entry_Items;



--
-- Start of comments.
--
-- NAME
--    Check_Formula_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for Activity metric formulas.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000	tdonohoe Created.
--
-- End of comments.


PROCEDURE Check_Formula_UK_Items(
   p_formula_rec    IN  ams_formula_rec_type,
   p_validation_mode 	 IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   	 OUT NOCOPY VARCHAR2
)
IS

   l_formula_count number;

   CURSOR c_formula_type IS
   SELECT COUNT(*)
   FROM   ams_act_metric_formulas
   WHERE  formula_type       = p_formula_rec.formula_type
   AND    activity_metric_id = p_formula_rec.activity_metric_id
   AND    level_depth        = p_formula_rec.level_depth
   AND    formula_id        <> p_formula_rec.formula_id;


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

      OPEN   c_formula_type;
      FETCH  c_formula_type INTO l_formula_count;
      CLOSE  c_formula_type;

      IF (l_formula_count > 0) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

               FND_MESSAGE.set_name('AMS', 'AMS_FML_MAX_LEVEL');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
      END IF;

END Check_Formula_Uk_Items;

--
-- Start of comments.
--
-- NAME
--    Check_Formula_Entry_UK_Items
--
-- PURPOSE
--    Perform Uniqueness check for Activity metric formula entries.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000	tdonohoe Created.
--
-- End of comments.
PROCEDURE Check_Formula_Entry_UK_Items(
   p_formula_entry_rec   IN  ams_formula_entry_rec_type,
   p_validation_mode 	 IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   	 OUT NOCOPY VARCHAR2
)
IS

   l_formula_entry_count number;

   CURSOR c_formula_entry_type IS
   SELECT COUNT(*)
   FROM   ams_act_metric_form_ent
   WHERE  formula_id         =  p_formula_entry_rec.formula_id
   AND    order_number       =  p_formula_entry_rec.order_number
   AND    formula_entry_id   <> p_formula_entry_rec.formula_entry_id;


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

 /*
      OPEN   c_formula_entry_type;
      FETCH  c_formula_entry_type INTO l_formula_entry_count;
      CLOSE  c_formula_entry_type;

      IF (l_formula_entry_count > 0) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN

               FND_MESSAGE.set_name('AMS', 'AMS_FML_ENT_DUP_ORDNUM');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
      END IF;
  */
END Check_Formula_Entry_Uk_Items;




--
-- Start of comments.
--
-- NAME
--    Check_Formula_Items
--
-- PURPOSE
--    Perform item level validation for activity metric formulas.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Check_Formula_Items (
   p_formula_rec         IN  ams_formula_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
   l_item_name                   VARCHAR2(30);  -- Used to standardize error messages.
   l_formula_rec                 ams_formula_rec_type := p_formula_rec;
   l_return_status               VARCHAR2(1);

BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --FORMULA_TYPE

   IF l_formula_rec.formula_type <> FND_API.G_MISS_CHAR THEN


      IF AMS_Utility_PVT.check_lookup_exists(p_lookup_type => 'AMS_FORMULA_TYPE',
                                             p_lookup_code => l_formula_rec.formula_type) = FND_API.g_false THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('AMS', 'AMS_FML_INVALID_TYPE');
                 FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Formula_Items;


--
-- Start of comments.
--
-- NAME
--    Check_Formula_Entry_Items
--
-- PURPOSE
--    Perform item level validation for activity metric formula entries.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Check_Formula_Entry_Items (
   p_formula_entry_rec   IN  ams_formula_entry_rec_type,
   x_return_status       OUT NOCOPY VARCHAR2
)
IS
   l_item_name                   VARCHAR2(30);  -- Used to standardize error messages.
   l_formula_entry_rec           ams_formula_entry_rec_type := p_formula_entry_rec;
   l_return_status               VARCHAR2(1);


BEGIN

   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --FORMULA_ENTRY_TYPE

   IF l_formula_entry_rec.formula_entry_type <> FND_API.G_MISS_CHAR THEN


      IF AMS_Utility_PVT.check_lookup_exists(p_lookup_type => 'AMS_FORMULA_ENT_TYPE',
                                             p_lookup_code => l_formula_entry_rec.formula_entry_type) = FND_API.g_false THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('AMS', 'AMS_FML_ENT_INVALID_TYPE');
                 FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

   --AMS_FORMULA_OPERATORS

   IF l_formula_entry_rec.formula_entry_operator IS NOT NULL AND l_formula_entry_rec.formula_entry_operator <> FND_API.G_MISS_CHAR THEN


      IF AMS_Utility_PVT.check_lookup_exists(p_lookup_type => 'AMS_FORMULA_OPERATOR',
                                             p_lookup_code => l_formula_entry_rec.formula_entry_operator) = FND_API.g_false THEN

          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('AMS', 'AMS_FML_ENT_INVALID_OP');
                 FND_MSG_PUB.add;
          END IF;

          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Formula_Entry_Items;



--
-- Start of comments.
--
-- NAME
--    Validate_Formula_Rec
--
-- PURPOSE
--    Perform Record Level and Other business validations for activity metric formula table.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Validate_Formula_rec(
   p_formula_rec           IN  ams_formula_rec_type,
   p_complete_formula_rec  IN  ams_formula_rec_type,
   x_return_status         OUT NOCOPY VARCHAR2
)
IS

   l_formula_rec                 ams_formula_rec_type := p_formula_rec;
   l_return_status 				 VARCHAR2(1);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF (l_formula_rec.activity_metric_id <> FND_API.G_MISS_NUM) THEN

      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => 'AMS_ACT_METRICS_ALL'
            ,p_pk_name                      => 'ACTIVITY_METRIC_ID'
            ,p_pk_value                     => l_formula_rec.activity_metric_id
            ,p_pk_data_type                 => NULL
            ,p_additional_where_clause      => NULL
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_FML_INVALID_ACT_METRIC');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
      END IF;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Formula_rec;


--
-- Start of comments.
--
-- NAME
--    Validate_Form_ent_rec
--
-- PURPOSE
--    Perform Record Level and Other business validations for activity metric formula table.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe Created.
--
-- End of comments.

PROCEDURE Validate_Form_ent_rec(
   p_formula_entry_rec           IN  ams_formula_entry_rec_type,
   p_complete_formula_entry_rec  IN  ams_formula_entry_rec_type,
   x_return_status               OUT NOCOPY VARCHAR2
)
IS

   l_formula_entry_rec           ams_formula_entry_rec_type := p_formula_entry_rec;
   l_return_status 		 VARCHAR2(1);


BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF (l_formula_entry_rec.formula_id <> FND_API.G_MISS_NUM) THEN

      IF AMS_Utility_PVT.Check_FK_Exists (
             p_table_name                   => 'AMS_ACT_METRIC_FORMULAS'
            ,p_pk_name                      => 'FORMULA_ID'
            ,p_pk_value                     => l_formula_entry_rec.formula_id
            ,p_pk_data_type                 => NULL
            ,p_additional_where_clause      => NULL
         ) = FND_API.G_FALSE
      THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name ('AMS', 'AMS_FML_INVALID_FORMULA_ID');
            FND_MSG_PUB.Add;
            END IF;

            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
      END IF;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Form_ent_rec;


--
-- Start of comments.
--
-- NAME
--    Validate_Formula_Items
--
-- PURPOSE
--    Perform All Item level validation for Activity metric formulas.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Validate_Formula_Items (
   p_formula_rec            IN  ams_formula_rec_type,
   p_validation_mode        IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN



   Check_Req_Formula_Items(
      p_formula_rec      => p_formula_rec,
      x_return_status    => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Uk_Items(
      p_formula_rec            => p_formula_rec,
      p_validation_mode        => p_validation_mode,
      x_return_status          => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Items(
      p_formula_rec           => p_formula_rec,
      x_return_status         => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Validate_Formula_Items;


--
-- Start of comments.
--
-- NAME
--    Validate_Form_Ent_Items
--
-- PURPOSE
--    Perform All Item level validation for Activity metric formula entries.
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe  Created.
--
-- End of comments.

PROCEDURE Validate_Form_Ent_Items (
   p_formula_entry_rec      IN  ams_formula_entry_rec_type,
   p_validation_mode        IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status          OUT NOCOPY VARCHAR2
)
IS
BEGIN



   Check_Req_Formula_Entry_Items(
      p_formula_entry_rec => p_formula_entry_rec,
      x_return_status     => x_return_status
   );
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Entry_Uk_Items(
      p_formula_entry_rec      => p_formula_entry_rec,
      p_validation_mode        => p_validation_mode,
      x_return_status          => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;


   Check_Formula_Entry_Items(
      p_formula_entry_rec     => p_formula_entry_rec,
      x_return_status         => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Validate_Form_Ent_Items;


-- Start of comments
-- NAME
--   Validate_Formula
--
-- PURPOSE
--   Validation API for Activity metric formula table.
--

-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.

--
-- End of comments
PROCEDURE Validate_Formula (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN  ams_formula_rec_type
)
IS
   L_API_VERSION               CONSTANT NUMBER := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_FORMULA';
   L_FULL_NAME   	       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status             VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': Validate items');
   END IF;

   -- Validate required items in the record.
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

       Validate_Formula_Items(
         p_formula_rec             => p_formula_rec,
         p_validation_mode 	   => JTF_PLSQL_API.g_create,
         x_return_status   	   => l_return_status
      );

	  -- If any errors happen abort API.
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		  RAISE FND_API.G_EXC_ERROR;
	  END IF;
   END IF;

  IF G_DEBUG THEN
     AMS_Utility_PVT.debug_message(l_full_name||': check record');
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_Formula_Rec(
         p_formula_rec           => p_formula_rec,
         p_complete_formula_rec  => NULL,
         x_return_status  	 => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             IF G_DEBUG THEN
                AMS_Utility_PVT.debug_message(l_full_name||': error in  check record');
             END IF;
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          IF G_DEBUG THEN
             AMS_Utility_PVT.debug_message(l_full_name||': error in  check record');
          END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': after check record');
   END IF;


   --
   -- End API Body.
   --

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_Formula;

-- Start of comments
-- NAME
--   Validate_Formula_Entry
--
-- PURPOSE
--   Validation API for Activity metric formula entry table.
--

-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe  Created.

--
-- End of comments
PROCEDURE Validate_Formula_Entry (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec          IN  ams_formula_entry_rec_type
)
IS
   L_API_VERSION               CONSTANT NUMBER := 1.0;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'VALIDATE_FORMULA_ENTRY';
   L_FULL_NAME   	       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status             VARCHAR2(1);

BEGIN
   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': Validate items');
   END IF;

   -- Validate required items in the record.
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

       Validate_Form_Ent_Items(
         p_formula_entry_rec       => p_formula_entry_rec,
         p_validation_mode 	   => JTF_PLSQL_API.g_create,
         x_return_status   	   => l_return_status
      );

	  -- If any errors happen abort API.
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;
   END IF;

  IF G_DEBUG THEN
     AMS_Utility_PVT.debug_message(l_full_name||': check record');
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      Validate_Form_Ent_Rec(
         p_formula_entry_rec           => p_formula_entry_rec,
         p_complete_formula_entry_rec  => NULL,
         x_return_status  	       => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             IF G_DEBUG THEN
                AMS_Utility_PVT.debug_message(l_full_name||': error in  check record');
             END IF;
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          IF G_DEBUG THEN
             AMS_Utility_PVT.debug_message(l_full_name||': error in  check record');
          END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': after check record');
   END IF;


   --
   -- End API Body.
   --

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Validate_Formula_Entry;



-------------------------------------------------------------------------------
-- Start of comments
-- NAME
--    Create_Formula
--
--
-- PURPOSE
--    Creates an Activity Metric Formula.

--
-- NOTES
--
-- HISTORY
-- 31-May-2000  tdonohoe@us    Created.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_Formula (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN  ams_formula_rec_type,
   x_formula_id                 OUT NOCOPY NUMBER
) IS

   --
   -- Standard API information constants.
   --
   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'CREATE_FORMULA';
   L_FULL_NAME   	          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status                VARCHAR2(1); -- Return value from procedures.
   l_formula_rec                  ams_formula_rec_type := p_formula_rec;
   l_formula_count                NUMBER ;

   CURSOR c_formula_count(l_formula_id IN NUMBER) IS
   SELECT count(*)
   FROM   ams_act_metric_formulas
   WHERE  formula_id = l_formula_id;

   CURSOR c_formula_id IS
   SELECT ams_act_metric_formulas_s.NEXTVAL
   FROM   dual;

BEGIN

   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_Formula_Pvt;

   IF G_DEBUG THEN
      AMS_Utility_PVT.Debug_Message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

   Default_Formula
       ( p_init_msg_list        => p_init_msg_list,
   	 p_formula_rec          => p_formula_rec,
   	 p_validation_mode      => JTF_PLSQL_API.g_create,
   	 x_complete_rec         => l_formula_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;



   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   --
   -- Validate the record before inserting.
   --


   IF l_formula_rec.formula_id IS NULL THEN
   	  LOOP
   	  --
   	  -- Set the value for the PK.
   	  	 OPEN c_formula_id;
   		 FETCH c_formula_id INTO l_formula_rec.formula_id;
   		 CLOSE c_formula_id;

		 OPEN  c_formula_count(l_formula_rec.formula_id);
		 FETCH c_formula_count INTO l_formula_count ;
		 CLOSE c_formula_count ;

		 EXIT WHEN l_formula_count = 0 ;
	  END LOOP ;
   END IF;



   Validate_Formula (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_formula_rec               => l_formula_rec
   );

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --
   -- Debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;



   --
   -- Insert into the base table.
   --
   INSERT INTO AMS_ACT_METRIC_FORMULAS
   ( formula_id
    ,activity_metric_id
    ,level_depth
    ,parent_formula_id
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login
    ,object_version_number
    ,formula_type
    )
    VALUES
    (l_formula_rec.formula_id
    ,l_formula_rec.activity_metric_id
    ,l_formula_rec.level_depth
    ,l_formula_rec.parent_formula_id
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,FND_GLOBAL.Conc_Login_ID
    ,1--object version number
    ,l_formula_rec.formula_type
    );


   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- finish

   --
   -- Set OUT value.
   --
   x_formula_id := l_formula_rec.formula_id;

   --
   -- End API Body.
   --

   --
   -- Standard check for commit request.
   --
   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

      --
   -- Add success message to message list.
   --

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end Success');
   END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN


      ROLLBACK TO Create_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Create_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN


      ROLLBACK TO Create_Formula_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );


END Create_Formula;


-------------------------------------------------------------------------------
-- Start of comments
-- NAME
--    Create_Formula_Entry
--
--
-- PURPOSE
--    Creates an Activity Metric Formula Entry.

--
-- NOTES
--
-- HISTORY
-- 31-May-2000  tdonohoe@us    Created.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Create_Formula_Entry (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec          IN  ams_formula_entry_rec_type,
   x_formula_entry_id           OUT NOCOPY NUMBER
) IS

   --
   -- Standard API information constants.
   --
   L_API_VERSION                  CONSTANT NUMBER := 1.0;
   L_API_NAME                     CONSTANT VARCHAR2(30) := 'CREATE_FORMULA_ENTRY';
   L_FULL_NAME   	          CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;


   l_return_status                VARCHAR2(1); -- Return value from procedures.
   l_formula_entry_rec            ams_formula_entry_rec_type := p_formula_entry_rec;
   l_formula_entry_count          NUMBER ;

   CURSOR c_formula_entry_count(l_formula_entry_id IN NUMBER) IS
   SELECT count(*)
   FROM   ams_act_metric_form_ent
   WHERE  formula_entry_id = l_formula_entry_id;

   CURSOR c_formula_entry_id IS
   SELECT ams_act_metric_formula_ent_s.NEXTVAL
   FROM   dual;

BEGIN

   --
   -- Initialize savepoint.
   --

   SAVEPOINT Create_Formula_Entry_Pvt;

   IF G_DEBUG THEN
      AMS_Utility_PVT.Debug_Message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

   Default_Formula_Entry
       ( p_init_msg_list        => p_init_msg_list,
   	 p_formula_entry_rec    => p_formula_entry_rec,
   	 p_validation_mode      => JTF_PLSQL_API.g_create,
   	 x_complete_entry_rec   => l_formula_entry_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;



   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   --
   -- Validate the record before inserting.
   --


   IF l_formula_entry_rec.formula_entry_id IS NULL THEN
   	  LOOP
   	  --
   	  -- Set the value for the PK.
   	  	 OPEN  c_formula_entry_id;
   		 FETCH c_formula_entry_id INTO l_formula_entry_rec.formula_entry_id;
   		 CLOSE c_formula_entry_id;

		 OPEN  c_formula_entry_count(l_formula_entry_rec.formula_entry_id);
		 FETCH c_formula_entry_count INTO l_formula_entry_count ;
		 CLOSE c_formula_entry_count ;

		 EXIT WHEN l_formula_entry_count = 0 ;
	  END LOOP ;
   END IF;



   Validate_Formula_Entry (
      p_api_version               => l_api_version,
      p_init_msg_list             => p_init_msg_list,
      p_validation_level          => p_validation_level,
      x_msg_count                 => x_msg_count,
      x_msg_data                  => x_msg_data,
      x_return_status             => l_return_status,
      p_formula_entry_rec         => l_formula_entry_rec
   );

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --
   -- Debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;



   --
   -- Insert into the base table.
   --
   INSERT INTO AMS_ACT_METRIC_FORM_ENT
   ( formula_entry_id
    ,formula_id
    ,order_number
    ,formula_entry_type
    ,formula_entry_value
    ,metric_column_value
    ,formula_entry_operator
    ,last_update_date
    ,last_updated_by
    ,creation_date
    ,created_by
    ,last_update_login
    ,object_version_number
   )
   VALUES
   ( l_formula_entry_rec.formula_entry_id
    ,l_formula_entry_rec.formula_id
    ,l_formula_entry_rec.order_number
    ,l_formula_entry_rec.formula_entry_type
    ,l_formula_entry_rec.formula_entry_value
    ,l_formula_entry_rec.metric_column_value
    ,l_formula_entry_rec.formula_entry_operator
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,SYSDATE
    ,FND_GLOBAL.User_ID
    ,FND_GLOBAL.User_ID
    ,1--OBJECT_VERSION_NUMBER
   );


   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- finish

   --
   -- Set OUT value.
   --
   x_formula_entry_id := l_formula_entry_rec.formula_entry_id;

   --
   -- End API Body.
   --

   --
   -- Standard check for commit request.
   --
   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

      --
   -- Add success message to message list.
   --

   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end Success');
   END IF;




EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN


      ROLLBACK TO Create_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN



      ROLLBACK TO Create_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN


      ROLLBACK TO Create_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );


END Create_Formula_Entry;


-- Start of comments
-- NAME
--    Update_Formula
--
-- PURPOSE
--   Updates an entry in the  AMS_ACT_METRIC_FORMULAS table
--
-- NOTES
--
-- HISTORY
-- 31-May-2000  tdonohoe  Created.
--
-- End of comments

PROCEDURE Update_Formula (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_rec                IN  ams_formula_rec_type
)
IS
   L_API_VERSION                CONSTANT NUMBER := 1.0;
   L_API_NAME                   CONSTANT VARCHAR2(30) := 'UPDATE_FORMULA';
   L_FULL_NAME   		CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status              VARCHAR2(1);
   l_formula_rec                ams_formula_rec_type := p_formula_rec;

BEGIN

   --
   -- Initialize savepoint.
   --
   SAVEPOINT Update_Formula_Pvt;

   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body
   --
   -- Debug Message


   Default_Formula
       ( p_init_msg_list        => p_init_msg_list,
   	 p_formula_rec          => p_formula_rec,
   	 p_validation_mode      => JTF_PLSQL_API.G_UPDATE,
   	 x_complete_rec         => l_formula_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;



   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_Formula_Items(
         p_formula_rec          => l_formula_rec,
         p_validation_mode      => JTF_PLSQL_API.g_update,
         x_return_status        => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;



   -- replace g_miss_char/num/date with current column values
   Complete_Formula_Rec(l_formula_rec,l_formula_rec);


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

      Validate_Formula_Rec(
	 p_formula_rec          => p_formula_rec,
         p_complete_formula_rec => l_formula_rec,
         x_return_status  	=> l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': Update Activity Metric Formulas Table');
   END IF;

   UPDATE  ams_act_metric_formulas SET
           activity_metric_id      =  l_formula_rec.activity_metric_id,
           level_depth             =  l_formula_rec.level_depth,
           parent_formula_id       =  l_formula_rec.parent_formula_id,
           last_update_date        =  SYSDATE,
           last_updated_by         =  FND_GLOBAL.User_Id,
           last_update_login       =  FND_GLOBAL.Conc_Login_Id,
           object_version_number   =  l_formula_rec.object_version_number + 1,
           formula_type            =  l_formula_rec.formula_type
   WHERE   formula_id              =  l_formula_rec.formula_id;


   IF  (SQL%NOTFOUND)
   THEN
      --
      -- Add error message to API message list.
      --
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
    END IF;


    --
   -- End API Body
   --

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO Update_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO Update_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

   WHEN OTHERS THEN

      ROLLBACK TO Update_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Update_Formula;




-- Start of comments
-- NAME
--    Update_Formula_Entry
--
-- PURPOSE
--   Updates an entry in the  AMS_ACT_METRIC_FORM_ENT table
--
-- NOTES
--
-- HISTORY
-- 09-Jun-2000  tdonohoe  Created.
--
-- End of comments

PROCEDURE Update_Formula_Entry (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_formula_entry_rec          IN  ams_formula_entry_rec_type
)
IS
   L_API_VERSION                CONSTANT NUMBER := 1.0;
   L_API_NAME                   CONSTANT VARCHAR2(30) := 'UPDATE_FORMULA_ENTRY';
   L_FULL_NAME   		CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_return_status              VARCHAR2(1);
   l_formula_entry_rec          ams_formula_entry_rec_type := p_formula_entry_rec;

BEGIN

   --
   -- Initialize savepoint.
   --
   SAVEPOINT Update_Formula_Entry_Pvt;

   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body
   --
   -- Debug Message


   Default_Formula_Entry
       ( p_init_msg_list        => p_init_msg_list,
   	 p_formula_entry_rec    => p_formula_entry_rec,
   	 p_validation_mode      => JTF_PLSQL_API.G_UPDATE,
   	 x_complete_entry_rec   => l_formula_entry_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;



   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      Validate_Form_Ent_Items(
         p_formula_entry_rec    => l_formula_entry_rec,
         p_validation_mode      => JTF_PLSQL_API.g_update,
         x_return_status        => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- replace g_miss_char/num/date with current column values
   Complete_Form_Ent_Rec(l_formula_entry_rec,l_formula_entry_rec);


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN

      Validate_Form_Ent_Rec(
	 p_formula_entry_rec          => p_formula_entry_rec,
         p_complete_formula_entry_rec => l_formula_entry_rec,
         x_return_status  	      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': Update Activity Metric Formula Entry Table');
   END IF;

   UPDATE  ams_act_metric_form_ent SET
    formula_id              = l_formula_entry_rec.formula_id
   ,order_number            = l_formula_entry_rec.order_number
   ,formula_entry_type      = l_formula_entry_rec.formula_entry_type
   ,formula_entry_value     = l_formula_entry_rec.formula_entry_value
   ,metric_column_value     = l_formula_entry_rec.metric_column_value
   ,formula_entry_operator  = l_formula_entry_rec.formula_entry_operator
   ,object_version_number   = l_formula_entry_rec.object_version_number + 1
   ,last_update_date        = SYSDATE
   ,last_updated_by         = FND_GLOBAL.User_ID
   ,last_update_login       = FND_GLOBAL.User_ID
   WHERE   formula_entry_id = l_formula_entry_rec.formula_entry_id;



   IF  (SQL%NOTFOUND)
   THEN

      --
      -- Add error message to API message list.
      --
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
    END IF;


    --
   -- End API Body
   --

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Update_Formula_Entry;


-- Start of comments
-- NAME
--    Delete_Formula
--
-- PURPOSE
--    Deletes an entry in the ams_act_metrics_formulas table.
--
-- NOTES
--
-- HISTORY
-- 24-Apr-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Delete_Formula (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_formula_id              IN  NUMBER,
   p_object_version_number    IN  NUMBER
)
IS
   L_API_VERSION              CONSTANT NUMBER := 1.0;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'DELETE_FORMULA';
   L_FULL_NAME   	      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status            VARCHAR2(1);

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Delete_Formula_pvt;

   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

      -- Debug message.
   	  IF G_DEBUG THEN
   	     AMS_Utility_PVT.debug_message(l_full_name ||': delete with Validation');

            AMS_Utility_PVT.debug_message('formula id '||to_char(p_formula_id));

	    AMS_Utility_PVT.debug_message('object version number '||to_char(p_object_version_number));
	 END IF;

         DELETE
	 FROM  ams_act_metric_formulas
         WHERE formula_id = p_formula_id
	 AND   object_version_number = p_object_version_number;

         IF (SQL%NOTFOUND) THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN

		FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         	FND_MSG_PUB.add;
      	 RAISE FND_API.g_exc_error;
      	 END IF;
	 END IF;

         DELETE
	 FROM  ams_act_metric_form_ent
         WHERE formula_id = p_formula_id;

   --
   -- End API Body.
   --

   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
   	  IF G_DEBUG THEN
   	     AMS_Utility_PVT.debug_message(l_full_name ||': End');
   	  END IF;


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Formula_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Delete_Formula;


-- Start of comments
-- NAME
--    Delete_Formula_Entry
--
-- PURPOSE
--    Deletes an entry in the ams_act_metrics_form_ent table.
--
-- NOTES
--
-- HISTORY
-- 09-Jun-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Delete_Formula_Entry (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_formula_entry_id         IN  NUMBER,
   p_object_version_number    IN  NUMBER
)
IS
   L_API_VERSION              CONSTANT NUMBER := 1.0;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'DELETE_FORMULA_ENTRY';
   L_FULL_NAME   	      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status            VARCHAR2(1);

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Delete_Formula_Entry_Pvt;

   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body.
   --

      -- Debug message.
   	  IF G_DEBUG THEN
   	     AMS_Utility_PVT.debug_message(l_full_name ||': delete with Validation');

            AMS_Utility_PVT.debug_message('formula id '||to_char(p_formula_entry_id));

	    AMS_Utility_PVT.debug_message('object version number '||to_char(p_object_version_number));
	 END IF;

         DELETE
	 FROM  ams_act_metric_form_ent
         WHERE formula_entry_id = p_formula_entry_id
	 AND   object_version_number = p_object_version_number;

         IF (SQL%NOTFOUND) THEN
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN

		FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         	FND_MSG_PUB.add;
      	 RAISE FND_API.g_exc_error;
      	 END IF;
	 END IF;

   --
   -- End API Body.
   --

   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   --
   -- Debug message.
   --
   	  IF G_DEBUG THEN
   	     AMS_Utility_PVT.debug_message(l_full_name ||': End');
   	  END IF;


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Delete_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Formula_Entry_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
END Delete_Formula_Entry;


-- Start of comments
-- NAME
--    Lock_Formula
--
-- PURPOSE
--    Lock the given row in AMS_ACT_METRICS_FORMULAS table.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Lock_Formula (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_formula_id              IN  NUMBER,
   p_object_version_number   IN  NUMBER
)
IS
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'LOCK_FORMULA';
   L_FULL_NAME    	   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_formula_id    NUMBER;

   CURSOR c_formula_info IS
   SELECT formula_id
   FROM   ams_act_metric_formulas
   WHERE  formula_id         = p_formula_id
   AND object_version_number = p_object_version_number
   FOR UPDATE OF formula_id NOWAIT;

BEGIN
   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN  c_formula_info;
   FETCH c_formula_info INTO l_formula_id;
   IF   (c_formula_info%NOTFOUND)
   THEN
      CLOSE c_formula_info;
	  -- Error, check the msg level and added an error message to the
	  -- API message list
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_formula_info;


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN AMS_Utility_PVT.RESOURCE_LOCKED THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
		   FND_MSG_PUB.add;
	  END IF;

      FND_MSG_PUB.Count_And_Get (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data,
         p_encoded	 =>      FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
	 p_encoded	 =>      FND_API.G_FALSE
		       );
END Lock_Formula;


-- Start of comments
-- NAME
--    Lock_Formula_Entry
--
-- PURPOSE
--    Lock the given row in AMS_ACT_METRIC_FORM_ENT table.
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe  Created.
--
-- End of comments

PROCEDURE Lock_Formula_Entry (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_formula_entry_id        IN  NUMBER,
   p_object_version_number   IN  NUMBER
)
IS
   L_API_VERSION           CONSTANT NUMBER := 1.0;
   L_API_NAME              CONSTANT VARCHAR2(30) := 'LOCK_FORMULA_ENTRY';
   L_FULL_NAME    	   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_formula_entry_id    NUMBER;

   CURSOR c_formula_entry_info IS
   SELECT formula_entry_id
   FROM   ams_act_metric_form_ent
   WHERE  formula_entry_id   = p_formula_entry_id
   AND object_version_number = p_object_version_number
   FOR UPDATE OF formula_entry_id NOWAIT;

BEGIN
   --
   -- Output debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- Begin API Body
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN  c_formula_entry_info;
   FETCH c_formula_entry_info INTO l_formula_entry_id;
   IF   (c_formula_entry_info%NOTFOUND)
   THEN
      CLOSE c_formula_entry_info;
	  -- Error, check the msg level and added an error message to the
	  -- API message list
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_formula_entry_info;


   --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );

   --
   -- Debug message.
   --
   IF G_DEBUG THEN
      AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data
      );
   WHEN AMS_Utility_PVT.RESOURCE_LOCKED THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
		   FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
		   FND_MSG_PUB.add;
	  END IF;

      FND_MSG_PUB.Count_And_Get (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data,
         p_encoded	 =>      FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
      END IF;
      FND_MSG_PUB.Count_And_Get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
	 p_encoded	 =>      FND_API.G_FALSE
		       );
END Lock_Formula_Entry;

-------------------------------------------------------------------------------
-- Start of comments
--
-- NAME
--    Complete_Formula_Rec
--
-- PURPOSE
--   Returns the Initialized Activity Metric Formula Record
--
-- NOTES
--
-- HISTORY
-- 31-May-2000 tdonohoe Created.
--
PROCEDURE Complete_Formula_Rec(
   p_formula_rec            IN  ams_formula_rec_type,
   x_complete_formula_rec   OUT NOCOPY ams_formula_rec_type
)
IS
   CURSOR c_formula IS
   SELECT *
   FROM  ams_act_metric_formulas
   WHERE formula_id = p_formula_rec.formula_id;

   l_formula_rec  c_formula%ROWTYPE;

BEGIN

   x_complete_formula_rec := p_formula_rec;

   OPEN  c_formula;
   FETCH c_formula INTO l_formula_rec;

   IF c_formula%NOTFOUND THEN
      CLOSE c_formula;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_formula;



   IF p_formula_rec.formula_id  = FND_API.G_MISS_NUM THEN
      x_complete_formula_rec.formula_id  := l_formula_rec.formula_id;
   END IF;

   IF p_formula_rec.activity_metric_id  = FND_API.G_MISS_NUM THEN
      x_complete_formula_rec.activity_metric_id  := l_formula_rec.activity_metric_id;
   END IF;

   IF p_formula_rec.level_depth  = FND_API.G_MISS_NUM THEN
      x_complete_formula_rec.level_depth  := l_formula_rec.level_depth;
   END IF;

   IF p_formula_rec.parent_formula_id  = FND_API.G_MISS_NUM THEN
      x_complete_formula_rec.parent_formula_id  := l_formula_rec.parent_formula_id;
   END IF;

   IF p_formula_rec.last_update_date  = FND_API.G_MISS_DATE THEN
      x_complete_formula_rec.last_update_date  := l_formula_rec.last_update_date;
   END IF;

   IF p_formula_rec.last_updated_by   = FND_API.G_MISS_NUM THEN
      x_complete_formula_rec.last_updated_by   := l_formula_rec.last_updated_by ;
   END IF;

   IF p_formula_rec.creation_date  = FND_API.G_MISS_DATE THEN
      x_complete_formula_rec.creation_date  := l_formula_rec.creation_date;
   END IF;

   IF p_formula_rec.created_by   = FND_API.G_MISS_NUM THEN
      x_complete_formula_rec.last_updated_by   := l_formula_rec.last_updated_by ;
   END IF;

   IF p_formula_rec.last_update_login  = FND_API.G_MISS_NUM THEN
      x_complete_formula_rec.last_updated_by   := l_formula_rec.last_updated_by ;
   END IF;

   IF p_formula_rec.formula_type  = FND_API.G_MISS_CHAR THEN
      x_complete_formula_rec.formula_type  := l_formula_rec.formula_type;
   END IF;

END Complete_Formula_Rec ;


-------------------------------------------------------------------------------
-- Start of comments
--
-- NAME
--    Complete_Form_Ent_Rec
--
-- PURPOSE
--   Returns the Initialized Activity Metric Formula Entry Record
--
-- NOTES
--
-- HISTORY
-- 01-Jun-2000 tdonohoe Created.
--
PROCEDURE Complete_Form_Ent_Rec(
   p_formula_entry_rec            IN  ams_formula_entry_rec_type,
   x_complete_formula_entry_rec   OUT NOCOPY ams_formula_entry_rec_type
)
IS
   CURSOR c_formula_entry IS
   SELECT *
   FROM  ams_act_metric_form_ent
   WHERE formula_entry_id = p_formula_entry_rec.formula_entry_id;

   l_formula_entry_rec  c_formula_entry%ROWTYPE;

BEGIN

   x_complete_formula_entry_rec := p_formula_entry_rec ;

   OPEN  c_formula_entry;
   FETCH c_formula_entry INTO l_formula_entry_rec;

   IF c_formula_entry%NOTFOUND THEN
      CLOSE c_formula_entry;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_formula_entry;


   IF p_formula_entry_rec.formula_entry_id  = FND_API.G_MISS_NUM THEN
      x_complete_formula_entry_rec.formula_entry_id  := l_formula_entry_rec.formula_entry_id;
   END IF;

   IF p_formula_entry_rec.formula_id  = FND_API.G_MISS_NUM THEN
      x_complete_formula_entry_rec.formula_id  := l_formula_entry_rec.formula_id;
   END IF;

   IF p_formula_entry_rec.order_number  = FND_API.G_MISS_NUM THEN
      x_complete_formula_entry_rec.order_number  := l_formula_entry_rec.order_number;
   END IF;

   IF p_formula_entry_rec.formula_entry_type   = FND_API.G_MISS_CHAR THEN
      x_complete_formula_entry_rec.formula_entry_type  := l_formula_entry_rec.formula_entry_type;
   END IF;

   IF p_formula_entry_rec.formula_entry_value  = FND_API.G_MISS_CHAR THEN
      x_complete_formula_entry_rec.formula_entry_value  := l_formula_entry_rec.formula_entry_value;
   END IF;

   IF p_formula_entry_rec.metric_column_value  = FND_API.G_MISS_CHAR THEN
      x_complete_formula_entry_rec.metric_column_value  := l_formula_entry_rec.metric_column_value;
   END IF;

   IF p_formula_entry_rec.formula_entry_operator  = FND_API.G_MISS_CHAR THEN
      x_complete_formula_entry_rec.formula_entry_operator  := l_formula_entry_rec.formula_entry_operator;
   END IF;

   IF p_formula_entry_rec.formula_entry_operator  = FND_API.G_MISS_CHAR THEN
      x_complete_formula_entry_rec.formula_entry_operator  := l_formula_entry_rec.formula_entry_operator;
   END IF;

   IF p_formula_entry_rec.last_update_date  = FND_API.G_MISS_DATE THEN
      x_complete_formula_entry_rec.last_update_date  := l_formula_entry_rec.last_update_date;
   END IF;

   IF p_formula_entry_rec.last_updated_by  = FND_API.G_MISS_NUM THEN
      x_complete_formula_entry_rec.last_updated_by  := l_formula_entry_rec.last_updated_by;
   END IF;

   IF p_formula_entry_rec.creation_date  = FND_API.G_MISS_DATE THEN
      x_complete_formula_entry_rec.creation_date  := l_formula_entry_rec.creation_date;
   END IF;

   IF p_formula_entry_rec.created_by  = FND_API.G_MISS_NUM THEN
      x_complete_formula_entry_rec.created_by  := l_formula_entry_rec.created_by;
   END IF;

   IF p_formula_entry_rec.last_update_login  = FND_API.G_MISS_NUM THEN
      x_complete_formula_entry_rec.last_update_login  := l_formula_entry_rec.last_update_login;
   END IF;

   IF p_formula_entry_rec.object_version_number  = FND_API.G_MISS_NUM THEN
      x_complete_formula_entry_rec.object_version_number  := l_formula_entry_rec.object_version_number;
   END IF;

END Complete_Form_Ent_Rec ;

END AMS_Formula_PVT;

/
