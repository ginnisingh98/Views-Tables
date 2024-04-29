--------------------------------------------------------
--  DDL for Package Body AMS_CONTCAMPAIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CONTCAMPAIGN_PVT" AS
/* $Header: amsvtceb.pls 120.3 2005/09/22 03:34:49 kbasavar noship $*/

--  Start of Comments
--
-- NAME
--   AMS_ContCampaign_PVT
--
-- PURPOSE
--   This package performs Continuous Campaigning
--    in Oracle Marketing
--
-- HISTORY
--   07/12/1999        ptendulk    CREATED
--   02/26/2000        ptendulk    Modified the Schedule next Run Procedure
--   02/26/2000        ptendulk    Modified the Schedule next Run Procedure
--                                 to support the timezone
--
--   05/07/2003        vmodur      Fix for SQL Binding Project
--   01/27/2005        soagrawa    Fixed bug# 4142260 in validate_sql
--   26-aug-2005       soagrawa    Fixes for R12
--   31-aug-2005       soagrawa    Modified to add variance and variance percentage for R12 Monitors
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_ContCampaign_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(15):='amsvtceb.pls';

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------------- Continuous Campaign ----------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


--
-- NAME
--    Convert_Uom
--
-- PURPOSE
--    This Procedure will  call the Inventory API to convert Uom
--    It will return the calculated quantity (in UOM of to_uom_code )
-- NOTES
--
-- HISTORY
-- 09/30/1999     ptendulk            Created.
--
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

/*PROCEDURE insert_log_mesg (p_mesg IN VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 insert into anirban_table values (p_mesg);
 commit;
END;*/

FUNCTION Convert_Uom(
   p_from_uom_code                IN  VARCHAR2,
   p_to_uom_code                IN  VARCHAR2,
   p_from_quantity             IN    NUMBER,
   p_precision                IN    NUMBER   DEFAULT Null,
   p_from_uom_name             IN  VARCHAR2 DEFAULT Null,
   p_to_uom_name              IN  VARCHAR2 DEFAULT Null
 )
RETURN NUMBER
IS

   l_to_quantity             NUMBER ;


BEGIN
    -- Call UOM Conversion API. Pass Item ID as 0 as the UOM is not attached to Item
    l_to_quantity := Inv_Convert.Inv_Um_Convert (
                                 item_id        => 0 ,      -- As This is Standard Conversion
                         precision       => p_precision,
                         from_quantity  => p_from_quantity,
                            from_unit      => p_from_uom_code,
                            to_unit        => p_to_uom_code,
                            from_name         => p_from_uom_name,
                            to_name          => p_to_uom_name ) ;

    RETURN l_to_quantity ;


EXCEPTION
  WHEN OTHERS THEN
        l_to_quantity  := -1 ;
      RETURN l_to_quantity ;
END Convert_Uom;


--
-- NAME
--    Convert_Currency
--
-- PURPOSE
--    This Procedure will  call the GL API to convert Functional currency
--    into Transaction Currency
-- NOTES
--
-- HISTORY
-- 09/30/1999     ptendulk            Created.
--
PROCEDURE Convert_Currency(
   x_return_status               OUT NOCOPY VARCHAR2,
   p_from_currency_code            IN  NUMBER,
   p_to_currency_code            IN  NUMBER,
   p_conv_date                IN    DATE DEFAULT SYSDATE,
   p_orig_amount             IN    NUMBER,
   x_converted_amount            OUT NOCOPY NUMBER
)
IS


   l_denominator      NUMBER ;
   l_numerator         NUMBER ;
   l_rate             NUMBER ;
   l_conversion_type    VARCHAR2(30) ;

BEGIN
   -- Initialize return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Give call to Function to get the Profile value defined for Currency Conversion type
   -- Profile option Has to be defined -- Dt : 10/23/99
   l_conversion_type := FND_PROFILE.Value('AMS_CURR_CONVERSION_TYPE');


   -- Call GL API to Convert the Amount
   GL_CURRENCY_API.Convert_Closest_Amount(
                     x_from_currency    => p_from_currency_code,
                  x_to_currency       => p_to_currency_code,
                  x_conversion_date  => p_conv_date,
                  x_conversion_type  => l_conversion_type,
                  x_user_rate       => 1 ,   --Not being Used
                  x_amount          => p_orig_amount,
                  x_max_roll_days    => -1 ,
    -- x_max_roll_days is -ve as it should roll back to find last conversion Rate
                  x_converted_amount => x_converted_amount,
                  x_denominator       => l_denominator,
                  x_numerator         => l_numerator,
                  x_rate             => l_rate ) ;



EXCEPTION
   WHEN GL_CURRENCY_API.NO_RATE THEN

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
-- No rate exist for for given conversion date and type between
-- transaction currency and functional currency
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_CURR_NO_RATE');
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;
   WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN -- MMSG
-- Atleast One of the two Currencies specified is invalid
         FND_MESSAGE.Set_Name('AMS', 'AMS_TRIG_INVALID_CURR');
         FND_MSG_PUB.Add;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- If any error happens abort API.
      RETURN;


END Convert_Currency;




-- Start of Comments
--
-- NAME
--   Validate_sql
--
-- PURPOSE
--   It will execute the Discoverer query dynamically and will return the value
--
-- CALLED BY
-- Perform_Checks
--
-- NOTES
-- This Procedure checks that SQL query returns only one row  and One Numeric Column .
--
-- HISTORY
--   07/13/1999        ptendulk            created
--   01/27/2005        soagrawa            Fixed bug# 4142260 to ignore workbook owner
-- End of Comments


PROCEDURE Validate_Sql(      p_api_version               IN      NUMBER,
                        p_init_msg_list           IN    VARCHAR2  := FND_API.G_FALSE,

                        x_return_status           OUT NOCOPY   VARCHAR2,
                        x_msg_count               OUT NOCOPY   NUMBER  ,
                      x_msg_data                OUT NOCOPY   VARCHAR2,

                        p_workbook_name             IN    VARCHAR2,
                            p_worksheet_name          IN    VARCHAR2,
                          p_workbook_owner_name       IN    VARCHAR2,

                      x_result               OUT NOCOPY   NUMBER)
IS

  l_api_version      CONSTANT NUMBER         := 1.0 ;
  l_api_name        CONSTANT VARCHAR2(30)  := 'Validate_Sql';
  l_full_name      CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;

  -- Status Local Variables
  -- Counter for Main PLSQL table
  l_count             NUMBER                   :=   0 ;
  -- Counter for DBMS PLSQL table
  l_sql_count          NUMBER                   :=   0 ;
  -- Store the Number return by SQL query
  l_result               NUMBER                    := 0 ;
  -- Check the size of the SQL string
  l_size             NUMBER                   :=   0 ;
  -- Store the total no of rows processed by the query
  l_row_processed        NUMBER                       := 0 ;
  -- Size constraint to Use Native dynamic sql
  l_dbms_size            NUMBER                         := 32767 ;
  -- The PL/SQL table which stores 255 character length strings to be passed
  -- to DBMS_SQL package
  l_sql_str              DBMS_SQL.varchar2s ;
  -- Store the copy of currnt SQL string
  l_str_copy              VARCHAR2(2000);

  l_length             NUMBER                   := 0 ;
  -- Handle for the cursor
  l_cur_hdl           NUMBER  ;
  -- Store no of rows
  l_rows                    NUMBER                     := 0 ;
  -- Store whole query if it is less than  32k
  l_query                   VARCHAR2(32767) ;

  -- Store Column count,col type for dbms sql
  l_col_cnt             NUMBER ;
  l_rec_tab           DBMS_SQL.DESC_TAB ;
  l_rec              DBMS_SQL.DESC_REC ;

  -- Declare dummy variable to check no of columns in native sql
  l_dummy                  VARCHAR2(2000);

--   01/27/2005 soagrawa Modified cursor to fix bug# 4142260 to ignore workbook owner
  CURSOR C_sql_string IS
  SELECT  sql_string
  FROM     ams_discoverer_sql
  WHERE   workbook_name  = p_workbook_name
  AND     worksheet_name = p_worksheet_name
--  AND     workbook_owner_name = p_workbook_owner_name
  ORDER BY sequence_order ;



  --this table will hold the sql strings which compose the discoverer workbook sql.
  l_workbook_sql t_SQLtable;
BEGIN


   IF (AMS_DEBUG_HIGH_ON) THEN





   AMS_Utility_PVT.debug_message(l_full_name||': start');


   END IF;

    --
    -- Initialize message list if p_init_msg_list is set to TRUE.
    --
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.Initialize;
    END IF;

    --
    -- Standard call to check for call compatibility.
    --
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
   -- Take the sql query into PLSQL table
    -- Check the Size of the query depending on the Size Execute
    -- the query as Native SQL or DBMS_SQL
   l_count := 0 ;
   -- dbms_output.put_line('l_count'||l_count) ;

   OPEN  C_sql_string ;
   LOOP
       FETCH C_sql_string INTO l_workbook_sql(l_count+1) ;
--       dbms_output.put_line(l_workbook_sql(l_count+1)) ;
       EXIT WHEN C_sql_string%NOTFOUND ;
               l_size  := l_size + lengthb(l_workbook_sql(l_count+1));
            l_count := l_count + 1 ;
   END LOOP;
   CLOSE c_sql_string ;

    -- dbms_output.put_line('Size Of the SQL is '||l_size);


   IF l_size > l_dbms_size THEN
   -- dbms_output.put_line('DBMS_SQL');
      --  Use DBMS_SQL. ----
      --  The sql statement has to be taken into PLSQL table to parse
      --  string larger than 32kb.
      l_count := 0 ;
        LOOP
         -- Copy Current String
         l_str_copy :=  l_workbook_sql(l_count + 1) ;
         LOOP
           -- Get the length of the current string
           l_length := length(l_str_copy) ;
             l_sql_count := l_sql_count + 1 ;
           IF l_length < 255 THEN
              -- If length is < 255 char we can exit loop after copying
              -- current contents into DBMS_SQL PL/SQL table
                  l_sql_str(l_sql_count):=  l_str_copy ;
                EXIT;
           ELSE
                  -- Copy 255 Characters and copy next 255 to the next row
                  l_sql_str(l_sql_count):=  substr(l_str_copy,1,255) ;
                l_str_copy                :=  substr(l_str_copy,256)   ;
           END IF;

         END LOOP ;
         EXIT WHEN (l_count + 1) = l_workbook_sql.last;
         l_count := l_count + 1 ;
       END LOOP ;

      -- Now the query is in plsql table. Parse it and execute.
       BEGIN

         IF (DBMS_SQL.Is_Open(l_cur_hdl) = FALSE) THEN
             l_cur_hdl := DBMS_SQL.Open_Cursor ;
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN



         AMS_Utility_PVT.debug_message(l_full_name||': PARSE SQL start');

         END IF;

         DBMS_SQL.Parse(l_cur_hdl ,
                      l_sql_str,
                     l_sql_str.first,
                     l_sql_str.last,
                    FALSE,
                    DBMS_SQL.Native) ;

         DBMS_SQL.Define_Column(l_cur_hdl,1,l_result) ;

         l_row_processed   := DBMS_SQL.Execute(l_cur_hdl);

           --
           -- Check the number of rows returned
           --
         LOOP
              IF dbms_sql.fetch_rows(l_cur_hdl) > 0 THEN
                 l_rows := l_rows + 1 ;
              ELSE
                     EXIT;
              END IF;
         END LOOP ;


         -- dbms_output.put_line('No of Rows Fetched '||l_rows);
--            l_row_processed   := DBMS_SQL.Execute(l_cur_hdl);
--             dbms_output.put_line('No of Rows Fetched '||dbms_sql.fetch_rows(l_cur_hdl));
         IF l_rows > 1  THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN -- MMSG
              -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: returns more than one row');
             FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_TOOROW');
             FND_MSG_PUB.Add;
           END IF;
           DBMS_SQL.Close_Cursor(l_cur_hdl) ;
           x_return_status := FND_API.G_RET_STS_ERROR;
           -- If any errors happen abort API/Procedure.
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_rows = 0 THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN -- MMSG
              -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: returns no rows');
             FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_NOROW');
             FND_MSG_PUB.Add;
           END IF;
           DBMS_SQL.Close_Cursor(l_cur_hdl) ;
           x_return_status := FND_API.G_RET_STS_ERROR;
           -- If any errors happen abort API/Procedure.
           RAISE FND_API.G_EXC_ERROR;
        END IF;
            -- dbms_OUTPUT.Put_Line('returns one row');

         -- If query returns only one row check whether it returns only one column
        DBMS_SQL.Describe_Columns(l_cur_hdl,l_col_cnt,l_rec_tab);
        -- dbms_output.put_line('No of columns : '||l_col_cnt);
        IF l_col_cnt > 1 THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: returns more than one column');
             FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_TOOCOL');
             FND_MSG_PUB.Add;
           END IF;
           DBMS_SQL.Close_Cursor(l_cur_hdl) ;
           x_return_status := FND_API.G_RET_STS_ERROR;
           -- If any errors happen abort API/Procedure.
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- dbms_OUTPUT.Put_Line('returns one column');
         -- If query returns only one column check whether the datatype is number

         l_rec := l_rec_tab(l_rec_tab.first) ;
         -- dbms_output.put_line('Column Type '||l_rec.col_type);
         IF l_rec.col_type <> 2 THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: Datatype of the column is not Number');
             FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_NONUM');
             FND_MSG_PUB.Add;
           END IF;
           DBMS_SQL.Close_Cursor(l_cur_hdl) ;
           x_return_status := FND_API.G_RET_STS_ERROR;
           -- If any errors happen abort API/Procedure.
             RAISE FND_API.G_EXC_ERROR;
         END IF;


         -- If column is number return the number
           DBMS_SQL.Column_Value(l_cur_hdl,1,l_result) ;
         DBMS_SQL.Close_Cursor(l_cur_hdl) ;
         -- Success Message
             -- MMSG
             -- dbms_OUTPUT.Put_Line('AMS_ContCampaign_PVT.Check_sql_row: The result is: '||to_char(l_result));

         IF (AMS_DEBUG_HIGH_ON) THEN



         AMS_Utility_PVT.debug_message(l_full_name ||': end');

         END IF;

        EXCEPTION
         WHEN INVALID_NUMBER THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN -- MMSG
              -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: Datatype of the column is not Number');
             FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_NONUM');
             FND_MSG_PUB.Add;
           END IF;
          x_return_status := FND_API.G_Ret_Sts_Error ;
          DBMS_SQL.Close_Cursor(l_cur_hdl);
          -- If any errors happen abort API/Procedure.
           RAISE FND_API.G_EXC_ERROR;
       END;


   ELSE  -- It is Native SQL
     -- dbms_output.put_line('Native_SQL');
      --  Use Native SQL
      l_count := 0 ;
      LOOP
         -- Copy Current String
         l_query :=  l_query||(l_workbook_sql(l_count + 1)) ;
         EXIT WHEN (l_count + 1) = l_workbook_sql.last;
         l_count := l_count + 1 ;
       END LOOP ;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message(l_full_name ||': Execute Native SQL');
      END IF;

       -- First Check for no of columns
       BEGIN
         EXECUTE IMMEDIATE l_query INTO l_result,l_dummy ;
            -- No exception is raised from above statement, means, there are 2 or more columns
            --  in the query
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN -- MMSG
             -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: returns more than one column');
            FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_TOOCOL');
            FND_MSG_PUB.Add;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- If any errors happen abort API/Procedure.
         RAISE FND_API.G_EXC_ERROR;
      EXCEPTION
            WHEN valid_no_columns THEN
                 -- The query Returns only one row , So the query is right
                -- dbms_output.put_line('Query Returns only one row');
                IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_PVT.debug_message(l_full_name ||': Query Returns One row');
                END IF;
                Null;
          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              -- If any errors happen abort API/Procedure.
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      -- Now Check for No of rows and Column Datatype
      BEGIN
          EXECUTE IMMEDIATE l_query INTO l_result ;
      EXCEPTION
         WHEN No_DATA_FOUND THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN -- MMSG
                         -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: returns no rows');
                       FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_NOROW');
                       FND_MSG_PUB.Add;
             END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             -- If any errors happen abort API/Procedure.
             RAISE FND_API.G_EXC_ERROR;
         WHEN TOO_MANY_ROWS THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN -- MMSG
                         -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: returns more than one row');
                       FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_TOOROW');
                       FND_MSG_PUB.Add;
                END IF;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    -- If any errors happen abort API/Procedure.
                    RAISE FND_API.G_EXC_ERROR;

         WHEN INVALID_NUMBER THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN -- MMSG
                         -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid: Column should be a NUMBER value');
                       FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_NONUM');
                       FND_MSG_PUB.Add;
                END IF;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    -- If any errors happen abort API/Procedure.
                    RAISE FND_API.G_EXC_ERROR;

         WHEN OTHERS THEN
                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                      THEN -- MMSG
                  -- dbms_OUTPUT.Put_Line('The SQL statement in Discoverer is invalid:');
                 FND_MESSAGE.set_name('AMS', 'AMS_TRIG_INVALID_DISC_SQL');
                 FND_MSG_PUB.Add;
                 END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 -- If any errors happen abort API/Procedure.
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END;

        --
        -- Debug Message
        --
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_Utility_PVT.debug_message(l_full_name ||': Execute native SQL: End');
        END IF;

   END IF ;
   -- Return the result of the query
   --insert_log_mesg ('Anirban inside validate sql api, just before it retutns the result: '||l_result);
   x_result := l_result ;

    --
   -- END of API body.
    --
    --
    -- Debug Message
    --
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_Utility_PVT.debug_message(l_full_name ||':End');
    END IF;


        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

           x_return_status := FND_API.G_Ret_Sts_Error ;

           FND_MSG_PUB.Count_And_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
             p_encoded          =>      FND_API.G_FALSE
           );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_And_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
           p_encoded          =>      FND_API.G_FALSE
           );



        WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count           =>      x_msg_count,
             p_data            =>      x_msg_data,
            p_encoded            =>      FND_API.G_FALSE
           );



END Validate_Sql;



-- Start of Comments
--
-- NAME
----   Record_result
--
-- PURPOSE
--   This Procedure is to record the results of the check and also that
--   of action
--
-- NOTES
--
--
-- HISTORY
--   07/21/1999        ptendulk            created
--   26-aug-2005       soagrawa     Added action for id to store who the NTF was sent to
-- End of Comments
PROCEDURE Record_Result(p_result_for_id         IN     NUMBER,
                  p_process_id          IN     NUMBER   :=     NULL,
                  p_chk1_value         IN     NUMBER   :=     NULL,
                  p_chk2_value         IN     NUMBER   :=     NULL,
                  p_chk2_high_value     IN      NUMBER   :=     NULL,
                  p_operator            IN     VARCHAR2 :=     NULL,
                  p_process_success     IN     VARCHAR2 :=     NULL,
                  p_check_met            IN     VARCHAR2 :=     NULL,
                  p_action_taken        IN      VARCHAR2 :=     NULL,
                  p_action_for_id         IN     NUMBER   :=     NULL,
                  x_result_id           OUT NOCOPY     NUMBER,
                  x_return_status         OUT NOCOPY   VARCHAR2)
IS
  CURSOR c_result_seq IS
  SELECT ams_trigger_results_s.NEXTVAL
  FROM    dual ;

  CURSOR c_act_det IS
         SELECT COUNT(1)
         FROM   ams_trigger_results
         WHERE  trigger_result_id = p_process_id ;


  l_result_id NUMBER;

  l_count NUMBER ;
BEGIN
 --  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 OPEN  c_act_det ;
 FETCH c_act_det INTO l_count ;
 CLOSE c_act_det;

 IF l_count > 0 THEN
    UPDATE ams_trigger_results
    SET
    trigger_finish_time = SYSDATE ,
    object_version_number = object_version_number + 1,
    actions_performed = p_action_taken
    WHERE trigger_result_id = p_process_id ;

    IF (SQL%NOTFOUND) THEN
         -- Error, check the msg level and added an error message to the
         -- API message list
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_result_id := null ;
 ELSE
   -- Insert

     -- open cursor AND fetch into local variable
    open c_result_seq;
    fetch c_result_seq into l_result_id;
    -- colse cursor
    close c_result_seq;


   INSERT INTO ams_trigger_results
   (trigger_result_id

   --Standard Who Columns
   ,last_update_date
   ,last_updated_by
   ,creation_date
   ,created_by
   ,last_update_login
   ,object_version_number
   ,trigger_result_for_id
   ,arc_trigger_result_for
   ,trigger_finish_time
   ,chk1_checked_value
   ,chk2_checked_value
   ,chk2_high_value
   ,chk1_to_chk2_operator_type
   ,process_success_flag
   ,check_met_flag
   ,actions_performed
   ,notified_user
   )
   VALUES
   (
   l_result_id
   -- standard who columns
   ,SYSDATE
   ,FND_GLOBAL.User_Id
   ,SYSDATE
   ,FND_GLOBAL.User_Id
   ,FND_GLOBAL.Conc_Login_Id
   ,1          -- Object Version ID
   ,p_result_for_id
   ,'TRIG'
   ,SYSDATE
   ,p_chk1_value
   ,p_chk2_value
   ,p_chk2_high_value
   ,p_operator
   ,p_process_success
   ,p_check_met
   ,p_action_taken
   ,p_action_for_id);

    x_result_id := l_result_id ;
 END IF;

   IF p_process_success = 'Y' THEN
      IF p_check_met <> 'Y' THEN
         update ams_triggers
         set TRIGGERED_STATUS = 'DORMANT'
         where trigger_id = p_result_for_id;
      ELSE
         update ams_triggers
         set TRIGGERED_STATUS = 'TRIGGERED'
         where trigger_id = p_result_for_id;
      END IF;
   END IF;

EXCEPTION
WHEN   OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
END Record_Result ;

-- Start of Comments
--
-- NAME
--   Schedule_Next_Trigger_Run
--
-- PURPOSE
--   This Procedure will mark the Last run time fot the trigger and
--   will calculate the next schedule run time. Will Update the AMS_TRIGGERS
--    table with the new values for Last run time, next schedule run time
--
-- NOTES
--
--
-- HISTORY
--   07/23/1999        ptendulk            created
--   11/06/1999        ptendulk            Modified
--   02/26/1999        ptendulk            Modified - Do not update Obj Version Number
-- End of Comments

PROCEDURE Schedule_Next_Trigger_Run
                    (p_api_version       IN   NUMBER,
                         p_init_msg_list     IN   VARCHAR2   := FND_API.G_FALSE,
                   p_commit             IN   VARCHAR2   := FND_API.G_FALSE,
                     p_trigger_id         IN   NUMBER,
                     x_msg_count         OUT NOCOPY  NUMBER,
                   x_msg_data          OUT NOCOPY  VARCHAR2,
                   x_return_status    OUT NOCOPY  VARCHAR2,
                      x_sch_date           OUT NOCOPY  DATE)
IS

    l_api_name      CONSTANT VARCHAR2(30)  := 'Schedule_Next_Trigger_Run ';
    l_api_version   CONSTANT NUMBER        := 1.0;
    l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;

    l_return_status   VARCHAR2(1);
    l_sch_date       DATE;
    l_trigger_id      ams_triggers.trigger_id%type := p_trigger_id ;

    l_user_last_run_date_time  DATE ;
    l_user_next_run_date_time  DATE ;

   -- Store the Ref. Date from which to calculate next date
   l_cur_date       DATE ;
    l_last_run_date   DATE;

    -- Temp. Variables
   l_tmp                VARCHAR2(2) ;
   l_str             VARCHAR2(30) ;

    CURSOR   c_triggers(l_my_trigger_id NUMBER) IS
               SELECT    *
               FROM    ams_triggers
              WHERE     trigger_id  = l_my_trigger_id ;
    l_trigger         c_triggers%rowtype ;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT Schedule_trig_run;
  --
  -- Debug Message
  --
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  --
  -- Initialize message list IF p_init_msg_list is set to TRUE.
  --
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
  END IF;

  --
  -- Standard call to check for call compatibility.
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  --  Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- API Body
  --
  OPEN c_triggers(l_trigger_id) ;
  FETCH c_triggers INTO l_trigger ;
  CLOSE c_triggers ;



  -- First Mark the Last Run Date Time (Update AMS_TRIGGERS with this date
  -- at the end   )
  IF l_trigger.last_run_date_time IS NULL THEN
         l_cur_date := l_trigger.start_date_time ;
      l_last_run_date := l_trigger.start_date_time ;
  ELSE
       l_cur_date :=  l_trigger.next_run_date_time ;
       l_last_run_date := l_trigger.next_run_date_time ;
  END IF;

  IF SYSDATE > l_cur_date
  THEN
     l_cur_date := sysdate;
     l_last_run_date := sysdate;
  END IF;

   AMS_Utility_PVT.Create_Log (
               x_return_status   => x_return_status,
               p_arc_log_used_by => 'TRIG',
               p_log_used_by_id  => l_trigger_id,
               p_msg_data        => 'Schedule_Next_Trigger_Run : repeat_frequency_type = ' || l_trigger.repeat_frequency_type,
               p_msg_type        => 'DEBUG'
               );

  IF l_trigger.repeat_frequency_type = 'DAILY' THEN
       l_sch_date := l_cur_date + l_trigger.repeat_every_x_frequency ;
  ELSIF    l_trigger.repeat_frequency_type = 'WEEKLY' THEN
       l_sch_date := l_cur_date + (7 * l_trigger.repeat_every_x_frequency) ;
  ELSIF    l_trigger.repeat_frequency_type = 'MONTHLY' THEN
       l_sch_date := add_months(l_cur_date , l_trigger.repeat_every_x_frequency) ;
  ELSIF    l_trigger.repeat_frequency_type = 'YEARLY' THEN
       l_sch_date := add_months(l_cur_date , (12*l_trigger.repeat_every_x_frequency)) ;
  ElSIF    l_trigger.repeat_frequency_type = 'HOURLY' THEN
       l_sch_date := l_cur_date + (l_trigger.repeat_every_x_frequency/24) ;
/*
--cgoyal fixed the trigger reschedule error on 27 May 03.
      IF (l_trigger.repeat_daily_start_time IS NOT NULL) AND (l_trigger.repeat_daily_start_time <> FND_API.G_MISS_DATE) AND (l_trigger.repeat_daily_end_time IS NOT NULL) AND (l_trigger.repeat_daily_end_time <> FND_API.G_MISS_DATE) THEN
    IF  l_sch_date > l_trigger.repeat_daily_end_time THEN
       l_tmp := TO_CHAR(l_sch_date+1,'DD') ;
            l_str := l_tmp||to_char(l_sch_date,'-MON-YYYY')||' '|| to_char(l_trigger.repeat_daily_start_time,'HH:MI:SS AM') ;
            l_sch_date := TO_DATE(l_str) ;
    END IF;
      END IF; */
  END IF;


  --
  -- Following code is added by ptendulk on 26 Apr 2000
  -- The calls added to calculate the time in User's timezone

  AMS_Utility_PVT.Convert_Timezone(
     p_init_msg_list       => p_init_msg_list,
     x_return_status       => x_return_status,
     x_msg_count           => x_msg_count,
     x_msg_data            => x_msg_data,

     p_user_tz_id          => l_trigger.timezone_id,
     p_in_time             => l_cur_date  ,
     p_convert_type        => 'USER' ,

     x_out_time            => l_user_last_run_date_time
    ) ;

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR ;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

  AMS_Utility_PVT.Convert_Timezone(
     p_init_msg_list       => p_init_msg_list,
     x_return_status       => x_return_status,
     x_msg_count           => x_msg_count,
     x_msg_data            => x_msg_data,

     p_user_tz_id          => l_trigger.timezone_id,
     p_in_time             => l_sch_date  ,
     p_convert_type        => 'USER' ,

     x_out_time            => l_user_next_run_date_time
    ) ;

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR ;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF;

   ----------------------------------------------------------------
   --  End of Code  added by ptendulk on 26th Apr
   ----------------------------------------------------------------
  --
  -- Debug Message
  --
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name||': Update Schedule Date');
  END IF;


  UPDATE ams_triggers
  SET    last_run_date_time = l_cur_date,
         next_run_date_time = l_sch_date,
         user_last_run_date_time = l_user_last_run_date_time,
         user_next_run_date_time = l_user_next_run_date_time
  WHERE  trigger_id = l_trigger_id ;

  IF (SQL%NOTFOUND) THEN
         -- Error, check the msg level and added an error message to the
         -- API message list
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN -- MMSG
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Assign the out Value
  x_sch_date := l_sch_date ;
  -- dbms_output.put_line('The next Schedule Date1 is :'||to_char(x_sch_date,'DD-MM-YYYY HH:MI:SS AM'));

  --
  -- Debug Message
  --
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name ||': delete');
  END IF;

  --
  -- END of API body.
  --
  --
  -- Standard check of p_commit.
  --
  IF FND_API.To_Boolean ( p_commit )
  THEN
          COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count AND IF count is 1, get message info.
  --
  FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );


EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN

           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_And_Get
           ( p_count       =>      x_msg_count,
             p_data        =>      x_msg_data,
            p_encoded       =>      FND_API.G_FALSE
           );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_And_Get
           ( p_count       =>      x_msg_count,
             p_data        =>      x_msg_data,
            p_encoded       =>      FND_API.G_FALSE
           );


        WHEN OTHERS THEN

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count       =>      x_msg_count,
             p_data        =>      x_msg_data,
             p_encoded       =>      FND_API.G_FALSE
           );


END Schedule_Next_Trigger_Run ;

-- Start of Comments
--
-- NAME
----   Perform_Checks
--
-- PURPOSE
--   This Function is to execute various checks defined on the trigger.
--   Function performs the checks, stores the result in Result table and
--    returns the flag Y/N to indicate whether the check was met or not
--
-- NOTES
--
--
-- HISTORY
--   07/12/1999        ptendulk       created
--   26-aug-2005       soagrawa       Modified to go against functional curr values in R12
--   26-aug-2005       soagrawa       Modified to pass action_for_id to record_result to store the NTF user
--   31-aug-2005       soagrawa       Modified to add variance and variance percentage for R12 Monitors
-- End of Comments

PROCEDURE Perform_Checks(p_api_version     IN   NUMBER ,
                         p_init_msg_list   IN   VARCHAR2   := FND_API.G_FALSE,

                     x_msg_count       OUT NOCOPY  NUMBER,
                   x_msg_data        OUT NOCOPY  VARCHAR2,
                         x_return_status   OUT NOCOPY VARCHAR2,

                     p_trigger_id       IN   NUMBER,
                   x_chk_success      OUT NOCOPY  VARCHAR2,
                         x_check_val       OUT NOCOPY  NUMBER ,
                         x_check_high_val  OUT NOCOPY  NUMBER ,
                         x_result_id       OUT NOCOPY  NUMBER
                      )
IS
    l_api_name      CONSTANT VARCHAR2(30)  := 'Perform_Checks';
    l_api_version   CONSTANT NUMBER        := 1.0;
    l_full_name     CONSTANT VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;



    l_return_status   VARCHAR2(1);
--   l_check_rec          ams_trigger_checks%ROWTYPE ;
   l_sql_stmt       VARCHAR2(100);
   l_chk_success    VARCHAR2(1);


    CURSOR   c_trigger_checks(l_my_trigger_id NUMBER) IS
        SELECT    *
       FROM      ams_trigger_checks
      WHERE     trigger_id = l_my_trigger_id  ;
     l_trigger_checks    c_trigger_checks%rowtype ;

    CURSOR   c_metric_det(l_act_met_id NUMBER) IS
        SELECT    trans_actual_value,
                  trans_forecasted_value,
                  trans_committed_value,
                  metric_uom_code,
                  transaction_currency_code,
                  func_actual_value,
                  func_forecasted_value,
                  func_committed_value,
                  functional_currency_code
        FROM      ams_act_metrics_all
        WHERE     activity_metric_id = l_act_met_id ;

    CURSOR c_trigger_Actions_det (l_my_trigger_id NUMBER) IS
       SELECT action_for_id
         FROM ams_trigger_Actions
   WHERE execute_Action_type = 'NOTIFY'
     AND trigger_id = l_my_trigger_id;

    l_notified_user   NUMBER;
    l_met_rec  c_metric_det%ROWTYPE ;
   -- Store the left hand side Value
   l_lhs_val           NUMBER ;
    -- Store the LHS after UOM Conversion
    l_uom_val           NUMBER ;
    -- Store the LHS after UOM and Currency Conversion
    l_final_val           NUMBER ;
   -- Store the right hand side Value
   l_rhs_val           NUMBER ;

    -- This has to be the first worksheet in the workbook for the current release
   l_chk2_worksheet_name   VARCHAR2(30);
    -- Store all the metric values
   l_fun_cur         VARCHAR2(15) ;
    l_check_met        VARCHAR2(1);

    l_high_value        NUMBER ;

BEGIN
  --
  -- Debug Message
  --
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  --
  -- Initialize message list IF p_init_msg_list is set to TRUE.
  --
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
  END IF;

  --
  -- Standard call to check for call compatibility.
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- API body
  --
  OPEN  c_trigger_checks(p_trigger_id) ;
  FETCH c_trigger_checks INTO l_trigger_checks ;
  CLOSE c_trigger_checks ;

  IF l_trigger_checks.CHK1_TYPE = 'METRIC'
  THEN
     AMS_REFRESHMETRIC_PVT.Refresh_Metric (
         p_api_version                 => p_api_version,
         p_init_msg_list               => p_init_msg_list,
         p_commit                      => FND_API.G_FALSE,
         x_return_status               => l_return_status,
         x_msg_count                   => x_msg_count,
         x_msg_data                    => x_msg_data,
         p_arc_act_metric_used_by      => l_trigger_checks.chk1_arc_source_code_from,
         p_act_metric_used_by_id       => l_trigger_checks.chk1_source_code_metric_id
      );

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;

  IF l_trigger_checks.CHK2_TYPE = 'METRIC'
  THEN
     IF l_trigger_checks.chk1_arc_source_code_from <> l_trigger_checks.chk2_arc_source_code_from
     THEN
        IF l_trigger_checks.chk1_source_code_metric_id <> l_trigger_checks.chk2_source_code_metric_id
        THEN
           AMS_REFRESHMETRIC_PVT.Refresh_Metric (
               p_api_version                 => p_api_version,
               p_init_msg_list               => p_init_msg_list,
               p_commit                      => FND_API.G_FALSE,
               x_return_status               => l_return_status,
               x_msg_count                   => x_msg_count,
               x_msg_data                    => x_msg_data,
               p_arc_act_metric_used_by      => l_trigger_checks.chk2_arc_source_code_from,
               p_act_metric_used_by_id       => l_trigger_checks.chk2_source_code_metric_id
            );

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
     END IF;
  END IF;


  IF l_trigger_checks.CHK1_TYPE = 'METRIC' THEN
         -- dbms_OUTPUT.Put_Line('Chk1_type : METRIC');
        OPEN  c_metric_det(l_trigger_checks.CHK1_SOURCE_CODE_METRIC_ID) ;
        FETCH c_metric_det INTO l_met_rec ;
        CLOSE c_metric_det  ;


       IF l_trigger_checks.chk1_source_code_metric_type = 'FORECAST'
      THEN
             l_lhs_val := l_met_rec.func_forecasted_value  ;
      ELSIF l_trigger_checks.chk1_source_code_metric_type = 'ACTUAL'
      THEN
             l_lhs_val := l_met_rec.func_actual_value  ;
      ELSIF l_trigger_checks.chk1_source_code_metric_type = 'COMMITTED'
      THEN
             l_lhs_val := l_met_rec.func_committed_value  ;
           -- new for R12
      ELSIF l_trigger_checks.chk1_source_code_metric_type = 'VARIANCE'
      THEN
             l_lhs_val := l_met_rec.func_actual_value -  l_met_rec.func_forecasted_value ;
      ELSIF l_trigger_checks.chk1_source_code_metric_type = 'VARIANCE_PERCENT'
      THEN
             l_lhs_val := ((l_met_rec.func_actual_value - l_met_rec.func_forecasted_value)/ l_met_rec.func_forecasted_value) * 100;
        END IF;
       -- insert_log_mesg ('Anirban , the value of variable l_lhs_val is : '||l_lhs_val);
  END IF;



  IF l_trigger_checks.chk2_type = 'METRIC' THEN
      -- Call Metric API to get value of metric in l_lhs_val
      -- dbms_OUTPUT.Put_Line('CHK2 Type: METRIC');

        OPEN  c_metric_det(l_trigger_checks.CHK2_SOURCE_CODE_METRIC_ID) ;
        FETCH c_metric_det INTO l_met_rec ;
        CLOSE c_metric_det  ;

       IF l_trigger_checks.chk2_source_code_metric_type = 'FORECAST'
      THEN
             l_rhs_val := l_met_rec.func_forecasted_value  ;
      ELSIF l_trigger_checks.chk2_source_code_metric_type = 'ACTUAL'
      THEN
             l_rhs_val := l_met_rec.func_actual_value  ;
      ELSIF l_trigger_checks.chk2_source_code_metric_type = 'COMMITTED'
      THEN
             l_rhs_val := l_met_rec.func_committed_value  ;
           -- new for R12
      ELSIF l_trigger_checks.chk1_source_code_metric_type = 'VARIANCE'
      THEN
             l_rhs_val := l_met_rec.func_actual_value -  l_met_rec.func_forecasted_value ;
      ELSIF l_trigger_checks.chk1_source_code_metric_type = 'VARIANCE_PERCENT'
      THEN
             l_rhs_val := ((l_met_rec.func_actual_value - l_met_rec.func_forecasted_value)/ l_met_rec.func_forecasted_value) * 100;
       END IF;

  --ELSIF l_trigger_checks.chk2_type = 'WORKBOOK' THEN
  ELSIF l_trigger_checks.chk2_type = 'DIWB' THEN
       -- dbms_OUTPUT.Put_Line('chk2_type = WB');
      -- Call Validate Discoverer SQL API to get value of sql query in l_rhs_val

--         Hardcode workbook owner and worksheet name  Has to be removed after
--          new structure for Discoverer comes from Discoverer Team ;
--          Only for testing purpose

       l_chk2_worksheet_name := l_trigger_checks.chk2_workbook_name ;

       Validate_Sql(p_api_version              => l_api_version,
                p_init_msg_list           => p_init_msg_list,

                 x_return_status           => l_return_status,
                 x_msg_count               => x_msg_count,
               x_msg_data                => x_msg_data ,

                 p_workbook_name            => l_trigger_checks.chk2_workbook_name,
                 p_worksheet_name         => l_trigger_checks.chk2_worksheet_name,
               p_workbook_owner_name      => l_trigger_checks.chk2_workbook_owner,
               x_result              => l_rhs_val)      ;


      -- dbms_OUTPUT.Put_Line('Value of the Discoverer 1: '||l_rhs_val);
         -- If any errors happen abort API.
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;
        --insert_log_mesg ('Anirban just AFTER validate sql api, value of variable l_rhs_val: the api retutns the result: '||l_rhs_val);
   IF l_trigger_checks.chk2_type = 'STATIC_VALUE' THEN

    -- Convert UOM First
        IF l_met_rec.metric_uom_code <> l_trigger_checks.chk2_uom_code THEN
            l_uom_val := Convert_Uom(
                           p_from_uom_code  => l_met_rec.metric_uom_code,
                           p_to_uom_code    => l_trigger_checks.chk2_uom_code,
                           p_from_quantity   => l_lhs_val) ;
        ELSE
            l_uom_val := l_lhs_val                           ;
        END IF;

    -- Convert Currency
        IF  l_trigger_checks.chk2_currency_code IS NOT NULL AND
            l_met_rec.transaction_currency_code <> l_trigger_checks.chk2_currency_code THEN

            Convert_Currency(
               x_return_status       => l_return_status,
               p_from_currency_code  => l_met_rec.transaction_currency_code,
               p_to_currency_code    => l_trigger_checks.chk2_currency_code,
               p_orig_amount       => l_uom_val,
               x_converted_amount    => l_final_val
                            )        ;
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
            l_final_val := l_uom_val ;

        END IF;
   --insert_log_mesg ('Anirban , the value of variable l_final_val is, AFTER Conver Currency api callout : '||l_final_val);
/*      Change for SQL Bind Project. this code is commented and replaced
           -- No proper indentation in this code!!!!!!!!!!!!!!
      -- dbms_OUTPUT.Put_Line('chk2_type = Static val');
            IF l_trigger_checks.chk1_to_chk2_operator_type = 'BETWEEN' THEN
                l_sql_stmt := 'SELECT COUNT(1) FROM dual WHERE '
                  ||l_final_val||' '||l_trigger_checks.chk1_to_chk2_operator_type
               ||' '||l_trigger_checks.chk2_low_value||' AND '
               ||l_trigger_checks.chk2_high_value      ;

       ELSE
                    l_rhs_val := l_trigger_checks.chk2_value ;
               l_sql_stmt := 'SELECT COUNT(1) FROM dual WHERE '
                   ||l_final_val||' '||l_trigger_checks.chk1_to_chk2_operator_type
               ||' '||l_trigger_checks.chk2_value  ;
       END IF;

        ELSE
          l_sql_stmt := 'SELECT COUNT(1) FROM dual WHERE '
              ||l_lhs_val||' '||l_trigger_checks.chk1_to_chk2_operator_type
             ||' '||l_rhs_val ;
   END IF;
    -- dbms_output.put_line('SQl STMT : '||l_sql_stmt);

   EXECUTE IMMEDIATE l_sql_stmt INTO l_chk_success ;
*/
-- New Replacement code for SQL Bind Project
            IF l_trigger_checks.chk1_to_chk2_operator_type = 'BETWEEN' THEN
                l_sql_stmt := 'SELECT COUNT(1) FROM dual WHERE '
                    ||' :b1 ' || ' BETWEEN '
                                        ||' :b2 AND :b3';
                EXECUTE IMMEDIATE l_sql_stmt INTO l_chk_success USING l_final_val, l_trigger_checks.chk2_low_value,
                        l_trigger_checks.chk2_high_value;

       ELSE
           l_rhs_val := l_trigger_checks.chk2_value;
      l_sql_stmt := 'SELECT COUNT(1) FROM dual WHERE '
                    ||' :b1 '||l_trigger_checks.chk1_to_chk2_operator_type
               ||' :b2' ;
      EXECUTE IMMEDIATE l_sql_stmt INTO l_chk_success USING l_final_val, l_rhs_val;
      --insert_log_mesg ('Anirban , inside 1st ELSE part of IF l_trigger_checks.chk1_to_chk2_operator_type = BETWEEN THEN : the value of variable l_rhs_val :: '||l_rhs_val);
      --insert_log_mesg ('Anirban , inside 1st ELSE part of IF l_trigger_checks.chk1_to_chk2_operator_type = BETWEEN THEN : the value of variable l_sql_stmt :: '||l_sql_stmt);

       END IF;

    ELSE

          l_sql_stmt := 'SELECT COUNT(1) FROM dual WHERE '
              ||' :b1 '||l_trigger_checks.chk1_to_chk2_operator_type
             ||' :b2 ' ;

          EXECUTE IMMEDIATE l_sql_stmt INTO l_chk_success USING l_lhs_val, l_rhs_val;

    END IF;
-- End of replacement code for SQL Bind Project



   -- Assign OUT Parameter
    x_check_val     :=   l_rhs_val ;
   x_chk_success   :=   l_chk_success ;
    IF l_trigger_checks.chk1_to_chk2_operator_type = 'BETWEEN' THEN
        x_check_high_val:=   l_trigger_checks.chk2_high_value ;
        x_check_val     :=   l_trigger_checks.chk2_low_value ;
    END IF;

    IF    l_chk_success = 1 THEN
             l_check_met := 'Y' ;
    ELSIF l_chk_success = 0 THEN
             l_check_met := 'N' ;
    END IF;

   -- Record the results
        --insert_log_mesg ('Anirban , just before Record_Result gets called :: '||p_trigger_id);
   --insert_log_mesg ('Anirban , just before Record_Result gets called :: '||l_lhs_val);
   --insert_log_mesg ('Anirban , just before Record_Result gets called :: '||x_check_val);

        OPEN  c_trigger_Actions_det (p_trigger_id);
   FETCH c_trigger_Actions_det INTO l_notified_user;
   CLOSE c_trigger_Actions_det;

   Record_Result(p_result_for_id      => p_trigger_id,
                 p_chk1_value          => l_lhs_val,
             p_chk2_value          => x_check_val,
                 p_chk2_high_value     => l_high_value ,
             p_operator             => l_trigger_checks.chk1_to_chk2_operator_type,
             p_process_success     => 'Y' ,
             p_check_met         => l_check_met,
             p_action_for_id           => l_notified_user,
                 x_result_id           => x_result_id,
             x_return_status      => x_return_status ) ;

   -- If any errors happen abort API.
   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --insert_log_mesg ('Anirban , just AFTER Record_Result gets called :: '||p_trigger_id);
   --insert_log_mesg ('Anirban , just AFTER Record_Result gets called :: '||l_lhs_val);
   --insert_log_mesg ('Anirban , just AFTER Record_Result gets called :: '||x_check_val);


    --
    -- END of API body.
    --

    --
   -- Standard call to get message count AND IF count is 1, get message info.
   --
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded          =>      FND_API.G_FALSE
        );

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_Utility_PVT.debug_message(l_full_name ||': end');

    END IF;


EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN

          Record_Result(p_result_for_id       => p_trigger_id,
                   p_chk1_value          => l_lhs_val,
                   p_chk2_value          => x_check_val,
                         p_chk2_high_value     => l_high_value ,
                   p_operator             => l_trigger_checks.chk1_to_chk2_operator_type,
                   p_process_success     => 'N' ,
                   p_check_met         => NULL,
          x_result_id           => x_result_id,
                   x_return_status      => x_return_status) ;

           x_return_status := FND_API.G_RET_STS_ERROR ;

           FND_MSG_PUB.Count_And_Get
           ( p_count       =>      x_msg_count,
             p_data        =>      x_msg_data,
            p_encoded       =>      FND_API.G_FALSE
           );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          Record_Result(p_result_for_id       => p_trigger_id,
                   p_chk1_value          => l_lhs_val,
                   p_chk2_value          => x_check_val,
                         p_chk2_high_value     => l_high_value ,
                   p_operator             => l_trigger_checks.chk1_to_chk2_operator_type,
                   p_process_success     => 'N' ,
                   p_check_met         => NULL,
                         x_result_id           => x_result_id,
                   x_return_status      => x_return_status) ;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           FND_MSG_PUB.Count_And_Get
           ( p_count       =>      x_msg_count,
             p_data        =>      x_msg_data,
            p_encoded       =>      FND_API.G_FALSE
           );


        WHEN OTHERS THEN

          Record_Result(p_result_for_id       => p_trigger_id,
                   p_chk1_value          => l_lhs_val,
                   p_chk2_value          => x_check_val,
                         p_chk2_high_value     => l_high_value ,
                   p_operator             => l_trigger_checks.chk1_to_chk2_operator_type,
                   p_process_success     => 'N' ,
                   p_check_met         => NULL,
                         x_result_id           => x_result_id,
                   x_return_status      => x_return_status) ;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
           THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;

           FND_MSG_PUB.Count_AND_Get
           ( p_count       =>      x_msg_count,
             p_data        =>      x_msg_data,
             p_encoded       =>      FND_API.G_FALSE
           );


END Perform_checks ;

-- Temp . Proc For Testing
PROCEDURE Fullfillment
IS
BEGIN
NULL;
END Fullfillment;

END AMS_ContCampaign_PVT;

/
