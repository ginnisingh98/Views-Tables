--------------------------------------------------------
--  DDL for Package Body BOM_VALIDATE_RTG_REVISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_VALIDATE_RTG_REVISION" AS
/* $Header: BOMLRRVB.pls 120.0.12000000.2 2007/02/27 15:42:48 earumuga ship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMLRRVB.pls
--
--  DESCRIPTION
--
--      Body of package BOM_Validate_Rtg_Revision
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00 Biao Zhang Initial Creation
--  22-DEC-00 Lochan Narvekar Modification
--
****************************************************************************/
        G_Pkg_Name      VARCHAR2(30) := 'BOM_Validate_Rtg_Revision';
        g_token_tbl     Error_Handler.Token_Tbl_Type;


        /*******************************************************************
        * Procedure     : Check_Existence
        * Returns       : None
        * Parameters IN : Rtg Revision Exposed Record
        *                 Rtg Revision Unexposed Record
        * Parameters out: Old Rtg Revision exposed Record
        *                 Old Rtg Revision Unexposed Record
        *                 Mesg Token Table
        *                 Return Status
        * Purpose       : Procedure will query the routing revision
        *                 record and return it in old record variables. If the
        *                 Transaction Type is Create and the record already
        *                 exists the return status would be error or if the
        *                 transaction type is Update or Delete and the record
        *                 does not exist then the return status would be an
        *                 error as well. Mesg_Token_Table will carry the
        *                 error messsage and the tokens associated with the
        *                 message.
        *********************************************************************/
      PROCEDURE Check_Existence
      (  p_rtg_revision_rec      IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
       , p_rtg_rev_unexp_rec     IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
       , x_old_rtg_revision_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Rec_Type
       , x_old_rtg_rev_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
       , x_Mesg_Token_Tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status         IN OUT NOCOPY VARCHAR2
      )
      IS
         l_token_tbl      Error_Handler.Token_Tbl_Type;
         l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type;
         l_return_status  VARCHAR2(1);
      BEGIN

        IF BOM_Rtg_Globals.Get_Debug = 'Y'
         THEN Error_Handler.Write_Debug('Quering Assembly item '
                 || to_char(p_rtg_rev_unexp_rec.assembly_item_id));
        END IF;

        IF BOM_Rtg_Globals.Get_Debug = 'Y'
        THEN Error_Handler.Write_Debug(' Org: '
             || to_char(p_rtg_rev_unexp_rec.organization_id)) ;
        END IF;

        IF BOM_Rtg_Globals.Get_Debug = 'Y'
         THEN Error_Handler.Write_Debug('Revision'
                 || p_rtg_revision_rec.revision );
        END IF;

        Bom_Rtg_Revision_Util.Query_Row
                (  p_assembly_item_id   =>
                        p_rtg_rev_unexp_rec.assembly_item_id
                 , p_organization_id    =>
                        p_rtg_rev_unexp_rec.organization_id
                 , p_revision           =>  p_rtg_revision_rec.revision
                 , x_rtg_revision_rec   => x_old_rtg_revision_rec
                 , x_rtg_rev_unexp_rec => x_old_rtg_rev_unexp_rec
                 , x_return_status      => l_return_status
                 );
        IF BOM_Rtg_Globals.Get_Debug = 'Y'
        THEN Error_Handler.Write_Debug('Query Row Returned with : '
                                         || l_return_status); END IF;

        IF l_return_status = BOM_Rtg_Globals.G_RECORD_FOUND AND
        p_rtg_revision_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
        THEN
          l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
          l_token_tbl(1).token_value :=
          p_rtg_revision_rec.assembly_item_name;
          l_token_tbl(2).token_name  := 'REVISION';
          l_token_tbl(2).token_value :=
          p_rtg_revision_rec.revision;
          Error_Handler.Add_Error_Token
          (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name  => 'BOM_RTG_REV_ALREADY_EXISTS'
             , p_token_tbl     => l_token_tbl
          );
          l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_return_status = BOM_Rtg_Globals.G_RECORD_NOT_FOUND AND
        p_rtg_revision_rec.transaction_type IN
        (BOM_RTG_Globals.G_OPR_UPDATE, BOM_Rtg_Globals.G_OPR_DELETE)
        THEN
          l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
          l_token_tbl(1).token_value := p_rtg_revision_rec.assembly_item_name;
          l_token_tbl(2).token_name  := 'REVISION';
          l_token_tbl(2).token_value := p_rtg_revision_rec.revision;
          Error_Handler.Add_Error_Token
          (  x_Mesg_token_tbl => l_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
             , p_message_name  => 'BOM_RTG_REV_DOESNOT_EXISTS'
             , p_token_tbl     => l_token_tbl
          );
          l_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF l_Return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
          l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
          l_token_tbl(1).token_value :=
          p_rtg_revision_rec.assembly_item_name;
          l_token_tbl(2).token_name  := 'REVISION';
          l_token_tbl(2).token_value :=
          p_rtg_revision_rec.revision;
          Error_Handler.Add_Error_Token
          (  x_Mesg_token_tbl     => l_Mesg_Token_Tbl
             , p_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
             , p_message_name       => NULL
             , p_message_text       =>
             'Unexpected error while existence verification of ' ||
             'Assembly item revision'||
             p_rtg_revision_rec.assembly_item_name
             , p_token_tbl          => l_token_tbl
          );
          l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS
        THEN
          l_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        x_return_status := l_return_status;
        x_mesg_token_tbl := l_mesg_token_tbl;
      END Check_Existence;


      /********************************************************************
      * Procedure     : Check_Attributes
      * Parameters IN : Revised Item Exposed Column record
      *                 Revised Item Unexposed Column record
      *                 Old Revised Item Exposed Column record
      *                 Old Revised Item unexposed column record
      * Parameters out: Return Status
      *                 Mesg Token Table
      * Purpose       : Check_Attrbibutes procedure will validate every
      *                 revised item attrbiute in its entirety.
      **********************************************************************/
      PROCEDURE Check_Attributes
      (  x_return_status           IN OUT NOCOPY VARCHAR2
       , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , p_rtg_revision_Rec        IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
       , p_rtg_rev_unexp_rec       IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
       , p_old_rtg_revision_rec    IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
       , p_old_rtg_rev_unexp_rec   IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
      )
      IS
        l_err_text              VARCHAR2(2000) := NULL;
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        l_eco VARCHAR2(10):= NULL;
        CURSOR c_created_by_eco IS
        SELECT change_notice
        FROM  mtl_rtg_item_revisions
        WHERE inventory_item_id = p_rtg_rev_unexp_rec.assembly_item_id
        AND organization_id = p_rtg_rev_unexp_rec.organization_id
        AND process_revision = p_rtg_revision_rec.revision;

      BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
          Error_Handler.Write_Debug(
          'Within Rtg Revision Check Attributes . . . ');
          Error_Handler.Write_Debug(
          'transaction_type:'||p_rtg_revision_rec.transaction_type);
          Error_Handler.Write_Debug(
          'change_notice:'||p_rtg_rev_unexp_rec.change_notice);
        END IF;

        IF  p_rtg_revision_rec.transaction_type= BOM_Rtg_Globals.G_OPR_UPDATE
        THEN
          open c_created_by_eco;
          fetch  c_created_by_eco into l_eco;
          close c_created_by_eco;
          IF l_eco IS NOT NULL AND l_eco <> FND_API.G_MISS_CHAR THEN
            IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
              Error_Handler.Write_Debug(
              'Within Rtg Revision Check Attributes 1. . . ');
            END IF;

            IF p_rtg_revision_rec.start_effective_date IS NOT NULL
            AND p_rtg_revision_rec.start_effective_date <>
            FND_API.G_MISS_DATE THEN
              IF BOM_Rtg_Globals.Get_Debug = 'Y' THEN
                Error_Handler.Write_Debug
                   ('Within Rtg Revision Check Attributes 2. . . ');
              END IF;

              l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
              l_token_tbl(1).token_value :=
              p_rtg_revision_rec.assembly_item_name;
              l_token_tbl(2).token_name  := 'REVISION';
              l_token_tbl(2).token_value :=
              p_rtg_revision_rec.revision;
              l_token_tbl(2).token_name  := 'START_EFFECITVE_DATE';
              l_token_tbl(2).token_value :=
              p_rtg_revision_rec.start_effective_date;
              Error_Handler.Add_Error_Token
              (  p_message_name  =>
                 'BOM_RTG_REV_EFFDT_NT_UPDATABLE'
                 , p_token_tbl     => l_token_tbl
                 , p_mesg_token_tbl     => l_mesg_token_tbl
                 , x_mesg_token_tbl     => l_mesg_token_tbl
               );
               x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
           END IF;-- if eco is NOT NULL
         END IF;
         x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;

       END Check_Attributes;


       /********************************************************************
       * Procedure     : Check_Entity
       * Parameters IN : Rtg Revision Exposed column record
       *                 Rtg Revision Unexposed column record
       *                 Old Rtg Revision exposed column record
       *                 Old Rtg Revision unexposed column record
       * Parameters out: Message Token Table
       *                 Return Status
       * Purpose       : This procedure will perform the business logic
       *                 validation for the RTG Revision Entity.It will perform
       *                 any cross entity validations and make sure that the
       *                 user is not entering values which may disturb the
       *                 integrity of the data.
       *********************************************************************/
       PROCEDURE Check_Entity
       ( p_rtg_revision_rec      IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
       , p_rtg_rev_unexp_rec     IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
       , p_old_rtg_revision_rec  IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
       , p_old_rtg_rev_unexp_rec IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
       , x_mesg_token_tbl        IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
       , x_return_status         IN OUT NOCOPY VARCHAR2
       )
       IS
         CURSOR c_Get_Revision IS
         SELECT process_revision
         FROM mtl_rtg_item_revisions
         WHERE inventory_item_id = p_rtg_rev_unexp_rec.assembly_item_id
         AND organization_id = p_rtg_rev_unexp_rec.organization_id
         AND effectivity_date <= sysdate  --added by arudresh, bug: 3756380
	 AND IMPLEMENTATION_DATE IS NOT NULL
         ORDER BY effectivity_date desc, process_revision desc;

         l_current_rev      VARCHAR2(3);
         l_effectivity_date DATE;
         l_token_tbl        Error_Handler.Token_Tbl_Type;
         l_Mesg_Token_Tbl   Error_Handler.Mesg_Token_Tbl_Type;
         l_dummy            NUMBER;
       BEGIN

        --
        -- For CREATE type, do the following check.
        --

        l_token_tbl(1).token_name  := 'ASSEMBLY_ITEM_NAME';
        l_token_tbl(1).token_value := p_rtg_revision_rec.assembly_item_name;
        l_token_tbl(2).token_name  := 'REVISION';
        l_token_tbl(2).token_value := p_rtg_revision_rec.revision;


        IF p_rtg_revision_rec.transaction_type = BOM_Rtg_Globals.G_OPR_CREATE
        THEN

        --
        -- Revision name is not allowed to use 'Quote'.
        --

          IF INSTR(p_rtg_revision_Rec.revision, '''') <> 0 THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

            Error_Handler.Add_Error_Token
            (  p_mesg_token_tbl => l_mesg_token_tbl
              ,x_mesg_token_tbl => l_mesg_token_tbl
              ,p_message_name   => 'BOM_RTG_REV_QUOTE_NOT_ALLOWED'
              ,p_token_tbl      => l_token_tbl
            );

          END IF;


        --  Check if the user has entered a revision that
        --  is greater tha the most current revision. If not then it is an error        --
	 IF (nvl(Bom_Globals.get_caller_type(),'') <> 'MIGRATION')
	--skip this check for migration bug: 3756380
	 THEN
          OPEN c_Get_Revision;
          FETCH  c_Get_Revision INTO l_current_rev;
          IF (l_current_rev is not null and
              p_rtg_revision_rec.revision <= l_current_rev)
          THEN
            l_token_tbl(3).token_name := 'CURRENT_REVISION';
            l_token_tbl(3).token_value := l_current_rev;
            Error_Handler.Add_Error_Token
            (  p_message_name       => 'BOM_NEXT_REVISION'
             , p_mesg_token_tbl     => l_mesg_token_tbl
             , x_mesg_token_tbl     => l_mesg_token_tbl
             , p_token_tbl          => l_token_tbl
            );
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_token_tbl.delete(3);
          END IF;
	 END IF;

        --
        -- If the user is attempting to create a new revision, then the
        -- routing for the item must exist for the user to be able to
        -- create a revision through BOM
        --
          BEGIN
            SELECT routing_sequence_id
            INTO l_dummy
            FROM bom_operational_routings
            WHERE assembly_item_id = p_rtg_rev_Unexp_Rec.assembly_item_id
            AND organization_id  =  p_rtg_rev_Unexp_Rec.organization_id
            AND nvl(alternate_routing_designator,'A') =
            nvl(p_rtg_revision_rec.alternate_routing_code,'A');
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            l_token_tbl.delete(2) ;

            Error_Handler.Add_Error_Token
            ( p_mesg_token_tbl       => l_mesg_token_tbl
              ,x_mesg_token_tbl       => l_mesg_token_tbl
              ,p_message_name         => 'BOM_RTG_REV_RTG_MISS'
              ,p_token_tbl            => l_token_tbl
            );

            l_token_tbl(2).token_name  := 'REVISION';
            l_token_tbl(2).token_value := p_rtg_revision_rec.revision;

          END;

         --
         -- For CREATE, revision must be unique.
         --
          BEGIN
            SELECT 1
            INTO l_dummy
            FROM dual
            WHERE not exists
            (SELECT 1
            FROM mtl_rtg_item_revisions
            WHERE organization_id = p_rtg_rev_Unexp_Rec.Organization_Id
            AND inventory_item_id = p_rtg_rev_Unexp_Rec.assembly_Item_Id
            AND process_revision  = p_rtg_revision_Rec.revision
            );

          EXCEPTION
            WHEN NO_DATA_FOUND then
            x_return_status := FND_API.G_RET_STS_ERROR;

            Error_Handler.Add_Error_Token
            (  p_mesg_token_tbl       => l_mesg_token_tbl
              ,x_mesg_token_tbl       => l_mesg_token_tbl
              ,p_message_name         => 'BOM_RTG_REV_NOT_UNIQUE'
              ,p_token_tbl            => l_token_tbl
            );
          END;
        END IF;

        -- If the user is attempting to create or update effective date of the
        -- revision and the date is less than the current date then it should
        -- get an error.
        IF ( p_rtg_revision_rec.transaction_type =
             BOM_Rtg_Globals.G_OPR_CREATE AND
	     nvl(Bom_Globals.get_caller_type(),'') <> 'MIGRATION' AND     -- bug 2871039
             TRUNC(NVL(p_rtg_revision_rec.start_effective_date, SYSDATE))
             < TRUNC(SYSDATE)
           ) OR
           (  p_rtg_revision_rec.transaction_type =
              BOM_Rtg_Globals.G_OPR_UPDATE AND
              p_old_rtg_revision_Rec.start_effective_date <>
              p_rtg_revision_rec.start_effective_date AND
              TRUNC(NVL(p_rtg_revision_rec.start_effective_date,SYSDATE))
              < TRUNC(SYSDATE)
           )
        THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_token_tbl(3).token_name := 'START_EFFECTIVE_DATE';
          l_token_tbl(3).token_value :=
          to_char(p_rtg_revision_rec.start_effective_date);
          Error_Handler.Add_Error_Token
          (  p_message_name       => 'BOM_RTG_REV_START_DT_LESS_CURR'
           , p_mesg_token_tbl     => l_mesg_token_tbl
           , x_mesg_token_tbl     => l_mesg_token_tbl
           , p_token_tbl          => l_token_tbl
          );
           l_token_tbl.delete(3) ;
        END IF;

        --
        -- Start effective date can not lie between the effective date of an
        -- existing revision.
        --
        IF p_rtg_revision_rec.transaction_type <> BOM_Rtg_Globals.G_OPR_DELETE
        THEN
        BEGIN
          SELECT 1
          INTO l_dummy
          FROM dual
          WHERE p_rtg_revision_rec.start_effective_date >
          (SELECT nvl(max(effectivity_date),
          p_rtg_revision_rec.start_effective_Date-1)
          FROM  mtl_rtg_item_revisions
          WHERE inventory_item_id  = p_rtg_rev_Unexp_Rec.assembly_Item_Id
          AND   organization_id    = p_rtg_rev_Unexp_Rec.Organization_Id
          AND   process_revision  < p_rtg_revision_rec.Revision
          )
          AND p_rtg_revision_rec.start_effective_date <
          (SELECT nvl(min(effectivity_date),
          p_rtg_revision_rec.start_effective_Date+1)
          FROM mtl_rtg_item_revisions
          WHERE inventory_item_id =p_rtg_rev_Unexp_Rec.assembly_Item_Id
          AND organization_id   = p_rtg_rev_Unexp_Rec.Organization_Id
          AND process_revision  > p_rtg_revision_rec.Revision
          );
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          l_token_tbl(3).token_name := 'START_EFFECTIVE_DATE';
          l_token_tbl(3).token_value :=
          to_char(p_rtg_revision_rec.start_effective_date);

          Error_Handler.Add_Error_Token
          (  p_message_name       => 'BOM_RTG_REV_START_DATE_INVALID'
             , p_mesg_token_tbl     => l_mesg_token_tbl
             , x_mesg_token_tbl     => l_mesg_token_tbl
             , p_token_tbl          => l_token_tbl
          );
          l_token_tbl.delete(3) ;
        END;
        END IF;

        IF p_rtg_revision_rec.transaction_type = BOM_Rtg_Globals.G_OPR_DELETE
        THEN
          SELECT effectivity_date into l_effectivity_date
          FROM mtl_rtg_item_revisions
          WHERE inventory_item_id =p_rtg_rev_Unexp_Rec.assembly_Item_Id
          AND organization_id   = p_rtg_rev_Unexp_Rec.Organization_Id
          AND process_revision  = p_rtg_revision_rec.Revision;
          IF trunc( l_effectivity_date) <= trunc(SYSDATE)
          THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            Error_Handler.Add_Error_Token
            (  p_message_name       => 'BOM_RTG_REV_CANNOT_DELETE'
             , p_mesg_token_tbl     => l_mesg_token_tbl
             , x_mesg_token_tbl     => l_mesg_token_tbl
             , p_token_tbl          => l_token_tbl
            );
          END IF;

        END IF;

      x_mesg_token_tbl := l_mesg_token_tbl;

    END Check_Entity;


END BOM_Validate_Rtg_Revision;

/
