--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_LINE_UTIL" AS
/* $Header: ENGUCHLB.pls 120.7 2007/08/14 06:36:57 prgopala ship $ */


    G_Pkg_Name      CONSTANT VARCHAR2(30) := 'ENG_Change_Line_Util';


/*****************************************************************
* Procedure : Query_Row
* Parameters IN : Change Line Key
* Parameters OUT: Change Line Exposed   column Record
*                 Change Line Unexposed column Record
* Returns   : None
* Purpose   : Change Line Query Row
*             will query the database record and seperate
*             the unexposed and exposed attributes before returning
*             the records.
********************************************************************/
PROCEDURE   Query_Row
( p_line_sequence_number  IN  NUMBER
, p_organization_id       IN  NUMBER
, p_change_notice         IN  VARCHAR2
, p_change_line_name      IN  VARCHAR2
, p_mesg_token_tbl        IN  Error_Handler.Mesg_Token_Tbl_Type
, x_change_line_rec       OUT NOCOPY Eng_Eco_Pub.Change_Line_Rec_Type
, x_change_line_unexp_rec OUT NOCOPY Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
, x_mesg_token_tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

   /* Define Variable */
   l_change_line_rec          Eng_Eco_Pub.Change_Line_Rec_Type ;
   l_change_line_unexp_rec    Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type;
   l_bo_id               VARCHAR2(3) ;
   l_err_text            VARCHAR2(2000);


   /* Define Cursor */
   Cursor cl_csr( p_line_sequence_number NUMBER
                , p_change_id  NUMBER
                )
   IS
   SELECT  cl.change_line_id
        ,  cl.change_type_id
        ,  cl.status_code
        ,  cl.assignee_id
        ,  cl.need_by_date
        ,  cl.object_id
        ,  cl.pk1_value
        ,  cl.pk2_value
        ,  cl.pk3_value
        ,  cl.pk4_value
        ,  cl.pk5_value
        ,  cl.scheduled_date
        ,  cl.implementation_date
        ,  cl.cancelation_date
        ,  cltl.name
        ,  cltl.description
        ,  cl.original_system_reference
   FROM   ENG_CHANGE_LINES cl
        , ENG_CHANGE_LINES_TL cltl
   WHERE  cl.change_id = p_change_id
   AND    cl.sequence_number = p_line_sequence_number
   AND    cl.change_line_id = cltl.change_line_id
   AND    cltl.language = userenv('LANG') ;

   Cursor c_csr( p_change_notice   VARCHAR2
               , p_organization_id NUMBER
               )
   IS
   SELECT change_id FROM eng_engineering_changes
   WHERE change_notice = p_change_notice and organization_id = p_organization_id;

   cl_rec    cl_csr%ROWTYPE ;
   l_change_id   NUMBER;


BEGIN

IF BOM_Globals.Get_Debug = 'Y' THEN
        Error_Handler.Write_Debug ('Querying a change line record . . . ' ) ;
        Error_Handler.Write_Debug (' : line sequence number ' || p_line_sequence_number);
        Error_Handler.Write_Debug (' : change notice ' || p_change_notice );
        Error_Handler.Write_Debug (' : organization_id ' || to_char( p_organization_id ));
END IF ;

   x_mesg_token_tbl := p_mesg_token_tbl;

   IF NOT c_csr %ISOPEN
   THEN
      OPEN c_csr( p_change_notice
                , p_organization_id ) ;
   END IF ;

   FETCH c_csr INTO l_change_id;
   l_change_line_unexp_rec.change_id := l_change_id;

   IF NOT cl_csr %ISOPEN
   THEN
      OPEN cl_csr( p_line_sequence_number
                 , l_change_id ) ;
   END IF ;

   FETCH cl_csr INTO cl_rec ;

   IF cl_csr%FOUND
   THEN

      -- Set  Queried Record to Exposed and Unexposed Record
      -- Unexposed Column
      l_change_line_unexp_rec.change_line_id   := cl_rec.change_line_id;
      l_change_line_unexp_rec.organization_id  := p_organization_id;
      l_change_line_unexp_rec.change_type_id   := cl_rec.change_type_id;
      l_change_line_unexp_rec.status_code      := cl_rec.status_code;
      l_change_line_unexp_rec.assignee_id      := cl_rec.assignee_id;
      l_change_line_unexp_rec.object_id        := cl_rec.object_id;
      l_change_line_unexp_rec.pk1_value        := cl_rec.pk1_value;
      l_change_line_unexp_rec.pk2_value        := cl_rec.pk2_value;
      l_change_line_unexp_rec.pk3_value        := cl_rec.pk3_value;
      l_change_line_unexp_rec.pk4_value        := cl_rec.pk4_value;
      l_change_line_unexp_rec.pk5_value        := cl_rec.pk5_value;

      -- Exposed Column
      l_change_line_rec.eco_name               := p_change_notice;
      l_change_line_rec.name                   := cl_rec.name;
      l_change_line_rec.description            := cl_rec.description;
      l_change_line_rec.sequence_number        := p_line_sequence_number;
      l_change_line_rec.original_system_reference  := cl_rec.original_system_reference ;
      l_change_line_rec.need_by_date           := cl_rec.need_by_date ;
      l_change_line_rec.scheduled_date         := cl_rec.scheduled_date ;
      l_change_line_rec.implementation_date    := cl_rec.implementation_date ;
      l_change_line_rec.cancelation_date       := cl_rec.cancelation_date ;

      /*
      l_change_line_rec.Attribute_category         := cl_rec.ATTRIBUTE_CATEGORY ;
      l_change_line_rec.Attribute1                 := cl_rec.ATTRIBUTE1 ;
      l_change_line_rec.Attribute2                 := cl_rec.ATTRIBUTE2 ;
      l_change_line_rec.Attribute3                 := cl_rec.ATTRIBUTE3 ;
      l_change_line_rec.Attribute4                 := cl_rec.ATTRIBUTE4 ;
      l_change_line_rec.Attribute5                 := cl_rec.ATTRIBUTE5 ;
      l_change_line_rec.Attribute6                 := cl_rec.ATTRIBUTE6 ;
      l_change_line_rec.Attribute7                 := cl_rec.ATTRIBUTE7 ;
      l_change_line_rec.Attribute8                 := cl_rec.ATTRIBUTE8 ;
      l_change_line_rec.Attribute9                 := cl_rec.ATTRIBUTE9 ;
      l_change_line_rec.Attribute10                := cl_rec.ATTRIBUTE10 ;
      l_change_line_rec.Attribute11                := cl_rec.ATTRIBUTE11 ;
      l_change_line_rec.Attribute12                := cl_rec.ATTRIBUTE12 ;
      l_change_line_rec.Attribute13                := cl_rec.ATTRIBUTE13 ;
      l_change_line_rec.Attribute14                := cl_rec.ATTRIBUTE14 ;
      l_change_line_rec.Attribute15                := cl_rec.ATTRIBUTE15 ;
      */

IF BOM_Globals.Get_Debug = 'Y' THEN
   Error_Handler.Write_Debug('Finished querying chage line record . . .') ;
END IF ;

      x_return_status          := BOM_Globals.G_RECORD_FOUND ;
      x_change_line_rec        := l_change_line_rec ;
      x_change_line_unexp_rec  := l_change_line_unexp_rec;

   ELSE

      x_return_status          := BOM_Globals.G_RECORD_NOT_FOUND ;
      x_change_line_rec        := l_change_line_rec ;
      x_change_line_unexp_rec  := l_change_line_unexp_rec ;

   END IF ;

   IF cl_csr%ISOPEN
   THEN
      CLOSE cl_csr ;
   END IF ;

   IF c_csr%ISOPEN
   THEN
      CLOSE c_csr ;
   END IF ;

EXCEPTION
   WHEN OTHERS THEN
      l_err_text := G_PKG_NAME || ' Utility (Change Line Query Row) '
                               || substrb(SQLERRM,1,200);


      Error_Handler.Add_Error_Token
      ( p_message_name   => NULL
      , p_message_text   => l_err_text
      , p_mesg_token_tbl => x_mesg_token_tbl
      , x_mesg_token_tbl => x_mesg_token_tbl
      );

      x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Query_Row;


/*********************************************************************
* Procedure : Perform_Writes
* Parameters IN : Change Line exposed column record
*                 Change Line unexposed column record
* Parameters OUT: Return Status
*                 Message Token Table
* Purpose   : Perform any insert/update/deletes to the
*             Change Line table.
*********************************************************************/
PROCEDURE Perform_Writes
(  p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status         OUT NOCOPY VARCHAR2
 )
IS

    l_change_line_rec             Eng_Eco_Pub.Change_Line_Rec_Type ;
    l_change_line_unexp_rec       Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type ;

    -- Error Handlig Variables
    l_return_status          VARCHAR2(1);
    l_temp_return_status     VARCHAR2(1);
    l_err_text               VARCHAR2(2000) ;
    l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
    l_temp_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
    l_Token_Tbl              Error_Handler.Token_Tbl_Type;


BEGIN

   --
   -- Initialize Common Record and Status
   --
   l_change_line_rec         := p_change_line_rec ;
   l_change_line_unexp_rec   := p_change_line_unexp_rec ;
   l_return_status           := FND_API.G_RET_STS_SUCCESS ;
   x_return_status            := FND_API.G_RET_STS_SUCCESS ;

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
        ('Performing Database Writes . . .') ;
END IF ;


   IF l_change_line_rec.transaction_type = BOM_Globals.G_OPR_CREATE THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Change Line: Executing Insert Row. . . ') ;
END IF;


      Insert_Row
        (  p_change_line_rec        => l_change_line_rec
         , p_change_line_unexp_rec  => l_change_line_unexp_rec
         , x_return_status          => l_temp_return_status
         , x_mesg_token_tbl         => l_temp_mesg_token_tbl
        ) ;

       IF l_temp_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
                l_return_status  := l_temp_return_status ;
                l_mesg_token_Tbl := l_temp_Mesg_Token_Tbl ;
       END IF ;

   ELSIF l_change_line_rec.transaction_type = BOM_Globals.G_OPR_UPDATE
   THEN


IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Change Line: Executing Update Row. . . ') ;
END IF ;

      Update_Row
        (  p_change_line_rec        => l_change_line_rec
         , p_change_line_unexp_rec  => l_change_line_unexp_rec
         , x_return_status          => l_temp_return_status
         , x_mesg_token_tbl         => l_temp_mesg_token_tbl
        ) ;

       IF l_temp_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
                l_return_status  := l_temp_return_status ;
                l_mesg_token_Tbl := l_temp_Mesg_Token_Tbl ;
       END IF ;



   ELSIF l_change_line_rec.transaction_type = BOM_Globals.G_OPR_DELETE
   THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Change Line: Executing Delete Row. . . ') ;
END IF ;

      Delete_Row
        (  p_change_line_rec        => l_change_line_rec
         , p_change_line_unexp_rec  => l_change_line_unexp_rec
         , x_return_status          => l_temp_return_status
         , x_mesg_token_tbl         => l_temp_mesg_token_tbl
        ) ;

       IF l_temp_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN
                l_return_status  := l_temp_return_status ;
                l_mesg_token_Tbl := l_temp_Mesg_Token_Tbl ;
       END IF ;

    END IF ;

    --
    -- Return Status
    --
    x_return_status  := l_return_status ;
    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl ;

EXCEPTION
   WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
      ('Some unknown error in Perform Writes . . .' || SQLERRM );
END IF ;

      l_err_text := G_PKG_NAME || ' Utility (Perform Writes) '
                                || substrb(SQLERRM,1,200);


          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Perform_Writes;



/*****************************************************************************
* Procedure :
* Parameters IN : Change Line exposed column record
*                 Change Line unexposed column record
* Parameters OUT: Return Status
*                 Message Token Table
* Purpose   : This procedure will insert a record in the Change Line
*             table:  ENG_CHANGE_LINES/_TL.
*
*****************************************************************************/
PROCEDURE Insert_Row
(  p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status         OUT NOCOPY VARCHAR2
)
IS

    -- Error Handlig Variables
    l_return_status       VARCHAR2(1);
    l_err_text            VARCHAR2(2000) ;
    l_Mesg_Token_Tbl      Error_Handler.Mesg_Token_Tbl_Type ;

   Cursor c_csr( p_change_notice   VARCHAR2
               , p_organization_id NUMBER
               )
   IS
   SELECT change_id FROM eng_engineering_changes
   WHERE change_notice = p_change_notice and organization_id = p_organization_id;

   l_change_id    NUMBER;
BEGIN

   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   l_change_id := p_change_line_unexp_rec.change_id;
   IF l_change_id IS NULL THEN
     IF NOT c_csr %ISOPEN
     THEN
       OPEN c_csr( p_change_line_rec.eco_name
                , p_change_line_unexp_rec.organization_id ) ;
     END IF ;

     FETCH c_csr INTO l_change_id;
   END IF;

   INSERT INTO ENG_CHANGE_LINES(
      change_line_id
    , change_id
    , change_type_id
    , status_code
    , sequence_number
    , need_by_date
    , scheduled_date
    , implementation_date
    , cancelation_date
    , assignee_id
    , object_id
    , pk1_value
    , pk2_value
    , pk3_value
    , pk4_value
    , pk5_value
    , last_update_date
    , last_updated_by
    , last_update_login
    , creation_date
    , created_by
    , request_id
    , program_application_id
    , program_id
    , program_update_date
    , original_system_reference
    , Approval_Status_Type
    ,   Required_Flag
    ,   Complete_Before_Status_Code
    ,   Start_After_Status_Code
   )
   VALUES (
      p_change_line_unexp_rec.change_line_id
    , l_change_id
    , p_change_line_unexp_rec.change_type_id
    , p_change_line_unexp_rec.status_code
    , p_change_line_rec.sequence_number
    , p_change_line_rec.need_by_date
    , p_change_line_rec.scheduled_date
    , p_change_line_rec.implementation_date
    , p_change_line_rec.cancelation_date
    , p_change_line_unexp_rec.assignee_id
    , p_change_line_unexp_rec.object_id
    , p_change_line_unexp_rec.pk1_value
    , p_change_line_unexp_rec.pk2_value
    , p_change_line_unexp_rec.pk3_value
    , p_change_line_unexp_rec.pk4_value
    , p_change_line_unexp_rec.pk5_value
    , SYSDATE                    -- Last Update Date
    , BOM_Globals.Get_User_Id    -- Last Updated By
    , BOM_Globals.Get_Login_Id   -- Last Update Login
    , SYSDATE                    -- Creation Date
    , BOM_Globals.Get_User_Id    -- Created By
    , NULL                       -- Request Id
    , BOM_Globals.Get_Prog_AppId -- Application Id
    , BOM_Globals.Get_Prog_Id    -- Program Id
    , SYSDATE                    -- program_update_date
    , p_change_line_rec.original_system_reference
    , p_change_line_unexp_rec.Approval_Status_Type --Added as it is mandatory 18-6-2003
    ,p_change_line_rec. Required_Flag
    , p_change_line_rec.Complete_Before_Status_Code
    ,p_change_line_rec. Start_After_Status_Code
    );


   INSERT INTO ENG_CHANGE_LINES_TL (
      change_line_id
    , language
    , source_lang
    , created_by
    , creation_date
    , last_update_date
    , last_updated_by
    , last_update_login
    , name
    , description
    )
    SELECT  p_change_line_unexp_rec.change_line_id
          , lang.language_code
          , USERENV('LANG')
          , BOM_Globals.Get_User_Id
          , SYSDATE
          , SYSDATE
          , BOM_Globals.Get_User_Id
          , BOM_Globals.Get_Login_Id
          , p_change_line_rec.name
          , p_change_line_rec.description
    FROM FND_LANGUAGES lang
    WHERE lang.installed_flag in ('I', 'B')
    AND NOT EXISTS ( SELECT NULL
                     FROM   ENG_CHANGE_LINES_TL tl
                     WHERE  tl.change_line_id = p_change_line_unexp_rec.change_line_id
                     AND    tl.language = lang.language_code
                     );


IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Change Line: '|| to_char(p_change_line_unexp_rec.change_line_id)
                                ||' has been created. ' );
END IF;

-- update IM TEXT Table

BEGIN

    ENG_CHANGE_TEXT_UTIL.Insert_Update_Change ( p_change_id => l_change_id );

EXCEPTION

    WHEN others THEN

        l_err_text := 'Error in ' || G_PKG_NAME || ' at ENG_CHANGE_TEXT_UTIL.Insert_Update_Change ';
END;

EXCEPTION

    WHEN OTHERS THEN


IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
   ('Unexpected Error occured in Insert . . .' || SQLERRM);
END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Change Line Insert) ' ||
                                        SUBSTR(SQLERRM, 1, 200);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Insert_Row ;


/***************************************************************************
* Procedure : Update_Row
* Parameters IN : Change Line exposed column record
*                 Change Line unexposed column record
* Parameters OUT: Return Status
*                 Message Token Table
* Purpose   : Update_Row procedure will update the production record with
*             the user given values. Any errors will be returned by filling
*             the Mesg_Token_Tbl and setting the return_status.
****************************************************************************/
PROCEDURE Update_Row
(  p_change_line_rec       IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl        OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status         OUT NOCOPY VARCHAR2
)
IS

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_Token_Tbl       Error_Handler.Token_Tbl_Type;

BEGIN

   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Performing update change line . . .') ;
END IF ;

   UPDATE ENG_CHANGE_LINES
   SET last_update_date           = SYSDATE
     , last_updated_by            = BOM_Globals.Get_User_Id
     , last_update_login          = BOM_Globals.Get_Login_Id
     , change_type_id             = p_change_line_unexp_rec.change_type_id
     , status_code                = p_change_line_unexp_rec.status_code
     , sequence_number            = p_change_line_rec.sequence_number
     , need_by_date               = p_change_line_rec.need_by_date
     , scheduled_date             = p_change_line_rec.scheduled_date
     , implementation_date        = p_change_line_rec.implementation_date
     , cancelation_date           = p_change_line_rec.cancelation_date
     , assignee_id                = p_change_line_unexp_rec.assignee_id
     , object_id                  = p_change_line_unexp_rec.object_id
     , pk1_value                  = p_change_line_unexp_rec.pk1_value
     , pk2_value                  = p_change_line_unexp_rec.pk2_value
     , pk3_value                  = p_change_line_unexp_rec.pk3_value
     , pk4_value                  = p_change_line_unexp_rec.pk4_value
     , pk5_value                  = p_change_line_unexp_rec.pk5_value
     , original_system_reference  = p_change_line_rec.original_system_reference
       WHERE change_line_id = p_change_line_unexp_rec.change_line_id ;

   UPDATE ENG_CHANGE_LINES_TL
   SET last_update_date           = SYSDATE
     , last_updated_by            = BOM_Globals.Get_User_Id
     , last_update_login          = BOM_Globals.Get_Login_Id
     , name                       = p_change_line_rec.name
     , description                = p_change_line_rec.description
   WHERE  change_line_id = p_change_line_unexp_rec.change_line_id
   AND    USERENV('LANG') = language;



EXCEPTION
    WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Update . . .' || SQLERRM);
END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Chage Line Update) ' ||
                                        SUBSTR(SQLERRM, 1, 200);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return the status and message table.
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Update_Row ;


/********************************************************************
* Procedure     : Delete_Row
* Parameters IN : Change Line exposed column record
*                 Change Line unexposed column record
* Parameters OUT: Return Status
*                 Message Token Table
* Purpose       : procedure will delete a change line record.
*********************************************************************/
PROCEDURE Delete_Row
(  p_change_line_rec            IN  Eng_Eco_Pub.Change_Line_Rec_Type
 , p_change_line_unexp_rec      IN  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
 , x_Mesg_Token_Tbl             OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
 , x_return_status              OUT NOCOPY VARCHAR2
 )
IS

    l_change_line_rec        Eng_Eco_Pub.Change_Line_Rec_Type ;
    l_change_line_unexp_rec  Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type ;

    -- Error Handlig Variables
    l_return_status   VARCHAR2(1);
    l_err_text        VARCHAR2(2000) ;
    l_Mesg_Token_Tbl  Error_Handler.Mesg_Token_Tbl_Type ;
    l_Token_Tbl       Error_Handler.Token_Tbl_Type;


BEGIN
   l_return_status      := FND_API.G_RET_STS_SUCCESS ;
   x_return_status      := FND_API.G_RET_STS_SUCCESS ;

   --
   -- Initialize Common Record and Status
   --
   l_change_line_rec         := p_change_line_rec ;
   l_change_line_unexp_rec   := p_change_line_unexp_rec ;


   -- Need to Delete Attachments ?

   -- Need to Delete Associations ?


   DELETE  FROM ENG_CHANGE_LINES
   WHERE   change_line_id = l_change_line_unexp_rec.change_line_id ;


   DELETE  FROM ENG_CHANGE_LINES_TL
   WHERE   change_line_id = l_change_line_unexp_rec.change_line_id ;

   -- Return the status and message table.
   x_return_status      := l_return_status;
   x_mesg_token_tbl     := l_mesg_token_tbl;


EXCEPTION

    WHEN OTHERS THEN

IF BOM_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
       ('Unexpected Error occured in Delete . . .' || SQLERRM);
END IF;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          l_err_text := G_PKG_NAME || ' : Utility (Change Line Delete) ' ||
                                        SUBSTR(SQLERRM, 1, 200);
          -- dbms_output.put_line('Unexpected Error: '||l_err_text);

          Error_Handler.Add_Error_Token
          (  p_message_name   => NULL
           , p_message_text   => l_err_text
           , p_mesg_token_tbl => l_mesg_token_tbl
           , x_mesg_token_tbl => l_mesg_token_tbl
          ) ;
       END IF ;

       -- Return the status and message table.
       x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_mesg_token_tbl := l_mesg_token_tbl ;

END Delete_Row ;



PROCEDURE Change_Subjects (
  p_change_line_rec            IN     Eng_Eco_Pub.Change_Line_Rec_Type
, p_change_line_unexp_rec      IN     Eng_Eco_Pub.Change_Line_Unexposed_Rec_Type
, x_change_subject_unexp_rec   IN OUT NOCOPY  Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type
, x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
, x_return_status              IN OUT NOCOPY  VARCHAR2)
IS

cursor Getsubject (p_change_type_id  in NUMBER) is
select ect.type_name ,ect.subject_id ,ese.entity_name,ese.parent_entity_name from
eng_change_order_types_vl ect ,eng_subject_entities ese
where ect.subject_id =ese.subject_id
and change_order_type_id =p_change_type_id
and subject_level=1 ;

/*cursor getlifecycleid (item_id NUMBER ,revision VARCHAR2 , l_org_id NUMBER) is
SELECT  LP.PROJ_ELEMENT_ID -- into l_current_lifecycle_id
FROM PA_EGO_LIFECYCLES_PHASES_V LP, MTL_ITEM_REVISIONS MIR
WHERE  LP.PROJ_ELEMENT_ID = MIR.CURRENT_PHASE_ID
AND MIR.INVENTORY_ITEM_ID = item_id
AND MIR.ORGANIZATION_ID = l_org_id
AND MIR.REVISION = revision;
*/ -- Commented by lkasturi

cursor getcataloggroupid(item_id NUMBER, l_org_id NUMBER) is
SELECT ITEM_CATALOG_GROUP_ID
from mtl_system_items msi
where msi.INVENTORY_ITEM_ID = item_id
AND   msi.ORGANIZATION_ID = l_org_id;

subject_type Getsubject%ROWTYPE;
l_entity_name VARCHAR2(30);
l_parent_entity_name VARCHAR2(30);
l_item_catalog_group_id NUMBER;
l_subject_id NUMBER;
l_change_subject_unexp_rec  Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type;

l_user_id           NUMBER;
l_login_id          NUMBER;
l_prog_appid        NUMBER;
l_prog_id           NUMBER;
l_request_id        NUMBER;
l_return_status     VARCHAR2(1);
l_org_id            NUMBER;
l_rev_id            NUMBER;
l_inv_item_id       NUMBER;
l_Mesg_Token_Tbl    Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl         Error_Handler.Token_Tbl_Type;
l_err_text          VARCHAR2(2000);

BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;

    OPEN Getsubject (p_change_line_Unexp_Rec.Change_Type_Id);
    FETCH Getsubject INTO subject_type;
    CLOSE Getsubject;
    l_entity_name := subject_type.entity_name;
    l_subject_id := subject_type.subject_id;
    l_parent_entity_name := subject_type.parent_entity_name;
    l_change_subject_unexp_rec.change_line_id := p_change_line_Unexp_Rec.change_line_id;
    l_change_subject_unexp_rec.ENTITY_NAME := l_entity_name;
    l_change_subject_unexp_rec.subject_level := 1;
    l_change_subject_unexp_rec.change_id := p_change_line_Unexp_Rec.change_id;

    l_org_id := p_change_line_Unexp_Rec.organization_id;  -- Added for bug 3651713


    IF (l_entity_name = 'EGO_ITEM_REVISION')
    THEN
        IF   p_change_line_rec.pk1_name IS NOT NULL
        THEN
            --l_org_id := ENG_Val_To_Id.ORGANIZATION(p_change_line_rec.pk2_name, l_err_text);
            l_change_subject_unexp_rec.pk2_value := l_org_id;
            IF (l_org_id IS NOT NULL AND l_org_id <> fnd_api.g_miss_num)
            THEN
                l_inv_item_id := ENG_Val_To_Id.revised_item(
                                     p_change_line_rec.pk1_name,
                                     l_org_id,
                                     l_err_text);
                l_change_subject_unexp_rec.pk1_value := l_inv_item_id;
                IF l_inv_item_id IS NOT NULL
                   AND l_inv_item_id <> fnd_api.g_miss_num
                THEN
                    IF p_change_line_rec.pk3_name IS NOT NULL
                    THEN
                        l_rev_id := ENG_Val_To_Id.revised_item_code(
                                        l_inv_item_id,
                                        l_org_id,
                                        p_change_line_rec.pk3_name);
                        l_change_subject_unexp_rec.pk3_value := l_rev_id;
                        IF (l_rev_id IS NOT NULL AND l_rev_id <> fnd_api.g_miss_num)
                        THEN
                            l_return_status := 'S'; --FND_API.G_RET_STS_SUCCESS;
                        ELSE
                            l_token_tbl(1).token_name := 'CHANGE_LINE_TYPE';
                            l_token_tbl(1).token_value := p_change_line_rec.change_type_code;
                            error_handler.add_error_token(
                               p_message_name   => 'ENG_PK3_NAME_INVALID',
                               p_mesg_token_tbl => l_mesg_token_tbl,
                               x_mesg_token_tbl => l_mesg_token_tbl,
                               p_token_tbl      => l_token_tbl);
                            l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF; --end of l_rev_id IS NOT NULL
                    END IF; -- end of pk3_name is not null
                ELSE
                    l_token_tbl(1).token_name := 'CHANGE_LINE_TYPE';
                    l_token_tbl(1).token_value := p_change_line_rec.change_type_code;
                    error_handler.add_error_token (
                        p_message_name   => 'ENG_PK1_NAME_INVALID',
                        p_mesg_token_tbl => l_mesg_token_tbl,
                        x_mesg_token_tbl => l_mesg_token_tbl,
                        p_token_tbl      => l_token_tbl );
                    l_return_status := FND_API.G_RET_STS_ERROR;
                END IF; -- l_inv_item_id IS NOT NULL
            ELSE
                l_token_tbl(1).token_name := 'CHANGE_LINE_TYPE';
                l_token_tbl(1).token_value := p_change_line_rec.change_type_code;
                error_handler.add_error_token (
                    p_message_name   => 'ENG_PK2_NAME_INVALID',
                    p_mesg_token_tbl => l_mesg_token_tbl,
                    x_mesg_token_tbl => l_mesg_token_tbl,
                    p_token_tbl      => l_token_tbl );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF; --l_org_id IS NOT NULL
        END IF; -- p_eco_rec.Pk1_Name is not null
    ELSIF l_entity_name = 'EGO_ITEM'
    THEN
        --For Item  PK1_NAME,PK2_NAME Columns are mandatory
        IF  p_change_line_rec.pk1_name IS NOT NULL
        THEN
            --l_org_id := ENG_Val_To_Id.ORGANIZATION(p_change_line_rec.pk2_name, l_err_text);
            l_change_subject_unexp_rec.pk2_value := l_org_id;
            IF (l_org_id IS NOT NULL AND l_org_id <> FND_API.G_MISS_NUM)
            THEN
                l_rev_id := ENG_Val_To_Id.revised_item (p_change_line_rec.pk1_name,
                                l_org_id,
                                l_err_text);
                l_change_subject_unexp_rec.pk1_value := l_rev_id;
                IF (l_rev_id IS NOT NULL AND l_rev_id <> FND_API.G_MISS_NUM)
                THEN
                    l_return_status := 'S';
                ELSE
                    l_token_tbl(1).token_name := 'CHANGE_LINE_TYPE';
                    l_token_tbl(1).token_value := p_change_line_rec.change_type_code;
                    error_handler.add_error_token (
                       p_message_name   => 'ENG_PK1_NAME_INVALID',
                       p_mesg_token_tbl => l_mesg_token_tbl,
                       x_mesg_token_tbl => l_mesg_token_tbl,
                       p_token_tbl      => l_token_tbl );
                    l_return_status := FND_API.G_RET_STS_ERROR;
                END IF; --l_rev_id IS NOT NULL
            ELSE
                l_token_tbl(1).token_name := 'CHANGE_LINE_TYPE';
                l_token_tbl(1).token_value := p_change_line_rec.change_type_code;
                error_handler.add_error_token (
                   p_message_name   => 'ENG_PK2_NAME_INVALID',
                   p_mesg_token_tbl => l_mesg_token_tbl,
                   x_mesg_token_tbl => l_mesg_token_tbl,
                   p_token_tbl      => l_token_tbl );
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF; --l_org_id IS NOT NULL
        END IF; -- p_eco_rec.Pk1_Name is not null
    END IF; --End Of If of check for l_entity_name

    IF l_return_status = 'S'
    THEN
        --
        -- Bug 3311072: Change the query to select item phase
        -- Added By LKASTURI
        --
        IF (l_change_subject_unexp_rec.pk1_value IS NOT NULL AND
           l_change_subject_unexp_rec.pk2_value IS NOT NULL)
        THEN
            BEGIN
                SELECT CURRENT_PHASE_ID
                INTO l_change_subject_unexp_rec.lifecycle_state_id
                FROM MTL_System_items_vl
                WHERE INVENTORY_ITEM_ID = l_change_subject_unexp_rec.pk1_value
                AND ORGANIZATION_ID = l_change_subject_unexp_rec.pk2_value;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_change_subject_unexp_rec.lifecycle_state_id := null;
            WHEN TOO_MANY_ROWS THEN
                l_change_subject_unexp_rec.lifecycle_state_id := null;
            END;
        ELSE
            l_change_subject_unexp_rec.lifecycle_state_id := null;
        END IF;

        -- End Changes

        IF p_change_line_rec.transaction_type = Eng_Globals.G_OPR_CREATE
        THEN
            Insert into eng_change_subjects
                 (CHANGE_SUBJECT_ID,
                  CHANGE_ID,
                  CHANGE_LINE_ID,
                  ENTITY_NAME,
                  PK1_VALUE,
                  PK2_VALUE,
                  PK3_VALUE,
                  PK4_VALUE,
                  PK5_VALUE,
                  SUBJECT_LEVEL,
                  LIFECYCLE_STATE_ID,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  REQUEST_ID,
                  PROGRAM_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_UPDATE_DATE)
                 values
                 (eng_change_subjects_s.nextval,
                  l_change_subject_unexp_rec.change_id,
                  l_change_subject_unexp_rec.change_line_id,
                  l_change_subject_unexp_rec.entity_name,
                  l_change_subject_unexp_rec.pk1_value,
                  l_change_subject_unexp_rec.pk2_value,
                  l_change_subject_unexp_rec.pk3_value,
                  l_change_subject_unexp_rec.pk4_value,
                  l_change_subject_unexp_rec.pk5_value,
                  l_change_subject_unexp_rec.subject_level,
                  l_change_subject_unexp_rec.lifecycle_state_id,
                  SYSDATE,
                  l_User_Id,
                  SYSDATE,
                  l_User_Id,
                  l_Login_Id,
                  l_request_id,
                  l_prog_appid,
                  l_prog_id,sysdate);

            IF l_parent_entity_name = 'EGO_ITEM'
            THEN
                Insert into eng_change_subjects
                    (CHANGE_SUBJECT_ID,
                     CHANGE_ID,
                     CHANGE_LINE_ID,
                     ENTITY_NAME,
                     PK1_VALUE,
                     PK2_VALUE,
                     PK3_VALUE,
                     PK4_VALUE,
                     PK5_VALUE,
                     SUBJECT_LEVEL,
                     LIFECYCLE_STATE_ID,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_LOGIN,
                     REQUEST_ID,
                     PROGRAM_ID,
                     PROGRAM_APPLICATION_ID,
                     PROGRAM_UPDATE_DATE)
                    values
                    (eng_change_subjects_s.nextval,
                     l_change_subject_unexp_rec.change_id,
                     l_change_subject_unexp_rec.change_line_id,
                     l_parent_entity_name, --l_change_subject_unexp_rec.entity_name,
                     l_change_subject_unexp_rec.pk1_value,
                     l_change_subject_unexp_rec.pk2_value,
                     null,
                     null,
                     null,
                     2,
                     null,
                     SYSDATE,
                     l_User_Id,
                     SYSDATE,
                     l_User_Id,
                     l_Login_Id,
                     l_request_id,
                     l_prog_appid,
                     l_prog_id,
                     sysdate);
            elsif l_parent_entity_name = 'EGO_CATALOG_GROUP'
            THEN
                OPEN getcataloggroupid(l_change_subject_unexp_rec.pk1_value,
                                       l_change_subject_unexp_rec.pk2_value);
                FETCH getcataloggroupid into l_item_catalog_group_id;
                Insert into eng_change_subjects
                   (CHANGE_SUBJECT_ID,
                    CHANGE_ID,
                    CHANGE_LINE_ID,
                    ENTITY_NAME,
                    PK1_VALUE,
                    PK2_VALUE,
                    PK3_VALUE,
                    PK4_VALUE,
                    PK5_VALUE,
                    SUBJECT_LEVEL,
                    LIFECYCLE_STATE_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    LAST_UPDATE_LOGIN,
                    REQUEST_ID,
                    PROGRAM_ID,
                    PROGRAM_APPLICATION_ID,
                    PROGRAM_UPDATE_DATE)
                   values
                   (eng_change_subjects_s.nextval,
                    l_change_subject_unexp_rec.change_id,
                     l_change_subject_unexp_rec.change_line_id,
                    l_parent_entity_name, --l_change_subject_unexp_rec.entity_name,
                    l_item_catalog_group_id,
                    null,
                    null,
                    null,
                    null,
                    2,
                    null,
                    SYSDATE,
                    l_User_Id,
                    SYSDATE,
                    l_User_Id,
                    l_Login_Id,
                    l_request_id,
                    l_prog_appid,
                    l_prog_id,
                    sysdate);
            END IF;
        ELSIF p_change_line_rec.transaction_type =  Eng_Globals.G_OPR_UPDATE
        THEN
            UPDATE eng_change_subjects SET
            pk1_value = l_change_subject_unexp_rec.pk1_value,
            pk2_value = l_change_subject_unexp_rec.pk2_value,
            pk3_value = l_change_subject_unexp_rec.pk3_value
            WHERE change_id = l_change_subject_unexp_rec.change_id
            AND change_line_id = l_change_subject_unexp_rec.change_line_id
            AND subject_level = 1;

            IF l_parent_entity_name = 'EGO_ITEM'
            THEN
                UPDATE eng_change_subjects SET
                pk1_value = l_change_subject_unexp_rec.pk1_value,
                pk2_value = l_change_subject_unexp_rec.pk2_value
                WHERE change_id = l_change_subject_unexp_rec.change_id
                AND subject_level = 2
                AND change_line_id = l_change_subject_unexp_rec.change_line_id;
            ELSIF l_parent_entity_name = 'EGO_CATALOG_GROUP'
            THEN
                OPEN getcataloggroupid(l_change_subject_unexp_rec.pk1_value,
                                       l_change_subject_unexp_rec.pk2_value);
                FETCH getcataloggroupid into l_item_catalog_group_id;
                UPDATE eng_change_subjects SET
                pk1_value = l_item_catalog_group_id
                WHERE change_id = l_change_subject_unexp_rec.change_id
                AND subject_level = 2
                AND change_line_id = l_change_subject_unexp_rec.change_line_id;
            END IF;
        ELSE
            DELETE FROM eng_change_subjects
            WHERE change_line_id = l_change_subject_unexp_rec.change_line_id
            AND change_id = l_change_subject_unexp_rec.change_id;
        END IF; -- if CREATE
    END IF; -- if return status is 'S'

    x_mesg_token_tbl := l_mesg_token_tbl;
    x_return_status := l_return_status;

END Change_Subjects;

-- ****************************************************************** --
--  API name    : Get_Concatenated_Subjects                           --
--  Type        : Public                                              --
--  Pre-reqs    : None.                                               --
--  Function    : Gets the concatenated subject value for display     --
--  Parameters  :                                                     --
--       IN     :                                                     --
--                p_change_id            NUMBER   Required            --
--                p_change_line_id       NUMBER                       --
--                p_subject_id           NUMBER                       --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       : None                                                --
-- ****************************************************************** --

FUNCTION Get_Concatenated_Subjects (
    p_change_id         NUMBER
  , p_change_line_id    NUMBER
  , p_subject_id        NUMBER
) RETURN VARCHAR2
IS

  CURSOR c_subject_details IS
  SELECT esev.query_object_name, esev.pk1_column_name, esev.pk2_column_name
       , esev.pk3_column_name, esev.pk4_column_name, esev.pk5_column_name
       , esev.query_column1_name, esev.query_column2_name, esev.query_column3_name
       , esev.query_column4_name, esev.query_column5_name
       , subs.entity_name, subs.subject_level, subs.pk1_value
       , subs.pk2_value, subs.pk3_value, subs.pk4_value, subs.pk5_value
    FROM eng_subject_entities_v esev, eng_change_subjects subs
   WHERE esev.subject_id     = p_subject_id
     AND esev.subject_level  = subs.subject_level
     AND esev.entity_name    = subs.entity_name
     AND subs.change_id      = p_change_id
     AND subs.change_line_id = p_change_line_id
   ORDER BY subs.subject_level DESC;

  l_sql_stmt          VARCHAR2(2000);
  l_where_clause      VARCHAR2(2000);
  l_bind_count        NUMBER;
  l_bind_values       DBMS_SQL.VARCHAR2_TABLE;
  l_desc_table        DBMS_SQL.Desc_Tab;
  l_cursor_id         NUMBER;
  l_dummy             NUMBER;
  l_value_char        VARCHAR2(4000);
  l_column_count      NUMBER;
  l_concat_subject    VARCHAR2(2000);
  l_subject_name1     VARCHAR2(2000);
  l_query_column_cl   VARCHAR2(1000);
BEGIN
  FOR csd1 in c_subject_details
  LOOP
    l_sql_stmt := null;
    l_bind_count := 0;
    l_where_clause := NULL;
    IF (csd1.pk1_column_name is not null)
    THEN
      l_bind_count := l_bind_count+1;
      l_bind_values(l_bind_count) := csd1.pk1_value;
      l_where_clause := csd1.pk1_column_name || ' = :' || l_bind_count;
    END IF;
    IF (csd1.pk2_column_name is not null)
    THEN
      l_bind_count := l_bind_count+1;
      l_bind_values(l_bind_count) := csd1.pk2_value;
      l_where_clause := l_where_clause ||' AND '|| csd1.pk2_column_name || ' = :' || l_bind_count;
    END IF;
    IF (csd1.pk3_column_name is not null)
    THEN
      l_bind_count := l_bind_count+1;
      l_bind_values(l_bind_count) := csd1.pk3_value;
      l_where_clause := l_where_clause ||' AND '|| csd1.pk3_column_name || ' = :' || l_bind_count;
    END IF;
    IF (csd1.pk4_column_name is not null)
    THEN
      l_bind_count := l_bind_count+1;
      l_bind_values(l_bind_count) := csd1.pk4_value;
      l_where_clause := l_where_clause ||' AND '|| csd1.pk4_column_name || ' = :' || l_bind_count;
    END IF;
    IF (csd1.pk5_column_name is not null)
    THEN
      l_bind_count := l_bind_count+1;
      l_bind_values(l_bind_count) := csd1.pk5_value;
      l_where_clause := l_where_clause ||' AND '|| csd1.pk5_column_name || ' = :' || l_bind_count;
    END IF;
    IF l_where_clause IS NOT NULL
    THEN
      l_query_column_cl := NULL;
      IF csd1.query_column1_name = 'ALTERNATE_BOM_DESIGNATOR'
      THEN
        l_query_column_cl := 'NVL(' ||csd1.query_column1_name||', FND_MESSAGE.get_string(''BOM'', ''BOM_PRIMARY'')) '|| csd1.query_column1_name;
      ELSE
        l_query_column_cl := csd1.query_column1_name;
      END IF;

      l_sql_stmt := 'SELECT '||l_query_column_cl|| ' FROM ' || csd1.query_object_name || ' WHERE ' || l_where_clause ;
      l_cursor_id := DBMS_SQL.Open_Cursor;
      DBMS_SQL.Parse(l_cursor_id, l_sql_stmt, DBMS_SQL.Native);
      DBMS_SQL.Describe_Columns(l_cursor_id, l_column_count, l_desc_table);
      FOR i IN 1..l_column_count
      LOOP
        DBMS_SQL.Define_Column(l_cursor_id, i, l_value_char, 1000);
      END LOOP;
      FOR l_bind_index IN 1..l_bind_count
      LOOP
        DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':'||l_bind_index, l_bind_values(l_bind_index));
      END LOOP;
      l_dummy := DBMS_SQL.Execute(l_cursor_id);
      IF (DBMS_SQL.Fetch_Rows(l_cursor_id) > 0)
      THEN
        dbms_sql.column_value(l_cursor_id, 1, l_subject_name1);
        IF l_concat_subject IS NOT NULL
        THEN
          l_concat_subject := l_concat_subject || ' > ';
        END IF;
        l_concat_subject := l_concat_subject || l_subject_name1;
      END IF;
    END IF;
    dbms_sql.close_cursor(l_cursor_id);
  END LOOP;
  RETURN l_concat_subject;
EXCEPTION
WHEN OTHERS THEN
  IF dbms_sql.is_open(l_cursor_id)
  THEN
    dbms_sql.close_cursor(l_cursor_id);
  END IF;
  RAISE;
END Get_Concatenated_Subjects;

-- Fix for bug no: 6038875
FUNCTION Get_Concatenated_Subjects_URL
(   p_change_id            IN NUMBER
  , p_change_line_id       IN NUMBER
)RETURN VARCHAR2
IS
 CURSOR c_subject_details IS
 SELECT * FROM(
  SELECT subs.entity_name, subs.pk1_value
       , REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(eco.entity_url,'pk1Value',subs.pk1_value)
       ,'pk2Value', subs.pk2_value)
       ,'pk3Value', subs.pk3_value)
       ,'pk4Value', subs.pk4_value)
       ,'pk1Value', subs.pk5_value) subject_url
    FROM ENG_CHANGE_OBJECTS eco, eng_change_subjects subs
   WHERE eco.entity_name    = subs.entity_name
     AND subs.pk1_value IS NOT NULL
     AND subs.entity_name <> 'EGO_COMPONENT'
     AND subs.change_id      = p_change_id
     AND subs.change_line_id = p_change_line_id
     ORDER BY subs.subject_level)
     WHERE ROWNUM=1;

 CURSOR c_item_rev_details IS
       SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE('&inventoryItemId=pk1Value&organizationId=pk2Value&revisionId=pk3Value'
       ,'pk1Value',subs.pk1_value)
       ,'pk2Value', subs.pk2_value)
       ,'pk3Value', subs.pk3_value)
       ,'pk4Value', subs.pk4_value)
       ,'pk1Value', subs.pk5_value) subject_url
       FROM eng_change_subjects subs
       WHERE subs.subject_level = 3 and subs.entity_name = 'EGO_ITEM_REVISION'
       AND subs.change_id      = p_change_id
       AND subs.change_line_id = p_change_line_id;

  l_subject_url		 VARCHAR2(4000);
  l_csd       c_subject_details%ROWTYPE;
  l_structure_name     VARCHAR2(400);
  l_structure_url_part VARCHAR2(4000);

BEGIN
  OPEN c_subject_details;
  FETCH c_subject_details INTO l_csd;
  l_subject_url := l_csd.subject_url;
  IF (l_csd.entity_name = 'EGO_STRUCTURE_NAME')
	THEN
	BEGIN
	   	SELECT Nvl(ALTERNATE_BOM_DESIGNATOR,bom_globals.retrieve_message('BOM','BOM_PRIMARY'))
		into l_structure_name
		FROM BOM_BILL_OF_MATERIALS
		WHERE bill_sequence_id = l_csd.pk1_value;
		if (l_structure_name IS NOT NULL) THEN
		   OPEN c_item_rev_details;
		   FETCH c_item_rev_details INTO l_structure_url_part;
		   CLOSE c_item_rev_details;
		   l_subject_url := 'OA.jsp?OAFunc=EGO_BOM_EXPLOSIONS&structName='||l_structure_name
		   ||l_structure_url_part;
		END IF;
	EXCEPTION
	   WHEN others THEN
	      OPEN c_item_rev_details;
	      FETCH c_item_rev_details INTO l_structure_url_part;
	      CLOSE c_item_rev_details;
	      l_subject_url:='OA.jsp?OAFunc=EGO_ITEM_OVERVIEW'||l_structure_url_part;
	END;
  END IF;
CLOSE c_subject_details;
return l_subject_url;
END Get_Concatenated_Subjects_URL;
END ENG_Change_Line_Util ;

/
