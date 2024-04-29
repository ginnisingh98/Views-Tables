--------------------------------------------------------
--  DDL for Package Body EGO_CATALOG_GROUP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CATALOG_GROUP_UTIL" AS
/* $Header: EGOUCAGB.pls 120.2 2006/08/01 10:42:02 srajapar noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      ENGUBOMB.pls
--
--  DESCRIPTION
--
--      Body of package EGO_Catalog_Group_Util
--
--  NOTES
--
--  HISTORY
--  02-JUL-1999 Rahul Chitko    Initial Creation
--  18-FEB-2003 Refai Farook  Propagation of end date to the recursive childs
--        (Update_Row procedure)
--  19-DEC-2003 Sridhar R       Bug 3324531
--                              removed references to bom_globals
--
****************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EGO_Catalog_Group_Util';

  /*********************************************************************
  * Procedure     : Query_Row
  * Parameters OUT:
  * Purpose       : Procedure will query the database record, seperate the
  *     values into exposed columns and unexposed columns and
  *     return with those records.
  ***********************************************************************/
  PROCEDURE Query_Row
  (  x_mesg_token_tbl  OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_Return_status   OUT NOCOPY VARCHAR2
  )
  IS
    l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
    l_dummy     varchar2(10);
  BEGIN
    Error_Handler.Write_Debug('Performing Query Row for catalog group ' ||
            EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name);

    SELECT  item_catalog_group_id
    , parent_catalog_group_id
    , summary_flag
    , enabled_flag
    , inactive_date
    , item_creation_Allowed_flag
    , description
    , segment1
    , segment2
    , segment3
    , segment4
    , segment5
    , segment6
    , segment7
    , segment8
    , segment9
    , segment10
    , segment11
    , segment12
    , segment13
    , segment14
    , segment15
    , segment16
    , segment17
    , segment18
    , segment19
    , segment20
    , attribute_category
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    INTO  EGO_Globals.G_Old_Catalog_Group_Rec.catalog_group_id
    , EGO_Globals.G_Old_Catalog_Group_Rec.parent_catalog_group_id
    , EGO_Globals.G_Old_Catalog_Group_Rec.summary_flag
    , EGO_Globals.G_Old_Catalog_Group_Rec.enabled_flag
    , EGO_Globals.G_Old_Catalog_Group_Rec.inactive_date
    , EGO_Globals.G_Old_Catalog_Group_Rec.Item_Creation_Allowed_Flag
    , EGO_Globals.G_Old_Catalog_Group_Rec.Description
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment1
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment2
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment3
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment4
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment5
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment6
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment7
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment8
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment9
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment10
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment11
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment12
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment13
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment14
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment15
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment16
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment17
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment18
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment19
    , EGO_Globals.G_Old_Catalog_Group_Rec.Segment20
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute_category
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute1
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute2
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute3
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute4
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute5
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute6
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute7
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute8
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute9
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute10
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute11
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute12
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute13
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute14
    , EGO_Globals.G_Old_Catalog_Group_Rec.attribute15
    FROM  mtl_item_catalog_groups_vl
    WHERE item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.catalog_group_id;

-- Bug 3324531
-- changed the global Bom_Globals.G_RECORD_FOUND to EGO_Globals.G_RECORD_FOUND
    x_return_status  := EGO_Globals.G_RECORD_FOUND;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
-- Bug 3324531
-- changed the global Bom_Globals.G_RECORD_NOT_FOUND to EGO_Globals.G_RECORD_NOT_FOUND
      x_return_status := EGO_Globals.G_RECORD_NOT_FOUND;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Query_Row;

  /********************************************************************
  * Procedure : Insert_Row
  * Parameters IN :
  * Parameters OUT: Message Token Table
  *     Return Status
  * Purpose :
  *********************************************************************/
  PROCEDURE Insert_Row
        (  x_mesg_token_Tbl OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status  OUT NOCOPY VARCHAR2
         )
  IS
    l_UserId        NUMBER := FND_GLOBAL.User_Id;
    l_LanguageCode  VARCHAR2(4) := EGO_Globals.Get_Language_Code;

  BEGIN

    Error_Handler.Write_Debug('Inserting Catalog Group . . . ');
    -- dbms_output.put_line('Inserting Catalog Group . . . ID' || EGO_Globals.G_Catalog_Group_Rec.catalog_group_id);

    INSERT INTO mtl_Item_Catalog_Groups_b
    (  item_catalog_group_id
     , parent_catalog_group_id
     , summary_flag
     , enabled_flag
     , inactive_date
     , item_creation_Allowed_Flag
     , segment1
     , segment2
     , segment3
     , segment4
     , segment5
     , segment6
     , segment7
     , segment8
     , segment9
     , segment10
     , segment11
     , segment12
     , segment13
     , segment14
     , segment15
     , segment16
     , segment17
     , segment18
     , segment19
     , segment20
     , attribute_category
     , attribute1
     , attribute2
     , attribute3
     , attribute4
     , attribute5
     , attribute6
     , attribute7
     , attribute8
     , attribute9
     , attribute10
     , attribute11
     , attribute12
     , attribute13
     , attribute14
     , attribute15
     , creation_date
     , created_by
     , last_update_date
     , last_updated_by
     , last_update_login
     )
    VALUES
    (  EGO_Globals.G_Catalog_Group_Rec.catalog_group_id
     , EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id
     , EGO_Globals.G_Catalog_Group_Rec.summary_flag
     , EGO_Globals.G_Catalog_Group_Rec.enabled_flag
     , EGO_Globals.G_Catalog_Group_Rec.inactive_date
     , EGO_Globals.G_Catalog_Group_Rec.Item_Creation_Allowed_Flag
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(1)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(2)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(3)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(4)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(5)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(6)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(7)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(8)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(9)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(10)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(11)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(12)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(13)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(14)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(15)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(16)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(17)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(18)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(19)
     , EGO_Item_Catalog_Pub.G_KF_Segment_Values(20)
     , EGO_Globals.G_Catalog_Group_Rec.attribute_category
     , EGO_Globals.G_Catalog_Group_Rec.attribute1
     , EGO_Globals.G_Catalog_Group_Rec.attribute2
     , EGO_Globals.G_Catalog_Group_Rec.attribute3
     , EGO_Globals.G_Catalog_Group_Rec.attribute4
     , EGO_Globals.G_Catalog_Group_Rec.attribute5
     , EGO_Globals.G_Catalog_Group_Rec.attribute6
     , EGO_Globals.G_Catalog_Group_Rec.attribute7
     , EGO_Globals.G_Catalog_Group_Rec.attribute8
     , EGO_Globals.G_Catalog_Group_Rec.attribute9
     , EGO_Globals.G_Catalog_Group_Rec.attribute10
     , EGO_Globals.G_Catalog_Group_Rec.attribute11
     , EGO_Globals.G_Catalog_Group_Rec.attribute12
     , EGO_Globals.G_Catalog_Group_Rec.attribute13
     , EGO_Globals.G_Catalog_Group_Rec.attribute14
     , EGO_Globals.G_Catalog_Group_Rec.attribute15
     , SYSDATE
     , FND_Global.User_Id
     , SYSDATE
     , FND_Global.User_Id
     , FND_Global.User_Id
    );


    -- dbms_output.put_line('Inserting into TL table . . .');
    /* ---------------------------------------------------------------
    **
    ** Insert data into the translation table
    **
    ** ---------------------------------------------------------------*/

    INSERT INTO Mtl_Item_Catalog_Groups_TL
    (  Item_Catalog_Group_Id
     , Language
     , Source_Lang
     , Created_By
     , Creation_Date
     , Last_Updated_By
     , Last_Update_Date
     , Description
     )
    SELECT EGO_Globals.G_Catalog_Group_Rec.catalog_group_id
         , lang.language_code
         , l_LanguageCode
         , l_UserId
         , SYSDATE
         , l_UserId
         , SYSDATE
         , EGO_Globals.G_Catalog_Group_Rec.description
      FROM FND_LANGUAGES lang
     WHERE lang.installed_flag in ('I', 'B')
       AND NOT EXISTS
           ( SELECT NULL
               FROM Mtl_Item_Catalog_Groups_tl TL
              WHERE tl.item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.catalog_group_id
                AND tl.language = lang.language_code
            );
    -- call the sync Catalog Group function.
    EGO_BROWSE_PVT.Sync_ICG_Denorm_Hier_Table
        (p_catalog_group_id => EGO_Globals.G_Catalog_Group_Rec.catalog_group_id
        ,p_old_parent_id    => NULL
        ,x_return_status    => x_return_status
        );

    EXCEPTION
    WHEN OTHERS THEN
      Error_Handler.Add_Error_Token
      (  p_message_name => NULL
       , p_application_id     => 'EGO'
       , p_message_text => G_PKG_NAME ||
              ' :Inserting Record ' ||
              SQLERRM
       , x_mesg_token_Tbl => x_mesg_token_tbl
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Insert_Row;

  /********************************************************************
  * Procedure     : Update_Row
  * Parameters IN : BOM Header exposed column record
  *                 BOM Header unexposed column record
  * Parameters OUT: Message Token Table
  *                 Return Status
  * Purpose       : Procedure will perfrom an Update into the
  *                 BOM_Bill_Of_Materials table.
  *********************************************************************/
  PROCEDURE Update_Row
  (  x_mesg_token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_Status      OUT NOCOPY VARCHAR2
   )
  IS

    l_old_parent_id   NUMBER;

    CURSOR c1(p_item_catalog_group_id NUMBER) IS
    SELECT item_catalog_group_id FROM mtl_item_catalog_groups_b
    CONNECT BY PRIOR item_catalog_group_id = parent_catalog_group_id
    START WITH item_catalog_group_id = p_item_catalog_group_id;

  BEGIN

    --
    -- User can update the inactive date, description and choose to rename the
    -- the catalog group.
    --
    Error_Handler.Write_Debug('Updating catalog group . . . ');

    SELECT parent_catalog_group_id
    INTO   l_old_parent_id
    FROM   mtl_item_catalog_groups_b
    WHERE  item_catalog_group_id =
               EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id;

    UPDATE mtl_item_catalog_groups_b
       SET Item_Creation_Allowed_Flag = EGO_Globals.G_Catalog_Group_Rec.Item_Creation_Allowed_Flag
          , parent_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id
          , Segment1 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(1)
          , Segment2 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(2)
          , Segment3 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(3)
          , Segment4 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(4)
          , Segment5 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(5)
          , Segment6 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(6)
          , Segment7 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(7)
          , Segment8 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(8)
          , Segment9 = EGO_Item_Catalog_Pub.G_KF_Segment_Values(9)
          , Segment10= EGO_Item_Catalog_Pub.G_KF_Segment_Values(10)
          , Segment11= EGO_Item_Catalog_Pub.G_KF_Segment_Values(11)
          , Segment12= EGO_Item_Catalog_Pub.G_KF_Segment_Values(12)
          , Segment13= EGO_Item_Catalog_Pub.G_KF_Segment_Values(13)
          , Segment14= EGO_Item_Catalog_Pub.G_KF_Segment_Values(14)
          , Segment15= EGO_Item_Catalog_Pub.G_KF_Segment_Values(15)
          , Segment16= EGO_Item_Catalog_Pub.G_KF_Segment_Values(16)
          , Segment17= EGO_Item_Catalog_Pub.G_KF_Segment_Values(17)
          , Segment18= EGO_Item_Catalog_Pub.G_KF_Segment_Values(18)
          , Segment19= EGO_Item_Catalog_Pub.G_KF_Segment_Values(19)
          , Segment20= EGO_Item_Catalog_Pub.G_KF_Segment_Values(20)
          , description    = EGO_Globals.G_Catalog_Group_Rec.description
          , last_update_date =  SYSDATE
          , last_updated_by = FND_Global.User_Id
          , last_update_login = FND_Global.User_Id
          , attribute_category = EGO_Globals.G_Catalog_Group_Rec.attribute_category
          , attribute1 = EGO_Globals.G_Catalog_Group_Rec.attribute1
          , attribute2 = EGO_Globals.G_Catalog_Group_Rec.attribute2
          , attribute3 = EGO_Globals.G_Catalog_Group_Rec.attribute3
          , attribute4 = EGO_Globals.G_Catalog_Group_Rec.attribute4
          , attribute5 = EGO_Globals.G_Catalog_Group_Rec.attribute5
          , attribute6 = EGO_Globals.G_Catalog_Group_Rec.attribute6
          , attribute7 = EGO_Globals.G_Catalog_Group_Rec.attribute7
          , attribute8 = EGO_Globals.G_Catalog_Group_Rec.attribute8
          , attribute9 = EGO_Globals.G_Catalog_Group_Rec.attribute9
          , attribute10= EGO_Globals.G_Catalog_Group_Rec.attribute10
          , attribute11= EGO_Globals.G_Catalog_Group_Rec.attribute11
          , attribute12= EGO_Globals.G_Catalog_Group_Rec.attribute12
          , attribute13= EGO_Globals.G_Catalog_Group_Rec.attribute13
          , attribute14= EGO_Globals.G_Catalog_Group_Rec.attribute14
          , attribute15= EGO_Globals.G_Catalog_Group_Rec.attribute15
    WHERE item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id;


    /* Update the TL table description */

    UPDATE  Mtl_Item_Catalog_Groups_TL
      SET  description        = EGO_Globals.G_Catalog_Group_Rec.description
         , last_updated_by    = FND_Global.User_Id
         , last_update_date   = SYSDATE
    WHERE  item_catalog_group_id =
                     EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id
      AND  LANGUAGE = EGO_Globals.Get_Language_Code;

    /* Update for the end date */

    IF EGO_Globals.G_Catalog_Group_Rec.inactive_date IS NOT NULL
    THEN
      -- If old end date is null or the old end date is
      -- different from the new end date

      IF EGO_Globals.G_Old_Catalog_Group_Rec.inactive_date IS NULL
         OR (EGO_Globals.G_Old_Catalog_Group_Rec.inactive_date IS NOT NULL AND
                  trunc(EGO_Globals.G_Catalog_Group_Rec.inactive_date) <>
                                 trunc(EGO_Globals.G_Old_Catalog_Group_Rec.inactive_date))
      THEN
        /* Propagate the new end date to all the recursive childs of this catalog */
        FOR r1 IN c1(EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id)
        LOOP
          UPDATE mtl_item_catalog_groups_b
          SET inactive_date = EGO_Globals.G_Catalog_Group_Rec.inactive_date
          WHERE item_catalog_group_id = r1.item_catalog_group_id;
        END LOOP;
      END IF;

    ELSE
      -- If there exists an end date and the new end date is null

      IF trunc(EGO_Globals.G_Old_Catalog_Group_Rec.inactive_date) IS NOT NULL
      THEN
        /* Propagate null (remove end date) to all the recursive childs */
        FOR r1 IN c1(EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id)
        LOOP
          UPDATE mtl_item_catalog_groups_b
          SET inactive_date = null
          WHERE item_catalog_group_id = r1.item_catalog_group_id;
        END LOOP;
      END IF;

    END IF;

    IF NVL(l_old_parent_id,-1) <>
       NVL(EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id,-1) THEN
      EGO_BROWSE_PVT.Sync_ICG_Denorm_Hier_Table
        (p_catalog_group_id => EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id
        ,p_old_parent_id    => l_old_parent_id
        ,x_return_status    => x_return_status
        );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- dbms_output.put_line('Error while updating : ' || SQLERRM);

      Error_Handler.Add_Error_Token
      (  p_message_name       => NULL
       , p_application_id     => 'EGO'
       , p_message_text       => G_PKG_NAME ||
                               ' :Updating Record ' ||
                               SQLERRM
       , x_mesg_token_Tbl     => x_mesg_token_tbl
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Update_Row;


  /********************************************************************
  * Procedure     : Delete_Row
  * Parameters IN :
  * Parameters OUT: Message Token Table
  *                 Return Status
  * Purpose       : Procedure will perfrom an Delete
  *********************************************************************/
  PROCEDURE Delete_Row
  (  x_mesg_token_Tbl     OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_Status      OUT NOCOPY VARCHAR2
   )
  IS
    l_mesg_token_tbl  Error_Handler.Mesg_Token_Tbl_Type;

  BEGIN

    /* Delete from TL */

    DELETE FROM mtl_item_catalog_groups_tl WHERE
      item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id
      AND  LANGUAGE = EGO_Globals.Get_Language_Code;

    /* Delete from base table */

    DELETE FROM mtl_item_catalog_groups_b WHERE
      item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id;

    EGO_BROWSE_PVT.Reload_ICG_Denorm_Hier_Table (x_return_status => x_return_status);

    EXCEPTION WHEN OTHERS
    THEN
      -- dbms_output.put_line('Error while deleting : ' || SQLERRM);

      Error_Handler.Add_Error_Token
      (  p_message_name       => NULL
       , p_application_id     => 'EGO'
       , p_message_text       => G_PKG_NAME ||
                                ' :Deleting Record ' ||
                                SQLERRM
       , x_mesg_token_Tbl     => x_mesg_token_tbl
      );
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Delete_Row;

  /*********************************************************************
  * Procedure : Perform_Writes
  * Parameters IN :
  * Parameters OUT: Messgae Token Table
  *     Return Status
  * Purpose : This is the only procedure that the user will have
  *     access to when he/she needs to perform any kind of
  *     writes to the catalog groups table.
  *********************************************************************/
  PROCEDURE Perform_Writes
  (  x_mesg_token_tbl OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_status  OUT NOCOPY VARCHAR2
  )
  IS
    l_Mesg_Token_tbl  Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF EGO_Globals.G_Catalog_Group_Rec.transaction_type = EGO_GLOBALS.G_OPR_CREATE
    THEN
      -- dbms_output.put_line('Inserting row . . . ');
      Insert_Row
        (  x_mesg_token_Tbl => l_mesg_token_tbl
         , x_return_Status  => l_return_status
        );
    ELSIF EGO_Globals.G_Catalog_Group_Rec.transaction_type =
              EGO_GLOBALS.G_OPR_UPDATE
    THEN
      -- dbms_output.put_line('Updating row . . . ');
      Update_Row
        (  x_mesg_token_Tbl     => l_mesg_token_tbl
         , x_return_Status      => l_return_status
        );

    ELSIF EGO_Globals.G_Catalog_Group_Rec.transaction_type =
              EGO_GLOBALS.G_OPR_DELETE
    THEN
      -- dbms_output.put_line('Deleting row . . . ');
      Delete_Row
        (  x_mesg_token_Tbl     => l_mesg_token_tbl
         , x_return_Status      => l_return_status
        );
    END IF;

    x_return_status := l_return_status;
    x_mesg_token_tbl := l_mesg_token_tbl;

  END Perform_Writes;


END EGO_Catalog_Group_Util;

/
