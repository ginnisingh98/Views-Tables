--------------------------------------------------------
--  DDL for Package Body AMS_LISTENTRY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTENTRY_PVT" as
/* $Header: amsvlseb.pls 120.0.12010000.2 2008/08/11 08:46:45 amlal ship $ */
-----------------------------------------------------------
-- PACKAGE
--    AMS_ListEntry_PVT
--
-- PROCEDURES
--   Create_ListEntry
--   Update_ListEntry
--   Delete_ListEntry
--   Lock_ListEntry
--   Validate_ListEntry
--   Update_ListEntry_Source_Code
--
--   Check_Entry_items
--   Check_Entry_record

--   Check_entry_req_items
--   Check_entry_uk_items
--   Check_entry_fk_items
--   Check_entry_lookup_items
--   Check_entry_flag_items

--   Init_Entry_rec
--   Complete_Entry_rec
--   Default_ListEntry.

-- FUNCTIONS
--   Get_ListPinCode

--
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_ListEntry_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='amsvlseb.pls';


AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
-- Start of comments
-- NAME
--    Default_ListEntry
--
--
-- PURPOSE
--    Defaults the list entry record.
--
-- NOTES
--
-- HISTORY
-- 06-Jun-2000	tdonohoe  Created.
-- 26-Jul-2001	gjoby     Modfied
--                        Source code not updated for schedule if cascade source
--                        if set to Y
-- End of comments


PROCEDURE Default_ListEntry(
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_listentry_rec          IN  entry_rec_type,
   p_validation_mode        IN  VARCHAR2 ,
   x_complete_rec           OUT NOCOPY entry_rec_type,
   x_return_status 	    OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2
)
IS

--getting the primary key and arc qualifer of the entity which owns this list.
CURSOR c_header_dets(header_id IN NUMBER)IS
SELECT list_used_by_id,arc_list_used_by
FROM   ams_list_headers_all
WHERE  list_header_id  = header_id;

l_list_used_by_id NUMBER;
l_arc_used_by     VARCHAR2(30);

--gettting the source_code from the ams_source_code table.
CURSOR C_get_source_code(object_id IN NUMBER,object_arc IN VARCHAR2) IS
SELECT source_code
FROM   ams_source_codes
WHERE  source_code_for_id  = object_id
AND    arc_source_code_for = object_arc;

l_source_code VARCHAR2(30);

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

   x_complete_rec := p_listentry_rec;

     -- Insert Mode.
     IF (p_validation_mode = JTF_PLSQL_API.g_create) THEN


          --ARC_LIST_USED_BY_SOURCE or SOURCE_CODE_FOR_ID
          IF(p_listentry_rec.arc_list_used_by_source IS NULL) OR (p_listentry_rec.source_code_for_id IS NULL) THEN

             --getting list header source code details.
             OPEN  c_header_dets(x_complete_rec.list_header_id);
             FETCH c_header_dets into x_complete_rec.source_code_for_id,
	                              x_complete_rec.arc_list_used_by_source;
             CLOSE c_header_dets;
          END IF;

	  --SOURCE_CODE
	  IF(p_listentry_rec.source_code IS NULL)THEN

	     OPEN  c_header_dets(x_complete_rec.list_header_id);
             FETCH c_header_dets INTO l_list_used_by_id,
                                      l_arc_used_by ;
             CLOSE c_header_dets;

             --A List does not have to be associated with a Marketing Entity
	     --In this case default the value to 'NONE'.
             IF(l_arc_used_by = 'NONE') THEN
                x_complete_rec.source_code := 'NONE';
             ELSE
                OPEN  c_get_source_code(l_list_used_by_id,l_arc_used_by);
                FETCH c_get_source_code INTO x_complete_rec.source_code;
                CLOSE c_get_source_code;
             END IF;
	  END IF;

	  --ARC_LIST_SELECT_ACTION_FROM
          x_complete_rec.arc_list_select_action_from := 'NONE';

	  --LIST_SELECT_ACTION_FROM_NAME
          x_complete_rec.list_select_action_from_name := 'NONE';

	  --LIST_SELECT_ACTION_ID
          x_complete_rec.list_select_action_id := 0;

     END IF;

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;



END Default_ListEntry;



-- Start of Comments
--
-- NAME
--   Get_ListPinCode
--
-- PURPOSE
--   This procedure Gets The Pin Code for a List Entry.
--
-- NOTES
--
--
-- HISTORY
--   06/08/1999        tdonohoe            created
-- End of Comments
Function Get_ListPinCode(p_list_header_id IN NUMBER,
                         p_list_entry_id  IN NUMBER)
Return Varchar2 IS

Begin

   return(to_char(p_list_entry_id));

End Get_ListPinCode;

---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_uk_items
--
-- HISTORY
--    10/16/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_entry_uk_items(
   p_entry_rec        IN  entry_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
  --Check if The Pin Code is Unique across all lists.
  Cursor C_Is_Pin_Unique IS SELECT Count(*)
                            FROM   Ams_List_Entries
                            WHERE  Pin_Code        = p_entry_rec.pin_code
			    AND    List_Entry_Id  <> p_entry_rec.List_Entry_Id;

  l_pin_count number;

  --Check if The List Entry System ID and type is Unique for this list.
  Cursor C_Is_SysID_Unique IS   SELECT COUNT(*)
                                FROM   Ams_List_Entries
                                WHERE  List_Header_Id                = p_entry_rec.list_header_id
                                AND    List_Entry_Source_System_id   = p_entry_rec.List_Entry_Source_System_ID
                                AND    List_Entry_Source_System_Type = p_entry_rec.List_Entry_Source_System_Type
				AND    List_Entry_Id                <> p_entry_rec.List_Entry_Id;

  l_source_system_count number;

Begin

    x_return_status := FND_API.g_ret_sts_success;

    Open  C_Is_SysID_Unique;
    Fetch C_Is_SysID_Unique into l_source_system_count;
    Close C_Is_SysID_Unique;

    IF(l_source_system_count > 0 )THEN
            -- Error, check the msg level and added an error message to the
            -- API message list
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN -- MMSG
                  FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_SYSID_DUPE');
                  FND_MSG_PUB.Add;
             END IF;

             -- If any errors happen abort API/Procedure.
             RAISE FND_API.G_EXC_ERROR;
             RETURN;
    END IF;


    Open  C_Is_Pin_Unique;
    Fetch C_Is_Pin_Unique into l_pin_count;
    Close C_Is_Pin_Unique;

    IF ( l_pin_count <> 0 )THEN
             -- Error, check the msg level and added an error message to the
             -- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                     FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_PINCODE_DUPE');
                     FND_MSG_PUB.Add;
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;
                -- If any errors happen abort API/Procedure.
                RAISE FND_API.G_EXC_ERROR;
                RETURN;
     END IF;

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


End;

---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_fk_items
--
-- HISTORY
--    10/16/1999  tdonohoe Created.
--    06/06/2000  tdonohoe Modified to include checks for PARTY_ID
--                and PARENT_PARTY_ID.
---------------------------------------------------------------------
PROCEDURE check_entry_fk_items(
   p_entry_rec        IN  entry_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   -------------------------- Party_Id ------------------------
   IF p_entry_rec.party_id <> FND_API.g_miss_num  AND p_entry_rec.party_id IS NOT NULL THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'hz_parties',
            'party_id',
            p_entry_rec.party_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_PARTY_INVALID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   --------------------------Parent_Party_Id ------------------------
   IF p_entry_rec.parent_party_id <> FND_API.g_miss_num AND p_entry_rec.parent_party_id IS NOT NULL THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'hz_parties',
            'party_id',
            p_entry_rec.parent_party_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_PAR_PARTY_INVALID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -------------------------- List Header Id ------------------------
   IF p_entry_rec.list_header_id <> FND_API.g_miss_num  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_list_headers_all',
            'list_header_id',
            p_entry_rec.list_header_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ID_MISSING');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -------------------------- Cell Code ------------------------
   IF (p_entry_rec.cell_code <> FND_API.g_miss_char) AND
      (p_entry_rec.cell_code <> NULL)
   THEN


       IF ( AMS_UTILITY_PVT.Check_FK_Exists('AMS_CELLS_ALL_B',
                                            'CELL_CODE',
                                            p_entry_rec.CELL_CODE)= FND_API.G_FALSE)
       THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                     FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_CELLCODE_INVALID');
                     FND_MESSAGE.set_token('CELLCODE',p_entry_rec.CELL_CODE);
                     FND_MSG_PUB.Add;
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;
                -- If any errors happen abort API/Procedure.
                RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;


  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


End;

---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_lookup_items
--
-- HISTORY
--    10/16/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_entry_lookup_items(
   p_entry_rec        IN  entry_rec_type,
   x_return_status   OUT NOCOPY  VARCHAR2
)
IS
BEGIN
  x_return_status := FND_API.g_ret_sts_success;
End;

---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_flag_items
--
-- HISTORY
--    10/01/99  tdonohoe  Create.
---------------------------------------------------------------------
PROCEDURE check_entry_flag_items(
   p_entry_rec        IN  entry_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- enabled_flag ------------------------
   IF  p_entry_rec.enabled_flag <> FND_API.G_MISS_CHAR
   AND p_entry_rec.enabled_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_entry_rec.enabled_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_BAD_ENABLED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;




   ----------------------- PART_OF_CONTROL_GROUP_FLAG  ------------------------
   IF p_entry_rec.PART_OF_CONTROL_GROUP_FLAG      <> FND_API.g_miss_char
      AND p_entry_rec.PART_OF_CONTROL_GROUP_FLAG      IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_entry_rec.PART_OF_CONTROL_GROUP_FLAG) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_BAD_CONTROL_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- MARKED_AS_RANDOM_FLAG ------------------------
   IF p_entry_rec.MARKED_AS_RANDOM_FLAG <> FND_API.g_miss_char
      AND p_entry_rec.MARKED_AS_RANDOM_FLAG IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_entry_rec.MARKED_AS_RANDOM_FLAG) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_BAD_RANDOM_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- MARKED_AS_DUPLICATE_FLAG ------------------------
   IF p_entry_rec.MARKED_AS_DUPLICATE_FLAG<> FND_API.g_miss_char
      AND p_entry_rec.MARKED_AS_DUPLICATE_FLAG IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_entry_rec.MARKED_AS_DUPLICATE_FLAG) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_BAD_DUPE_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- MANUALLY ENTERED FLAG ------------------------
   IF p_entry_rec.MANUALLY_ENTERED_FLAG <> FND_API.g_miss_char
      AND p_entry_rec.MANUALLY_ENTERED_FLAG IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_entry_rec.MANUALLY_ENTERED_FLAG) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ENT_BAD_MANUAL_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


End;
---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_req_items
--
-- HISTORY
--    10/16/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_entry_req_items(
   p_entry_rec       IN entry_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
 IS

BEGIN

    --  Initialize API/Procedure return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_entry_rec.list_header_id IS NULL
    THEN
                -- missing required fields
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                    FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ENT_HEADER_MISSING');
                    FND_MSG_PUB.Add;
                END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- If any errors happen abort API/Procedure.
        return;
    END IF;


    IF  p_entry_rec.list_entry_source_system_ID IS NULL
    THEN
                -- missing required fields
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                    FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ENT_SYSID_MISSING');
                    FND_MSG_PUB.Add;
                END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             -- If any errors happen abort API/Procedure.
             return;
    END IF;

    IF p_entry_rec.list_entry_source_system_type IS NULL
    THEN
                -- missing required fields
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                    FND_MESSAGE.Set_Name('AMS', 'AMS_LIST_ENT_SYSTYPE_MISSING');
                    FND_MSG_PUB.Add;
                END IF;
             x_return_status := FND_API.G_RET_STS_ERROR;
             -- If any errors happen abort API/Procedure.
             return;
    END IF;

  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END check_entry_req_items;



---------------------------------------------------------------------
-- PROCEDURE
--    validate_listentry
--
-- PURPOSE
--    Validate a listentry record.
--
-- PARAMETERS
--    p_entry_rec: the listentry record to be validated
--
-- NOTES
--    1. p_entry_rec should be the complete list entry  record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec         IN  entry_rec_type
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_Entry';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_entry_rec                    entry_rec_type := p_entry_rec;
        l_list_entry_id                NUMBER;

BEGIN



        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listentry_PVT.Validate_Entry: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        ---------------------- validate ------------------------
       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
            check_entry_items(
              p_entry_rec        => p_entry_rec,
              p_validation_mode => JTF_PLSQL_API.g_create,
              x_return_status   => l_return_status);

          IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          END IF;
       END IF;

       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
            check_entry_record(
              p_entry_rec       => p_entry_rec,
              p_complete_rec   => NULL,
              x_return_status  => l_return_status);

          IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          ELSIF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          END IF;
       END IF;

        -- Success Message
        -- MMSG
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listentry_PVT.Validate_ListEntry', TRUE);
            FND_MSG_PUB.Add;
        END IF;


        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_listentry_PVT.Validate_ListEntry: END', TRUE);
            FND_MSG_PUB.Add;
        END IF;


        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded         =>      FND_API.G_FALSE
        );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
            );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
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
          p_encoded     =>      FND_API.G_FALSE
            );

End Validate_ListEntry;


---------------------------------------------------------------------
-- PROCEDURE
--    create_listentry
--
-- PURPOSE
--    Create a new list entry.
--
-- PARAMETERS
--    p_entry_rec: the new record to be inserted
--    x_entry_id: return the list_entry_id of the new list entry
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. If list_entry_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If list_entry_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
-- HISTORY
--    06/06/2000 tdonohoe added SOURCE_CODE_FOR_ID,PARTY_ID AND PARENT_PARTY_ID columns.
---------------------------------------------------------------------
PROCEDURE create_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec         IN  entry_rec_type,
   x_entry_id          OUT NOCOPY NUMBER
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Create_ListEntry';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status               VARCHAR2(1);  -- Return value from procedures
        l_list_entry_id               NUMBER;

        l_sqlerrm varchar2(600);
        l_sqlcode varchar2(100);

        l_listentry_rec   entry_rec_type := p_entry_rec;
        l_entry_count     NUMBER;

        l_list_used_by_id  NUMBER;
        l_arc_list_used_by VARCHAR2(30);


        CURSOR c_entry_seq IS
        SELECT ams_list_entries_s.NEXTVAL
        FROM DUAL;

        CURSOR c_entry_count(entry_id IN NUMBER) IS
        SELECT COUNT(*)
        FROM   ams_list_entries
        WHERE  list_entry_id = entry_id;


	        l_created_by                NUMBER;  --batoleti added this var. For bug# 6688996
	/* batoleti. Bug# 6688996. Added the below cursor */
       CURSOR cur_get_created_by (x_list_header_id IN NUMBER) IS
      SELECT created_by
      FROM ams_list_headers_all
      WHERE list_header_id= x_list_header_id;


  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Create_ListEntry_PVT;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_ListEntry_PVT.Create_ListEntry: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


       Default_ListEntry
       ( p_init_msg_list        => p_init_msg_list,
   	 p_listentry_rec        => p_entry_rec,
   	 p_validation_mode      => JTF_PLSQL_API.g_create,
   	 x_complete_rec         => l_listentry_rec,
   	 x_return_status        => l_return_status,
   	 x_msg_count            => x_msg_count,
   	 x_msg_data             => x_msg_data  ) ;

       -- If any errors happen abort API.
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       Validate_ListEntry
      ( p_api_version                       => 1.0
        ,p_init_msg_list                    => p_init_msg_list
        ,p_validation_level                 => p_validation_level
        ,x_return_status                    => l_return_status
        ,x_msg_count                        => x_msg_count
        ,x_msg_data                         => x_msg_data
        ,p_entry_rec                        => l_listentry_rec
       );

       -- If any errors happen abort API.
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       IF l_listentry_rec.list_entry_id IS NULL THEN
       LOOP
           OPEN c_entry_seq;
           FETCH c_entry_seq INTO l_listentry_rec.list_entry_id;
           CLOSE c_entry_seq;

           OPEN c_entry_count(l_listentry_rec.list_entry_id);
           FETCH c_entry_count INTO l_entry_count;
           CLOSE c_entry_count;

           EXIT WHEN l_entry_count = 0;
         END LOOP;
       END IF;

       --getting the pin_code for the list entry.
       l_listentry_rec.pin_code := Get_ListPinCode(l_listentry_rec.list_header_id,
                                                   l_listentry_rec.list_entry_id);

   -- batoleti  coding starts for bug# 6688996
      l_created_by := 0;

       OPEN cur_get_created_by(l_listentry_rec.LIST_HEADER_ID);

       FETCH cur_get_created_by INTO l_created_by;
       CLOSE cur_get_created_by;

   -- batoleti  coding ends for bug# 6688996

       INSERT INTO ams_list_entries
       (list_entry_id

       ,last_update_date
       ,last_updated_by
       ,creation_date
       ,created_by

       ,last_update_login
       ,object_version_number

       ,view_application_id

       ,list_header_id
       ,list_select_action_id
       ,arc_list_select_action_from
       ,list_select_action_from_name
       ,source_code
       ,arc_list_used_by_source
       ,source_code_for_id
       ,pin_code
       ,list_entry_source_system_id
       ,list_entry_source_system_type
       ,manually_entered_flag
       ,marked_as_duplicate_flag
       ,marked_as_random_flag
       ,part_of_control_group_flag
       ,exclude_in_triggered_list_flag
       ,enabled_flag
       ,cell_code
       ,dedupe_key
       ,campaign_id
       ,media_id
       ,channel_id
       ,channel_schedule_id
       ,event_offer_id
       ,customer_id
       ,market_segment_id
       ,vendor_id
       ,transfer_flag
       ,transfer_status
       ,list_source
       ,duplicate_master_entry_id
       ,marked_flag
       ,lead_id
       ,letter_id
       ,picking_header_id
       ,batch_id
       ,col1
       ,col2
       ,col3
       ,col4
       ,col5
       ,col6
       ,col7
       ,col8
       ,col9
       ,col10
       ,col11
       ,col12
       ,col13
       ,col14
       ,col15
       ,col16
       ,col17
       ,col18
       ,col19
       ,col20
       ,col21
       ,col22
       ,col23
       ,col24
       ,col25
       ,col26
       ,col27
       ,col28
       ,col29
       ,col30
       ,col31
       ,col32
       ,col33
       ,col34
       ,col35
       ,col36
       ,col37
       ,col38
       ,col39
       ,col40
       ,col41
       ,col42
       ,col43
       ,col44
       ,col45
       ,col46
       ,col47
       ,col48
       ,col49
       ,col50
       ,col51
       ,col52
       ,col53
       ,col54
       ,col55
       ,col56
       ,col57
       ,col58
       ,col59
       ,col60
       ,col61
       ,col62
       ,col63
       ,col64
       ,col65
       ,col66
       ,col67
       ,col68
       ,col69
       ,col70
       ,col71
       ,col72
       ,col73
       ,col74
       ,col75
       ,col76
       ,col77
       ,col78
       ,col79
       ,col80
       ,col81
       ,col82
       ,col83
       ,col84
       ,col85
       ,col86
       ,col87
       ,col88
       ,col89
       ,col90
       ,col91
       ,col92
       ,col93
       ,col94
       ,col95
       ,col96
       ,col97
       ,col98
       ,col99
       ,col100
       ,col101
       ,col102
       ,col103
       ,col104
       ,col105
       ,col106
       ,col107
       ,col108
       ,col109
       ,col110
       ,col111
       ,col112
       ,col113
       ,col114
       ,col115
       ,col116
       ,col117
       ,col118
       ,col119
       ,col120
       ,col121
       ,col122
       ,col123
       ,col124
       ,col125
       ,col126
       ,col127
       ,col128
       ,col129
       ,col130
       ,col131
       ,col132
       ,col133
       ,col134
       ,col135
       ,col136
       ,col137
       ,col138
       ,col139
       ,col140
       ,col141
       ,col142
       ,col143
       ,col144
       ,col145
       ,col146
       ,col147
       ,col148
       ,col149
       ,col150
       ,col151
       ,col152
       ,col153
       ,col154
       ,col155
       ,col156
       ,col157
       ,col158
       ,col159
       ,col160
       ,col161
       ,col162
       ,col163
       ,col164
       ,col165
       ,col166
       ,col167
       ,col168
       ,col169
       ,col170
       ,col171
       ,col172
       ,col173
       ,col174
       ,col175
       ,col176
       ,col177
       ,col178
       ,col179
       ,col180
       ,col181
       ,col182
       ,col183
       ,col184
       ,col185
       ,col186
       ,col187
       ,col188
       ,col189
       ,col190
       ,col200
       ,col201
       ,col202
       ,col203
       ,col204
       ,col205
       ,col206
       ,col207
       ,col208
       ,col209
       ,col210
       ,col211
       ,col212
       ,col213
       ,col214
       ,col215
       ,col216
       ,col217
       ,col218
       ,col219
       ,col220
       ,col221
       ,col222
       ,col223
       ,col224
       ,col225
       ,col226
       ,col227
       ,col228
       ,col229
       ,col230
       ,col231
       ,col232
       ,col233
       ,col234
       ,col235
       ,col236
       ,col237
       ,col238
       ,col239
       ,col240
       ,col241
       ,col242
       ,col243
       ,col244
       ,col245
       ,col246
       ,col247
       ,col248
       ,col249
       ,col250
       ,COL251
       ,COL252
       ,COL253
       ,COL254
       ,COL255
       ,COL256
       ,COL257
       ,COL258
       ,COL259
       ,COL260
       ,COL261
       ,COL262
       ,COL263
       ,COL264
       ,COL265
       ,COL266
       ,COL267
       ,COL268
       ,COL269
       ,COL270
       ,COL271
       ,COL272
       ,COL273
       ,COL274
       ,COL275
       ,COL276
       ,COL277
       ,COL278
       ,COL279
       ,COL280
       ,COL281
       ,COL282
       ,COL283
       ,COL284
       ,COL285
       ,COL286
       ,COL287
       ,COL288
       ,COL289
       ,COL290
       ,COL291
       ,COL292
       ,COL293
       ,COL294
       ,COL295
       ,COL296
       ,COL297
       ,COL298
       ,COL299
       ,COL300
       ,ADDRESS_LINE1
       ,ADDRESS_LINE2
       ,CALLBACK_FLAG
       ,CITY
       ,COUNTRY
       ,DO_NOT_USE_FLAG
       ,DO_NOT_USE_REASON
       ,EMAIL_ADDRESS
       ,FAX
       ,PHONE
       ,RECORD_OUT_FLAG
       ,STATE
       ,SUFFIX
       ,TITLE
       ,USAGE_RESTRICTION
       ,ZIPCODE
       ,CURR_CP_COUNTRY_CODE
       ,CURR_CP_PHONE_NUMBER
       ,CURR_CP_RAW_PHONE_NUMBER
       ,CURR_CP_AREA_CODE
       ,CURR_CP_ID
       ,CURR_CP_INDEX
       ,CURR_CP_TIME_ZONE
       ,CURR_CP_TIME_ZONE_AUX
       ,IMP_SOURCE_LINE_ID
       ,NEXT_CALL_TIME
       ,RECORD_RELEASE_TIME
       ,party_id
       ,parent_party_id
       )
 VALUES
 (    l_listentry_rec.list_entry_id

     ,sysdate
     ,FND_GLOBAL.User_Id
     ,sysdate
     ,nvl(l_created_by,FND_GLOBAL.User_Id)
     ,FND_GLOBAL.Conc_Login_Id

     ,1--OBJECT_VERSION_NUMBER

     ,FND_GLOBAL.RESP_APPL_ID

     ,l_listentry_rec.LIST_HEADER_ID
     ,l_listentry_rec.LIST_SELECT_ACTION_ID
     ,l_listentry_rec.ARC_LIST_SELECT_ACTION_FROM
     ,l_listentry_rec.LIST_SELECT_ACTION_FROM_NAME
     ,l_listentry_rec.SOURCE_CODE
     ,l_listentry_rec.ARC_LIST_USED_BY_SOURCE
     ,l_listentry_rec.SOURCE_CODE_FOR_ID
     ,l_listentry_rec.PIN_CODE--pin code corresponds to the list_entry_id.
     ,l_listentry_rec.LIST_ENTRY_SOURCE_SYSTEM_ID
     ,l_listentry_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE
     ,NVL(l_listentry_rec.MANUALLY_ENTERED_FLAG,'Y')
     ,NVL(l_listentry_rec.MARKED_AS_DUPLICATE_FLAG,'N')
     ,NVL(l_listentry_rec.MARKED_AS_RANDOM_FLAG,'N')
     ,NVL(l_listentry_rec.PART_OF_CONTROL_GROUP_FLAG,'N')
     ,NVL(l_listentry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG,'N')
     ,NVL(l_listentry_rec.ENABLED_FLAG,'Y')
     ,l_listentry_rec.CELL_CODE
     ,l_listentry_rec.DEDUPE_KEY
     ,l_listentry_rec.CAMPAIGN_ID
     ,l_listentry_rec.MEDIA_ID
     ,l_listentry_rec.CHANNEL_ID
     ,l_listentry_rec.CHANNEL_SCHEDULE_ID
     ,l_listentry_rec.EVENT_OFFER_ID
     ,l_listentry_rec.CUSTOMER_ID
     ,l_listentry_rec.MARKET_SEGMENT_ID
     ,l_listentry_rec.VENDOR_ID
     ,l_listentry_rec.TRANSFER_FLAG
     ,l_listentry_rec.TRANSFER_STATUS
     ,l_listentry_rec.LIST_SOURCE
     ,l_listentry_rec.DUPLICATE_MASTER_ENTRY_ID
     ,l_listentry_rec.MARKED_FLAG
     ,l_listentry_rec.LEAD_ID
     ,l_listentry_rec.LETTER_ID
     ,l_listentry_rec.PICKING_HEADER_ID
     ,l_listentry_rec.BATCH_ID
     ,l_listentry_rec.COL1
     ,l_listentry_rec.COL2
     ,l_listentry_rec.COL3
     ,l_listentry_rec.COL4
     ,l_listentry_rec.COL5
     ,l_listentry_rec.COL6
     ,l_listentry_rec.COL7
     ,l_listentry_rec.COL8
     ,l_listentry_rec.COL9
     ,l_listentry_rec.COL10
     ,l_listentry_rec.COL11
     ,l_listentry_rec.COL12
     ,l_listentry_rec.COL13
     ,l_listentry_rec.COL14
     ,l_listentry_rec.COL15
     ,l_listentry_rec.COL16
     ,l_listentry_rec.COL17
     ,l_listentry_rec.COL18
     ,l_listentry_rec.COL19
     ,l_listentry_rec.COL20
     ,l_listentry_rec.COL21
     ,l_listentry_rec.COL22
     ,l_listentry_rec.COL23
     ,l_listentry_rec.COL24
     ,l_listentry_rec.COL25
     ,l_listentry_rec.COL26
     ,l_listentry_rec.COL27
     ,l_listentry_rec.COL28
     ,l_listentry_rec.COL29
     ,l_listentry_rec.COL30
     ,l_listentry_rec.COL31
     ,l_listentry_rec.COL32
     ,l_listentry_rec.COL33
     ,l_listentry_rec.COL34
     ,l_listentry_rec.COL35
     ,l_listentry_rec.COL36
     ,l_listentry_rec.COL37
     ,l_listentry_rec.COL38
     ,l_listentry_rec.COL39
     ,l_listentry_rec.COL40
     ,l_listentry_rec.COL41
     ,l_listentry_rec.COL42
     ,l_listentry_rec.COL43
     ,l_listentry_rec.COL44
     ,l_listentry_rec.COL45
     ,l_listentry_rec.COL46
     ,l_listentry_rec.COL47
     ,l_listentry_rec.COL48
     ,l_listentry_rec.COL49
     ,l_listentry_rec.COL50
     ,l_listentry_rec.COL51
     ,l_listentry_rec.COL52
     ,l_listentry_rec.COL53
     ,l_listentry_rec.COL54
     ,l_listentry_rec.COL55
     ,l_listentry_rec.COL56
     ,l_listentry_rec.COL57
     ,l_listentry_rec.COL58
     ,l_listentry_rec.COL59
     ,l_listentry_rec.COL60
     ,l_listentry_rec.COL61
     ,l_listentry_rec.COL62
     ,l_listentry_rec.COL63
     ,l_listentry_rec.COL64
     ,l_listentry_rec.COL65
     ,l_listentry_rec.COL66
     ,l_listentry_rec.COL67
     ,l_listentry_rec.COL68
     ,l_listentry_rec.COL69
     ,l_listentry_rec.COL70
     ,l_listentry_rec.COL71
     ,l_listentry_rec.COL72
     ,l_listentry_rec.COL73
     ,l_listentry_rec.COL74
     ,l_listentry_rec.COL75
     ,l_listentry_rec.COL76
     ,l_listentry_rec.COL77
     ,l_listentry_rec.COL78
     ,l_listentry_rec.COL79
     ,l_listentry_rec.COL80
     ,l_listentry_rec.COL81
     ,l_listentry_rec.COL82
     ,l_listentry_rec.COL83
     ,l_listentry_rec.COL84
     ,l_listentry_rec.COL85
     ,l_listentry_rec.COL86
     ,l_listentry_rec.COL87
     ,l_listentry_rec.COL88
     ,l_listentry_rec.COL89
     ,l_listentry_rec.COL90
     ,l_listentry_rec.COL91
     ,l_listentry_rec.COL92
     ,l_listentry_rec.COL93
     ,l_listentry_rec.COL94
     ,l_listentry_rec.COL95
     ,l_listentry_rec.COL96
     ,l_listentry_rec.COL97
     ,l_listentry_rec.COL98
     ,l_listentry_rec.COL99
     ,l_listentry_rec.COL100
     ,l_listentry_rec.COL101
     ,l_listentry_rec.COL102
     ,l_listentry_rec.COL103
     ,l_listentry_rec.COL104
     ,l_listentry_rec.COL105
     ,l_listentry_rec.COL106
     ,l_listentry_rec.COL107
     ,l_listentry_rec.COL108
     ,l_listentry_rec.COL109
     ,l_listentry_rec.COL110
     ,l_listentry_rec.COL111
     ,l_listentry_rec.COL112
     ,l_listentry_rec.COL113
     ,l_listentry_rec.COL114
     ,l_listentry_rec.COL115
     ,l_listentry_rec.COL116
     ,l_listentry_rec.COL117
     ,l_listentry_rec.COL118
     ,l_listentry_rec.COL119
     ,l_listentry_rec.COL120
     ,l_listentry_rec.COL121
     ,l_listentry_rec.COL122
     ,l_listentry_rec.COL123
     ,l_listentry_rec.COL124
     ,l_listentry_rec.COL125
     ,l_listentry_rec.COL126
     ,l_listentry_rec.COL127
     ,l_listentry_rec.COL128
     ,l_listentry_rec.COL129
     ,l_listentry_rec.COL130
     ,l_listentry_rec.COL131
     ,l_listentry_rec.COL132
     ,l_listentry_rec.COL133
     ,l_listentry_rec.COL134
     ,l_listentry_rec.COL135
     ,l_listentry_rec.COL136
     ,l_listentry_rec.COL137
     ,l_listentry_rec.COL138
     ,l_listentry_rec.COL139
     ,l_listentry_rec.COL140
     ,l_listentry_rec.COL141
     ,l_listentry_rec.COL142
     ,l_listentry_rec.COL143
     ,l_listentry_rec.COL144
     ,l_listentry_rec.COL145
     ,l_listentry_rec.COL146
     ,l_listentry_rec.COL147
     ,l_listentry_rec.COL148
     ,l_listentry_rec.COL149
     ,l_listentry_rec.COL150
     ,l_listentry_rec.COL151
     ,l_listentry_rec.COL152
     ,l_listentry_rec.COL153
     ,l_listentry_rec.COL154
     ,l_listentry_rec.COL155
     ,l_listentry_rec.COL156
     ,l_listentry_rec.COL157
     ,l_listentry_rec.COL158
     ,l_listentry_rec.COL159
     ,l_listentry_rec.COL160
     ,l_listentry_rec.COL161
     ,l_listentry_rec.COL162
     ,l_listentry_rec.COL163
     ,l_listentry_rec.COL164
     ,l_listentry_rec.COL165
     ,l_listentry_rec.COL166
     ,l_listentry_rec.COL167
     ,l_listentry_rec.COL168
     ,l_listentry_rec.COL169
     ,l_listentry_rec.COL170
     ,l_listentry_rec.COL171
     ,l_listentry_rec.COL172
     ,l_listentry_rec.COL173
     ,l_listentry_rec.COL174
     ,l_listentry_rec.COL175
     ,l_listentry_rec.COL176
     ,l_listentry_rec.COL177
     ,l_listentry_rec.COL178
     ,l_listentry_rec.COL179
     ,l_listentry_rec.COL180
     ,l_listentry_rec.COL181
     ,l_listentry_rec.COL182
     ,l_listentry_rec.COL183
     ,l_listentry_rec.COL184
     ,l_listentry_rec.COL185
     ,l_listentry_rec.COL186
     ,l_listentry_rec.COL187
     ,l_listentry_rec.COL188
     ,l_listentry_rec.COL189
     ,l_listentry_rec.COL190
     ,l_listentry_rec.COL200
     ,l_listentry_rec.COL201
     ,l_listentry_rec.COL202
     ,l_listentry_rec.COL203
     ,l_listentry_rec.COL204
     ,l_listentry_rec.COL205
     ,l_listentry_rec.COL206
     ,l_listentry_rec.COL207
     ,l_listentry_rec.COL208
     ,l_listentry_rec.COL209
     ,l_listentry_rec.COL210
     ,l_listentry_rec.COL211
     ,l_listentry_rec.COL212
     ,l_listentry_rec.COL213
     ,l_listentry_rec.COL214
     ,l_listentry_rec.COL215
     ,l_listentry_rec.COL216
     ,l_listentry_rec.COL217
     ,l_listentry_rec.COL218
     ,l_listentry_rec.COL219
     ,l_listentry_rec.COL220
     ,l_listentry_rec.COL221
     ,l_listentry_rec.COL222
     ,l_listentry_rec.COL223
     ,l_listentry_rec.COL224
     ,l_listentry_rec.COL225
     ,l_listentry_rec.COL226
     ,l_listentry_rec.COL227
     ,l_listentry_rec.COL228
     ,l_listentry_rec.COL229
     ,l_listentry_rec.COL230
     ,l_listentry_rec.COL231
     ,l_listentry_rec.COL232
     ,l_listentry_rec.COL233
     ,l_listentry_rec.COL234
     ,l_listentry_rec.COL235
     ,l_listentry_rec.COL236
     ,l_listentry_rec.COL237
     ,l_listentry_rec.COL238
     ,l_listentry_rec.COL239
     ,l_listentry_rec.COL240
     ,l_listentry_rec.COL241
     ,l_listentry_rec.COL242
     ,l_listentry_rec.COL243
     ,l_listentry_rec.COL244
     ,l_listentry_rec.COL245
     ,l_listentry_rec.COL246
     ,l_listentry_rec.COL247
     ,l_listentry_rec.COL248
     ,l_listentry_rec.COL249
     ,l_listentry_rec.COL250
       ,l_listentry_rec.COL251
       ,l_listentry_rec.COL252
       ,l_listentry_rec.COL253
       ,l_listentry_rec.COL254
       ,l_listentry_rec.COL255
       ,l_listentry_rec.COL256
       ,l_listentry_rec.COL257
       ,l_listentry_rec.COL258
       ,l_listentry_rec.COL259
       ,l_listentry_rec.COL260
       ,l_listentry_rec.COL261
       ,l_listentry_rec.COL262
       ,l_listentry_rec.COL263
       ,l_listentry_rec.COL264
       ,l_listentry_rec.COL265
       ,l_listentry_rec.COL266
       ,l_listentry_rec.COL267
       ,l_listentry_rec.COL268
       ,l_listentry_rec.COL269
       ,l_listentry_rec.COL270
       ,l_listentry_rec.COL271
       ,l_listentry_rec.COL272
       ,l_listentry_rec.COL273
       ,l_listentry_rec.COL274
       ,l_listentry_rec.COL275
       ,l_listentry_rec.COL276
       ,l_listentry_rec.COL277
       ,l_listentry_rec.COL278
       ,l_listentry_rec.COL279
       ,l_listentry_rec.COL280
       ,l_listentry_rec.COL281
       ,l_listentry_rec.COL282
       ,l_listentry_rec.COL283
       ,l_listentry_rec.COL284
       ,l_listentry_rec.COL285
       ,l_listentry_rec.COL286
       ,l_listentry_rec.COL287
       ,l_listentry_rec.COL288
       ,l_listentry_rec.COL289
       ,l_listentry_rec.COL290
       ,l_listentry_rec.COL291
       ,l_listentry_rec.COL292
       ,l_listentry_rec.COL293
       ,l_listentry_rec.COL294
       ,l_listentry_rec.COL295
       ,l_listentry_rec.COL296
       ,l_listentry_rec.COL297
       ,l_listentry_rec.COL298
       ,l_listentry_rec.COL299
       ,l_listentry_rec.COL300
       ,l_listentry_rec.ADDRESS_LINE1
       ,l_listentry_rec.ADDRESS_LINE2
       ,l_listentry_rec.CALLBACK_FLAG
       ,l_listentry_rec.CITY
       ,l_listentry_rec.COUNTRY
       ,l_listentry_rec.DO_NOT_USE_FLAG
       ,l_listentry_rec.DO_NOT_USE_REASON
       ,l_listentry_rec.EMAIL_ADDRESS
       ,l_listentry_rec.FAX
       ,l_listentry_rec.PHONE
       ,l_listentry_rec.RECORD_OUT_FLAG
       ,l_listentry_rec.STATE
       ,l_listentry_rec.SUFFIX
       ,l_listentry_rec.TITLE
       ,l_listentry_rec.USAGE_RESTRICTION
       ,l_listentry_rec.ZIPCODE
       ,l_listentry_rec.CURR_CP_COUNTRY_CODE
       ,l_listentry_rec.CURR_CP_PHONE_NUMBER
       ,l_listentry_rec.CURR_CP_RAW_PHONE_NUMBER
       ,l_listentry_rec.CURR_CP_AREA_CODE
       ,l_listentry_rec.CURR_CP_ID
       ,l_listentry_rec.CURR_CP_INDEX
       ,l_listentry_rec.CURR_CP_TIME_ZONE
       ,l_listentry_rec.CURR_CP_TIME_ZONE_AUX
       ,l_listentry_rec.IMP_SOURCE_LINE_ID
       ,l_listentry_rec.NEXT_CALL_TIME
       ,l_listentry_rec.RECORD_RELEASE_TIME
     ,l_listentry_rec.PARTY_ID
     ,l_listentry_rec.PARENT_PARTY_ID
     );

     ------------------------- finish -------------------------------
     x_entry_id := l_listentry_rec.list_entry_id;

     -- Standard check of p_commit.
     IF FND_API.To_Boolean ( p_commit )
     THEN
        COMMIT WORK;
     END IF;

     -- Success Message
     -- MMSG
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
     THEN
        FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Create_ListEntry', TRUE);
        FND_MSG_PUB.Add;
     END IF;


     IF (AMS_DEBUG_HIGH_ON) THEN
        FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('ROW','AMS_List_Entry_PVT.Create_ListEntry: END', TRUE);
        FND_MSG_PUB.Add;
     END IF;


     -- Standard call to get message count AND IF count is 1, get message info.
     FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
            );



      EXCEPTION

            WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO Create_ListEntry_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );


            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO Create_ListEntry_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded     =>      FND_API.G_FALSE
                );

            WHEN OTHERS THEN

                ROLLBACK TO Create_ListEntry_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                THEN
                        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                END IF;

                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );

END Create_ListEntry;

---------------------------------------------------------------------
-- PROCEDURE
--    update_listentry
--
-- PURPOSE
--    Update a listentry.
--
-- PARAMETERS
--    p_entry_rec: the record with new items
--
-- NOTES
--
-- HISTORY
--    06/06/2000 tdonohoe added SOURCE_CODE_FOR_ID,PARTY_ID AND PARENT_PARTY_ID columns.
----------------------------------------------------------------------
PROCEDURE update_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_rec          IN  entry_rec_type
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Update_ListEntry';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_listentry_rec                entry_rec_type := p_entry_rec;


  BEGIN


        -- Standard Start of API savepoint
        SAVEPOINT Update_ListEntry_PVT;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW','AMS_List_Header_PVT.Update_list_entry: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;




   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- replace g_miss_char/num/date with current column values
   --init_entry_rec(l_listentry_rec);
   complete_entry_rec(p_entry_rec, l_listentry_rec);

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_entry_items(
         p_entry_rec        => l_listentry_rec,
         p_validation_mode =>  JTF_PLSQL_API.g_update,
         x_return_status   =>  l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;


   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_entry_record(
         p_entry_rec       => p_entry_rec,
         p_complete_rec   => l_listentry_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

    update ams_list_entries
    set
         last_update_date               =  sysdate
        ,last_updated_by                =  FND_GLOBAL.User_Id
        ,last_update_login              =  FND_GLOBAL.Conc_Login_Id
        ,object_version_number          =  l_listentry_rec.object_version_number + 1

        ,EXCLUDE_IN_TRIGGERED_LIST_FLAG =  l_listentry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG
        ,CELL_CODE                      =  l_listentry_rec.CELL_CODE
        ,CAMPAIGN_ID                    =  l_listentry_rec.CAMPAIGN_ID
        ,MEDIA_ID                       =  l_listentry_rec.MEDIA_ID
        ,CHANNEL_ID                     =  l_listentry_rec.CHANNEL_ID
        ,CHANNEL_SCHEDULE_ID            =  l_listentry_rec.CHANNEL_SCHEDULE_ID
        ,EVENT_OFFER_ID                 =  l_listentry_rec.EVENT_OFFER_ID
        ,CUSTOMER_ID                    =  l_listentry_rec.CUSTOMER_ID
        ,MARKET_SEGMENT_ID              =  l_listentry_rec.MARKET_SEGMENT_ID
        ,VENDOR_ID                      =  l_listentry_rec.VENDOR_ID
        ,TRANSFER_FLAG                  =  l_listentry_rec.TRANSFER_FLAG
        ,TRANSFER_STATUS                =  l_listentry_rec.TRANSFER_STATUS
        ,LIST_SOURCE                    =  l_listentry_rec.LIST_SOURCE
        ,DUPLICATE_MASTER_ENTRY_ID      =  l_listentry_rec.DUPLICATE_MASTER_ENTRY_ID
        ,MARKED_FLAG                    =  l_listentry_rec.MARKED_FLAG
        ,LEAD_ID                        =  l_listentry_rec.LEAD_ID
        ,LETTER_ID                      =  l_listentry_rec.LETTER_ID
        ,PICKING_HEADER_ID              =  l_listentry_rec.PICKING_HEADER_ID
        ,BATCH_ID                       =  l_listentry_rec.BATCH_ID
        ,COL1                           =  l_listentry_rec.COL1
        ,COL2                           =  l_listentry_rec.COL2
        ,COL3                           =  l_listentry_rec.COL3
        ,COL4                           =  l_listentry_rec.COL4
        ,COL5                           =  l_listentry_rec.COL5
        ,COL6                           =  l_listentry_rec.COL6
        ,COL7                           =  l_listentry_rec.COL7
        ,COL8                           =  l_listentry_rec.COL8
        ,COL9                           =  l_listentry_rec.COL9
        ,COL10                          =  l_listentry_rec.COL10
        ,COL11                          =  l_listentry_rec.COL11
        ,COL12                          =  l_listentry_rec.COL12
        ,COL13                          =  l_listentry_rec.COL13
        ,COL14                          =  l_listentry_rec.COL14
        ,COL15                          =  l_listentry_rec.COL15
        ,COL16                          =  l_listentry_rec.COL16
        ,COL17                          =  l_listentry_rec.COL17
        ,COL18                          =  l_listentry_rec.COL18
        ,COL19                          =  l_listentry_rec.COL19
        ,COL20                          =  l_listentry_rec.COL20
        ,COL21                          =  l_listentry_rec.COL21
        ,COL22                          =  l_listentry_rec.COL22
        ,COL23                          =  l_listentry_rec.COL23
        ,COL24                          =  l_listentry_rec.COL24
        ,COL25                          =  l_listentry_rec.COL25
        ,COL26                          =  l_listentry_rec.COL26
        ,COL27                          =  l_listentry_rec.COL27
        ,COL28                          =  l_listentry_rec.COL28
        ,COL29                          =  l_listentry_rec.COL29
        ,COL30                          =  l_listentry_rec.COL30
        ,COL31                          =  l_listentry_rec.COL31
        ,COL32                          =  l_listentry_rec.COL32
        ,COL33                          =  l_listentry_rec.COL33
        ,COL34                          =  l_listentry_rec.COL34
        ,COL35                          =  l_listentry_rec.COL35
        ,COL36                          =  l_listentry_rec.COL36
        ,COL37                          =  l_listentry_rec.COL37
        ,COL38                          =  l_listentry_rec.COL38
        ,COL39                          =  l_listentry_rec.COL39
        ,COL40                          =  l_listentry_rec.COL40
        ,COL41                          =  l_listentry_rec.COL41
        ,COL42                          =  l_listentry_rec.COL42
        ,COL43                          =  l_listentry_rec.COL43
        ,COL44                          =  l_listentry_rec.COL44
        ,COL45                          =  l_listentry_rec.COL45
        ,COL46                          =  l_listentry_rec.COL46
        ,COL47                          =  l_listentry_rec.COL47
        ,COL48                          =  l_listentry_rec.COL48
        ,COL49                          =  l_listentry_rec.COL49
        ,COL50                          =  l_listentry_rec.COL50
        ,COL51                          =  l_listentry_rec.COL51
        ,COL52                          =  l_listentry_rec.COL52
        ,COL53                          =  l_listentry_rec.COL53
        ,COL54                          =  l_listentry_rec.COL54
        ,COL55                          =  l_listentry_rec.COL55
        ,COL56                          =  l_listentry_rec.COL56
        ,COL57                          =  l_listentry_rec.COL57
        ,COL58                          =  l_listentry_rec.COL58
        ,COL59                          =  l_listentry_rec.COL59
        ,COL60                          =  l_listentry_rec.COL60
        ,COL61                          =  l_listentry_rec.COL61
        ,COL62                          =  l_listentry_rec.COL62
        ,COL63                          =  l_listentry_rec.COL63
        ,COL64                          =  l_listentry_rec.COL64
        ,COL65                          =  l_listentry_rec.COL65
        ,COL66                          =  l_listentry_rec.COL66
        ,COL67                          =  l_listentry_rec.COL67
        ,COL68                          =  l_listentry_rec.COL68
        ,COL69                          =  l_listentry_rec.COL69
        ,COL70                          =  l_listentry_rec.COL70
        ,COL71                          =  l_listentry_rec.COL71
        ,COL72                          =  l_listentry_rec.COL72
        ,COL73                          =  l_listentry_rec.COL73
        ,COL74                          =  l_listentry_rec.COL74
        ,COL75                          =  l_listentry_rec.COL75
        ,COL76                          =  l_listentry_rec.COL76
        ,COL77                          =  l_listentry_rec.COL77
        ,COL78                          =  l_listentry_rec.COL78
        ,COL79                          =  l_listentry_rec.COL79
        ,COL80                          =  l_listentry_rec.COL80
        ,COL81                          =  l_listentry_rec.COL81
        ,COL82                          =  l_listentry_rec.COL82
        ,COL83                          =  l_listentry_rec.COL83
        ,COL84                          =  l_listentry_rec.COL84
        ,COL85                          =  l_listentry_rec.COL85
        ,COL86                          =  l_listentry_rec.COL86
        ,COL87                          =  l_listentry_rec.COL87
        ,COL88                          =  l_listentry_rec.COL88
        ,COL89                          =  l_listentry_rec.COL89
        ,COL90                          =  l_listentry_rec.COL90
        ,COL91                          =  l_listentry_rec.COL91
        ,COL92                          =  l_listentry_rec.COL92
        ,COL93                          =  l_listentry_rec.COL93
        ,COL94                          =  l_listentry_rec.COL94
        ,COL95                          =  l_listentry_rec.COL95
        ,COL96                          =  l_listentry_rec.COL96
        ,COL97                          =  l_listentry_rec.COL97
        ,COL98                          =  l_listentry_rec.COL98
        ,COL99                          =  l_listentry_rec.COL99
        ,COL100                         =  l_listentry_rec.COL100
        ,COL101                         =  l_listentry_rec.COL101
        ,COL102                         =  l_listentry_rec.COL102
        ,COL103                         =  l_listentry_rec.COL103
        ,COL104                         =  l_listentry_rec.COL104
        ,COL105                         =  l_listentry_rec.COL105
        ,COL106                         =  l_listentry_rec.COL106
        ,COL107                         =  l_listentry_rec.COL107
        ,COL108                         =  l_listentry_rec.COL108
        ,COL109                         =  l_listentry_rec.COL109
        ,COL110                         =  l_listentry_rec.COL110
        ,COL111                         =  l_listentry_rec.COL111
        ,COL112                         =  l_listentry_rec.COL112
        ,COL113                         =  l_listentry_rec.COL113
        ,COL114                         =  l_listentry_rec.COL114
        ,COL115                         =  l_listentry_rec.COL115
        ,COL116                         =  l_listentry_rec.COL116
        ,COL117                         =  l_listentry_rec.COL117
        ,COL118                         =  l_listentry_rec.COL118
        ,COL119                         =  l_listentry_rec.COL119
        ,COL120                         =  l_listentry_rec.COL120
        ,COL121                         =  l_listentry_rec.COL121
        ,COL122                         =  l_listentry_rec.COL122
        ,COL123                         =  l_listentry_rec.COL123
        ,COL124                         =  l_listentry_rec.COL124
        ,COL125                         =  l_listentry_rec.COL125
        ,COL126                         =  l_listentry_rec.COL126
        ,COL127                         =  l_listentry_rec.COL127
        ,COL128                         =  l_listentry_rec.COL128
        ,COL129                         =  l_listentry_rec.COL129
        ,COL130                         =  l_listentry_rec.COL130
        ,COL131                         =  l_listentry_rec.COL131
        ,COL132                         =  l_listentry_rec.COL132
        ,COL133                         =  l_listentry_rec.COL133
        ,COL134                         =  l_listentry_rec.COL134
        ,COL135                         =  l_listentry_rec.COL135
        ,COL136                         =  l_listentry_rec.COL136
        ,COL137                         =  l_listentry_rec.COL137
        ,COL138                         =  l_listentry_rec.COL138
        ,COL139                         =  l_listentry_rec.COL139
        ,COL140                         =  l_listentry_rec.COL140
        ,COL141                         =  l_listentry_rec.COL141
        ,COL142                         =  l_listentry_rec.COL142
        ,COL143                         =  l_listentry_rec.COL143
        ,COL144                         =  l_listentry_rec.COL144
        ,COL145                         =  l_listentry_rec.COL145
        ,COL146                         =  l_listentry_rec.COL146
        ,COL147                         =  l_listentry_rec.COL147
        ,COL148                         =  l_listentry_rec.COL148
        ,COL149                         =  l_listentry_rec.COL149
        ,COL150                         =  l_listentry_rec.COL150
        ,COL151                         =  l_listentry_rec.COL151
        ,COL152                         =  l_listentry_rec.COL152
        ,COL153                         =  l_listentry_rec.COL153
        ,COL154                         =  l_listentry_rec.COL154
        ,COL155                         =  l_listentry_rec.COL155
        ,COL156                         =  l_listentry_rec.COL156
        ,COL157                         =  l_listentry_rec.COL157
        ,COL158                         =  l_listentry_rec.COL158
        ,COL159                         =  l_listentry_rec.COL159
        ,COL160                         =  l_listentry_rec.COL160
        ,COL161                         =  l_listentry_rec.COL161
        ,COL162                         =  l_listentry_rec.COL162
        ,COL163                         =  l_listentry_rec.COL163
        ,COL164                         =  l_listentry_rec.COL164
        ,COL165                         =  l_listentry_rec.COL165
        ,COL166                         =  l_listentry_rec.COL166
        ,COL167                         =  l_listentry_rec.COL167
        ,COL168                         =  l_listentry_rec.COL168
        ,COL169                         =  l_listentry_rec.COL169
        ,COL170                         =  l_listentry_rec.COL170
        ,COL171                         =  l_listentry_rec.COL171
        ,COL172                         =  l_listentry_rec.COL172
        ,COL173                         =  l_listentry_rec.COL173
        ,COL174                         =  l_listentry_rec.COL174
        ,COL175                         =  l_listentry_rec.COL175
        ,COL176                         =  l_listentry_rec.COL176
        ,COL177                         =  l_listentry_rec.COL177
        ,COL178                         =  l_listentry_rec.COL178
        ,COL179                         =  l_listentry_rec.COL179
        ,COL180                         =  l_listentry_rec.COL180
        ,COL181                         =  l_listentry_rec.COL181
        ,COL182                         =  l_listentry_rec.COL182
        ,COL183                         =  l_listentry_rec.COL183
        ,COL184                         =  l_listentry_rec.COL184
        ,COL185                         =  l_listentry_rec.COL185
        ,COL186                         =  l_listentry_rec.COL186
        ,COL187                         =  l_listentry_rec.COL187
        ,COL188                         =  l_listentry_rec.COL188
        ,COL189                         =  l_listentry_rec.COL189
        ,COL190                         =  l_listentry_rec.COL190
        ,COL200                         =  l_listentry_rec.COL200
        ,COL201                         =  l_listentry_rec.COL201
        ,COL202                         =  l_listentry_rec.COL202
        ,COL203                         =  l_listentry_rec.COL203
        ,COL204                         =  l_listentry_rec.COL204
        ,COL205                         =  l_listentry_rec.COL205
        ,COL206                         =  l_listentry_rec.COL206
        ,COL207                         =  l_listentry_rec.COL207
        ,COL208                         =  l_listentry_rec.COL208
        ,COL209                         =  l_listentry_rec.COL209
        ,COL210                         =  l_listentry_rec.COL210
        ,COL211                         =  l_listentry_rec.COL211
        ,COL212                         =  l_listentry_rec.COL212
        ,COL213                         =  l_listentry_rec.COL213
        ,COL214                         =  l_listentry_rec.COL214
        ,COL215                         =  l_listentry_rec.COL215
        ,COL216                         =  l_listentry_rec.COL216
        ,COL217                         =  l_listentry_rec.COL217
        ,COL218                         =  l_listentry_rec.COL218
        ,COL219                         =  l_listentry_rec.COL219
        ,COL220                         =  l_listentry_rec.COL220
        ,COL221                         =  l_listentry_rec.COL221
        ,COL222                         =  l_listentry_rec.COL222
        ,COL223                         =  l_listentry_rec.COL223
        ,COL224                         =  l_listentry_rec.COL224
        ,COL225                         =  l_listentry_rec.COL225
        ,COL226                         =  l_listentry_rec.COL226
        ,COL227                         =  l_listentry_rec.COL227
        ,COL228                         =  l_listentry_rec.COL228
        ,COL229                         =  l_listentry_rec.COL229
        ,COL230                         =  l_listentry_rec.COL230
        ,COL231                         =  l_listentry_rec.COL231
        ,COL232                         =  l_listentry_rec.COL232
        ,COL233                         =  l_listentry_rec.COL233
        ,COL234                         =  l_listentry_rec.COL234
        ,COL235                         =  l_listentry_rec.COL235
        ,COL236                         =  l_listentry_rec.COL236
        ,COL237                         =  l_listentry_rec.COL237
        ,COL238                         =  l_listentry_rec.COL238
        ,COL239                         =  l_listentry_rec.COL239
        ,COL240                         =  l_listentry_rec.COL240
        ,COL241                         =  l_listentry_rec.COL241
        ,COL242                         =  l_listentry_rec.COL242
        ,COL243                         =  l_listentry_rec.COL243
        ,COL244                         =  l_listentry_rec.COL244
        ,COL245                         =  l_listentry_rec.COL245
        ,COL246                         =  l_listentry_rec.COL246
        ,COL247                         =  l_listentry_rec.COL247
        ,COL248                         =  l_listentry_rec.COL248
        ,COL249                         =  l_listentry_rec.COL249
        ,COL250                         =  l_listentry_rec.COL250
   ,COL251     =  l_listentry_rec.COL251
   ,COL252     =  l_listentry_rec.COL252
   ,COL253     =  l_listentry_rec.COL253
   ,COL254     =  l_listentry_rec.COL254
   ,COL255     =  l_listentry_rec.COL255
   ,COL256     =  l_listentry_rec.COL256
   ,COL257     =  l_listentry_rec.COL257
   ,COL258     =  l_listentry_rec.COL258
   ,COL259     =  l_listentry_rec.COL259
   ,COL260     =  l_listentry_rec.COL260
   ,COL261     =  l_listentry_rec.COL261
   ,COL262     =  l_listentry_rec.COL262
   ,COL263     =  l_listentry_rec.COL263
   ,COL264     =  l_listentry_rec.COL264
   ,COL265     =  l_listentry_rec.COL265
   ,COL266     =  l_listentry_rec.COL266
   ,COL267     =  l_listentry_rec.COL267
   ,COL268     =  l_listentry_rec.COL268
   ,COL269     =  l_listentry_rec.COL269
   ,COL270     =  l_listentry_rec.COL270
   ,COL271     =  l_listentry_rec.COL271
   ,COL272     =  l_listentry_rec.COL272
   ,COL273     =  l_listentry_rec.COL273
   ,COL274     =  l_listentry_rec.COL274
   ,COL275     =  l_listentry_rec.COL275
   ,COL276     =  l_listentry_rec.COL276
   ,COL277     =  l_listentry_rec.COL277
   ,COL278     =  l_listentry_rec.COL278
   ,COL279     =  l_listentry_rec.COL279
   ,COL280     =  l_listentry_rec.COL280
   ,COL281     =  l_listentry_rec.COL281
   ,COL282     =  l_listentry_rec.COL282
   ,COL283     =  l_listentry_rec.COL283
   ,COL284     =  l_listentry_rec.COL284
   ,COL285     =  l_listentry_rec.COL285
   ,COL286     =  l_listentry_rec.COL286
   ,COL287     =  l_listentry_rec.COL287
   ,COL288     =  l_listentry_rec.COL288
   ,COL289     =  l_listentry_rec.COL289
   ,COL290     =  l_listentry_rec.COL290
   ,COL291     =  l_listentry_rec.COL291
   ,COL292     =  l_listentry_rec.COL292
   ,COL293     =  l_listentry_rec.COL293
   ,COL294     =  l_listentry_rec.COL294
   ,COL295     =  l_listentry_rec.COL295
   ,COL296     =  l_listentry_rec.COL296
   ,COL297     =  l_listentry_rec.COL297
   ,COL298     =  l_listentry_rec.COL298
   ,COL299     =  l_listentry_rec.COL299
   ,COL300     =  l_listentry_rec.COL300
   ,ADDRESS_LINE1     =  l_listentry_rec.ADDRESS_LINE1
   ,ADDRESS_LINE2     =  l_listentry_rec.ADDRESS_LINE2
   ,CALLBACK_FLAG     =  l_listentry_rec.CALLBACK_FLAG
   ,CITY     =  l_listentry_rec.CITY
   ,COUNTRY     =  l_listentry_rec.COUNTRY
   ,DO_NOT_USE_FLAG     =  l_listentry_rec.DO_NOT_USE_FLAG
   ,DO_NOT_USE_REASON     =  l_listentry_rec.DO_NOT_USE_REASON
   ,EMAIL_ADDRESS     =  l_listentry_rec.EMAIL_ADDRESS
   ,FAX     =  l_listentry_rec.FAX
   ,PHONE     =  l_listentry_rec.PHONE
   ,RECORD_OUT_FLAG     =  l_listentry_rec.RECORD_OUT_FLAG
   ,STATE     =  l_listentry_rec.STATE
   ,SUFFIX     =  l_listentry_rec.SUFFIX
   ,TITLE     =  l_listentry_rec.TITLE
   ,USAGE_RESTRICTION     =  l_listentry_rec.USAGE_RESTRICTION
   ,ZIPCODE     =  l_listentry_rec.ZIPCODE
   ,CURR_CP_COUNTRY_CODE     =  l_listentry_rec.CURR_CP_COUNTRY_CODE
   ,CURR_CP_PHONE_NUMBER     =  l_listentry_rec.CURR_CP_PHONE_NUMBER
   ,CURR_CP_RAW_PHONE_NUMBER     =  l_listentry_rec.CURR_CP_RAW_PHONE_NUMBER
   ,CURR_CP_AREA_CODE     =  l_listentry_rec.CURR_CP_AREA_CODE
   ,CURR_CP_ID     =  l_listentry_rec.CURR_CP_ID
   ,CURR_CP_INDEX     =  l_listentry_rec.CURR_CP_INDEX
   ,CURR_CP_TIME_ZONE     =  l_listentry_rec.CURR_CP_TIME_ZONE
   ,CURR_CP_TIME_ZONE_AUX     =  l_listentry_rec.CURR_CP_TIME_ZONE_AUX
   ,IMP_SOURCE_LINE_ID     =  l_listentry_rec.IMP_SOURCE_LINE_ID
   ,NEXT_CALL_TIME     =  l_listentry_rec.NEXT_CALL_TIME
   ,RECORD_RELEASE_TIME     =  l_listentry_rec.RECORD_RELEASE_TIME
	,PARTY_ID                       =  l_listentry_rec.PARTY_ID
	,PARENT_PARTY_ID                =  l_listentry_rec.PARENT_PARTY_ID
        WHERE list_entry_id             =  l_listentry_rec.list_entry_id
        AND   object_version_number     =  l_listentry_rec.object_version_number;


              if (SQL%NOTFOUND) then
                -- Error, check the msg level and added an error message to the
                -- API message list
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN -- MMSG
                            FND_MESSAGE.set_name('AMS', 'API_UNEXP_ERROR_IN_PROCESSING');
                            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Update_List_Entry API', TRUE);
                            FND_MSG_PUB.Add;
                        END IF;
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;

                -- Standard check of p_commit.
                IF FND_API.To_Boolean ( p_commit )
                THEN
                    COMMIT WORK;
                END IF;


                -- Success Message
                -- MMSG
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                THEN
                    FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
                    FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Update_ListEntry', TRUE);
                    FND_MSG_PUB.Add;
                END IF;


                IF (AMS_DEBUG_HIGH_ON) THEN
                    FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
                    FND_MESSAGE.Set_Token('ROW','AMS_List_Entry_PVT.Update_ListEntry: END', TRUE);
                    FND_MSG_PUB.Add;
                END IF;


                -- Standard call to get message count AND IF count is 1, get message info.
                FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
                  p_encoded         =>      FND_API.G_FALSE
                );



          EXCEPTION

                WHEN FND_API.G_EXC_ERROR THEN

                    ROLLBACK TO Update_ListEntry_PVT;
                    x_return_status := FND_API.G_RET_STS_ERROR ;

                    FND_MSG_PUB.Count_AND_Get
                    ( p_count           =>      x_msg_count,
                      p_data            =>      x_msg_data,
                      p_encoded     =>      FND_API.G_FALSE
                    );


                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                    ROLLBACK TO Update_ListEntry_PVT;
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                    FND_MSG_PUB.Count_AND_Get
                    ( p_count           =>      x_msg_count,
                      p_data            =>      x_msg_data,
                      p_encoded     =>      FND_API.G_FALSE
                    );


                WHEN OTHERS THEN

                    ROLLBACK TO Update_ListEntry_PVT;
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
                    THEN
                            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
                    END IF;

                    FND_MSG_PUB.Count_AND_Get
                    ( p_count           =>      x_msg_count,
                      p_data            =>      x_msg_data,
                      p_encoded     =>      FND_API.G_FALSE
                    );

END Update_ListEntry;


--------------------------------------------------------------------
-- PROCEDURE
--    delete_listentry
--
-- PURPOSE
--    Delete a listentry.
--
-- PARAMETERS
--    p_entry_id: the listentry_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE delete_listentry(
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.g_false,
   p_commit                   IN  VARCHAR2 := FND_API.g_false,
   p_validation_level         IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_entry_id                 IN  NUMBER,
   p_object_version_number    IN  NUMBER
) IS

        l_api_name            CONSTANT VARCHAR2(30)  := 'Delete_ListEntry';
        l_api_version         CONSTANT NUMBER        := 1.0;

        -- Status Local Variables
        l_return_status                VARCHAR2(1);  -- Return value from procedures
        l_return_val                   VARCHAR2(1);

  BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT Delete_ListEntry_PVT;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Delete_ListEntry: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;



        --
        -- API body
        --

        -- Perform the database operation


        IF (AMS_DEBUG_LOW_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT - DELETE FROM ams_list_entries', TRUE);
            FND_MSG_PUB.Add;
        END IF;


        -- Delete header data
        DELETE
	FROM  ams_list_entries
        WHERE list_entry_id         = p_entry_id
	AND   object_version_number = p_object_version_number;

        if (SQL%NOTFOUND) then
        -- Error, check the msg level and added an error message to the
        -- API message list
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN -- MMSG
                FND_MESSAGE.set_name('AMS', 'API_UNEXP_ERROR_IN_PROCESSING');
                FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Delete_ListEntry API', TRUE);
                FND_MSG_PUB.Add;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

        --
        -- END of API body.
        --

        -- Standard check of p_commit.
        IF FND_API.To_Boolean ( p_commit )
        THEN
            COMMIT WORK;
        END IF;

        -- Success Message
        -- MMSG
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Delete_List_Entry', TRUE);
            FND_MSG_PUB.Add;
        END IF;


        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Delete_List_Entry: END', TRUE);
            FND_MSG_PUB.Add;
        END IF;


        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
      p_encoded     =>      FND_API.G_FALSE
        );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            ROLLBACK TO Delete_ListEntry_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            ROLLBACK TO Delete_ListEntry_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
            );


        WHEN OTHERS THEN

            ROLLBACK TO Delete_ListEntry_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
                    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
            END IF;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
            );


END Delete_ListEntry;



-------------------------------------------------------------------
-- PROCEDURE
--    lock_listentry
--
-- PURPOSE
--    Lock a List Entry.
--
-- PARAMETERS
--    p_entry_id: the list_entry_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_listentry(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_entry_id           IN  NUMBER,
   p_object_version    IN  NUMBER
) IS

       l_api_name            CONSTANT VARCHAR2(30)  := 'Lock_ListEntry';
       l_api_version         CONSTANT NUMBER        := 1.0;
       l_entry_id            NUMBER;

       CURSOR c_entry IS
       SELECT list_entry_id
       FROM   ams_list_entries
       WHERE  list_entry_id = p_entry_id
       AND object_version_number = p_object_version
       FOR UPDATE OF list_entry_id NOWAIT;

  BEGIN


        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Lock_ListEntry: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        ------------------------ lock -------------------------
        OPEN c_entry;
        FETCH c_entry INTO l_entry_id;
        IF (c_entry%NOTFOUND) THEN
            CLOSE c_entry;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
        END IF;
        CLOSE c_entry;


        -- Success Message
        -- MMSG
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Lock_ListEntry', TRUE);
            FND_MSG_PUB.Add;
        END IF;


        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Lock_ListEntry: END', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
            );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
            );

        WHEN AMS_Utility_PVT.RESOURCE_LOCKED THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN -- MMSG
                FND_MESSAGE.SET_NAME('AMS','API_RESOURCE_LOCKED');
                FND_MSG_PUB.Add;
           END IF;

            FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
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
              p_encoded     =>      FND_API.G_FALSE
            );

END Lock_ListEntry;

---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_items
--
-- HISTORY
--    10/16/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_entry_items(
   p_entry_rec        IN  entry_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   check_entry_req_items(
      p_entry_rec       => p_entry_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_entry_uk_items(
      p_entry_rec        => p_entry_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_entry_fk_items(
      p_entry_rec       => p_entry_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_entry_lookup_items(
      p_entry_rec        => p_entry_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   check_entry_flag_items(
      p_entry_rec        => p_entry_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END check_entry_items;



---------------------------------------------------------------------
-- PROCEDURE
--    check_entry_record
--
-- HISTORY
--    10/17/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE check_entry_record(
   p_entry_rec       IN  entry_rec_type,
   p_complete_rec   IN  entry_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS



BEGIN
   x_return_status := FND_API.g_ret_sts_success;

END check_entry_record;

---------------------------------------------------------------------
-- PROCEDURE
--    init_entry_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_entry_rec(
   x_entry_rec         OUT NOCOPY  entry_rec_type
) IS

Begin

 x_entry_rec.LIST_ENTRY_ID                   := FND_API.g_miss_num;
 x_entry_rec.LIST_HEADER_ID                  := FND_API.g_miss_num;

 x_entry_rec.LAST_UPDATE_DATE                := FND_API.g_miss_date;
 x_entry_rec.LAST_UPDATED_BY                 := FND_API.g_miss_num;

 x_entry_rec.CREATION_DATE                   := FND_API.g_miss_date;
 x_entry_rec.CREATED_BY                      := FND_API.g_miss_num;

 x_entry_rec.LAST_UPDATE_LOGIN               := FND_API.g_miss_num;
 x_entry_rec.OBJECT_VERSION_NUMBER           := FND_API.g_miss_num;
 x_entry_rec.LIST_SELECT_ACTION_ID           := FND_API.g_miss_num;

 x_entry_rec.ARC_LIST_SELECT_ACTION_FROM     := FND_API.g_miss_char;
 x_entry_rec.LIST_SELECT_ACTION_FROM_NAME    := FND_API.g_miss_char;
 x_entry_rec.SOURCE_CODE                     := FND_API.g_miss_char;
 x_entry_rec.SOURCE_CODE_FOR_ID              := FND_API.g_miss_num;
 x_entry_rec.ARC_LIST_USED_BY_SOURCE         := FND_API.g_miss_char;
 x_entry_rec.PIN_CODE                        := FND_API.g_miss_char;

 x_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_ID     := FND_API.g_miss_num;
 x_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE   := FND_API.g_miss_char;

 x_entry_rec.VIEW_APPLICATION_ID             := FND_API.g_miss_num;

 x_entry_rec.MANUALLY_ENTERED_FLAG           := FND_API.g_miss_char;
 x_entry_rec.MARKED_AS_DUPLICATE_FLAG        := FND_API.g_miss_char;
 x_entry_rec.MARKED_AS_RANDOM_FLAG           := FND_API.g_miss_char;
 x_entry_rec.PART_OF_CONTROL_GROUP_FLAG      := FND_API.g_miss_char;
 x_entry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG  := FND_API.g_miss_char;
 x_entry_rec.ENABLED_FLAG                    := FND_API.g_miss_char;
 x_entry_rec.CELL_CODE                       := FND_API.g_miss_char;
 x_entry_rec.DEDUPE_KEY                      := FND_API.g_miss_char;

 x_entry_rec.RANDOMLY_GENERATED_NUMBER       := FND_API.g_miss_num;
 x_entry_rec.CAMPAIGN_ID                     := FND_API.g_miss_num;
 x_entry_rec.MEDIA_ID                        := FND_API.g_miss_num;
 x_entry_rec.CHANNEL_ID                      := FND_API.g_miss_num;
 x_entry_rec.CHANNEL_SCHEDULE_ID             := FND_API.g_miss_num;
 x_entry_rec.EVENT_OFFER_ID                  := FND_API.g_miss_num;
 x_entry_rec.CUSTOMER_ID                     := FND_API.g_miss_num;
 x_entry_rec.MARKET_SEGMENT_ID               := FND_API.g_miss_num;
 x_entry_rec.VENDOR_ID                       := FND_API.g_miss_num;

 x_entry_rec.TRANSFER_FLAG                   := FND_API.g_miss_char;
 x_entry_rec.TRANSFER_STATUS                 := FND_API.g_miss_char;

 x_entry_rec.LIST_SOURCE                     := FND_API.g_miss_char;

 x_entry_rec.DUPLICATE_MASTER_ENTRY_ID       := FND_API.g_miss_num;

 x_entry_rec.MARKED_FLAG                     := FND_API.g_miss_char;

 x_entry_rec.LEAD_ID                         := FND_API.g_miss_num;
 x_entry_rec.LETTER_ID                       := FND_API.g_miss_num;
 x_entry_rec.PICKING_HEADER_ID               := FND_API.g_miss_num;
 x_entry_rec.BATCH_ID                        := FND_API.g_miss_num;

 x_entry_rec.COL1                            := FND_API.g_miss_char;
 x_entry_rec.COL2                            := FND_API.g_miss_char;
 x_entry_rec.COL3                            := FND_API.g_miss_char;
 x_entry_rec.COL4                            := FND_API.g_miss_char;
 x_entry_rec.COL5                            := FND_API.g_miss_char;
 x_entry_rec.COL6                            := FND_API.g_miss_char;
 x_entry_rec.COL7                            := FND_API.g_miss_char;
 x_entry_rec.COL8                            := FND_API.g_miss_char;
 x_entry_rec.COL9                            := FND_API.g_miss_char;
 x_entry_rec.COL10                           := FND_API.g_miss_char;
 x_entry_rec.COL11                           := FND_API.g_miss_char;
 x_entry_rec.COL12                           := FND_API.g_miss_char;
 x_entry_rec.COL13                           := FND_API.g_miss_char;
 x_entry_rec.COL14                           := FND_API.g_miss_char;
 x_entry_rec.COL15                           := FND_API.g_miss_char;
 x_entry_rec.COL16                           := FND_API.g_miss_char;
 x_entry_rec.COL17                           := FND_API.g_miss_char;
 x_entry_rec.COL18                           := FND_API.g_miss_char;
 x_entry_rec.COL19                           := FND_API.g_miss_char;
 x_entry_rec.COL20                           := FND_API.g_miss_char;
 x_entry_rec.COL21                           := FND_API.g_miss_char;
 x_entry_rec.COL22                           := FND_API.g_miss_char;
 x_entry_rec.COL23                           := FND_API.g_miss_char;
 x_entry_rec.COL24                           := FND_API.g_miss_char;
 x_entry_rec.COL25                           := FND_API.g_miss_char;
 x_entry_rec.COL26                           := FND_API.g_miss_char;
 x_entry_rec.COL27                           := FND_API.g_miss_char;
 x_entry_rec.COL28                           := FND_API.g_miss_char;
 x_entry_rec.COL29                           := FND_API.g_miss_char;
 x_entry_rec.COL30                           := FND_API.g_miss_char;
 x_entry_rec.COL31                           := FND_API.g_miss_char;
 x_entry_rec.COL32                           := FND_API.g_miss_char;
 x_entry_rec.COL33                           := FND_API.g_miss_char;
 x_entry_rec.COL34                           := FND_API.g_miss_char;
 x_entry_rec.COL35                           := FND_API.g_miss_char;
 x_entry_rec.COL36                           := FND_API.g_miss_char;
 x_entry_rec.COL37                           := FND_API.g_miss_char;
 x_entry_rec.COL38                           := FND_API.g_miss_char;
 x_entry_rec.COL39                           := FND_API.g_miss_char;
 x_entry_rec.COL40                           := FND_API.g_miss_char;
 x_entry_rec.COL41                           := FND_API.g_miss_char;
 x_entry_rec.COL42                           := FND_API.g_miss_char;
 x_entry_rec.COL43                           := FND_API.g_miss_char;
 x_entry_rec.COL44                           := FND_API.g_miss_char;
 x_entry_rec.COL45                           := FND_API.g_miss_char;
 x_entry_rec.COL46                           := FND_API.g_miss_char;
 x_entry_rec.COL47                           := FND_API.g_miss_char;
 x_entry_rec.COL48                           := FND_API.g_miss_char;
 x_entry_rec.COL49                           := FND_API.g_miss_char;
 x_entry_rec.COL50                           := FND_API.g_miss_char;
 x_entry_rec.COL51                           := FND_API.g_miss_char;
 x_entry_rec.COL52                           := FND_API.g_miss_char;
 x_entry_rec.COL53                           := FND_API.g_miss_char;
 x_entry_rec.COL54                           := FND_API.g_miss_char;
 x_entry_rec.COL55                           := FND_API.g_miss_char;
 x_entry_rec.COL56                           := FND_API.g_miss_char;
 x_entry_rec.COL57                           := FND_API.g_miss_char;
 x_entry_rec.COL58                           := FND_API.g_miss_char;
 x_entry_rec.COL59                           := FND_API.g_miss_char;
 x_entry_rec.COL60                           := FND_API.g_miss_char;
 x_entry_rec.COL61                           := FND_API.g_miss_char;
 x_entry_rec.COL62                           := FND_API.g_miss_char;
 x_entry_rec.COL63                           := FND_API.g_miss_char;
 x_entry_rec.COL64                           := FND_API.g_miss_char;
 x_entry_rec.COL65                           := FND_API.g_miss_char;
 x_entry_rec.COL66                           := FND_API.g_miss_char;
 x_entry_rec.COL67                           := FND_API.g_miss_char;
 x_entry_rec.COL68                           := FND_API.g_miss_char;
 x_entry_rec.COL69                           := FND_API.g_miss_char;
 x_entry_rec.COL70                           := FND_API.g_miss_char;
 x_entry_rec.COL71                           := FND_API.g_miss_char;
 x_entry_rec.COL72                           := FND_API.g_miss_char;
 x_entry_rec.COL73                           := FND_API.g_miss_char;
 x_entry_rec.COL74                           := FND_API.g_miss_char;
 x_entry_rec.COL75                           := FND_API.g_miss_char;
 x_entry_rec.COL76                           := FND_API.g_miss_char;
 x_entry_rec.COL77                           := FND_API.g_miss_char;
 x_entry_rec.COL78                           := FND_API.g_miss_char;
 x_entry_rec.COL79                           := FND_API.g_miss_char;
 x_entry_rec.COL80                           := FND_API.g_miss_char;
 x_entry_rec.COL81                           := FND_API.g_miss_char;
 x_entry_rec.COL82                           := FND_API.g_miss_char;
 x_entry_rec.COL83                           := FND_API.g_miss_char;
 x_entry_rec.COL84                           := FND_API.g_miss_char;
 x_entry_rec.COL85                           := FND_API.g_miss_char;
 x_entry_rec.COL86                           := FND_API.g_miss_char;
 x_entry_rec.COL87                           := FND_API.g_miss_char;
 x_entry_rec.COL88                           := FND_API.g_miss_char;
 x_entry_rec.COL89                           := FND_API.g_miss_char;
 x_entry_rec.COL90                           := FND_API.g_miss_char;
 x_entry_rec.COL91                           := FND_API.g_miss_char;
 x_entry_rec.COL92                           := FND_API.g_miss_char;
 x_entry_rec.COL93                           := FND_API.g_miss_char;
 x_entry_rec.COL94                           := FND_API.g_miss_char;
 x_entry_rec.COL95                           := FND_API.g_miss_char;
 x_entry_rec.COL96                           := FND_API.g_miss_char;
 x_entry_rec.COL97                           := FND_API.g_miss_char;
 x_entry_rec.COL98                           := FND_API.g_miss_char;
 x_entry_rec.COL99                           := FND_API.g_miss_char;
 x_entry_rec.COL100                          := FND_API.g_miss_char;
 x_entry_rec.COL101                          := FND_API.g_miss_char;
 x_entry_rec.COL102                          := FND_API.g_miss_char;
 x_entry_rec.COL103                          := FND_API.g_miss_char;
 x_entry_rec.COL104                          := FND_API.g_miss_char;
 x_entry_rec.COL105                          := FND_API.g_miss_char;
 x_entry_rec.COL106                          := FND_API.g_miss_char;
 x_entry_rec.COL107                          := FND_API.g_miss_char;
 x_entry_rec.COL108                          := FND_API.g_miss_char;
 x_entry_rec.COL109                          := FND_API.g_miss_char;
 x_entry_rec.COL110                          := FND_API.g_miss_char;
 x_entry_rec.COL111                          := FND_API.g_miss_char;
 x_entry_rec.COL112                          := FND_API.g_miss_char;
 x_entry_rec.COL113                          := FND_API.g_miss_char;
 x_entry_rec.COL114                          := FND_API.g_miss_char;
 x_entry_rec.COL115                          := FND_API.g_miss_char;
 x_entry_rec.COL116                          := FND_API.g_miss_char;
 x_entry_rec.COL117                          := FND_API.g_miss_char;
 x_entry_rec.COL118                          := FND_API.g_miss_char;
 x_entry_rec.COL119                          := FND_API.g_miss_char;
 x_entry_rec.COL120                          := FND_API.g_miss_char;
 x_entry_rec.COL121                          := FND_API.g_miss_char;
 x_entry_rec.COL122                          := FND_API.g_miss_char;
 x_entry_rec.COL123                          := FND_API.g_miss_char;
 x_entry_rec.COL124                          := FND_API.g_miss_char;
 x_entry_rec.COL125                          := FND_API.g_miss_char;
 x_entry_rec.COL126                          := FND_API.g_miss_char;
 x_entry_rec.COL127                          := FND_API.g_miss_char;
 x_entry_rec.COL128                          := FND_API.g_miss_char;
 x_entry_rec.COL129                          := FND_API.g_miss_char;
 x_entry_rec.COL130                          := FND_API.g_miss_char;
 x_entry_rec.COL131                          := FND_API.g_miss_char;
 x_entry_rec.COL132                          := FND_API.g_miss_char;
 x_entry_rec.COL133                          := FND_API.g_miss_char;
 x_entry_rec.COL134                          := FND_API.g_miss_char;
 x_entry_rec.COL135                          := FND_API.g_miss_char;
 x_entry_rec.COL136                          := FND_API.g_miss_char;
 x_entry_rec.COL137                          := FND_API.g_miss_char;
 x_entry_rec.COL138                          := FND_API.g_miss_char;
 x_entry_rec.COL139                          := FND_API.g_miss_char;
 x_entry_rec.COL140                          := FND_API.g_miss_char;
 x_entry_rec.COL141                          := FND_API.g_miss_char;
 x_entry_rec.COL142                          := FND_API.g_miss_char;
 x_entry_rec.COL143                          := FND_API.g_miss_char;
 x_entry_rec.COL144                          := FND_API.g_miss_char;
 x_entry_rec.COL145                          := FND_API.g_miss_char;
 x_entry_rec.COL146                          := FND_API.g_miss_char;
 x_entry_rec.COL147                          := FND_API.g_miss_char;
 x_entry_rec.COL148                          := FND_API.g_miss_char;
 x_entry_rec.COL149                          := FND_API.g_miss_char;
 x_entry_rec.COL150                          := FND_API.g_miss_char;
 x_entry_rec.COL151                          := FND_API.g_miss_char;
 x_entry_rec.COL152                          := FND_API.g_miss_char;
 x_entry_rec.COL153                          := FND_API.g_miss_char;
 x_entry_rec.COL154                          := FND_API.g_miss_char;
 x_entry_rec.COL155                          := FND_API.g_miss_char;
 x_entry_rec.COL156                          := FND_API.g_miss_char;
 x_entry_rec.COL157                          := FND_API.g_miss_char;
 x_entry_rec.COL158                          := FND_API.g_miss_char;
 x_entry_rec.COL159                          := FND_API.g_miss_char;
 x_entry_rec.COL160                          := FND_API.g_miss_char;
 x_entry_rec.COL161                          := FND_API.g_miss_char;
 x_entry_rec.COL162                          := FND_API.g_miss_char;
 x_entry_rec.COL163                          := FND_API.g_miss_char;
 x_entry_rec.COL164                          := FND_API.g_miss_char;
 x_entry_rec.COL165                          := FND_API.g_miss_char;
 x_entry_rec.COL166                          := FND_API.g_miss_char;
 x_entry_rec.COL167                          := FND_API.g_miss_char;
 x_entry_rec.COL168                          := FND_API.g_miss_char;
 x_entry_rec.COL169                          := FND_API.g_miss_char;
 x_entry_rec.COL170                          := FND_API.g_miss_char;
 x_entry_rec.COL171                          := FND_API.g_miss_char;
 x_entry_rec.COL172                          := FND_API.g_miss_char;
 x_entry_rec.COL173                          := FND_API.g_miss_char;
 x_entry_rec.COL174                          := FND_API.g_miss_char;
 x_entry_rec.COL175                          := FND_API.g_miss_char;
 x_entry_rec.COL176                          := FND_API.g_miss_char;
 x_entry_rec.COL177                          := FND_API.g_miss_char;
 x_entry_rec.COL178                          := FND_API.g_miss_char;
 x_entry_rec.COL179                          := FND_API.g_miss_char;
 x_entry_rec.COL180                          := FND_API.g_miss_char;
 x_entry_rec.COL181                          := FND_API.g_miss_char;
 x_entry_rec.COL182                          := FND_API.g_miss_char;
 x_entry_rec.COL183                          := FND_API.g_miss_char;
 x_entry_rec.COL184                          := FND_API.g_miss_char;
 x_entry_rec.COL185                          := FND_API.g_miss_char;
 x_entry_rec.COL186                          := FND_API.g_miss_char;
 x_entry_rec.COL187                          := FND_API.g_miss_char;
 x_entry_rec.COL188                          := FND_API.g_miss_char;
 x_entry_rec.COL189                          := FND_API.g_miss_char;
 x_entry_rec.COL190                          := FND_API.g_miss_char;
 x_entry_rec.COL191                          := FND_API.g_miss_char;
 x_entry_rec.COL192                          := FND_API.g_miss_char;
 x_entry_rec.COL193                          := FND_API.g_miss_char;
 x_entry_rec.COL194                          := FND_API.g_miss_char;
 x_entry_rec.COL195                          := FND_API.g_miss_char;
 x_entry_rec.COL196                          := FND_API.g_miss_char;
 x_entry_rec.COL197                          := FND_API.g_miss_char;
 x_entry_rec.COL198                          := FND_API.g_miss_char;
 x_entry_rec.COL199                          := FND_API.g_miss_char;
 x_entry_rec.COL200                          := FND_API.g_miss_char;
 x_entry_rec.COL201                          := FND_API.g_miss_char;
 x_entry_rec.COL202                          := FND_API.g_miss_char;
 x_entry_rec.COL203                          := FND_API.g_miss_char;
 x_entry_rec.COL204                          := FND_API.g_miss_char;
 x_entry_rec.COL205                          := FND_API.g_miss_char;
 x_entry_rec.COL206                          := FND_API.g_miss_char;
 x_entry_rec.COL207                          := FND_API.g_miss_char;
 x_entry_rec.COL208                          := FND_API.g_miss_char;
 x_entry_rec.COL209                          := FND_API.g_miss_char;
 x_entry_rec.COL210                          := FND_API.g_miss_char;
 x_entry_rec.COL211                          := FND_API.g_miss_char;
 x_entry_rec.COL212                          := FND_API.g_miss_char;
 x_entry_rec.COL213                          := FND_API.g_miss_char;
 x_entry_rec.COL214                          := FND_API.g_miss_char;
 x_entry_rec.COL215                          := FND_API.g_miss_char;
 x_entry_rec.COL216                          := FND_API.g_miss_char;
 x_entry_rec.COL217                          := FND_API.g_miss_char;
 x_entry_rec.COL218                          := FND_API.g_miss_char;
 x_entry_rec.COL219                          := FND_API.g_miss_char;
 x_entry_rec.COL220                          := FND_API.g_miss_char;
 x_entry_rec.COL221                          := FND_API.g_miss_char;
 x_entry_rec.COL222                          := FND_API.g_miss_char;
 x_entry_rec.COL223                          := FND_API.g_miss_char;
 x_entry_rec.COL224                          := FND_API.g_miss_char;
 x_entry_rec.COL225                          := FND_API.g_miss_char;
 x_entry_rec.COL226                          := FND_API.g_miss_char;
 x_entry_rec.COL227                          := FND_API.g_miss_char;
 x_entry_rec.COL228                          := FND_API.g_miss_char;
 x_entry_rec.COL229                          := FND_API.g_miss_char;
 x_entry_rec.COL230                          := FND_API.g_miss_char;
 x_entry_rec.COL231                          := FND_API.g_miss_char;
 x_entry_rec.COL232                          := FND_API.g_miss_char;
 x_entry_rec.COL233                          := FND_API.g_miss_char;
 x_entry_rec.COL234                          := FND_API.g_miss_char;
 x_entry_rec.COL235                          := FND_API.g_miss_char;
 x_entry_rec.COL236                          := FND_API.g_miss_char;
 x_entry_rec.COL237                          := FND_API.g_miss_char;
 x_entry_rec.COL238                          := FND_API.g_miss_char;
 x_entry_rec.COL239                          := FND_API.g_miss_char;
 x_entry_rec.COL240                          := FND_API.g_miss_char;
 x_entry_rec.COL241                          := FND_API.g_miss_char;
 x_entry_rec.COL242                          := FND_API.g_miss_char;
 x_entry_rec.COL243                          := FND_API.g_miss_char;
 x_entry_rec.COL244                          := FND_API.g_miss_char;
 x_entry_rec.COL245                          := FND_API.g_miss_char;
 x_entry_rec.COL246                          := FND_API.g_miss_char;
 x_entry_rec.COL247                          := FND_API.g_miss_char;
 x_entry_rec.COL248                          := FND_API.g_miss_char;
 x_entry_rec.COL249                          := FND_API.g_miss_char;
 x_entry_rec.COL250                          := FND_API.g_miss_char;
 x_entry_rec.PARTY_ID                        := FND_API.g_miss_num;
 x_entry_rec.COL251                          := FND_API.g_miss_char;
 x_entry_rec.COL252                          := FND_API.g_miss_char;
 x_entry_rec.COL253                          := FND_API.g_miss_char;
 x_entry_rec.COL254                          := FND_API.g_miss_char;
 x_entry_rec.COL255                          := FND_API.g_miss_char;
 x_entry_rec.COL256                          := FND_API.g_miss_char;
 x_entry_rec.COL257                          := FND_API.g_miss_char;
 x_entry_rec.COL258                          := FND_API.g_miss_char;
 x_entry_rec.COL259                          := FND_API.g_miss_char;
 x_entry_rec.COL260                          := FND_API.g_miss_char;
 x_entry_rec.COL261                          := FND_API.g_miss_char;
 x_entry_rec.COL262                          := FND_API.g_miss_char;
 x_entry_rec.COL263                          := FND_API.g_miss_char;
 x_entry_rec.COL264                          := FND_API.g_miss_char;
 x_entry_rec.COL265                          := FND_API.g_miss_char;
 x_entry_rec.COL266                          := FND_API.g_miss_char;
 x_entry_rec.COL267                          := FND_API.g_miss_char;
 x_entry_rec.COL268                          := FND_API.g_miss_char;
 x_entry_rec.COL269                          := FND_API.g_miss_char;
 x_entry_rec.COL270                          := FND_API.g_miss_char;
 x_entry_rec.COL271                          := FND_API.g_miss_char;
 x_entry_rec.COL272                          := FND_API.g_miss_char;
 x_entry_rec.COL273                          := FND_API.g_miss_char;
 x_entry_rec.COL274                          := FND_API.g_miss_char;
 x_entry_rec.COL275                          := FND_API.g_miss_char;
 x_entry_rec.COL276                          := FND_API.g_miss_char;
 x_entry_rec.COL277                          := FND_API.g_miss_char;
 x_entry_rec.COL278                          := FND_API.g_miss_char;
 x_entry_rec.COL279                          := FND_API.g_miss_char;
 x_entry_rec.COL280                          := FND_API.g_miss_char;
 x_entry_rec.COL281                          := FND_API.g_miss_char;
 x_entry_rec.COL282                          := FND_API.g_miss_char;
 x_entry_rec.COL283                          := FND_API.g_miss_char;
 x_entry_rec.COL284                          := FND_API.g_miss_char;
 x_entry_rec.COL285                          := FND_API.g_miss_char;
 x_entry_rec.COL286                          := FND_API.g_miss_char;
 x_entry_rec.COL287                          := FND_API.g_miss_char;
 x_entry_rec.COL288                          := FND_API.g_miss_char;
 x_entry_rec.COL289                          := FND_API.g_miss_char;
 x_entry_rec.COL290                          := FND_API.g_miss_char;
 x_entry_rec.COL291                          := FND_API.g_miss_char;
 x_entry_rec.COL292                          := FND_API.g_miss_char;
 x_entry_rec.COL293                          := FND_API.g_miss_char;
 x_entry_rec.COL294                          := FND_API.g_miss_char;
 x_entry_rec.COL295                          := FND_API.g_miss_char;
 x_entry_rec.COL296                          := FND_API.g_miss_char;
 x_entry_rec.COL297                          := FND_API.g_miss_char;
 x_entry_rec.COL298                          := FND_API.g_miss_char;
 x_entry_rec.COL299                          := FND_API.g_miss_char;
 x_entry_rec.COL300                          := FND_API.g_miss_char;
 x_entry_rec.ADDRESS_LINE1                   := FND_API.g_miss_char;
 x_entry_rec.ADDRESS_LINE2                   := FND_API.g_miss_char;
 x_entry_rec.CALLBACK_FLAG                   := FND_API.g_miss_char;
 x_entry_rec.CITY                            := FND_API.g_miss_char;
 x_entry_rec.COUNTRY                         := FND_API.g_miss_char;
 x_entry_rec.DO_NOT_USE_FLAG                 := FND_API.g_miss_char;
 x_entry_rec.DO_NOT_USE_REASON               := FND_API.g_miss_char;
 x_entry_rec.EMAIL_ADDRESS                   := FND_API.g_miss_char;
 x_entry_rec.FAX                             := FND_API.g_miss_char;
 x_entry_rec.PHONE                           := FND_API.g_miss_char;
 x_entry_rec.RECORD_OUT_FLAG                 := FND_API.g_miss_char;
 x_entry_rec.STATE                           := FND_API.g_miss_char;
 x_entry_rec.SUFFIX                          := FND_API.g_miss_char;
 x_entry_rec.TITLE                           := FND_API.g_miss_char;
 x_entry_rec.USAGE_RESTRICTION               := FND_API.g_miss_char;
 x_entry_rec.ZIPCODE                         := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_COUNTRY_CODE            := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_PHONE_NUMBER            := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_RAW_PHONE_NUMBER        := FND_API.g_miss_char;
 x_entry_rec.CURR_CP_AREA_CODE               := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_ID                      := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_INDEX                   := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_TIME_ZONE               := FND_API.g_miss_num;
 x_entry_rec.CURR_CP_TIME_ZONE_AUX           := FND_API.g_miss_num;
 x_entry_rec.IMP_SOURCE_LINE_ID              := FND_API.g_miss_num;
 x_entry_rec.NEXT_CALL_TIME                  := FND_API.g_miss_date;
 x_entry_rec.RECORD_RELEASE_TIME             := FND_API.g_miss_date;
 x_entry_rec.PARENT_PARTY_ID                 := FND_API.g_miss_num;

END init_entry_rec;

---------------------------------------------------------------------
-- PROCEDURE
--    complete_entry_rec
--
-- HISTORY
--    10/16/99  tdonohoe  Created.
---------------------------------------------------------------------
PROCEDURE complete_entry_rec(
   p_entry_rec      IN  entry_rec_type,
   x_complete_rec  OUT NOCOPY entry_rec_type
)
IS

  CURSOR c_entry IS
   SELECT *
   FROM ams_list_entries
   WHERE list_entry_id = p_entry_rec.list_entry_id;

   l_entry_rec  c_entry%ROWTYPE;

BEGIN

   x_complete_rec := p_entry_rec;

   OPEN c_entry;
   FETCH c_entry INTO l_entry_rec;
   IF c_entry%NOTFOUND THEN
      CLOSE c_entry;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_entry;


 IF p_entry_rec.ARC_LIST_SELECT_ACTION_FROM = FND_API.g_miss_char THEN
     x_complete_rec.ARC_LIST_SELECT_ACTION_FROM  := l_entry_rec.ARC_LIST_SELECT_ACTION_FROM;
 END IF;

 IF p_entry_rec.LIST_SELECT_ACTION_FROM_NAME = FND_API.g_miss_char THEN
     x_complete_rec.LIST_SELECT_ACTION_FROM_NAME := l_entry_rec.LIST_SELECT_ACTION_FROM_NAME;
 END IF;

 IF p_entry_rec.SOURCE_CODE = FND_API.g_miss_char THEN
     x_complete_rec.SOURCE_CODE := l_entry_rec.SOURCE_CODE;
 END IF;

 IF p_entry_rec.ARC_LIST_USED_BY_SOURCE = FND_API.g_miss_char THEN
     x_complete_rec.ARC_LIST_USED_BY_SOURCE := l_entry_rec.ARC_LIST_USED_BY_SOURCE;
 END IF;

 --added 06-Jun-2000 tdonohoe
 IF p_entry_rec.SOURCE_CODE_FOR_ID = FND_API.g_miss_num THEN
     x_complete_rec.SOURCE_CODE_FOR_ID := l_entry_rec.SOURCE_CODE_FOR_ID;
 END IF;
  --end added 06-Jun-2000 tdonohoe

 IF p_entry_rec.PIN_CODE   = FND_API.g_miss_char THEN
     x_complete_rec.PIN_CODE := l_entry_rec.PIN_CODE;
 END IF;

 IF p_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_ID = FND_API.g_miss_num THEN
     x_complete_rec.LIST_ENTRY_SOURCE_SYSTEM_ID := l_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_ID;
 END IF;

 IF p_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE = FND_API.g_miss_char THEN
     x_complete_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE := l_entry_rec.LIST_ENTRY_SOURCE_SYSTEM_TYPE;
 END IF;
 IF p_entry_rec.VIEW_APPLICATION_ID    = FND_API.g_miss_num THEN
     x_complete_rec.VIEW_APPLICATION_ID := l_entry_rec.VIEW_APPLICATION_ID;
 END IF;
 IF p_entry_rec.MANUALLY_ENTERED_FLAG  = FND_API.g_miss_char THEN
     x_complete_rec.MANUALLY_ENTERED_FLAG := l_entry_rec.MANUALLY_ENTERED_FLAG;
 END IF;
 IF p_entry_rec.MARKED_AS_DUPLICATE_FLAG = FND_API.g_miss_char THEN
     x_complete_rec.MARKED_AS_DUPLICATE_FLAG := l_entry_rec.MARKED_AS_DUPLICATE_FLAG;
 END IF;

 IF p_entry_rec.MARKED_AS_RANDOM_FLAG = FND_API.g_miss_char THEN
     x_complete_rec.MARKED_AS_RANDOM_FLAG := l_entry_rec.MARKED_AS_RANDOM_FLAG;
 END IF;

 IF p_entry_rec.PART_OF_CONTROL_GROUP_FLAG  = FND_API.g_miss_char THEN
     x_complete_rec.PART_OF_CONTROL_GROUP_FLAG := l_entry_rec.PART_OF_CONTROL_GROUP_FLAG;
 END IF;

 IF p_entry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG = FND_API.g_miss_char THEN
     x_complete_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG := l_entry_rec.EXCLUDE_IN_TRIGGERED_LIST_FLAG;
 END IF;

 IF p_entry_rec.ENABLED_FLAG = FND_API.g_miss_char THEN
     x_complete_rec.ENABLED_FLAG := l_entry_rec.ENABLED_FLAG;
 END IF;

 IF p_entry_rec.CELL_CODE = FND_API.g_miss_char THEN
     x_complete_rec.CELL_CODE := l_entry_rec.CELL_CODE;
 END IF;

 IF p_entry_rec.DEDUPE_KEY = FND_API.g_miss_char THEN
     x_complete_rec.DEDUPE_KEY := l_entry_rec.DEDUPE_KEY;
 END IF;

 IF p_entry_rec.RANDOMLY_GENERATED_NUMBER     = FND_API.g_miss_num THEN
     x_complete_rec.RANDOMLY_GENERATED_NUMBER := l_entry_rec.RANDOMLY_GENERATED_NUMBER ;
 END IF;

 IF p_entry_rec.CAMPAIGN_ID    = FND_API.g_miss_num THEN
     x_complete_rec.CAMPAIGN_ID  := l_entry_rec.CAMPAIGN_ID;
 END IF;

 IF p_entry_rec.MEDIA_ID   = FND_API.g_miss_num THEN
     x_complete_rec.MEDIA_ID := l_entry_rec.MEDIA_ID;
 END IF;

 IF p_entry_rec.CHANNEL_ID   = FND_API.g_miss_num THEN
     x_complete_rec.CHANNEL_ID := l_entry_rec.CHANNEL_ID;
 END IF;

 IF p_entry_rec.CHANNEL_SCHEDULE_ID   = FND_API.g_miss_num THEN
     x_complete_rec.CHANNEL_SCHEDULE_ID := l_entry_rec.CHANNEL_SCHEDULE_ID;
 END IF;

 IF p_entry_rec.EVENT_OFFER_ID   = FND_API.g_miss_num THEN
     x_complete_rec.EVENT_OFFER_ID := l_entry_rec.EVENT_OFFER_ID;
 END IF;

 IF p_entry_rec.CUSTOMER_ID   = FND_API.g_miss_num THEN
     x_complete_rec.CUSTOMER_ID := l_entry_rec.CUSTOMER_ID;
 END IF;

 IF p_entry_rec.MARKET_SEGMENT_ID   = FND_API.g_miss_num THEN
     x_complete_rec.MARKET_SEGMENT_ID := l_entry_rec.MARKET_SEGMENT_ID ;
 END IF;

 IF p_entry_rec.VENDOR_ID   = FND_API.g_miss_num THEN
     x_complete_rec.VENDOR_ID   := l_entry_rec.VENDOR_ID ;
 END IF;

 IF p_entry_rec.TRANSFER_FLAG = FND_API.g_miss_char THEN
     x_complete_rec.TRANSFER_FLAG := l_entry_rec.TRANSFER_FLAG;
 END IF;

 IF p_entry_rec.TRANSFER_STATUS = FND_API.g_miss_char THEN
     x_complete_rec.TRANSFER_STATUS := l_entry_rec.TRANSFER_STATUS;
 END IF;

 IF p_entry_rec.LIST_SOURCE = FND_API.g_miss_char THEN
     x_complete_rec.LIST_SOURCE := l_entry_rec.LIST_SOURCE;
 END IF;

 IF p_entry_rec.DUPLICATE_MASTER_ENTRY_ID   = FND_API.g_miss_num THEN
     x_complete_rec.DUPLICATE_MASTER_ENTRY_ID := l_entry_rec.DUPLICATE_MASTER_ENTRY_ID;
 END IF;

 IF p_entry_rec.MARKED_FLAG  = FND_API.g_miss_char THEN
     x_complete_rec.MARKED_FLAG := l_entry_rec.MARKED_FLAG;
 END IF;
 IF p_entry_rec.LEAD_ID   = FND_API.g_miss_num THEN
     x_complete_rec.LEAD_ID := l_entry_rec.LEAD_ID;
 END IF;

 IF p_entry_rec.LETTER_ID   = FND_API.g_miss_num THEN
     x_complete_rec.LETTER_ID := l_entry_rec.LETTER_ID;
 END IF;

 IF p_entry_rec.PICKING_HEADER_ID   = FND_API.g_miss_num THEN
     x_complete_rec.PICKING_HEADER_ID := l_entry_rec.PICKING_HEADER_ID;
 END IF;

 IF p_entry_rec.BATCH_ID   = FND_API.g_miss_num THEN
     x_complete_rec.BATCH_ID := l_entry_rec.BATCH_ID;
 END IF;

 IF p_entry_rec.COL1   = FND_API.g_miss_char THEN
     x_complete_rec.COL1 := l_entry_rec.COL1 ;
 END IF;

 IF p_entry_rec.COL2   = FND_API.g_miss_char THEN
     x_complete_rec.COL2 := l_entry_rec.COL2 ;
 END IF;

 IF p_entry_rec.COL3   = FND_API.g_miss_char THEN
     x_complete_rec.COL3  := l_entry_rec.COL3 ;
 END IF;

 IF p_entry_rec.COL4    = FND_API.g_miss_char THEN
     x_complete_rec.COL4 := l_entry_rec.COL4;
 END IF;

 IF p_entry_rec.COL5   = FND_API.g_miss_char THEN
     x_complete_rec.COL5 := l_entry_rec.COL5;
 END IF;

 IF p_entry_rec.COL6   = FND_API.g_miss_char THEN
     x_complete_rec.COL6 := l_entry_rec.COL6;
 END IF;

 IF p_entry_rec.COL7   = FND_API.g_miss_char THEN
     x_complete_rec.COL7 := l_entry_rec.COL7;
 END IF;

 IF p_entry_rec.COL8    = FND_API.g_miss_char THEN
     x_complete_rec.COL8 := l_entry_rec.COL8;
 END IF;

 IF p_entry_rec.COL9    = FND_API.g_miss_char THEN
     x_complete_rec.COL9 := l_entry_rec.COL9;
 END IF;

 IF p_entry_rec.COL10   = FND_API.g_miss_char THEN
     x_complete_rec.COL10 := l_entry_rec.COL10;
 END IF;

 IF p_entry_rec.COL11    = FND_API.g_miss_char THEN
     x_complete_rec.COL11 := l_entry_rec.COL11;
 END IF;

 IF p_entry_rec.COL12     = FND_API.g_miss_char THEN
     x_complete_rec.COL12  := l_entry_rec.COL12 ;
 END IF;

 IF p_entry_rec.COL13     = FND_API.g_miss_char THEN
     x_complete_rec.COL13 := l_entry_rec.COL13;
 END IF;

 IF p_entry_rec.COL14     = FND_API.g_miss_char THEN
     x_complete_rec.COL14 := l_entry_rec.COL14;
 END IF;

 IF p_entry_rec.COL15      = FND_API.g_miss_char THEN
     x_complete_rec.COL15 := l_entry_rec.COL15;
 END IF;

 IF p_entry_rec.COL16      = FND_API.g_miss_char THEN
     x_complete_rec.COL16 := l_entry_rec.COL16;
 END IF;

 IF p_entry_rec.COL17 = FND_API.g_miss_char THEN
     x_complete_rec.COL17 := l_entry_rec.COL17;
 END IF;

 IF p_entry_rec.COL18 = FND_API.g_miss_char THEN
     x_complete_rec.COL18 := l_entry_rec.COL18;
 END IF;

 IF p_entry_rec.COL19 = FND_API.g_miss_char THEN
     x_complete_rec.COL19 := l_entry_rec.COL19;
 END IF;

 IF p_entry_rec.COL20 = FND_API.g_miss_char THEN
     x_complete_rec.COL20 := l_entry_rec.COL20;
 END IF;

 IF p_entry_rec.COL21 = FND_API.g_miss_char THEN
     x_complete_rec.COL21 := l_entry_rec.COL21;
 END IF;

 IF p_entry_rec.COL22 = FND_API.g_miss_char THEN
     x_complete_rec.COL22 := l_entry_rec.COL22;
 END IF;

 IF p_entry_rec.COL23 = FND_API.g_miss_char THEN
     x_complete_rec.COL23 := l_entry_rec.COL23;
 END IF;

 IF p_entry_rec.COL24 = FND_API.g_miss_char THEN
     x_complete_rec.COL24 := l_entry_rec.COL24;
 END IF;

 IF p_entry_rec.COL25 = FND_API.g_miss_char THEN
     x_complete_rec.COL25 := l_entry_rec.COL25;
 END IF;

 IF p_entry_rec.COL26  = FND_API.g_miss_char THEN
     x_complete_rec.COL26 := l_entry_rec.COL26;
 END IF;

 IF p_entry_rec.COL27 = FND_API.g_miss_char THEN
     x_complete_rec.COL27 := l_entry_rec.COL27;
 END IF;

 IF p_entry_rec.COL28 = FND_API.g_miss_char THEN
     x_complete_rec.COL28 := l_entry_rec.COL28;
 END IF;

 IF p_entry_rec.COL29 = FND_API.g_miss_char THEN
     x_complete_rec.COL29 := l_entry_rec.COL29;
 END IF;

 IF p_entry_rec.COL30 = FND_API.g_miss_char THEN
     x_complete_rec.COL30 := l_entry_rec.COL30;
 END IF;

 IF p_entry_rec.COL31 = FND_API.g_miss_char THEN
     x_complete_rec.COL31 := l_entry_rec.COL31;
 END IF;

 IF p_entry_rec.COL32  = FND_API.g_miss_char THEN
     x_complete_rec.COL32 := l_entry_rec.COL32;
 END IF;

 IF p_entry_rec.COL33 = FND_API.g_miss_char THEN
     x_complete_rec.COL33 := l_entry_rec.COL33;
 END IF;

 IF p_entry_rec.COL34 = FND_API.g_miss_char THEN
     x_complete_rec.COL34 := l_entry_rec.COL34;
 END IF;

 IF p_entry_rec.COL35 = FND_API.g_miss_char THEN
     x_complete_rec.COL35 := l_entry_rec.COL35;
 END IF;

 IF p_entry_rec.COL36 = FND_API.g_miss_char THEN
     x_complete_rec.COL36 := l_entry_rec.COL36;
 END IF;

 IF p_entry_rec.COL37 = FND_API.g_miss_char THEN
     x_complete_rec.COL37 := l_entry_rec.COL37;
 END IF;

 IF p_entry_rec.COL38 = FND_API.g_miss_char THEN
     x_complete_rec.COL38 := l_entry_rec.COL38;
 END IF;

 IF p_entry_rec.COL39 = FND_API.g_miss_char THEN
     x_complete_rec.COL39 := l_entry_rec.COL39;
 END IF;

 IF p_entry_rec.COL40 = FND_API.g_miss_char THEN
     x_complete_rec.COL40 := l_entry_rec.COL40;
 END IF;

 IF p_entry_rec.COL41 = FND_API.g_miss_char THEN
     x_complete_rec.COL41 := l_entry_rec.COL41;
 END IF;

 IF p_entry_rec.COL42 = FND_API.g_miss_char THEN
     x_complete_rec.COL42 := l_entry_rec.COL42;
 END IF;

 IF p_entry_rec.COL43 = FND_API.g_miss_char THEN
     x_complete_rec.COL43 := l_entry_rec.COL43;
 END IF;

 IF p_entry_rec.COL44 = FND_API.g_miss_char THEN
     x_complete_rec.COL44 := l_entry_rec.COL44;
 END IF;

 IF p_entry_rec.COL45 = FND_API.g_miss_char THEN
     x_complete_rec.COL45 := l_entry_rec.COL45;
 END IF;

 IF p_entry_rec.COL46 = FND_API.g_miss_char THEN
     x_complete_rec.COL46 := l_entry_rec.COL46;
 END IF;

 IF p_entry_rec.COL47 = FND_API.g_miss_char THEN
     x_complete_rec.COL47 := l_entry_rec.COL47;
 END IF;

 IF p_entry_rec.COL48 = FND_API.g_miss_char THEN
   x_complete_rec.COL48 := l_entry_rec.COL48;
 END IF;

 IF p_entry_rec.COL49 = FND_API.g_miss_char THEN
   x_complete_rec.COL49 := l_entry_rec.COL49;
 END IF;

 IF p_entry_rec.COL50 = FND_API.g_miss_char THEN
     x_complete_rec.COL50 := l_entry_rec.COL50;
 END IF;

 IF p_entry_rec.COL51 = FND_API.g_miss_char THEN
     x_complete_rec.COL51 := l_entry_rec.COL51;
 END IF;

 IF p_entry_rec.COL52 = FND_API.g_miss_char THEN
     x_complete_rec.COL52 := l_entry_rec.COL52;
 END IF;

 IF p_entry_rec.COL53 = FND_API.g_miss_char THEN
     x_complete_rec.COL53 := l_entry_rec.COL53;
 END IF;

 IF p_entry_rec.COL54 = FND_API.g_miss_char THEN
     x_complete_rec.COL54 := l_entry_rec.COL54;
 END IF;

 IF p_entry_rec.COL55 = FND_API.g_miss_char THEN
     x_complete_rec.COL55 := l_entry_rec.COL55;
 END IF;

 IF p_entry_rec.COL56 = FND_API.g_miss_char THEN
     x_complete_rec.COL56 := l_entry_rec.COL56;
 END IF;

 IF p_entry_rec.COL57 = FND_API.g_miss_char THEN
x_complete_rec.COL57 := l_entry_rec.COL57;
 END IF;

 IF p_entry_rec.COL58 = FND_API.g_miss_char THEN
x_complete_rec.COL58 := l_entry_rec.COL58;
 END IF;

 IF p_entry_rec.COL59 = FND_API.g_miss_char THEN
x_complete_rec.COL59 := l_entry_rec.COL59;
 END IF;

 IF p_entry_rec.COL60 = FND_API.g_miss_char THEN
x_complete_rec.COL60 := l_entry_rec.COL60;
 END IF;

 IF p_entry_rec.COL61 = FND_API.g_miss_char THEN
x_complete_rec.COL61 := l_entry_rec.COL61;
 END IF;

 IF p_entry_rec.COL62  = FND_API.g_miss_char THEN
x_complete_rec.COL62 := l_entry_rec.COL62;
 END IF;

 IF p_entry_rec.COL63 = FND_API.g_miss_char THEN
x_complete_rec.COL63 := l_entry_rec.COL63;
 END IF;

 IF p_entry_rec.COL64 = FND_API.g_miss_char THEN
x_complete_rec.COL64 := l_entry_rec.COL64;
 END IF;

 IF p_entry_rec.COL65 = FND_API.g_miss_char THEN
x_complete_rec.COL65 := l_entry_rec.COL65;
 END IF;

 IF p_entry_rec.COL66 = FND_API.g_miss_char THEN
x_complete_rec.COL66 := l_entry_rec.COL66;
 END IF;

 IF p_entry_rec.COL67 = FND_API.g_miss_char THEN
x_complete_rec.COL67 := l_entry_rec.COL67;
 END IF;

 IF p_entry_rec.COL68 = FND_API.g_miss_char THEN
x_complete_rec.COL68 := l_entry_rec.COL68;
 END IF;

 IF p_entry_rec.COL69 = FND_API.g_miss_char THEN
x_complete_rec.COL69 := l_entry_rec.COL69;
 END IF;

 IF p_entry_rec.COL70 = FND_API.g_miss_char THEN
x_complete_rec.COL70  := l_entry_rec.COL70 ;
 END IF;

 IF p_entry_rec.COL71 = FND_API.g_miss_char THEN
x_complete_rec.COL71 := l_entry_rec.COL71;
 END IF;

 IF p_entry_rec.COL72 = FND_API.g_miss_char THEN
x_complete_rec.COL72 := l_entry_rec.COL72;
 END IF;

 IF p_entry_rec.COL73 = FND_API.g_miss_char THEN
x_complete_rec.COL73 := l_entry_rec.COL73;
 END IF;

 IF p_entry_rec.COL74 = FND_API.g_miss_char THEN
x_complete_rec.COL74  := l_entry_rec.COL74 ;
 END IF;

 IF p_entry_rec.COL75 = FND_API.g_miss_char THEN
x_complete_rec.COL75 := l_entry_rec.COL75;
 END IF;

 IF p_entry_rec.COL76 = FND_API.g_miss_char THEN
x_complete_rec.COL76 := l_entry_rec.COL76;
 END IF;

 IF p_entry_rec.COL77 = FND_API.g_miss_char THEN
x_complete_rec.COL77  := l_entry_rec.COL77 ;
 END IF;

 IF p_entry_rec.COL78 = FND_API.g_miss_char THEN
x_complete_rec.COL78 := l_entry_rec.COL78;
 END IF;

 IF p_entry_rec.COL79 = FND_API.g_miss_char THEN
x_complete_rec.COL79 := l_entry_rec.COL79;
 END IF;

 IF p_entry_rec.COL80  = FND_API.g_miss_char THEN
     x_complete_rec.COL80 := l_entry_rec.COL80;
 END IF;

 IF p_entry_rec.COL81 = FND_API.g_miss_char THEN
     x_complete_rec.COL81 := l_entry_rec.COL81;
 END IF;

 IF p_entry_rec.COL82 = FND_API.g_miss_char THEN
     x_complete_rec.COL82 := l_entry_rec.COL82;
 END IF;

 IF p_entry_rec.COL83 = FND_API.g_miss_char THEN
     x_complete_rec.COL83 := l_entry_rec.COL83;
 END IF;

 IF p_entry_rec.COL84 = FND_API.g_miss_char THEN
     x_complete_rec.COL84 := l_entry_rec.COL84;
 END IF;

 IF p_entry_rec.COL85 = FND_API.g_miss_char THEN
     x_complete_rec.COL85 := l_entry_rec.COL85;
 END IF;

 IF p_entry_rec.COL86 = FND_API.g_miss_char THEN
x_complete_rec.COL86 := l_entry_rec.COL86;
 END IF;

 IF p_entry_rec.COL87  = FND_API.g_miss_char THEN
x_complete_rec.COL87 := l_entry_rec.COL87;
 END IF;

 IF p_entry_rec.COL88 = FND_API.g_miss_char THEN
x_complete_rec.COL88 := l_entry_rec.COL88;
 END IF;

 IF p_entry_rec.COL89  = FND_API.g_miss_char THEN
x_complete_rec.COL89 := l_entry_rec.COL89;
 END IF;

 IF p_entry_rec.COL90  = FND_API.g_miss_char THEN
x_complete_rec.COL90 := l_entry_rec.COL90;
 END IF;

 IF p_entry_rec.COL91  = FND_API.g_miss_char THEN
x_complete_rec.COL91 := l_entry_rec.COL91;
 END IF;

 IF p_entry_rec.COL92  = FND_API.g_miss_char THEN
x_complete_rec.COL92 := l_entry_rec.COL92;
 END IF;

 IF p_entry_rec.COL93 = FND_API.g_miss_char THEN
x_complete_rec.COL93 := l_entry_rec.COL93;
 END IF;

 IF p_entry_rec.COL94 = FND_API.g_miss_char THEN
x_complete_rec.COL94:= l_entry_rec.COL94;
 END IF;

 IF p_entry_rec.COL95 = FND_API.g_miss_char THEN
x_complete_rec.COL95 := l_entry_rec.COL95;
 END IF;

 IF p_entry_rec.COL96 = FND_API.g_miss_char THEN
x_complete_rec.COL96 := l_entry_rec.COL96;
 END IF;

 IF p_entry_rec.COL97 = FND_API.g_miss_char THEN
x_complete_rec.COL97  := l_entry_rec.COL97 ;
 END IF;

 IF p_entry_rec.COL98 = FND_API.g_miss_char THEN
x_complete_rec.COL98 := l_entry_rec.COL98;
 END IF;

 IF p_entry_rec.COL99 = FND_API.g_miss_char THEN
x_complete_rec.COL99 := l_entry_rec.COL99;
 END IF;

 IF p_entry_rec.COL100 = FND_API.g_miss_char THEN
x_complete_rec.COL100  := l_entry_rec.COL100 ;
END IF;

 IF p_entry_rec.COL101 = FND_API.g_miss_char THEN
x_complete_rec.COL101  := l_entry_rec.COL101 ;
 END IF;

 IF p_entry_rec.COL102 = FND_API.g_miss_char THEN
x_complete_rec.COL102 := l_entry_rec.COL102;
 END IF;

 IF p_entry_rec.COL103 = FND_API.g_miss_char THEN
x_complete_rec.COL103 := l_entry_rec.COL103;
 END IF;

 IF p_entry_rec.COL104 = FND_API.g_miss_char THEN
x_complete_rec.COL104  := l_entry_rec.COL104 ;
 END IF;

 IF p_entry_rec.COL105 = FND_API.g_miss_char THEN
x_complete_rec.COL105 := l_entry_rec.COL105;
 END IF;

 IF p_entry_rec.COL106 = FND_API.g_miss_char THEN
x_complete_rec.COL106 := l_entry_rec.COL106;
 END IF;

 IF p_entry_rec.COL107 = FND_API.g_miss_char THEN
x_complete_rec.COL107 := l_entry_rec.COL107;
 END IF;

 IF p_entry_rec.COL108 = FND_API.g_miss_char THEN
x_complete_rec.COL108  := l_entry_rec.COL108 ;
 END IF;

 IF p_entry_rec.COL109 = FND_API.g_miss_char THEN
x_complete_rec.COL109  := l_entry_rec.COL109 ;
 END IF;

 IF p_entry_rec.COL110 = FND_API.g_miss_char THEN
x_complete_rec.COL110  := l_entry_rec.COL110 ;
 END IF;

 IF p_entry_rec.COL111 = FND_API.g_miss_char THEN
x_complete_rec.COL111 := l_entry_rec.COL111;
 END IF;

 IF p_entry_rec.COL112 = FND_API.g_miss_char THEN
x_complete_rec.COL112 := l_entry_rec.COL112;
 END IF;

 IF p_entry_rec.COL113 = FND_API.g_miss_char THEN
x_complete_rec.COL113 := l_entry_rec.COL113;
 END IF;

 IF p_entry_rec.COL114 = FND_API.g_miss_char THEN
x_complete_rec.COL114 := l_entry_rec.COL114;
 END IF;

 IF p_entry_rec.COL115 = FND_API.g_miss_char THEN
x_complete_rec.COL115 := l_entry_rec.COL115;
 END IF;

 IF p_entry_rec.COL116 = FND_API.g_miss_char THEN
x_complete_rec.COL116 := l_entry_rec.COL116;
 END IF;

 IF p_entry_rec.COL117 = FND_API.g_miss_char THEN
x_complete_rec.COL117 := l_entry_rec.COL117;
 END IF;

 IF p_entry_rec.COL118 = FND_API.g_miss_char THEN
x_complete_rec.COL118 := l_entry_rec.COL118;
 END IF;

 IF p_entry_rec.COL119 = FND_API.g_miss_char THEN
x_complete_rec.COL119 := l_entry_rec.COL119;
 END IF;

 IF p_entry_rec.COL120 = FND_API.g_miss_char THEN
x_complete_rec.COL120 := l_entry_rec.COL120;
 END IF;

 IF p_entry_rec.COL121 = FND_API.g_miss_char THEN
x_complete_rec.COL121 := l_entry_rec.COL121;
 END IF;

 IF p_entry_rec.COL122 = FND_API.g_miss_char THEN
x_complete_rec.COL122  := l_entry_rec.COL122 ;
 END IF;

 IF p_entry_rec.COL123 = FND_API.g_miss_char THEN
x_complete_rec.COL123  := l_entry_rec.COL123 ;
 END IF;

 IF p_entry_rec.COL124 = FND_API.g_miss_char THEN
x_complete_rec.COL124 := l_entry_rec.COL124;
 END IF;

 IF p_entry_rec.COL125 = FND_API.g_miss_char THEN
x_complete_rec.COL125 := l_entry_rec.COL125;
 END IF;

 IF p_entry_rec.COL126 = FND_API.g_miss_char THEN
x_complete_rec.COL126 := l_entry_rec.COL126;
 END IF;

 IF p_entry_rec.COL127 = FND_API.g_miss_char THEN
x_complete_rec.COL127 := l_entry_rec.COL127;
 END IF;

 IF p_entry_rec.COL128  = FND_API.g_miss_char THEN
x_complete_rec.COL128 := l_entry_rec.COL128;
 END IF;

 IF p_entry_rec.COL129 = FND_API.g_miss_char THEN
x_complete_rec.COL129  := l_entry_rec.COL129 ;
 END IF;

 IF p_entry_rec.COL130 = FND_API.g_miss_char THEN
x_complete_rec.COL130 := l_entry_rec.COL130;
 END IF;

 IF p_entry_rec.COL131 = FND_API.g_miss_char THEN
x_complete_rec.COL131 := l_entry_rec.COL131;
 END IF;

 IF p_entry_rec.COL132 = FND_API.g_miss_char THEN
x_complete_rec.COL132 := l_entry_rec.COL132;
 END IF;

 IF p_entry_rec.COL133 = FND_API.g_miss_char THEN
x_complete_rec.COL133 := l_entry_rec.COL133;
 END IF;

 IF p_entry_rec.COL134 = FND_API.g_miss_char THEN
x_complete_rec.COL134 := l_entry_rec.COL134;
 END IF;

 IF p_entry_rec.COL135 = FND_API.g_miss_char THEN
x_complete_rec.COL135 := l_entry_rec.COL135;
 END IF;

 IF p_entry_rec.COL136 = FND_API.g_miss_char THEN
x_complete_rec.COL136 := l_entry_rec.COL136;
 END IF;

 IF p_entry_rec.COL137 = FND_API.g_miss_char THEN
x_complete_rec.COL137  := l_entry_rec.COL137 ;
 END IF;

 IF p_entry_rec.COL138 = FND_API.g_miss_char THEN
x_complete_rec.COL138 := l_entry_rec.COL138;
 END IF;

 IF p_entry_rec.COL139 = FND_API.g_miss_char THEN
x_complete_rec.COL139 := l_entry_rec.COL139;
 END IF;

 IF p_entry_rec.COL140 = FND_API.g_miss_char THEN
x_complete_rec.COL140 := l_entry_rec.COL140;
 END IF;

 IF p_entry_rec.COL141 = FND_API.g_miss_char THEN
x_complete_rec.COL141 := l_entry_rec.COL141;
 END IF;

 IF p_entry_rec.COL142 = FND_API.g_miss_char THEN
x_complete_rec.COL142  := l_entry_rec.COL142 ;
 END IF;

 IF p_entry_rec.COL143 = FND_API.g_miss_char THEN
x_complete_rec.COL143 := l_entry_rec.COL143;
 END IF;

 IF p_entry_rec.COL144 = FND_API.g_miss_char THEN
x_complete_rec.COL144 := l_entry_rec.COL144;
 END IF;

 IF p_entry_rec.COL145 = FND_API.g_miss_char THEN
x_complete_rec.COL145 := l_entry_rec.COL145;
 END IF;

 IF p_entry_rec.COL146 = FND_API.g_miss_char THEN
x_complete_rec.COL146 := l_entry_rec.COL146;
 END IF;

 IF p_entry_rec.COL147 = FND_API.g_miss_char THEN
x_complete_rec.COL147  := l_entry_rec.COL147 ;
 END IF;

 IF p_entry_rec.COL148  = FND_API.g_miss_char THEN
x_complete_rec.COL148 := l_entry_rec.COL148;
 END IF;

 IF p_entry_rec.COL149  = FND_API.g_miss_char THEN
x_complete_rec.COL149 := l_entry_rec.COL149;
 END IF;

 IF p_entry_rec.COL150 = FND_API.g_miss_char THEN
x_complete_rec.COL150 := l_entry_rec.COL150;
 END IF;

 IF p_entry_rec.COL151 = FND_API.g_miss_char THEN
x_complete_rec.COL151 := l_entry_rec.COL151;
 END IF;

 IF p_entry_rec.COL152 = FND_API.g_miss_char THEN
x_complete_rec.COL152  := l_entry_rec.COL152 ;

 END IF;

 IF p_entry_rec.COL153 = FND_API.g_miss_char THEN
x_complete_rec.COL153 := l_entry_rec.COL153;
 END IF;

 IF p_entry_rec.COL154 = FND_API.g_miss_char THEN
x_complete_rec.COL154 := l_entry_rec.COL154;
 END IF;

 IF p_entry_rec.COL155 = FND_API.g_miss_char THEN
x_complete_rec.COL155 := l_entry_rec.COL155;
 END IF;

 IF p_entry_rec.COL156  = FND_API.g_miss_char THEN
x_complete_rec.COL156 := l_entry_rec.COL156;
 END IF;

 IF p_entry_rec.COL157 = FND_API.g_miss_char THEN
x_complete_rec.COL157 := l_entry_rec.COL157;
 END IF;

 IF p_entry_rec.COL158 = FND_API.g_miss_char THEN
x_complete_rec.COL158 := l_entry_rec.COL158;
 END IF;

 IF p_entry_rec.COL159 = FND_API.g_miss_char THEN
x_complete_rec.COL159 := l_entry_rec.COL159;
 END IF;

 IF p_entry_rec.COL160 = FND_API.g_miss_char THEN
x_complete_rec.COL160 := l_entry_rec.COL160;
 END IF;

 IF p_entry_rec.COL161 = FND_API.g_miss_char THEN
x_complete_rec.COL161 := l_entry_rec.COL161;
 END IF;

 IF p_entry_rec.COL162  = FND_API.g_miss_char THEN
x_complete_rec.COL162  := l_entry_rec.COL162 ;
 END IF;

 IF p_entry_rec.COL163  = FND_API.g_miss_char THEN
x_complete_rec.COL163 := l_entry_rec.COL163;
 END IF;

 IF p_entry_rec.COL164  = FND_API.g_miss_char THEN
x_complete_rec.COL164 := l_entry_rec.COL164;
 END IF;

 IF p_entry_rec.COL165  = FND_API.g_miss_char THEN
x_complete_rec.COL165 := l_entry_rec.COL165;
 END IF;

 IF p_entry_rec.COL166  = FND_API.g_miss_char THEN
x_complete_rec.COL166 := l_entry_rec.COL166;
 END IF;

 IF p_entry_rec.COL167  = FND_API.g_miss_char THEN
x_complete_rec.COL167 := l_entry_rec.COL167;
 END IF;

 IF p_entry_rec.COL168 = FND_API.g_miss_char THEN
x_complete_rec.COL168 := l_entry_rec.COL168;
 END IF;

 IF p_entry_rec.COL169 = FND_API.g_miss_char THEN
x_complete_rec.COL169 := l_entry_rec.COL169;
 END IF;

 IF p_entry_rec.COL170 = FND_API.g_miss_char THEN
x_complete_rec.COL170 := l_entry_rec.COL170;
 END IF;

 IF p_entry_rec.COL171 = FND_API.g_miss_char THEN
x_complete_rec.COL171 := l_entry_rec.COL171;
 END IF;

 IF p_entry_rec.COL172 = FND_API.g_miss_char THEN
x_complete_rec.COL172 := l_entry_rec.COL172;
 END IF;

 IF p_entry_rec.COL173  = FND_API.g_miss_char THEN
x_complete_rec.COL173  := l_entry_rec.COL173 ;
 END IF;

 IF p_entry_rec.COL174  = FND_API.g_miss_char THEN
x_complete_rec.COL174 := l_entry_rec.COL174;
 END IF;

 IF p_entry_rec.COL175 = FND_API.g_miss_char THEN
x_complete_rec.COL175 := l_entry_rec.COL175;
 END IF;

 IF p_entry_rec.COL176 = FND_API.g_miss_char THEN
x_complete_rec.COL176 := l_entry_rec.COL176;
 END IF;

 IF p_entry_rec.COL177 = FND_API.g_miss_char THEN
x_complete_rec.COL177 := l_entry_rec.COL177;
 END IF;

 IF p_entry_rec.COL178 = FND_API.g_miss_char THEN
x_complete_rec.COL178 := l_entry_rec.COL178;
 END IF;

 IF p_entry_rec.COL179 = FND_API.g_miss_char THEN
x_complete_rec.COL179 := l_entry_rec.COL179;
 END IF;

 IF p_entry_rec.COL180 = FND_API.g_miss_char THEN
x_complete_rec.COL180 := l_entry_rec.COL180;
 END IF;

 IF p_entry_rec.COL181 = FND_API.g_miss_char THEN
x_complete_rec.COL181 := l_entry_rec.COL181;
 END IF;

 IF p_entry_rec.COL182 = FND_API.g_miss_char THEN
x_complete_rec.COL182 := l_entry_rec.COL182;
 END IF;

 IF p_entry_rec.COL183 = FND_API.g_miss_char THEN
x_complete_rec.COL183 := l_entry_rec.COL183;
 END IF;

 IF p_entry_rec.COL184 = FND_API.g_miss_char THEN
x_complete_rec.COL184  := l_entry_rec.COL184 ;
 END IF;

 IF p_entry_rec.COL185 = FND_API.g_miss_char THEN
x_complete_rec.COL185 := l_entry_rec.COL185;
 END IF;

 IF p_entry_rec.COL186 = FND_API.g_miss_char THEN
x_complete_rec.COL186 := l_entry_rec.COL186;
 END IF;

 IF p_entry_rec.COL187 = FND_API.g_miss_char THEN
x_complete_rec.COL187 := l_entry_rec.COL187;
 END IF;

 IF p_entry_rec.COL188 = FND_API.g_miss_char THEN
x_complete_rec.COL188 := l_entry_rec.COL188;
 END IF;

 IF p_entry_rec.COL189 = FND_API.g_miss_char THEN
x_complete_rec.COL189 := l_entry_rec.COL189;
 END IF;

 IF p_entry_rec.COL190  = FND_API.g_miss_char THEN
x_complete_rec.COL190 := l_entry_rec.COL190;
 END IF;

 IF p_entry_rec.COL191  = FND_API.g_miss_char THEN
     x_complete_rec.COL191 := l_entry_rec.COL191;
 END IF;

 IF p_entry_rec.COL192  = FND_API.g_miss_char THEN
     x_complete_rec.COL192 := l_entry_rec.COL192;
 END IF;

 IF p_entry_rec.COL193  = FND_API.g_miss_char THEN
     x_complete_rec.COL193  := l_entry_rec.COL193 ;
 END IF;

 IF p_entry_rec.COL194  = FND_API.g_miss_char THEN
     x_complete_rec.COL194 := l_entry_rec.COL194;
 END IF;

 IF p_entry_rec.COL195  = FND_API.g_miss_char THEN
     x_complete_rec.COL195 := l_entry_rec.COL195;
 END IF;

 IF p_entry_rec.COL196  = FND_API.g_miss_char THEN
     x_complete_rec.COL196 := l_entry_rec.COL196;
 END IF;

 IF p_entry_rec.COL197  = FND_API.g_miss_char THEN
     x_complete_rec.COL197  := l_entry_rec.COL197 ;
 END IF;

 IF p_entry_rec.COL198   = FND_API.g_miss_char THEN
     x_complete_rec.COL198 := l_entry_rec.COL198;
 END IF;

 IF p_entry_rec.COL199 = FND_API.g_miss_char THEN
     x_complete_rec.COL199 := l_entry_rec.COL199;
 END IF;

 IF p_entry_rec.COL200  = FND_API.g_miss_char THEN
     x_complete_rec.COL200 := l_entry_rec.COL200;
 END IF;

 IF p_entry_rec.COL201  = FND_API.g_miss_char THEN
     x_complete_rec.COL201 := l_entry_rec.COL201;
 END IF;

 IF p_entry_rec.COL202 = FND_API.g_miss_char THEN
     x_complete_rec.COL202 := l_entry_rec.COL202;
 END IF;

 IF p_entry_rec.COL203 = FND_API.g_miss_char THEN
     x_complete_rec.COL203 := l_entry_rec.COL203;
 END IF;

 IF p_entry_rec.COL204 = FND_API.g_miss_char THEN
     x_complete_rec.COL204 := l_entry_rec.COL204;
 END IF;

 IF p_entry_rec.COL205 = FND_API.g_miss_char THEN
     x_complete_rec.COL205 := l_entry_rec.COL205;
 END IF;

 IF p_entry_rec.COL206 = FND_API.g_miss_char THEN
     x_complete_rec.COL206 := l_entry_rec.COL206;
 END IF;

 IF p_entry_rec.COL207 = FND_API.g_miss_char THEN
     x_complete_rec.COL207 := l_entry_rec.COL207;
 END IF;

 IF p_entry_rec.COL208 = FND_API.g_miss_char THEN
     x_complete_rec.COL208 := l_entry_rec.COL208;
 END IF;

 IF p_entry_rec.COL209 = FND_API.g_miss_char THEN
     x_complete_rec.COL209 := l_entry_rec.COL209;
 END IF;

 IF p_entry_rec.COL210 = FND_API.g_miss_char THEN
     x_complete_rec.COL210 := l_entry_rec.COL210;
 END IF;

 IF p_entry_rec.COL211 = FND_API.g_miss_char THEN
     x_complete_rec.COL211 := l_entry_rec.COL211;
 END IF;

 IF p_entry_rec.COL212 = FND_API.g_miss_char THEN
     x_complete_rec.COL212 := l_entry_rec.COL212;
 END IF;

 IF p_entry_rec.COL213 = FND_API.g_miss_char THEN
     x_complete_rec.COL213 := l_entry_rec.COL213;
 END IF;

 IF p_entry_rec.COL214 = FND_API.g_miss_char THEN
     x_complete_rec.COL214 := l_entry_rec.COL214;
 END IF;

 IF p_entry_rec.COL215 = FND_API.g_miss_char THEN
     x_complete_rec.COL215 := l_entry_rec.COL215;
 END IF;

 IF p_entry_rec.COL216 = FND_API.g_miss_char THEN
      x_complete_rec.COL216 := l_entry_rec.COL216;
 END IF;

 IF p_entry_rec.COL217 = FND_API.g_miss_char THEN
     x_complete_rec.COL217 := l_entry_rec.COL217;
 END IF;

 IF p_entry_rec.COL218 = FND_API.g_miss_char THEN
     x_complete_rec.COL218 := l_entry_rec.COL218;
 END IF;

 IF p_entry_rec.COL219 = FND_API.g_miss_char THEN
     x_complete_rec.COL219 := l_entry_rec.COL219;
 END IF;

 IF p_entry_rec.COL220 = FND_API.g_miss_char THEN
     x_complete_rec.COL220  := l_entry_rec.COL220 ;
 END IF;

 IF p_entry_rec.COL221 = FND_API.g_miss_char THEN
     x_complete_rec.COL221 := l_entry_rec.COL221;
 END IF;

 IF p_entry_rec.COL222 = FND_API.g_miss_char THEN
     x_complete_rec.COL222 := l_entry_rec.COL222;
 END IF;

 IF p_entry_rec.COL223 = FND_API.g_miss_char THEN
     x_complete_rec.COL223 := l_entry_rec.COL223;
 END IF;

 IF p_entry_rec.COL224 = FND_API.g_miss_char THEN
     x_complete_rec.COL224 := l_entry_rec.COL224;
 END IF;

 IF p_entry_rec.COL225 = FND_API.g_miss_char THEN
     x_complete_rec.COL225 := l_entry_rec.COL225;
 END IF;

 IF p_entry_rec.COL226 = FND_API.g_miss_char THEN
     x_complete_rec.COL226 := l_entry_rec.COL226;
 END IF;

 IF p_entry_rec.COL227 = FND_API.g_miss_char THEN
     x_complete_rec.COL227  := l_entry_rec.COL227 ;
 END IF;

 IF p_entry_rec.COL228 = FND_API.g_miss_char THEN
     x_complete_rec.COL228  := l_entry_rec.COL228 ;
 END IF;

 IF p_entry_rec.COL229 = FND_API.g_miss_char THEN
     x_complete_rec.COL229 := l_entry_rec.COL229;
 END IF;

 IF p_entry_rec.COL230 = FND_API.g_miss_char THEN
     x_complete_rec.COL230  := l_entry_rec.COL230 ;
 END IF;

 IF p_entry_rec.COL231 = FND_API.g_miss_char THEN
     x_complete_rec.COL231 := l_entry_rec.COL231;
 END IF;

 IF p_entry_rec.COL232 = FND_API.g_miss_char THEN
     x_complete_rec.COL232 := l_entry_rec.COL232;
 END IF;

 IF p_entry_rec.COL233 = FND_API.g_miss_char THEN
     x_complete_rec.COL233 := l_entry_rec.COL233;
 END IF;

 IF p_entry_rec.COL234 = FND_API.g_miss_char THEN
     x_complete_rec.COL234 := l_entry_rec.COL234;
 END IF;

 IF p_entry_rec.COL235 = FND_API.g_miss_char THEN
     x_complete_rec.COL235  := l_entry_rec.COL235 ;
 END IF;

 IF p_entry_rec.COL236 = FND_API.g_miss_char THEN
     x_complete_rec.COL236 := l_entry_rec.COL236;
 END IF;

 IF p_entry_rec.COL237 = FND_API.g_miss_char THEN
     x_complete_rec.COL237 := l_entry_rec.COL237;
 END IF;

 IF p_entry_rec.COL238 = FND_API.g_miss_char THEN
     x_complete_rec.COL238  := l_entry_rec.COL238 ;
 END IF;

 IF p_entry_rec.COL239 = FND_API.g_miss_char THEN
     x_complete_rec.COL239 := l_entry_rec.COL239;
 END IF;

 IF p_entry_rec.COL240 = FND_API.g_miss_char THEN
     x_complete_rec.COL240 := l_entry_rec.COL240;
 END IF;

 IF p_entry_rec.COL241 = FND_API.g_miss_char THEN
     x_complete_rec.COL241  := l_entry_rec.COL241 ;
 END IF;

 IF p_entry_rec.COL242 = FND_API.g_miss_char THEN
     x_complete_rec.COL242 := l_entry_rec.COL242;
 END IF;

 IF p_entry_rec.COL243 = FND_API.g_miss_char THEN
     x_complete_rec.COL243 := l_entry_rec.COL243;
 END IF;

 IF p_entry_rec.COL244 = FND_API.g_miss_char THEN
     x_complete_rec.COL244 := l_entry_rec.COL244;
 END IF;

 IF p_entry_rec.COL245 = FND_API.g_miss_char THEN
     x_complete_rec.COL245 := l_entry_rec.COL245;
 END IF;

 IF p_entry_rec.COL246 = FND_API.g_miss_char THEN
     x_complete_rec.COL246 := l_entry_rec.COL246;
 END IF;

 IF p_entry_rec.COL247 = FND_API.g_miss_char THEN
     x_complete_rec.COL247 := l_entry_rec.COL247;
 END IF;

 IF p_entry_rec.COL248 = FND_API.g_miss_char THEN
     x_complete_rec.COL248  := l_entry_rec.COL248 ;
 END IF;

 IF p_entry_rec.COL249 = FND_API.g_miss_char THEN
     x_complete_rec.COL249 := l_entry_rec.COL249;
 END IF;

 IF p_entry_rec.COL250 = FND_API.g_miss_char THEN
     x_complete_rec.COL250 := l_entry_rec.COL250;
 END IF;

 IF p_entry_rec.COL251 = FND_API.g_miss_char THEN
    x_complete_rec.COL251 := l_entry_rec.COL251;
 END IF;


 IF p_entry_rec.COL252 = FND_API.g_miss_char THEN
    x_complete_rec.COL252 := l_entry_rec.COL252;
 END IF;


 IF p_entry_rec.COL253 = FND_API.g_miss_char THEN
    x_complete_rec.COL253 := l_entry_rec.COL253;
 END IF;


 IF p_entry_rec.COL254 = FND_API.g_miss_char THEN
    x_complete_rec.COL254 := l_entry_rec.COL254;
 END IF;


 IF p_entry_rec.COL255 = FND_API.g_miss_char THEN
    x_complete_rec.COL255 := l_entry_rec.COL255;
 END IF;


 IF p_entry_rec.COL256 = FND_API.g_miss_char THEN
    x_complete_rec.COL256 := l_entry_rec.COL256;
 END IF;


 IF p_entry_rec.COL257 = FND_API.g_miss_char THEN
    x_complete_rec.COL257 := l_entry_rec.COL257;
 END IF;


 IF p_entry_rec.COL258 = FND_API.g_miss_char THEN
    x_complete_rec.COL258 := l_entry_rec.COL258;
 END IF;


 IF p_entry_rec.COL259 = FND_API.g_miss_char THEN
    x_complete_rec.COL259 := l_entry_rec.COL259;
 END IF;


 IF p_entry_rec.COL260 = FND_API.g_miss_char THEN
    x_complete_rec.COL260 := l_entry_rec.COL260;
 END IF;


 IF p_entry_rec.COL261 = FND_API.g_miss_char THEN
    x_complete_rec.COL261 := l_entry_rec.COL261;
 END IF;


 IF p_entry_rec.COL262 = FND_API.g_miss_char THEN
    x_complete_rec.COL262 := l_entry_rec.COL262;
 END IF;


 IF p_entry_rec.COL263 = FND_API.g_miss_char THEN
    x_complete_rec.COL263 := l_entry_rec.COL263;
 END IF;


 IF p_entry_rec.COL264 = FND_API.g_miss_char THEN
    x_complete_rec.COL264 := l_entry_rec.COL264;
 END IF;


 IF p_entry_rec.COL265 = FND_API.g_miss_char THEN
    x_complete_rec.COL265 := l_entry_rec.COL265;
 END IF;


 IF p_entry_rec.COL266 = FND_API.g_miss_char THEN
    x_complete_rec.COL266 := l_entry_rec.COL266;
 END IF;


 IF p_entry_rec.COL267 = FND_API.g_miss_char THEN
    x_complete_rec.COL267 := l_entry_rec.COL267;
 END IF;


 IF p_entry_rec.COL268 = FND_API.g_miss_char THEN
    x_complete_rec.COL268 := l_entry_rec.COL268;
 END IF;


 IF p_entry_rec.COL269 = FND_API.g_miss_char THEN
    x_complete_rec.COL269 := l_entry_rec.COL269;
 END IF;


 IF p_entry_rec.COL270 = FND_API.g_miss_char THEN
    x_complete_rec.COL270 := l_entry_rec.COL270;
 END IF;


 IF p_entry_rec.COL271 = FND_API.g_miss_char THEN
    x_complete_rec.COL271 := l_entry_rec.COL271;
 END IF;


 IF p_entry_rec.COL272 = FND_API.g_miss_char THEN
    x_complete_rec.COL272 := l_entry_rec.COL272;
 END IF;


 IF p_entry_rec.COL273 = FND_API.g_miss_char THEN
    x_complete_rec.COL273 := l_entry_rec.COL273;
 END IF;


 IF p_entry_rec.COL274 = FND_API.g_miss_char THEN
    x_complete_rec.COL274 := l_entry_rec.COL274;
 END IF;


 IF p_entry_rec.COL275 = FND_API.g_miss_char THEN
    x_complete_rec.COL275 := l_entry_rec.COL275;
 END IF;


 IF p_entry_rec.COL276 = FND_API.g_miss_char THEN
    x_complete_rec.COL276 := l_entry_rec.COL276;
 END IF;


 IF p_entry_rec.COL277 = FND_API.g_miss_char THEN
    x_complete_rec.COL277 := l_entry_rec.COL277;
 END IF;


 IF p_entry_rec.COL278 = FND_API.g_miss_char THEN
    x_complete_rec.COL278 := l_entry_rec.COL278;
 END IF;


 IF p_entry_rec.COL279 = FND_API.g_miss_char THEN
    x_complete_rec.COL279 := l_entry_rec.COL279;
 END IF;


 IF p_entry_rec.COL280 = FND_API.g_miss_char THEN
    x_complete_rec.COL280 := l_entry_rec.COL280;
 END IF;


 IF p_entry_rec.COL281 = FND_API.g_miss_char THEN
    x_complete_rec.COL281 := l_entry_rec.COL281;
 END IF;


 IF p_entry_rec.COL282 = FND_API.g_miss_char THEN
    x_complete_rec.COL282 := l_entry_rec.COL282;
 END IF;


 IF p_entry_rec.COL283 = FND_API.g_miss_char THEN
    x_complete_rec.COL283 := l_entry_rec.COL283;
 END IF;


 IF p_entry_rec.COL284 = FND_API.g_miss_char THEN
    x_complete_rec.COL284 := l_entry_rec.COL284;
 END IF;


 IF p_entry_rec.COL285 = FND_API.g_miss_char THEN
    x_complete_rec.COL285 := l_entry_rec.COL285;
 END IF;


 IF p_entry_rec.COL286 = FND_API.g_miss_char THEN
    x_complete_rec.COL286 := l_entry_rec.COL286;
 END IF;


 IF p_entry_rec.COL287 = FND_API.g_miss_char THEN
    x_complete_rec.COL287 := l_entry_rec.COL287;
 END IF;


 IF p_entry_rec.COL288 = FND_API.g_miss_char THEN
    x_complete_rec.COL288 := l_entry_rec.COL288;
 END IF;


 IF p_entry_rec.COL289 = FND_API.g_miss_char THEN
    x_complete_rec.COL289 := l_entry_rec.COL289;
 END IF;


 IF p_entry_rec.COL290 = FND_API.g_miss_char THEN
    x_complete_rec.COL290 := l_entry_rec.COL290;
 END IF;


 IF p_entry_rec.COL291 = FND_API.g_miss_char THEN
    x_complete_rec.COL291 := l_entry_rec.COL291;
 END IF;


 IF p_entry_rec.COL292 = FND_API.g_miss_char THEN
    x_complete_rec.COL292 := l_entry_rec.COL292;
 END IF;


 IF p_entry_rec.COL293 = FND_API.g_miss_char THEN
    x_complete_rec.COL293 := l_entry_rec.COL293;
 END IF;


 IF p_entry_rec.COL294 = FND_API.g_miss_char THEN
    x_complete_rec.COL294 := l_entry_rec.COL294;
 END IF;


 IF p_entry_rec.COL295 = FND_API.g_miss_char THEN
    x_complete_rec.COL295 := l_entry_rec.COL295;
 END IF;


 IF p_entry_rec.COL296 = FND_API.g_miss_char THEN
    x_complete_rec.COL296 := l_entry_rec.COL296;
 END IF;


 IF p_entry_rec.COL297 = FND_API.g_miss_char THEN
    x_complete_rec.COL297 := l_entry_rec.COL297;
 END IF;


 IF p_entry_rec.COL298 = FND_API.g_miss_char THEN
    x_complete_rec.COL298 := l_entry_rec.COL298;
 END IF;


 IF p_entry_rec.COL299 = FND_API.g_miss_char THEN
    x_complete_rec.COL299 := l_entry_rec.COL299;
 END IF;


 IF p_entry_rec.COL300 = FND_API.g_miss_char THEN
    x_complete_rec.COL300 := l_entry_rec.COL300;
 END IF;


 IF p_entry_rec.ADDRESS_LINE1 = FND_API.g_miss_char THEN
    x_complete_rec.ADDRESS_LINE1 := l_entry_rec.ADDRESS_LINE1;
 END IF;


 IF p_entry_rec.ADDRESS_LINE2 = FND_API.g_miss_char THEN
    x_complete_rec.ADDRESS_LINE2 := l_entry_rec.ADDRESS_LINE2;
 END IF;


 IF p_entry_rec.CALLBACK_FLAG = FND_API.g_miss_char THEN
    x_complete_rec.CALLBACK_FLAG := l_entry_rec.CALLBACK_FLAG;
 END IF;


 IF p_entry_rec.CITY = FND_API.g_miss_char THEN
    x_complete_rec.CITY := l_entry_rec.CITY;
 END IF;


 IF p_entry_rec.COUNTRY = FND_API.g_miss_char THEN
    x_complete_rec.COUNTRY := l_entry_rec.COUNTRY;
 END IF;


 IF p_entry_rec.DO_NOT_USE_FLAG = FND_API.g_miss_char THEN
    x_complete_rec.DO_NOT_USE_FLAG := l_entry_rec.DO_NOT_USE_FLAG;
 END IF;


 IF p_entry_rec.DO_NOT_USE_REASON = FND_API.g_miss_char THEN
    x_complete_rec.DO_NOT_USE_REASON := l_entry_rec.DO_NOT_USE_REASON;
 END IF;


 IF p_entry_rec.EMAIL_ADDRESS = FND_API.g_miss_char THEN
    x_complete_rec.EMAIL_ADDRESS := l_entry_rec.EMAIL_ADDRESS;
 END IF;


 IF p_entry_rec.FAX = FND_API.g_miss_char THEN
    x_complete_rec.FAX := l_entry_rec.FAX;
 END IF;


 IF p_entry_rec.PHONE = FND_API.g_miss_char THEN
    x_complete_rec.PHONE := l_entry_rec.PHONE;
 END IF;


 IF p_entry_rec.RECORD_OUT_FLAG = FND_API.g_miss_char THEN
    x_complete_rec.RECORD_OUT_FLAG := l_entry_rec.RECORD_OUT_FLAG;
 END IF;


 IF p_entry_rec.STATE = FND_API.g_miss_char THEN
    x_complete_rec.STATE := l_entry_rec.STATE;
 END IF;


 IF p_entry_rec.SUFFIX = FND_API.g_miss_char THEN
    x_complete_rec.SUFFIX := l_entry_rec.SUFFIX;
 END IF;


 IF p_entry_rec.TITLE = FND_API.g_miss_char THEN
    x_complete_rec.TITLE := l_entry_rec.TITLE;
 END IF;


 IF p_entry_rec.USAGE_RESTRICTION = FND_API.g_miss_char THEN
    x_complete_rec.USAGE_RESTRICTION := l_entry_rec.USAGE_RESTRICTION;
 END IF;


 IF p_entry_rec.ZIPCODE = FND_API.g_miss_char THEN
    x_complete_rec.ZIPCODE := l_entry_rec.ZIPCODE;
 END IF;


 IF p_entry_rec.CURR_CP_COUNTRY_CODE = FND_API.g_miss_char THEN
    x_complete_rec.CURR_CP_COUNTRY_CODE := l_entry_rec.CURR_CP_COUNTRY_CODE;
 END IF;


 IF p_entry_rec.CURR_CP_PHONE_NUMBER = FND_API.g_miss_char  THEN
    x_complete_rec.CURR_CP_PHONE_NUMBER := l_entry_rec.CURR_CP_PHONE_NUMBER;
 END IF;


 IF p_entry_rec.CURR_CP_RAW_PHONE_NUMBER = FND_API.g_miss_char  THEN
    x_complete_rec.CURR_CP_RAW_PHONE_NUMBER := l_entry_rec.CURR_CP_RAW_PHONE_NUMBER;
 END IF;


 IF p_entry_rec.CURR_CP_AREA_CODE = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_AREA_CODE := l_entry_rec.CURR_CP_AREA_CODE;
 END IF;


 IF p_entry_rec.CURR_CP_ID = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_ID := l_entry_rec.CURR_CP_ID;
 END IF;


 IF p_entry_rec.CURR_CP_INDEX = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_INDEX := l_entry_rec.CURR_CP_INDEX;
 END IF;


 IF p_entry_rec.CURR_CP_TIME_ZONE = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_TIME_ZONE := l_entry_rec.CURR_CP_TIME_ZONE;
 END IF;


 IF p_entry_rec.CURR_CP_TIME_ZONE_AUX = FND_API.g_miss_num  THEN
    x_complete_rec.CURR_CP_TIME_ZONE_AUX := l_entry_rec.CURR_CP_TIME_ZONE_AUX;
 END IF;


 IF p_entry_rec.IMP_SOURCE_LINE_ID = FND_API.g_miss_num  THEN
    x_complete_rec.IMP_SOURCE_LINE_ID := l_entry_rec.IMP_SOURCE_LINE_ID;
 END IF;


 IF p_entry_rec.NEXT_CALL_TIME = FND_API.g_miss_date THEN
    x_complete_rec.NEXT_CALL_TIME := l_entry_rec.NEXT_CALL_TIME;
 END IF;


 IF p_entry_rec.RECORD_RELEASE_TIME = FND_API.g_miss_date THEN
    x_complete_rec.RECORD_RELEASE_TIME := l_entry_rec.RECORD_RELEASE_TIME;
 END IF;

  --added 06-Jun-2000 tdonohoe
 IF p_entry_rec.PARTY_ID = FND_API.g_miss_num THEN
     x_complete_rec.PARTY_ID := l_entry_rec.PARTY_ID;
 END IF;
  --end added 06-Jun-2000 tdonohoe

   --added 06-Jun-2000 tdonohoe
 IF p_entry_rec.PARENT_PARTY_ID = FND_API.g_miss_num THEN
     x_complete_rec.PARENT_PARTY_ID := l_entry_rec.PARENT_PARTY_ID;
 END IF;
  --end added 06-Jun-2000 tdonohoe


END complete_entry_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    update_listentry_source_code
--
-- PURPOSE
--    Updates The Source_Code and Arc_List_Used_By_Source fields on The List Entry table.

--    A List may be generated without a Source Code Associated , in this case the two columns
--    will be defaulted to NONE and 0.

--    If The List later gets a Source code we must update the two columns to reflect this change
--    to allow list tracking from the interactions table.

-- PARAMETERS
--    p_list_id -- the list header id.
-- NOTES
-- HISTORY
-- 06-Jan-2000 choang      Modified call to get_source_code to include
--                         x_source_id.
---------------------------------------------------------------------

PROCEDURE Update_ListEntry_Source_Code(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_list_id           IN  NUMBER
) IS

    l_api_name            CONSTANT VARCHAR2(30)  := 'Update_ListEntry_Source_Code';
    l_api_version         CONSTANT NUMBER        := 1.0;

    --taken from ams_list_headers_all table.
    l_list_used_by_id     NUMBER;
    l_arc_list_used_by    VARCHAR2(30);


    l_return_status       VARCHAR2(1);
    l_source_code         VARCHAR2(30);
    l_source_id           NUMBER;

    Cursor C_Header_Dets Is  Select list_used_by_id,
                                    arc_list_used_by
                             From   ams_list_headers_all
                             where  list_header_id = p_list_id;

    Cursor C_Current_Code IS select max(Source_Code)
                             from   ams_list_entries
                             where  list_header_id = p_list_id;

    l_current_code varchar(30);

   l_source_code_flag varchar2(1) := 'N' ;
   l_campaign_id number;
   Cursor c_camp_source_code(cur_list_used_by_id number) is
   select cp.campaign_id , cp.cascade_source_code_flag
   from ams_campaigns_all_b cp ,
        ams_campaign_schedules sc
   where sc.campaign_id = cp.campaign_id
     and sc.CAMPAIGN_SCHEDULE_ID    = cur_list_used_by_id  ;


Begin

    -- Standard Start of API savepoint
        SAVEPOINT Update_ListEntry_Source_Code;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Initialize message list IF p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_ListEntry_PVT.Update_ListEntry_Source_Code: Start', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        Open  C_header_dets;
        Fetch C_header_dets into l_list_used_by_id,l_arc_list_used_by;
        Close C_header_dets;

        Open  C_Current_Code;
        Fetch C_Current_Code into l_current_code;
        Close C_Current_Code;

        if  l_arc_list_used_by = 'CSCH' then
           open  c_camp_source_code(l_list_used_by_id );
           fetch c_camp_source_code into
                 l_campaign_id , l_source_code_flag ;
           close c_camp_source_code;
        end if;

        if(l_arc_list_used_by <> 'NONE')then
           if l_source_code_flag = 'Y' then
              ams_utility_pvt.get_source_code(
                                    p_activity_type => 'CAMP',
                                    p_activity_id   => l_campaign_id,
                                    x_return_status => l_return_status,
                                    x_source_code   => l_source_code,
                                    x_source_id     => l_source_id);
           else
              ams_utility_pvt.get_source_code(
                                    p_activity_type => l_arc_list_used_by,
                                    p_activity_id   => l_list_used_by_id,
                                    x_return_status => l_return_status,
                                    x_source_code   => l_source_code,
                                    x_source_id     => l_source_id);
           end if;


             --found a valid source code
             if(l_return_status = FND_API.G_TRUE)then
                  if(l_current_code <> l_source_code)then
                     update ams_list_entries
                     set    source_code             = l_source_code,
                            arc_list_used_by_source = l_arc_list_used_by,
                            source_code_for_id      = l_list_used_by_id
                     where  list_header_id = p_list_id;
                  end if;
             end if;
        end if;

      -- MMSG
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            FND_MESSAGE.Set_Name('AMS', 'API_SUCCESS');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Update_ListEntry_Source_Code', TRUE);
            FND_MSG_PUB.Add;
        END IF;


        IF (AMS_DEBUG_HIGH_ON) THEN
            FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('ROW', 'AMS_List_Entry_PVT.Update_ListEntry_Source_Code: END', TRUE);
            FND_MSG_PUB.Add;
        END IF;

        -- Standard call to get message count AND IF count is 1, get message info.
        FND_MSG_PUB.Count_AND_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
        );



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
            );


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Count_AND_Get
            ( p_count           =>      x_msg_count,
              p_data            =>      x_msg_data,
              p_encoded     =>      FND_API.G_FALSE
            );

        WHEN AMS_Utility_PVT.RESOURCE_LOCKED THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN -- MMSG
                FND_MESSAGE.SET_NAME('AMS','API_RESOURCE_LOCKED');
                FND_MSG_PUB.Add;
           END IF;

            FND_MSG_PUB.Count_AND_Get
                ( p_count           =>      x_msg_count,
                  p_data            =>      x_msg_data,
          p_encoded     =>      FND_API.G_FALSE
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
              p_encoded     =>      FND_API.G_FALSE
            );

End update_listentry_source_code;


END AMS_ListEntry_PVT;

/
