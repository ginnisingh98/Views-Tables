--------------------------------------------------------
--  DDL for Package Body BOM_RTG_REVISION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_REVISION_UTIL" AS
/* $Header: BOMURRVB.pls 120.1.12000000.2 2007/04/11 10:01:23 shchandr ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMURRVB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Rtg_Revision_UTIL
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Biao Zhang Initial Creation
--
****************************************************************************/
  G_Pkg_Name      VARCHAR2(30) := 'BOM_Rtg_Revision_UTIL';
  g_token_tbl     Error_Handler.Token_Tbl_Type;

  /*********************************************************************
  * Procedure     : Query_Row
  * Parameters IN : Assembly item id
  *                 Organization Id
  *                 Alternate_Rtg_Code
  * Parameters out: Rtg revision exposed column record
  *                 Rtg Revision unexposed column record
  *                 Mesg token Table
  *                 Return Status
  * Purpose       : Procedure will query the database record, seperate the
  *                 values into exposed columns and unexposed columns and
  *                 return with those records.
  ***********************************************************************/
  PROCEDURE Query_Row
  (  p_assembly_item_id    IN  NUMBER
   , p_organization_id     IN  NUMBER
   , p_revision            IN  VARCHAR2
   , x_rtg_revision_rec    IN OUT NOCOPY Bom_Rtg_Pub.rtg_revision_Rec_Type
   , x_rtg_rev_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.rtg_rev_unexposed_Rec_Type
   , x_Return_status       IN OUT NOCOPY VARCHAR2
  )
  IS
    l_rtg_revision_rec      Bom_Rtg_Pub.Rtg_revision_Rec_Type;
    l_rtg_rev_unexp_rec     Bom_Rtg_Pub.Rtg_rev_Unexposed_Rec_Type;
    l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
    l_dummy                 varchar2(10);
  BEGIN
    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Revision: ' ||
      l_rtg_revision_rec.revision );
    END IF;

    SELECT  inventory_item_id
    ,       organization_id
    ,       process_revision
    -- ,       implementation_date
    ,       effectivity_date
    ,       attribute_category
    ,       attribute1
    ,       attribute2
    ,       attribute3
    ,       attribute4
    ,       attribute5
    ,       attribute6
    ,       attribute7
    ,       attribute8
    ,       attribute9
    ,       attribute10
    ,       attribute11
    ,       attribute12
    ,       attribute13
    ,       attribute14
    ,       attribute15
    INTO l_rtg_rev_unexp_rec.assembly_item_id
    ,       l_rtg_rev_unexp_rec.organization_id
    ,       l_rtg_revision_rec.revision
    ,       l_rtg_revision_rec.start_effective_date
    ,       l_rtg_revision_rec.attribute_category
    ,       l_rtg_revision_rec.attribute1
    ,       l_rtg_revision_rec.attribute2
    ,       l_rtg_revision_rec.attribute3
    ,       l_rtg_revision_rec.attribute4
    ,       l_rtg_revision_rec.attribute5
    ,       l_rtg_revision_rec.attribute6
    ,       l_rtg_revision_rec.attribute7
    ,       l_rtg_revision_rec.attribute8
    ,       l_rtg_revision_rec.attribute9
    ,       l_rtg_revision_rec.attribute10
    ,       l_rtg_revision_rec.attribute11
    ,       l_rtg_revision_rec.attribute12
    ,       l_rtg_revision_rec.attribute13
    ,       l_rtg_revision_rec.attribute14
    ,       l_rtg_revision_rec.attribute15
    FROM  mtl_rtg_item_revisions
    WHERE inventory_item_id = p_assembly_item_id
    AND organization_id = p_organization_id
    AND process_revision = p_revision;

    x_return_status  := BOM_Rtg_Globals.G_RECORD_FOUND;
    x_rtg_revision_rec  := l_rtg_revision_rec;
    x_rtg_rev_unexp_rec := l_rtg_rev_unexp_rec;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := BOM_Rtg_Globals.G_RECORD_NOT_FOUND;
        x_rtg_revision_rec := l_rtg_revision_rec;
        x_rtg_rev_unexp_rec := l_rtg_rev_unexp_rec;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_rtg_revision_rec := l_rtg_revision_rec;
        x_rtg_rev_unexp_rec := l_rtg_rev_unexp_rec;

  END Query_Row;

  /********************************************************************
  * Procedure     : Insert_Row
  * Parameters IN : rtg Revisioner exposed column record
  *                 rtg Revisioner unexposed column record
  * Parameters out: Message Token Table
  *                 Return Status
  * Purpose       : Procedure will perfrom an insert into the
  *                 rtg_Bill_Of_Materials table thus creating a new bill
  *********************************************************************/
  PROCEDURE Insert_Row
  (  p_rtg_revision_rec   IN  Bom_Rtg_Pub.rtg_revision_Rec_Type
   , p_rtg_rev_unexp_rec  IN  Bom_Rtg_Pub.rtg_rev_Unexposed_Rec_Type
   , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_Status      IN OUT NOCOPY VARCHAR2
  )
  IS
    l_start_effectivity_date DATE;
    p_implementation_date DATE;

  BEGIN

   /* Bug 5970070. Time stamp is supported for RTG revisions. So populate
    the revision in l_start_effectivity_date as it is.
    IF trunc(p_rtg_revision_rec.start_effective_date)
       = trunc(sysdate) THEN
       l_start_effectivity_date :=
       to_date(to_char(sysdate,'DD-MON-YY-HH24:MI:SS'),
       'DD-MON-YY-HH24:MI:SS');
       IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
         Error_Handler.Write_Debug('start_effective_date :'||
         to_char(l_start_effectivity_date,'DD-MON-YY-HH24:MI:SS'));
       END IF;
    ELSIF
      trunc(p_rtg_revision_rec.start_effective_date) > trunc(sysdate) THEN
        l_start_effectivity_date
        := trunc(p_rtg_revision_rec.start_effective_date);
    ELSIF nvl(bom_globals.get_caller_type,'0') = 'MIGRATION' THEN
	l_start_effectivity_date := p_rtg_revision_rec.start_effective_date;
    END IF;   */

    l_start_effectivity_date := p_rtg_revision_rec.start_effective_date;  -- Bug 5970070

    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Writing rtg Revisioner rec for '
      || p_rtg_revision_rec.assembly_item_name);
    END IF;

    --bug:3254815 Update request id, prog id, prog appl id and prog update date.
    INSERT INTO mtl_rtg_item_revisions
    (  inventory_item_id
    ,       organization_id
    ,       process_revision
    ,       implementation_date
    ,       effectivity_date
    ,       attribute_category
    ,       attribute1
    ,       attribute2
    ,       attribute3
    ,       attribute4
    ,       attribute5
    ,       attribute6
    ,       attribute7
    ,       attribute8
    ,       attribute9
    ,       attribute10
    ,       attribute11
    ,       attribute12
    ,       attribute13
    ,       attribute14
    ,       attribute15
    ,       creation_date
    ,       created_by
    ,       last_update_date
    ,       last_updated_by
    ,       last_update_login
    ,       request_id
    ,       program_id
    ,       program_application_id
    ,       program_update_date
    )
    VALUES
    (  p_rtg_rev_unexp_rec.assembly_item_id
     , p_rtg_rev_unexp_rec.organization_id
     , p_rtg_revision_rec.revision
     , l_start_effectivity_date
     , l_start_effectivity_date
     , p_rtg_revision_rec.attribute_category
     , p_rtg_revision_rec.attribute1
     , p_rtg_revision_rec.attribute2
     , p_rtg_revision_rec.attribute3
     , p_rtg_revision_rec.attribute4
     , p_rtg_revision_rec.attribute5
     , p_rtg_revision_rec.attribute6
     , p_rtg_revision_rec.attribute7
     , p_rtg_revision_rec.attribute8
     , p_rtg_revision_rec.attribute9
     , p_rtg_revision_rec.attribute10
     , p_rtg_revision_rec.attribute11
     , p_rtg_revision_rec.attribute12
     , p_rtg_revision_rec.attribute13
     , p_rtg_revision_rec.attribute14
     , p_rtg_revision_rec.attribute15
     , SYSDATE
     , BOM_Rtg_Globals.Get_User_Id
     , SYSDATE
     , BOM_Rtg_Globals.Get_User_Id
     , BOM_Rtg_Globals.Get_User_Id
     , Fnd_Global.Conc_Request_Id
     , Fnd_Global.Conc_Program_Id
     , Fnd_Global.Prog_Appl_Id
     , SYSDATE
    );
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
        Error_Handler.Add_Error_Token
        (  p_message_name       => NULL
         , p_message_text       => G_PKG_NAME ||
         ' :Inserting Record ' ||
         SQLERRM
         , x_mesg_token_Tbl     => x_mesg_token_tbl
        );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Insert_Row;

  /********************************************************************
  * Procedure     : Update_Row
  * Parameters IN : RTG Revisioner exposed column record
  *                 RTG Revisioner unexposed column record
  * Parameters out: Message Token Table
  *                 Return Status
  * Purpose       : Procedure will perfrom an Update into the
  *                 rtg_Bill_Of_Materials table.
  ********************************************************************/
  PROCEDURE Update_Row
  (  p_RTG_revision_rec   IN  Bom_Rtg_Pub.RTG_Revision_Rec_Type
   , p_RTG_rev_unexp_rec  IN  Bom_Rtg_Pub.RTG_Rev_Unexposed_Rec_Type
   , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_Status      IN OUT NOCOPY VARCHAR2
   )
  IS
    p_start_effective_date DATE;
    p_implementation_date DATE;
  BEGIN

    --
    -- The only fields that are updateable in RTG Revisioner are the
    -- CTP, Priority, completion subinventory, completion_locator,
    --
    --
    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
       Error_Handler.Write_Debug('Updating routing revision '
       || p_rtg_revision_rec.revision);
    END IF;

    UPDATE  mtl_rtg_item_revisions
    SET effectivity_date =
    p_rtg_revision_rec.start_effective_date
    , implementation_date =
    p_rtg_revision_rec.start_effective_date
    , last_update_date =  SYSDATE
    , last_updated_by = BOM_Rtg_Globals.Get_User_Id
    , last_update_login = BOM_Rtg_Globals.Get_User_Id
    , attribute_category =p_rtg_revision_rec.attribute_category                     , attribute1 = p_rtg_revision_rec.attribute1
    , attribute2 = p_rtg_revision_rec.attribute2
    , attribute3 = p_rtg_revision_rec.attribute3
    , attribute4 = p_rtg_revision_rec.attribute4
    , attribute5 = p_rtg_revision_rec.attribute5
    , attribute6 = p_rtg_revision_rec.attribute6
    , attribute7 = p_rtg_revision_rec.attribute7
    , attribute8 = p_rtg_revision_rec.attribute8
    , attribute9 = p_rtg_revision_rec.attribute9
    , attribute10= p_rtg_revision_rec.attribute10
    , attribute11= p_rtg_revision_rec.attribute11
    , attribute12= p_rtg_revision_rec.attribute12
    , attribute13= p_rtg_revision_rec.attribute13
    , attribute14= p_rtg_revision_rec.attribute14
    , attribute15= p_rtg_revision_rec.attribute15
    , request_id = Fnd_Global.Conc_Request_Id
    , program_id = Fnd_Global.Conc_Program_Id
    , program_application_id = Fnd_Global.Prog_Appl_Id
    , program_update_date = SYSDATE
    WHERE inventory_item_id = p_rtg_rev_unexp_rec.assembly_item_id                  AND organization_id = p_rtg_rev_unexp_rec.organization_id
    AND process_revision = p_rtg_revision_rec.revision;


  END Update_Row;


  /********************************************************************
  * Procedure     : Delete_Row
  * Parameters IN : rtg Revisioner exposed column record
  *                 rtg Revisioner unexposed column record
  * Parameters out: Message Token Table
  *                 Return Status
  * Purpose       : Procedure will perfrom an Delete from the
  *                 rtg_Bill_Of_Materials by creating a delete Group.
  *********************************************************************/
  PROCEDURE Delete_Row
  (  p_rtg_revision_rec     IN  Bom_Rtg_Pub.rtg_revision_Rec_Type
   , p_rtg_rev_unexp_rec    IN  Bom_Rtg_Pub.rtg_rev_Unexposed_Rec_Type
   , x_mesg_token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_Status        IN OUT NOCOPY VARCHAR2
  )
  IS
    l_rtg_rev_unexp_rec  Bom_Rtg_Pub.rtg_rev_Unexposed_Rec_Type
    := p_rtg_rev_unexp_rec;

    l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
      Error_Handler.Write_Debug('Delete routing revision '
      || p_rtg_revision_rec.revision);
    END IF;

    DELETE FROM mtl_rtg_item_revisions
    WHERE inventory_item_id = p_rtg_rev_unexp_rec.assembly_item_id
    AND organization_id = p_rtg_rev_unexp_rec.organization_id
    AND process_revision = p_rtg_revision_rec.revision;

    EXCEPTION
      WHEN OTHERS THEN
        Error_Handler.Add_Error_Token
        (  p_Message_Name  => NULL
         , p_Message_Text  => 'ERROR in Delete Routing Revision' ||
         substr(SQLERRM, 1, 100) || ' '    ||
         to_char(SQLCODE)
         , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
         , x_Mesg_Token_Tbl     => x_Mesg_Token_Tbl
        );
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl;

  END Delete_Row;

  /*********************************************************************
  * Procedure     : Perform_Writes
  * Parameters IN : Rtg Revisioner Exposed Column Record
  *                 Rtg Revisioner Unexposed column record
  * Parameters out: Messgae Token Table
  *                 Return Status
  * Purpose       : This is the only procedure that the user will have
  *                 access to when he/she needs to perform any kind of
  *                 writes to the bom_operational_routings.
  *********************************************************************/
  PROCEDURE Perform_Writes
  (  p_rtg_revision_rec   IN  Bom_Rtg_Pub.rtg_revision_Rec_Type
   , p_rtg_rev_unexp_rec  IN  Bom_Rtg_Pub.rtg_rev_Unexposed_Rec_Type
   , x_mesg_token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_status      IN OUT NOCOPY VARCHAR2
  )
  IS
    l_Mesg_Token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_rtg_revision_rec.transaction_type =
       BOM_Rtg_Globals.G_OPR_CREATE THEN
      Insert_Row
      (  p_rtg_revision_rec   => p_rtg_revision_rec
       , p_rtg_rev_unexp_rec  => p_rtg_rev_unexp_rec
       , x_mesg_token_Tbl     => l_mesg_token_tbl
       , x_return_Status      => l_return_status
      );
    ELSIF p_rtg_revision_rec.transaction_type =
          BOM_Rtg_Globals.G_OPR_UPDATE THEN
      Update_Row
      (  p_rtg_revision_rec   => p_rtg_revision_rec
       , p_rtg_rev_unexp_rec => p_rtg_rev_unexp_rec
       , x_mesg_token_Tbl     => l_mesg_token_tbl
       , x_return_Status      => l_return_status
      );

    ELSIF p_rtg_revision_rec.transaction_type =
          BOM_Rtg_Globals.G_OPR_DELETE THEN
      Delete_Row
      (  p_rtg_revision_rec   => p_rtg_revision_rec
       , p_rtg_rev_unexp_rec => p_rtg_rev_unexp_rec
       , x_mesg_token_Tbl     => l_mesg_token_tbl
       , x_return_Status      => l_return_status
      );
    END IF;
    x_return_status := l_return_status;
    x_mesg_token_tbl := l_mesg_token_tbl;

  END Perform_Writes;


END BOM_Rtg_Revision_UTIL;

/
