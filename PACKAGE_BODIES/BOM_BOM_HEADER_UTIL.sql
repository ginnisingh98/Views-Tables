--------------------------------------------------------
--  DDL for Package Body BOM_BOM_HEADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOM_HEADER_UTIL" AS
/* $Header: BOMUBOMB.pls 120.5.12010000.2 2010/01/22 19:38:42 vbrobbey ship $ */
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
--      Body of package Bom_Bom_Header_Util
--
--  NOTES
--
--  HISTORY
--  02-JUL-1999 Rahul Chitko    Initial Creation
--  19-Aug-2003 Hari Gelli	added obj_name, pk1_value, pk2_value in insert_row
--  06-Feb-2004 Vani            added Is_Preferred Flag for inserts
--  11-JAN-2005 Vani            added effectivity control in Insert_Row
--  21-FEB-2005 Vani	        added query_table_row method to query from
--				                    bom_structures_b instead of bom_bill_of_materials.
--  06-MAY-2005 Abhsihek Rudresh  Common BOM Attrs Update
--  13-JUL-06   Bhavnesh Patel    Added support for Structure Type
****************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'Bom_Bom_Header_Util';
FUNCTION get_effectivity_control (item_id NUMBER, org_id NUMBER) return NUMBER;

  /*********************************************************************
  * Procedure     : Query_Row
  * Parameters IN : Assembly item id
  *                 Organization Id
  *                 Alternate_Bom_Code
  * Parameters OUT: Bom header exposed column record
  *                 BOm Header unexposed column record
  *                 Mesg token Table
  *                 Return Status
  * Purpose       : Procedure will query the database record, seperate the
  *     values into exposed columns and unexposed columns and
  *     return with those records.
  ***********************************************************************/
  PROCEDURE Query_Row
  (  p_assembly_item_id    IN  NUMBER
   , p_organization_id     IN  NUMBER
   , p_alternate_bom_code  IN VARCHAR2 := NULL
   , x_bom_header_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_head_Rec_Type
   , x_bom_head_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_head_unexposed_Rec_Type
   , x_Return_status       IN OUT NOCOPY VARCHAR2
  )
  IS
    l_bom_header_rec  Bom_Bo_Pub.Bom_Head_Rec_Type;
    l_bom_head_unexp_rec  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type;
    l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
    l_dummy     varchar2(10);
  BEGIN
                SELECT decode(p_alternate_bom_code, FND_API.G_MISS_CHAR,
                              'Missing', NULL, 'XXXX', p_alternate_bom_code)
                   INTO l_dummy
                  from sys.dual;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Alt: ' || l_dummy
); END IF;

    SELECT  assembly_item_id
    , organization_id
    , alternate_bom_designator
    , common_assembly_item_id
    , common_organization_id
    , specific_assembly_comment
    , attribute_category
    ,       attribute1
    ,       attribute2
    ,       attribute3
    ,       attribute4
    ,       attribute5
    , attribute6
    ,       attribute7
    ,       attribute8
    ,       attribute9
    , attribute10
    ,       attribute11
    ,       attribute12
    ,       attribute13
    ,       attribute14
    ,       attribute15
    , assembly_type
    , assembly_type
    , common_bill_sequence_id
    , bill_sequence_id
    , structure_type_id
    , implementation_date
      INTO  l_bom_head_unexp_rec.assembly_item_id
    , l_bom_head_unexp_rec.organization_id
    , l_bom_header_rec.alternate_bom_code
    , l_bom_head_unexp_rec.common_assembly_item_id
    , l_bom_head_unexp_rec.common_organization_id
    , l_bom_header_rec.assembly_comment
    , l_bom_header_rec.attribute_category
    , l_bom_header_rec.attribute1
    , l_bom_header_rec.attribute2
    , l_bom_header_rec.attribute3
    , l_bom_header_rec.attribute4
    , l_bom_header_rec.attribute5
    , l_bom_header_rec.attribute6
    , l_bom_header_rec.attribute7
    , l_bom_header_rec.attribute8
    , l_bom_header_rec.attribute9
    , l_bom_header_rec.attribute10
    , l_bom_header_rec.attribute11
    , l_bom_header_rec.attribute12
    , l_bom_header_rec.attribute13
    , l_bom_header_rec.attribute14
    , l_bom_header_rec.attribute15
    , l_bom_head_unexp_rec.assembly_type
    , l_bom_header_rec.assembly_type
    , l_bom_head_unexp_rec.common_bill_sequence_id
    , l_bom_head_unexp_rec.bill_sequence_id
    , l_bom_head_unexp_rec.structure_type_id
    , l_bom_header_rec.bom_implementation_date
      FROM  bom_bill_of_materials
     WHERE  assembly_item_id = p_assembly_item_id
       AND  organization_id  = p_organization_id
       AND  effectivity_control <>4 -- Rev effective structures should be filtered.
       AND  NVL(alternate_bom_designator, 'XXXX') =
      NVL(DECODE( p_alternate_bom_code,FND_API.G_MISS_CHAR,
            NULL, p_alternate_bom_code
           ), 'XXXX');

    x_return_status  := BOM_Globals.G_RECORD_FOUND;
    x_bom_header_rec  := l_bom_header_rec;
    x_bom_head_unexp_rec := l_bom_head_unexp_rec;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := BOM_Globals.G_RECORD_NOT_FOUND;
      x_bom_header_rec := l_bom_header_rec;
      x_bom_head_unexp_rec := l_bom_head_unexp_rec;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_bom_header_rec := l_bom_header_rec;
                        x_bom_head_unexp_rec := l_bom_head_unexp_rec;

  END Query_Row;


  /*********************************************************************
  * Procedure     : Query_Table_Row
  * Parameters IN : Assembly item id
  *                 Organization Id
  *                 Alternate_Bom_Code
  * Parameters OUT: Bom header exposed column record
  *                 BOm Header unexposed column record
  *                 Mesg token Table
  *                 Return Status
  * Purpose       : Procedure will query the database record, From BOM_STRUCTURES_B
  *     seperate the values into exposed columns and unexposed columns and
  *     return with those records.
  ***********************************************************************/
  PROCEDURE Query_Table_Row
  (  p_assembly_item_id    IN  NUMBER
   , p_organization_id     IN  NUMBER
   , p_alternate_bom_code  IN VARCHAR2 := NULL
   , x_bom_header_rec      IN OUT NOCOPY Bom_Bo_Pub.Bom_head_Rec_Type
   , x_bom_head_unexp_rec  IN OUT NOCOPY Bom_Bo_Pub.Bom_head_unexposed_Rec_Type
   , x_Return_status       IN OUT NOCOPY VARCHAR2
  )
  IS
    l_bom_header_rec  Bom_Bo_Pub.Bom_Head_Rec_Type;
    l_bom_head_unexp_rec  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type;
    l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
    l_dummy     varchar2(10);
  BEGIN
                SELECT decode(p_alternate_bom_code, FND_API.G_MISS_CHAR,
                              'Missing', NULL, 'XXXX', p_alternate_bom_code)
                   INTO l_dummy
                  from sys.dual;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Alt: ' || l_dummy
); END IF;

    SELECT  assembly_item_id
    , organization_id
    , alternate_bom_designator
    , common_assembly_item_id
    , common_organization_id
    , specific_assembly_comment
    , attribute_category
    ,       attribute1
   ,       attribute2
    ,       attribute3
    ,       attribute4
    ,       attribute5
    , attribute6
    ,       attribute7
    ,       attribute8
    ,       attribute9
    , attribute10
    ,       attribute11
    ,       attribute12
    ,       attribute13
    ,       attribute14
    ,       attribute15
    , assembly_type
    , common_bill_sequence_id
    , bill_sequence_id
    , structure_type_id
    , implementation_date
      INTO  l_bom_head_unexp_rec.assembly_item_id
    , l_bom_head_unexp_rec.organization_id
    , l_bom_header_rec.alternate_bom_code
    , l_bom_head_unexp_rec.common_assembly_item_id
    , l_bom_head_unexp_rec.common_organization_id
    , l_bom_header_rec.assembly_comment
    , l_bom_header_rec.attribute_category
    , l_bom_header_rec.attribute1
    , l_bom_header_rec.attribute2
    , l_bom_header_rec.attribute3
    , l_bom_header_rec.attribute4
    , l_bom_header_rec.attribute5
    , l_bom_header_rec.attribute6
    , l_bom_header_rec.attribute7
    , l_bom_header_rec.attribute8
    , l_bom_header_rec.attribute9
    , l_bom_header_rec.attribute10
    , l_bom_header_rec.attribute11
    , l_bom_header_rec.attribute12
    , l_bom_header_rec.attribute13
    , l_bom_header_rec.attribute14
    , l_bom_header_rec.attribute15
    , l_bom_head_unexp_rec.assembly_type
   , l_bom_head_unexp_rec.common_bill_sequence_id
    , l_bom_head_unexp_rec.bill_sequence_id
    , l_bom_head_unexp_rec.structure_type_id
    , l_bom_header_rec.bom_implementation_date
      FROM  bom_structures_b
     WHERE  assembly_item_id = p_assembly_item_id
       AND  organization_id  = p_organization_id
       AND  NVL(alternate_bom_designator, 'XXXX') =
      NVL(DECODE( p_alternate_bom_code,FND_API.G_MISS_CHAR,
            NULL, p_alternate_bom_code
           ), 'XXXX');

    x_return_status  := BOM_Globals.G_RECORD_FOUND;
    x_bom_header_rec  := l_bom_header_rec;
    x_bom_head_unexp_rec := l_bom_head_unexp_rec;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := BOM_Globals.G_RECORD_NOT_FOUND;
      x_bom_header_rec := l_bom_header_rec;
      x_bom_head_unexp_rec := l_bom_head_unexp_rec;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_bom_header_rec := l_bom_header_rec;
                        x_bom_head_unexp_rec := l_bom_head_unexp_rec;

  END Query_Table_Row;


  /********************************************************************
  * Procedure : Insert_Row
  * Parameters IN : BOM Header exposed column record
  *     BOM Header unexposed column record
  * Parameters OUT: Message Token Table
  *     Return Status
  * Purpose : Procedure will perfrom an insert into the
  *     BOM_Bill_Of_Materials table thus creating a new bill
  *********************************************************************/
  PROCEDURE Insert_Row
        (  p_bom_header_rec IN  BOM_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_mesg_token_Tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status  IN OUT NOCOPY VARCHAR2
         )
  IS
      l_preferred_flag Varchar2(1);
      l_effectivity_control NUMBER;
      x_err_text   varchar2(2000);
  BEGIN

       IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Writing Bom Header rec for ' || p_bom_header_rec.assembly_item_name); END IF;

       l_effectivity_control :=  get_effectivity_control
                          (p_bom_head_unexp_rec.assembly_item_id,
                           p_bom_head_unexp_rec.organization_id);
       l_preferred_flag := BOM_Validate.Is_Preferred_Structure
                        (p_assembly_item_id =>p_bom_head_unexp_rec.assembly_item_id,
                         p_organization_id => p_bom_head_unexp_rec.organization_Id,
                         p_alternate_bom_code => p_bom_header_rec.alternate_bom_code,
                         x_err_text => x_err_text);

    --bug:3254815 Update request id, prog id, prog appl id and prog update date.
    INSERT INTO bom_bill_of_materials
    (  assembly_item_id
     , organization_id
     , alternate_bom_designator
     , common_assembly_item_id
     , common_organization_id
     , assembly_type
     , bill_sequence_id
     , common_bill_sequence_id
                 , specific_assembly_comment  -- Added on 05/31/01
                 , original_system_reference  -- Added on 05/31/01
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
     , structure_type_id
     , implementation_date
     , effectivity_control
     , Obj_Name
     , pk1_value
     , pk2_value
     , is_preferred
     , source_bill_sequence_id
     , request_id
     , program_id
     , program_application_id
     , program_update_date
     )
    VALUES
    (  p_bom_head_unexp_rec.assembly_item_id
     , p_bom_head_unexp_rec.organization_id
     , DECODE(p_bom_header_rec.alternate_bom_code,
        FND_API.G_MISS_CHAR,
        NULL,
        p_bom_header_rec.alternate_bom_code)
     , DECODE(p_bom_head_unexp_rec.common_bill_sequence_id,
        FND_API.G_MISS_NUM,
        NULL,
        p_bom_head_unexp_rec.bill_sequence_id,
        NULL,
        p_bom_head_unexp_rec.common_assembly_item_id
        )
     , DECODE(p_bom_head_unexp_rec.common_bill_sequence_id,
        FND_API.G_MISS_NUM,
        NULL,
        p_bom_head_unexp_rec.bill_sequence_id,
        NULL,
        p_bom_head_unexp_rec.common_organization_id
        )
     ,  p_bom_header_rec.Assembly_Type /* Assembly Type */
     , p_bom_head_unexp_rec.bill_sequence_id
     , DECODE(p_bom_head_unexp_rec.common_bill_sequence_id,
        FND_API.G_MISS_NUM,
        p_bom_head_unexp_rec.bill_sequence_id,
        NULL,
        p_bom_head_unexp_rec.bill_sequence_id,
        p_bom_head_unexp_rec.common_bill_sequence_id
        )
                 , DECODE(p_bom_header_rec.assembly_comment,
                          FND_API.G_MISS_CHAR,
                          NULL,
                          p_bom_header_rec.assembly_comment)
                 , DECODE(p_bom_header_rec.original_system_reference,
                          FND_API.G_MISS_CHAR,
                          NULL,
                          p_bom_header_rec.original_system_reference)
     , p_bom_header_rec.attribute_category
     , p_bom_header_rec.attribute1
     , p_bom_header_rec.attribute2
                 , p_bom_header_rec.attribute3
                 , p_bom_header_rec.attribute4
                 , p_bom_header_rec.attribute5
                 , p_bom_header_rec.attribute6
     , p_bom_header_rec.attribute7
                 , p_bom_header_rec.attribute8
                 , p_bom_header_rec.attribute9
                 , p_bom_header_rec.attribute10
                 , p_bom_header_rec.attribute11
                 , p_bom_header_rec.attribute12
                 , p_bom_header_rec.attribute13
                 , p_bom_header_rec.attribute14
                 , p_bom_header_rec.attribute15
     , SYSDATE
     , BOM_Globals.Get_User_Id
     , SYSDATE
     , BOM_Globals.Get_User_Id
     , BOM_Globals.Get_User_Id
     , p_bom_head_unexp_rec.structure_type_id
     , p_bom_header_rec.bom_implementation_date
     , l_effectivity_control
     , NULL
     , p_bom_head_unexp_rec.assembly_item_id
     , p_bom_head_unexp_rec.organization_id
     , decode ( l_preferred_flag, 'N',null,'Y')
--     , p_bom_head_unexp_rec.source_bill_sequence_id
     , DECODE(p_bom_head_unexp_rec.source_bill_sequence_id,
        FND_API.G_MISS_NUM,
        p_bom_head_unexp_rec.bill_sequence_id,
        NULL,
        p_bom_head_unexp_rec.bill_sequence_id,
        p_bom_head_unexp_rec.source_bill_sequence_id
        )

     , Fnd_Global.Conc_Request_Id
     , Fnd_Global.Conc_Program_Id
     , Fnd_Global.Prog_Appl_Id
     , sysdate
    );
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
    WHEN OTHERS THEN
                  IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Oracle Error in Writing Bom Header rec ' || to_char(sqlcode)||'/'||sqlerrm); END IF;
                  IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('The mandatory values are, Assembly_item_id : ' ||to_char(p_bom_head_unexp_rec.assembly_item_id)); END IF;
      IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Bill_Sequence_Id : '||to_char(p_bom_head_unexp_rec.bill_sequence_id)||'. User Id : '||to_char(Bom_Globals.Get_User_Id)); END IF;
      Error_Handler.Add_Error_Token
      (  p_message_name => NULL
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
        (  p_bom_header_rec     IN  BOM_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         )
        IS

  -- Added for bug 8208327
	CURSOR c_CheckCommon IS
	SELECT NVL(common_bill_sequence_id,bill_sequence_id) common_bill_seq,
		bill_sequence_id
	FROM bom_bill_of_materials
	WHERE bill_sequence_id =  p_bom_head_unexp_rec.bill_sequence_id;

	l_is_common_bom BOOLEAN := FALSE;
	-- End Added for bug 8208327

        BEGIN

                --
                -- The only fields that are updateable in BOM Header is the
                -- common bill information
                --
    IF Bom_Globals.Get_Debug = 'Y' THEN
            Error_Handler.Write_Debug('Updating bill seq ' || p_bom_head_unexp_rec.bill_sequence_id);
    END IF;

      -- Added for bug 8208327
      -- Check if current BOM is a common bom
      FOR CheckCommon IN c_CheckCommon
	 LOOP
	       IF CheckCommon.common_bill_seq <> CheckCommon.bill_sequence_id
		 THEN
		     l_is_common_bom := TRUE;
	       END IF;

      END LOOP;
      --If bom is common bom, then do not update commmon_assembly_item_id, common_organization_id,
      --and common_bill_sequence_id.

      IF l_is_common_bom = TRUE THEN
	       UPDATE bom_bill_of_materials
		    SET specific_assembly_comment =
			  DECODE(p_bom_header_rec.assembly_comment,
				 FND_API.G_MISS_CHAR,
				 NULL,
				 p_bom_header_rec.assembly_comment
				 )
		      , original_system_reference =
			  DECODE(p_bom_header_rec.original_system_reference,
				 FND_API.G_MISS_CHAR,
				 NULL,
				 p_bom_header_rec.original_system_reference
				 )
		      , last_update_date =  SYSDATE
		      , last_updated_by = BOM_Globals.Get_User_Id
		      , last_update_login = BOM_Globals.Get_User_Id
		      , attribute_category = p_bom_header_rec.attribute_category
		      , attribute1 = p_bom_header_rec.attribute1
		      , attribute2 = p_bom_header_rec.attribute2
		      , attribute3 = p_bom_header_rec.attribute3
		      , attribute4 = p_bom_header_rec.attribute4
		      , attribute5 = p_bom_header_rec.attribute5
		      , attribute6 = p_bom_header_rec.attribute6
		      , attribute7 = p_bom_header_rec.attribute7
		      , attribute8 = p_bom_header_rec.attribute8
		      , attribute9 = p_bom_header_rec.attribute9
		      , attribute10= p_bom_header_rec.attribute10
		      , attribute11= p_bom_header_rec.attribute11
		      , attribute12= p_bom_header_rec.attribute12
		      , attribute13= p_bom_header_rec.attribute13
		      , attribute14= p_bom_header_rec.attribute14
		      , attribute15= p_bom_header_rec.attribute15
		      , request_id = Fnd_Global.Conc_Request_Id
		      , program_id = Fnd_Global.Conc_Program_Id
		      , program_application_id = Fnd_Global.Prog_Appl_Id
		      , program_update_date = sysdate
		   WHERE bill_sequence_id = p_bom_head_unexp_rec.bill_sequence_id;


	      --If bom is not a common bom, then update commmon_assembly_item_id, common_organization_id,
	      --and common_bill_sequence_id.
	ELSE

                UPDATE bom_bill_of_materials
                   SET common_assembly_item_id =
                         DECODE(p_bom_head_unexp_rec.common_assembly_item_id,
                                FND_API.G_MISS_NUM,
                                null,
                                p_bom_head_unexp_rec.common_assembly_item_id
                                )
                     , common_organization_id =
                         DECODE(p_bom_head_unexp_rec.common_organization_id,
                                FND_API.G_MISS_NUM,
                                null,
                                p_bom_head_unexp_rec.common_organization_id
                                )
                     , common_bill_sequence_id =
                         DECODE(p_bom_head_unexp_rec.common_bill_sequence_id,
                                FND_API.G_MISS_NUM,
                                p_bom_head_unexp_rec.bill_sequence_id,
                                NULL,
                                p_bom_head_unexp_rec.bill_sequence_id,
                                p_bom_head_unexp_rec.common_bill_sequence_id
                                )
                     , specific_assembly_comment =
                         DECODE(p_bom_header_rec.assembly_comment,
                                FND_API.G_MISS_CHAR,
                                NULL,
                                p_bom_header_rec.assembly_comment
                                )
                     , original_system_reference =
                         DECODE(p_bom_header_rec.original_system_reference,
                                FND_API.G_MISS_CHAR,
                                NULL,
                                p_bom_header_rec.original_system_reference
                                )
                     , source_bill_sequence_id =
                         DECODE(p_bom_head_unexp_rec.source_bill_sequence_id,
                                FND_API.G_MISS_NUM,
                                p_bom_head_unexp_rec.bill_sequence_id,
                                NULL,
                                p_bom_head_unexp_rec.bill_sequence_id,
                                p_bom_head_unexp_rec.source_bill_sequence_id
                                )
                     , last_update_date =  SYSDATE
                     , last_updated_by = BOM_Globals.Get_User_Id
                     , last_update_login = BOM_Globals.Get_User_Id
                     , attribute_category = p_bom_header_rec.attribute_category
                     , attribute1 = p_bom_header_rec.attribute1
                     , attribute2 = p_bom_header_rec.attribute2
                     , attribute3 = p_bom_header_rec.attribute3
                     , attribute4 = p_bom_header_rec.attribute4
                     , attribute5 = p_bom_header_rec.attribute5
                     , attribute6 = p_bom_header_rec.attribute6
                     , attribute7 = p_bom_header_rec.attribute7
                     , attribute8 = p_bom_header_rec.attribute8
                     , attribute9 = p_bom_header_rec.attribute9
                     , attribute10= p_bom_header_rec.attribute10
                     , attribute11= p_bom_header_rec.attribute11
                     , attribute12= p_bom_header_rec.attribute12
                     , attribute13= p_bom_header_rec.attribute13
                     , attribute14= p_bom_header_rec.attribute14
                     , attribute15= p_bom_header_rec.attribute15
                     , request_id = Fnd_Global.Conc_Request_Id
                     , program_id = Fnd_Global.Conc_Program_Id
                     , program_application_id = Fnd_Global.Prog_Appl_Id
                     , program_update_date = sysdate
                     , structure_type_id =
                         DECODE(p_bom_head_unexp_rec.structure_type_id,
                                FND_API.G_MISS_NUM,
                                structure_type_id,
                                NULL,
                                structure_type_id,
                                p_bom_head_unexp_rec.structure_type_id
                                )
                  WHERE bill_sequence_id = p_bom_head_unexp_rec.bill_sequence_id
                     ;
     END IF;
     -- End Added for bug 8208327

  END Update_Row;


        /********************************************************************
        * Procedure     : Delete_Row
        * Parameters IN : BOM Header exposed column record
        *                 BOM Header unexposed column record
        * Parameters OUT: Message Token Table
        *                 Return Status
        * Purpose       : Procedure will perfrom an Delete from the
        *                 BOM_Bill_Of_Materials by creating a delete Group.
        *********************************************************************/
        PROCEDURE Delete_Row
        (  p_bom_header_rec     IN  BOM_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
         , x_mesg_token_Tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_return_Status      IN OUT NOCOPY VARCHAR2
         )
        IS
    Cursor CheckGroup is
        SELECT description,
                   delete_group_sequence_id,
                   delete_type
             FROM bom_delete_groups
              WHERE delete_group_name = p_bom_header_rec.delete_group_name
          AND organization_id = p_bom_head_unexp_rec.organization_id;
    l_bom_head_unexp_rec  Bom_bo_Pub.Bom_Head_Unexposed_Rec_Type :=
          p_bom_head_unexp_rec;
    l_bom_header_rec      Bom_bo_Pub.Bom_Head_Rec_Type :=
          p_bom_header_rec;
    l_dg_sequence_id  NUMBER;
    l_mesg_token_tbl  Error_Handler.Mesg_Token_Tbl_Type;
    l_assembly_type  NUMBER;


        BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR DG IN CheckGroup
    LOOP
      IF DG.delete_type <> 2 /* Bill */ then
              Error_Handler.Add_Error_Token
        (  p_message_name =>
            'BOM_DUPLICATE_DELETE_GROUP'
         , p_mesg_token_tbl =>
          l_mesg_token_Tbl
         , x_mesg_token_tbl =>
          l_mesg_token_tbl
         );
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_mesg_token_tbl := l_mesg_token_tbl;
        RETURN;
      END IF;

      l_bom_head_unexp_rec.DG_Sequence_Id :=
        DG.delete_group_sequence_id;
      l_bom_header_rec.DG_Description := DG.description;

    END LOOP;

    IF l_bom_head_unexp_rec.DG_Sequence_Id <> FND_API.G_MISS_NUM
    THEN
      l_dg_sequence_id := l_bom_head_unexp_rec.DG_Sequence_Id;
    ELSE
      l_dg_sequence_id := NULL;
      Error_Handler.Add_Error_Token
       (  p_message_name => 'NEW_DELETE_GROUP'
                          , p_mesg_token_tbl => l_mesg_token_Tbl
                          , x_mesg_token_tbl => l_mesg_token_tbl
        , p_message_type   => 'W' /* Warning */
                         );
    END IF;

 --bug 5199643
   select assembly_type into l_assembly_type
   from bom_structures_b
   where bill_sequence_id =l_bom_head_unexp_rec.bill_sequence_id;

    l_dg_sequence_id :=
    MODAL_DELETE.DELETE_MANAGER
    (  new_group_seq_id        => l_dg_sequence_id,
                   name                    => l_bom_header_rec.Delete_Group_Name,
                   group_desc              => l_bom_header_rec.dg_description,
                   org_id                  => l_bom_head_unexp_rec.organization_id,
                   bom_or_eng              => l_assembly_type /* dg type should be same as bill type */,
                   del_type                => 2 /* Bill */,
                   ent_bill_seq_id         => l_bom_head_unexp_rec.bill_sequence_id,
                   ent_rtg_seq_id          => NULL,
                   ent_inv_item_id         => l_bom_head_unexp_rec.assembly_item_id,
                   ent_alt_designator      => l_bom_header_rec.alternate_bom_code,
                   ent_comp_seq_id         => NULL,
                   ent_op_seq_id           => NULL,
                   user_id                 => BOM_Globals.Get_User_Id
    );

    x_mesg_token_tbl := l_mesg_token_tbl;

        END Delete_Row;

  /*********************************************************************
  * Procedure : Perform_Writes
  * Parameters IN : BOM Header Exposed Column Record
  *     BOM Header Unexposed column record
  * Parameters OUT: Messgae Token Table
  *     Return Status
  * Purpose : This is the only procedure that the user will have
  *     access to when he/she needs to perform any kind of
  *     writes to the bom_bill_of_materials table.
  *********************************************************************/
  PROCEDURE Perform_Writes
  (  p_bom_header_rec IN  Bom_Bo_Pub.Bom_Head_Rec_Type
   , p_bom_head_unexp_rec IN  Bom_Bo_Pub.Bom_Head_Unexposed_Rec_Type
   , x_mesg_token_tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
   , x_return_status  IN OUT NOCOPY VARCHAR2
  )
  IS
    l_Mesg_Token_tbl  Error_Handler.Mesg_Token_Tbl_Type;
    l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_bom_header_rec.transaction_type = BOM_GLOBALS.G_OPR_CREATE
    THEN
      Insert_Row
      (  p_bom_header_rec => p_bom_header_rec
       , p_bom_head_unexp_rec => p_bom_head_unexp_rec
       , x_mesg_token_Tbl => l_mesg_token_tbl
       , x_return_Status  => l_return_status
       );
    ELSIF p_bom_header_rec.transaction_type =
              BOM_GLOBALS.G_OPR_UPDATE
    THEN
      Update_Row
      (  p_bom_header_rec => p_bom_header_rec
       , p_bom_head_unexp_rec => p_bom_head_unexp_rec
       , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );

    ELSIF p_bom_header_rec.transaction_type =
              BOM_GLOBALS.G_OPR_DELETE
    THEN
      Delete_Row
      (  p_bom_header_rec => p_bom_header_rec
       , p_bom_head_unexp_rec => p_bom_head_unexp_rec
                         , x_mesg_token_Tbl     => l_mesg_token_tbl
                         , x_return_Status      => l_return_status
                         );
    END IF;

    x_return_status := l_return_status;
    x_mesg_token_tbl := l_mesg_token_tbl;

  END Perform_Writes;


  FUNCTION get_effectivity_control ( item_id NUMBER, org_id NUMBER) return NUMBER is

   l_eff_control  NUMBER;
   BEGIN
   select effectivity_control into l_eff_control
    from mtl_system_items_b
    where inventory_item_id = item_id
    and organization_id = org_id;
   return l_eff_control;
  END;
END Bom_Bom_Header_Util;

/
