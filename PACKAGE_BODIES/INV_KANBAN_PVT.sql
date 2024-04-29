--------------------------------------------------------
--  DDL for Package Body INV_KANBAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_KANBAN_PVT" as
/* $Header: INVVKBNB.pls 120.11.12010000.7 2010/03/08 07:46:33 ksaripal ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_KANBAN_PVT';
TYPE Kanban_Card_Tbl_Type IS TABLE OF INV_Kanban_PVT.Kanban_Card_Rec_Type
    INDEX BY BINARY_INTEGER;


PROCEDURE mydebug(msg IN VARCHAR2) IS
BEGIN
   inv_log_util.trace(msg, 'INV_KANBAN_PVT', 9);
END mydebug;


--
--
--
--  Get_Constants : This procedure returns the server side global variables.
--                  Client side can have access to these global variables by
--                  calling this procedure.
--
Procedure Get_Constants
(X_Ret_Success                  Out NOCOPY Varchar2,
 X_Ret_Error                    Out NOCOPY Varchar2 ,
 X_Ret_Unexp_Error              Out NOCOPY Varchar2 ,
 X_Current_Plan                 Out NOCOPY Number,
 X_Source_Type_InterOrg         Out NOCOPY Number,
 X_Source_Type_Supplier         Out NOCOPY Number,
 X_Source_Type_IntraOrg         Out NOCOPY Number,
 X_Source_Type_Production       Out NOCOPY Number,
 X_Card_Type_Replenishable      Out NOCOPY Number,
 X_Card_Type_NonReplenishable   Out NOCOPY Number,
 X_Card_Status_Active           Out NOCOPY Number,
 X_Card_Status_Hold             Out NOCOPY Number,
 X_Card_Status_Cancel           Out NOCOPY Number,
 X_No_Pull_sequence             Out NOCOPY Number,
 X_Doc_Type_Po                  Out NOCOPY Number,
 X_Doc_Type_Release             Out NOCOPY Number,
 X_Doc_Type_Internal_Req        Out NOCOPY Number)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

 X_Ret_Success                  := FND_API.G_RET_STS_SUCCESS;
 X_Ret_Error                    := FND_API.G_RET_STS_ERROR;
 X_Ret_Unexp_Error              := FND_API.G_RET_STS_UNEXP_ERROR;
 X_Current_Plan                 := INV_Kanban_PVT.G_Current_Plan;
 X_Source_Type_InterOrg         := INV_Kanban_PVT.G_Source_Type_InterOrg;
 X_Source_Type_Supplier         := INV_Kanban_PVT.G_Source_Type_Supplier;
 X_Source_Type_IntraOrg         := INV_Kanban_PVT.G_Source_Type_IntraOrg;
 X_Source_Type_Production       := INV_Kanban_PVT.G_Source_Type_Production;
 X_Card_Type_Replenishable      := INV_Kanban_PVT.G_Card_Type_Replenishable;
 X_Card_Type_NonReplenishable   := INV_Kanban_PVT.G_Card_Type_NonReplenishable;
 X_Card_Status_Active           := INV_Kanban_PVT.G_Card_Status_Active;
 X_Card_Status_Hold             := INV_Kanban_PVT.G_Card_Status_Hold;
 X_Card_Status_Cancel           := INV_Kanban_PVT.G_Card_Status_Cancel;
 X_No_Pull_sequence             := INV_Kanban_PVT.G_No_Pull_sequence;
 X_Doc_Type_Po                  := INV_Kanban_PVT.G_Doc_Type_Po;
 X_Doc_Type_Release             := INV_Kanban_PVT.G_Doc_Type_Release;
 X_Doc_Type_Internal_Req        := INV_Kanban_PVT.G_Doc_Type_Internal_Req;

End Get_Constants;
--
--
--  Get_Pull_Sequence_Tokens : This procedure gets the names required to
--                             build the message for a pull sequence
--
PROCEDURE Get_Pull_Sequence_Tokens
(p_Pull_Sequence_Id     Number,
 x_org_code         Out NOCOPY varchar2,
 x_item_name        Out NOCOPY varchar2,
 x_subinventory     Out NOCOPY varchar2,
 x_loc_name         Out NOCOPY varchar2)
IS

l_locator_id          number;
l_organization_id     number;
l_org_code            varchar2(3);
l_item_name           varchar2(200);
l_loc_name            varchar2(200);
l_subinventory        varchar2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
        Select concatenated_segments,organization_code,
               subinventory_name,locator_id,pull.organization_id
        into x_item_name,x_org_code,x_subinventory,l_locator_id,
             l_organization_id
        from mtl_system_items_kfv a , mtl_parameters b,
             mtl_kanban_pull_sequences pull
        where a.inventory_item_id   = pull.inventory_item_id
        and   a.organization_id     = Pull.organization_id
        and   b.organization_id     = Pull.organization_id
        and   pull.pull_sequence_id = p_Pull_sequence_id;

        if l_locator_id is not null Then

           Select concatenated_segments
           into x_loc_name
           from mtl_item_locations_kfv
           where inventory_location_id = l_locator_id
           and   organization_id = l_organization_id;

        end if;
Exception

When Others
Then Null;

End Get_Pull_Sequence_Tokens;

--
--
--  Delete_Pull_Sequence : This procedure deletes all pull sequences for
--                         a given plan.
--
--
PROCEDURE Delete_Pull_Sequence
(x_return_status  Out NOCOPY Varchar2,
 p_kanban_plan_id     Number)

IS

Cursor Get_Pull_Sequences IS
Select pull_sequence_id
From mtl_kanban_pull_sequences
Where kanban_plan_id = p_kanban_plan_id;

l_return_status      Varchar2(1) := FND_API.G_RET_STS_SUCCESS;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
        If p_kanban_plan_id = INV_kanban_PVT.G_Current_Plan
        then
                For pull_sequences in get_pull_sequences
                loop
                        If Ok_To_Delete_Pull_Sequence(pull_sequences.pull_sequence_id)
                        then
                                INV_PullSequence_Pkg.delete_Row(l_return_status,pull_sequences.pull_sequence_id);
                        Else
                                Raise FND_API.G_EXC_ERROR;
                        end if;
                end loop;
        Else
                Delete from Mtl_kanban_pull_sequences
                Where kanban_plan_id = p_kanban_plan_id;
        end if;
        x_return_status := l_return_status;

Exception

    WHEN FND_API.G_EXC_ERROR THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Pull_Sequence'
            );
        END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Delete_Pull_Sequence;
--
--
--  Validate_Pull_Sequence : This procedure verifies whether all required
--                           fields are present.
--
--
PROCEDURE Validate_Pull_Sequence
(p_Pull_Sequence_Rec INV_Kanban_PVT.Pull_sequence_Rec_Type)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
        if p_Pull_Sequence_Rec.Organization_Id is null
        then
                FND_MESSAGE.SET_NAME('INV','INV_ORG_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Organization');
                FND_MSG_PUB.Add;
                Raise       FND_API.G_EXC_ERROR;
        End if;

        if p_Pull_Sequence_Rec.inventory_item_id is null
        then
                FND_MESSAGE.SET_NAME('INV','INV_ITEM_REQUIRED');
                FND_MSG_PUB.Add;
                Raise       FND_API.G_EXC_ERROR;
        end if;

        if p_Pull_Sequence_Rec.subinventory_name is null
        then
                FND_MESSAGE.SET_NAME('INV','INV_SUBINV_REQUIRED');
                FND_MSG_PUB.Add;
                Raise       FND_API.G_EXC_ERROR;
        end if;

        if p_Pull_Sequence_Rec.source_type is null
        then
                FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_SOURCE_TYPE',TRUE);
                FND_MSG_PUB.Add;
                Raise       FND_API.G_EXC_ERROR;
        end if;

        if p_Pull_Sequence_Rec.kanban_plan_id is null
        then
                FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_KANBAN_PLAN',TRUE);
                FND_MSG_PUB.Add;
                Raise       FND_API.G_EXC_ERROR;
        end if;

        if p_Pull_Sequence_Rec.source_type = INV_Kanban_PVT.G_Source_type_IntraOrg
        And p_Pull_Sequence_Rec.source_subinventory is null
        then
                FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_SOURCE_SUBINV',TRUE);
                FND_MSG_PUB.Add;
                Raise       FND_API.G_EXC_ERROR;
        end if;

/*Code modification for bug2186198*/
        /*if p_Pull_Sequence_Rec.source_type = INV_Kanban_PVT.G_Source_type_Production
        And p_Pull_Sequence_Rec.wip_line_id is null
        then
                FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_WIP_LINE');
                FND_MSG_PUB.Add;
                Raise       FND_API.G_EXC_ERROR;
        end if; */


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       Raise FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Pull_Sequence'
            );
        END IF;
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

End Validate_Pull_Sequence;
--
--
--  Insert_Pull_Sequence : This procedure inserts record in
--                         MTL_KANBAN_PULL_SEQUENCES with data from the record.
--
--
PROCEDURE Insert_Pull_Sequence
(x_return_status     Out NOCOPY Varchar2,
 p_Pull_Sequence_Rec     INV_Kanban_PVT.Pull_sequence_Rec_Type)
IS
l_Pull_Sequence_Rec   INV_Kanban_PVT.Pull_sequence_Rec_Type;
l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
        FND_MSG_PUB.initialize;
        l_Pull_Sequence_Rec := INV_PullSequence_PKG.Convert_Miss_To_Null
                                (p_Pull_Sequence_Rec);

        Validate_Pull_sequence(l_pull_sequence_rec);

        l_pull_sequence_rec.Creation_Date     := SYSDATE;
        l_pull_sequence_rec.Created_By        := FND_GLOBAL.USER_ID;
        l_pull_sequence_rec.last_update_date  := SYSDATE;
        l_pull_sequence_rec.last_updated_by   := FND_GLOBAL.USER_ID;
        l_pull_sequence_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

        INV_PullSequence_PKG.Insert_Row(l_pull_sequence_rec);

        x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Pull_sequence'
            );
        END IF;

End Insert_Pull_sequence;
--
--
--  Update_Pull_Sequence : This procedure Updates the record in
--                         MTL_KANBAN_PULL_SEQUENCES with data from the
--                         record.
--
--
PROCEDURE Update_Pull_sequence
(x_return_status       Out NOCOPY Varchar2,
 x_Pull_Sequence_Rec   IN OUT NOCOPY INV_Kanban_PVT.Pull_sequence_Rec_Type)
IS
  l_Pull_Sequence_Rec      INV_Kanban_PVT.Pull_Sequence_Rec_Type;
  l_Old_Pull_Sequence_Rec  INV_Kanban_PVT.Pull_Sequence_Rec_Type;
  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_org_code           VARCHAR2(3);
  l_item_name          VARCHAR2(30);
  l_loc_name           VARCHAR2(30);


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
        FND_MSG_PUB.initialize;
        l_Pull_Sequence_Rec := x_Pull_Sequence_Rec;
        l_Pull_Sequence_Rec.pull_sequence_id := Null;

        if (l_pull_Sequence_Rec.pull_sequence_Id is null or
          l_pull_Sequence_Rec.pull_sequence_Id = FND_API.G_MISS_NUM) And
           (l_pull_Sequence_Rec.Kanban_Plan_Id is null or
            l_pull_Sequence_Rec.Kanban_Plan_Id = FND_API.G_MISS_NUM or
            l_pull_Sequence_Rec.Organization_Id is null or
            l_pull_Sequence_Rec.Organization_Id = FND_API.G_MISS_NUM or
            l_pull_Sequence_Rec.Inventory_Item_Id is null or
            l_pull_Sequence_Rec.Inventory_Item_Id  = FND_API.G_MISS_NUM or
            l_pull_Sequence_Rec.Subinventory_Name is null or
            l_pull_Sequence_Rec.Subinventory_Name = FND_API.G_MISS_CHAR )
        then
                FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_PULL_SEQUENCE');
                FND_MSG_PUB.Add;
                l_return_status      := FND_API.G_RET_STS_ERROR;

        elsif (l_pull_Sequence_Rec.pull_sequence_Id is null  or
               l_pull_Sequence_Rec.pull_sequence_Id = FND_API.G_MISS_NUM)
        then
                Begin
                Select Pull_Sequence_Id
                Into l_Pull_Sequence_Rec.Pull_Sequence_Id
                From Mtl_Kanban_Pull_Sequences
                Where Kanban_Plan_Id    = l_pull_Sequence_Rec.Kanban_plan_id
                And   Organization_Id   = l_pull_Sequence_Rec.Organization_Id
                And   Inventory_Item_Id = l_pull_Sequence_Rec.Inventory_Item_Id
                And   Subinventory_Name = l_pull_Sequence_Rec.Subinventory_Name
                And Nvl(Locator_Id,-1) = Nvl(l_pull_Sequence_Rec.Locator_Id,-1);
                Exception
                When No_data_Found
                Then

                        Select concatenated_segments,organization_code
                        into l_item_name,l_org_code
                        from mtl_system_items_kfv a , mtl_parameters b
                        where a.inventory_item_id =
                                l_Pull_Sequence_Rec.inventory_item_id
                        and a.organization_id =
                                l_Pull_Sequence_Rec.organization_id
                        and b.organization_id =
                                l_Pull_Sequence_Rec.organization_id;

                        if l_Pull_Sequence_Rec.locator_id is not null Then

                                Select concatenated_segments
                                into l_loc_name
                                from mtl_item_locations_kfv
                                where inventory_location_id =
                                        l_Pull_Sequence_Rec.locator_id
                                and organization_id =
                                        l_Pull_Sequence_Rec.organization_id;

                        end if;

                        FND_MESSAGE.SET_NAME('INV','INV_NO_PULLSEQ_EXISTS');
                        FND_MESSAGE.SET_TOKEN('ORG_CODE',l_org_code);
                        FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
                        FND_MESSAGE.SET_TOKEN('SUB_CODE',l_Pull_Sequence_Rec.Subinventory_Name);
                        FND_MESSAGE.SET_TOKEN('LOCATOR_NAME',l_loc_name);
                        FND_MSG_PUB.Add;
                        l_return_status      := FND_API.G_RET_STS_ERROR;
                When Others
                Then
                        l_return_status      := FND_API.G_RET_STS_UNEXP_ERROR;
                End;
        end if;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

        END IF;
 -- dbms_output.put_line('pull:'||to_char(l_pull_sequence_rec.pull_sequence_id));

        l_old_pull_sequence_rec := INV_PullSequence_PKG.Query_Row (p_pull_sequence_id  =>
                                l_pull_sequence_rec.pull_sequence_id);
        l_pull_sequence_rec := INV_PullSequence_Pkg.Complete_Record
        (   p_pull_sequence_rec           => l_pull_sequence_rec
        ,   p_old_pull_sequence_rec       => l_old_pull_sequence_rec
        );
        Validate_Pull_sequence(l_Pull_sequence_rec);

        l_pull_sequence_rec.last_update_date := SYSDATE;
        l_pull_sequence_rec.last_updated_by := FND_GLOBAL.USER_ID;
        l_pull_sequence_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

        INV_PullSequence_PKG.Update_Row(l_pull_sequence_Rec);

        x_return_status := l_return_status;

        x_pull_sequence_rec := l_Pull_Sequence_Rec;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Pull_sequence'
            );
        END IF;

End Update_Pull_sequence;
--
--Update_Pull_Sequence_Tbl : This procedure Updates the records in
--                           MTL_KANBAN_PULL_SEQUENCES with data from the
--                           table of pull sequences id's passed to it.
--                           It generates and prints kanban cards as well.
------------------------------------------------------------------------------
-- PROCEDURE : UPDATE_PULL_SEQUENCE_TBL
------------------------------------------------------------------------------
PROCEDURE Update_Pull_sequence_Tbl (x_return_status  Out NOCOPY Varchar2,
                              p_Pull_Sequence_tbl   INV_Kanban_PVT.Pull_sequence_Id_Tbl_Type,
                                x_update_flag       Varchar2,
                              p_operation_tbl   INV_Kanban_PVT.operation_tbl_type := G_operation_tbl)
IS
 l_record_count         NUMBER      := 0;
 l_PullSeqTable         INV_Kanban_PVT.Pull_Sequence_id_Tbl_Type;
 l_report_id            NUMBER   := 0;
 l_return_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 v_req_id               NUMBER;
 v_generate_cards       BOOLEAN := FALSE;
 l_Pull_sequence_rec    INV_Kanban_PVT.Pull_sequence_Rec_Type;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

 l_operation_tbl        INV_Kanban_PVT.operation_tbl_type; --Operation to be performed update/insert
 l_report_generate_id   NUMBER   := 0; --Report id for generating cards
 l_report_print_id      NUMBER   := 0; --Report id for printing cards
 l_count_generate       NUMBER := 0;  --Count of number of cards to be generated
 l_count_print          NUMBER := 0; -- Count of number of cards to be printed
 CURSOR C2 IS SELECT mtl_kanban_pull_sequences_s.nextval FROM sys.dual;
--Get new pull_sequence_id during insert.

Begin
        FND_MSG_PUB.initialize;
        l_PullSeqTable := p_Pull_Sequence_tbl;
        l_operation_tbl:= p_operation_tbl;

        SELECT  MTL_KANBAN_CARD_PRINT_TEMP_S.nextval
        INTO  l_report_generate_id  from  DUAL;

        SELECT  MTL_KANBAN_CARD_PRINT_TEMP_S.nextval
        INTO  l_report_print_id  from  DUAL;

        FOR l_record_count in 1 ..l_PullSeqtable.Count LOOP
        l_pull_sequence_rec := INV_PullSequence_PKG.Query_Row
                                  ( p_pull_sequence_id  =>
                                    l_PullSeqtable(l_record_count));
        l_pull_sequence_rec.kanban_plan_id := -1;
        IF X_UPDATE_FLAG = 'Y' THEN
                v_generate_cards := TRUE;
                IF(l_pull_sequence_rec.planning_update_status = 1) THEN
                                l_pull_sequence_rec.planning_update_status := NULL ;
                                UPDATE mtl_kanban_pull_sequences
                                SET    planning_update_status = NULL
                                WHERE  pull_sequence_id = l_pull_sequence_rec.pull_sequence_id;
                END IF;

                IF (l_operation_tbl.COUNT > 0) THEN
                  IF(l_operation_tbl(l_record_count) = 0 ) THEN
                        INV_Kanban_PVT.update_pull_sequence(
                                l_return_status,
                                l_Pull_sequence_rec);
                  ELSE
                        OPEN C2;
                        FETCH C2 INTO l_Pull_Sequence_Rec.pull_sequence_id;
                        CLOSE C2;

                        INV_Kanban_PVT.insert_pull_sequence(
                        l_return_status,
                        l_Pull_sequence_rec);
                  END IF;

                ELSE
                        -- Existing Functionality
                        INV_Kanban_PVT.update_pull_sequence(
                                l_return_status,
                                l_Pull_sequence_rec);

                END IF; -- end of l_operation_tbl.COUNT > 0 if loop

                -- Check for errors and take action
                IF l_return_status IN ( FND_API.G_RET_STS_ERROR,
                        FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
         ELSE
            IF  INV_kanban_PVT.Ok_To_Create_Kanban_Cards( p_pull_sequence_id  =>
                                                  l_PullSeqtable(l_record_count) )  then
               v_generate_cards := TRUE;
            ELSE
               v_generate_cards := FALSE;
            END IF;
         END IF;

         -- Two counter variables l_count_generate and l_count_print are defined.
         -- Depending upon the value of v_generate_cards, the respective counter variable will be
         -- incremented each time we loop through the PullSeqTable.
         IF(v_generate_cards) THEN
                       l_report_id              :=      l_report_generate_id;
                       l_count_generate         :=      l_count_generate + 1;
         ELSE
                       l_report_id              :=      l_report_print_id;
                       l_count_print            :=      l_count_print +1;
         END IF;

         insert into mtl_kanban_card_print_temp(
                                        report_id,
                                        kanban_card_id,
                                        pull_sequence_id)
         values (
                                l_report_id,
                                -1,
                                l_Pull_sequence_rec.pull_sequence_id
                );


         IF X_UPDATE_FLAG = 'Y' THEN
         -- we should not delete old kanban cards but change their status
            -- for historical purposes.

            update_kanban_card_status
              (p_card_status => g_card_status_cancel,
               p_pull_sequence_id => l_Pull_Sequence_Rec.pull_sequence_id);
         END IF;
         --


     END LOOP;

 -- Instead of v_generate_cards, cards will be generated if l_count_generate > 0
 IF( l_count_generate > 0) THEN
        v_req_id := fnd_request.submit_request(
                                        'INV',
                                        'INVKBCGN',
                                         NULL,
                                         NULL,
                                         FALSE,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         1,
                                         NULL,
                                         1,
                                         l_report_id );

        IF ( NVL(v_req_id, 0) <> 0) THEN
             COMMIT;
             FND_MESSAGE.SET_NAME ('INV', 'INV_PROCESS');
             Fnd_message.set_token('REQUEST_ID',to_char(v_req_id), FALSE);
             fnd_message.set_token('PROCESS','INV_GENERATE_KANBAN_CARDS', TRUE);
             FND_MSG_PUB.Add;
        ELSE
                fnd_message.set_name('INV','INV_PROCESS_FAILED');
                fnd_message.set_token('PROCESS', 'INV_GENERATE_KANBAN_CARDS', TRUE);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
END IF;

-- Cards will be printed if variable l_count_print > 0
IF (l_count_print >0 ) THEN
  v_req_id := fnd_request.submit_request( 'INV',
                                          'INVKBCPR',
                                           NULL,
                                           NULL,
                                           FALSE,
                                           NULL, /* p_org_id */
                                           NULL, /* p_date_created_low */
                                           NULL, /* p_date_created_high */
                                           NULL, /* p_kanban_card_number_low */
                                           NULL, /* p_kanban_card_number_high */
                                           NULL, /* p_item_low */
                                           NULL, /* p_item_high */
                                           NULL, /* p_subinv */
                                           NULL, /* p_locator_low */
                                           NULL, /* p_locator_high */
                                           NULL, /* p_source_type */
                                           NULL, /* p_kanban_card_type */
                                           NULL, /* p_supplier */
                                           NULL, /* p_supplier_site */
                                           NULL, /* p_source_org_id */
                                           NULL, /* p_source_subinv */
                                           NULL, /* p_source_loc_id */
                                           3,   /* p_sort_by */
                                           2, /* p_call_from */
                                           NULL,        /* p_kanban_card_id */
                                           l_report_id  /* p_report_id */
                                        );

        IF ( NVL(v_req_id, 0) <> 0) THEN
             COMMIT;
             FND_MESSAGE.SET_NAME ('INV', 'INV_PROCESS');
             Fnd_message.set_token('REQUEST_ID',to_char(v_req_id), FALSE);
             fnd_message.set_token('PROCESS', 'INV_PRINT_KANBAN_CARDS', TRUE);
             FND_MSG_PUB.Add;
        ELSE
--           delete from MTL_KANBAN_CARD_PRINT_TEMP
--           where
--           report_id = l_report_id;
--           COMMIT;
           fnd_message.set_name('INV','INV_PROCESS_FAILED');
           fnd_message.set_token('PROCESS', 'INV_PRINT_KANBAN_CARDS', TRUE);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
END IF;
        x_return_status := l_return_status;

    EXCEPTION
                -- CHECK the code in all the exception sections
                WHEN FND_API.G_EXC_ERROR THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;

                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                        THEN
                                FND_MSG_PUB.Add_Exc_Msg
                                        (   G_PKG_NAME
                                                ,   'Update_Pull_sequence'
                                        );
                        END IF;
 End Update_Pull_sequence_tbl;

--
--
--
--  Update_Card_Supply_Status : This procedure updates the supply status
--                              for a kanban card id record. If the supply
--                              status is Inprocess the document details
--                              are also captured.
--
--
PROCEDURE Update_Card_Supply_Status(X_Return_Status      Out NOCOPY Varchar2,
                                    p_Kanban_Card_Id     Number,
                                    p_Supply_Status      Number,
                                    p_Document_type      Number,
                                    p_Document_Header_Id Number,
                                    p_Document_detail_Id NUMBER,
                                    p_replenish_quantity NUMBER,
                                    p_need_by_date       DATE,
                                    p_source_wip_entity_id  NUMBER)

IS
l_kanban_card_rec     INV_Kanban_PVT.Kanban_Card_Rec_Type;
l_return_status       Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
l_supply_status_from  Varchar2(30);
l_supply_status_to    Varchar2(30);
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_temp NUMBER := NULL;
l_update              Boolean := TRUE; -- For Bug 3740514
Begin
        FND_MSG_PUB.initialize;

        IF p_Kanban_Card_Id is NULL THEN
          FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_KANBAN_CARD');
          FND_MSG_PUB.Add;
          l_return_status := FND_API.G_RET_STS_ERROR;
         ELSIF p_supply_status is null  THEN
           FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_SUPPLY_STATUS');
           FND_MSG_PUB.Add;
           l_return_status := FND_API.G_RET_STS_ERROR;
         ELSE

           l_kanban_card_rec := INV_KanbanCard_PKG.Query_Row
             ( p_Kanban_Card_id      => p_kanban_Card_Id);

           --Bug 3288422 fix. Preventing replenishment 1) If lock cannot be
           --acquired on the kanban_card_record 2) if the card is in hold
           --OR cancel status
           BEGIN
              SELECT kanban_card_id
                INTO l_temp
                FROM MTL_KANBAN_CARDS
                WHERE kanban_card_id = p_kanban_Card_Id
                FOR UPDATE NOWAIT;
              mydebug('Lock accuired for kanban card');
           EXCEPTION
              WHEN OTHERS THEN
                 l_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MESSAGE.SET_NAME('INV','INV_CANNOT_LOCK_KANBAN_CARD');
                 FND_MSG_PUB.ADD;
           END;

           IF l_return_status = FND_API.g_ret_sts_error THEN
              NULL;
            ELSIF (l_kanban_card_rec.card_status = G_Card_Status_Hold ) THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('INV','INV_CANNOT_REPL_HOLD_CARD');
              FND_MSG_PUB.ADD;
            ELSIF (l_kanban_card_rec.card_status = G_Card_Status_Cancel ) then
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('INV','INV_CANNOT_REPL_CANCEL_CARD');
              FND_MSG_PUB.ADD;

              --Bug 3288422 fix.
            ELSE
              IF INV_KanbanCard_PKG.Supply_Status_Change_OK
                (l_kanban_card_rec.supply_status,
                 p_supply_status,
                 l_kanban_card_rec.card_status)
                THEN
         /*Bug 3740514 --If the supply status is Full and the source is Supplier,calling
                        a new procedure update_card_and_card_status to check if the correct
                        Release is being updated.*/

              IF ( p_supply_status IN (INV_Kanban_PVT.G_Supply_Status_InProcess,INV_Kanban_PVT.G_Supply_Status_Full) AND
                 l_Kanban_Card_Rec.source_type = INV_Kanban_PVT.G_Source_Type_Supplier) THEN
                    update_card_and_card_status(
                    p_kanban_card_id => l_kanban_card_rec.kanban_card_id,
           p_supply_status  => p_supply_status,/*4490269*/
           p_document_header_id => p_document_header_id, /*Bug#7133795*/
           p_document_detail_id => p_document_detail_id, /*Bug#7133795*/
                    p_update         => l_update);
              END IF;

           /*Bug 3740514--Only if l_update is TRUE will the kanban card details be updated to the
                         new values.*/

         IF (l_update) THEN
                    mydebug('Supply status change OK');
                    l_kanban_card_rec.supply_status := p_supply_status;
                    l_kanban_card_rec.document_type := p_document_type;
                    l_kanban_card_rec.document_header_id := p_document_header_id;
                    l_kanban_card_rec.document_detail_id := p_document_detail_id;
                    l_kanban_card_rec.last_update_date := SYSDATE;
                    l_kanban_card_rec.last_updated_by := FND_GLOBAL.USER_ID;
                    l_kanban_card_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
                    l_kanban_card_rec.replenish_quantity := p_replenish_quantity;
                    l_kanban_card_rec.need_by_date       := p_need_by_date;
                    l_kanban_card_rec.source_wip_entity_id := p_source_wip_entity_id;
                    mydebug('calling INV_KanbanCard_PKG.Update_Row');
                    INV_KanbanCard_PKG.Update_Row(l_kanban_card_rec);
         END IF;
               ELSE
                 mydebug('Supply status change not OK');
                 If l_kanban_card_rec.card_status in
                   (INV_Kanban_PVT.G_Card_Status_Cancel,
                    INV_Kanban_PVT.G_Card_Status_Hold)
                   then
                    FND_MESSAGE.SET_TOKEN('CARD_NUMBER',l_kanban_card_rec.kanban_card_number);
                 End If;
                 l_return_status := FND_API.G_RET_STS_ERROR;
                 FND_MSG_PUB.Add;
              END IF;--IF INV_KanbanCard_PKG.Supply_Status_Change_OK
           END IF;--IF l_return_status = FND_API.g_ret_sts_error
        END IF;--IF p_Kanban_Card_Id is NULL THEN

        IF l_return_status = FND_API.g_ret_sts_error THEN
           Raise FND_API.G_EXC_ERROR;
        end if;

        x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Card_Supply_Status'
            );
        END IF;

End Update_Card_Supply_Status;
--
--
--  Update_Card_Supply_Status : This procedure updates the supply status
--                              for a kanban card id record.
--
--
PROCEDURE Update_Card_Supply_Status(X_Return_Status      Out NOCOPY Varchar2,
                                    p_Kanban_card_Id         Number,
                                    p_Supply_Status          Number)
IS
l_document_type      Number;
l_document_header_id Number;
l_Document_detail_id Number;

l_quantity_delivered  Number;
l_quantity            Number;
l_reference_type_code Number;
l_move_order_line_id  Number;
l_Supply_Status       Number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
l_Supply_Status := p_Supply_Status;

-- Bug 3032156. The following IF condition has been added to keep the
-- supply status to 'Full' while partially transacting the move order.
-- The status changes to 'InProcess if 'INV_FILL_PARTIAL_MOVE_KANBAN'
-- profile value is set to 'No' and the IF conditions are satisfied.

if nvl(fnd_profile.value('INV_FILL_PARTIAL_MOVE_KANBAN'),2) = 2 then
-- Bug 2383538 Checking the mtl_txn_request_lines when partially
-- transacting the move order to change the supply status to Inprocess
   Begin
     select line_id, nvl(quantity,0), nvl(reference_type_code,0)
     into l_move_order_line_id, l_quantity, l_reference_type_code
     from mtl_txn_request_lines
     where reference_type_code = 1
     and reference_id = p_Kanban_card_Id
     and line_status in (3,7);
        if (l_reference_type_code = 1) then
           select sum(abs(transaction_quantity)) into l_quantity_delivered from
           mtl_material_transactions where
           move_order_line_id = l_move_order_line_id and
           transaction_quantity < 0;
           if (nvl(l_quantity_delivered,0) < l_quantity) then
               l_Supply_Status := INV_KANBAN_PVT.G_Supply_Status_InProcess;
           end if;
        end if;
   Exception When Others Then
     Null;
   End;
End if;

 Update_Card_Supply_Status(X_Return_Status      => x_Return_Status,
                           p_kanban_card_Id     => p_Kanban_Card_Id,
                           p_Supply_Status      => l_Supply_Status,
                           p_Document_type      => l_document_type,
                           p_Document_Header_Id => l_document_header_id,
                           p_Document_detail_Id => l_Document_detail_id);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Card_Supply_Status'
            );
        END IF;

End Update_Card_Supply_Status;
--
--
--  Update_Card_Supply_Status : This procedure updates the supply status
--                              for a kanban card id record.
--
PROCEDURE Update_Card_Supply_Status
(   p_api_version_number            IN  NUMBER
    ,p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
    ,p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
    ,p_validation_level              IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status                 OUT NOCOPY VARCHAR2
    ,x_msg_count                     OUT NOCOPY NUMBER
    ,x_msg_data                      OUT NOCOPY VARCHAR2
    ,p_Kanban_Card_Id                    Number
    ,p_Supply_Status                     NUMBER
    ,p_Document_type                 IN  NUMBER DEFAULT NULL
    ,p_Document_Header_Id            IN  NUMBER DEFAULT NULL
    ,p_Document_detail_Id            IN  NUMBER DEFAULT NULL
    ,p_replenish_quantity            IN  NUMBER DEFAULT NULL
    ,p_need_by_date                  IN  DATE   DEFAULT NULL
    ,p_source_wip_entity_id          IN  NUMBER DEFAULT NULL)
  IS

l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Update_Card_Supply_Status';
l_return_status               VARCHAR2(1)     := FND_API.G_RET_STS_SUCCESS;
l_document_type               Number;
l_document_header_id          Number;
l_document_detail_id          Number;

l_msg_data                   VARCHAR2(255);
l_msg_count                  NUMBER := NULL;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

    -- Standard Start of API savepoint

    SAVEPOINT KANBAN_PVT;
    mydebug('Inside Update_Card_Supply_Status 1');
    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    mydebug('Calling Update_Card_Supply_Status 2');
    Update_Card_Supply_Status(X_Return_Status      => l_Return_Status,
                              p_kanban_card_Id     => p_Kanban_Card_Id,
                              p_Supply_Status      => p_Supply_Status,
                              p_Document_type      => l_document_type,
                              p_Document_Header_Id => l_document_header_id,
                              p_Document_detail_Id => l_document_detail_id,
                              p_replenish_quantity => p_replenish_quantity,
                              p_need_by_date       => p_need_by_date,
                              p_source_wip_entity_id => p_source_wip_entity_id);

   x_return_status := l_return_status;

   -- Standard check of p_commit.

        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

   -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO KANBAN_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count     ,
                        p_data                  =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO KANBAN_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count     ,
                        p_data                  =>      x_msg_data
                );

        WHEN OTHERS THEN
                ROLLBACK TO KANBAN_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count     ,
                        p_data                  =>      x_msg_data
                );

End Update_Card_Supply_Status;
--
--
-- This package is for those cards which do not have Document_detail_Id.
--
--
PROCEDURE Update_Card_Supply_Status(X_Return_Status      Out NOCOPY Varchar2,
                                    p_Kanban_Card_Id     Number,
                                    p_Supply_Status      Number,
                                    p_Document_type      Number,
                                    p_Document_Header_Id Number)
IS
l_Document_detail_id    Number := FND_API.G_MISS_NUM;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

 Update_Card_Supply_Status(X_Return_Status      => x_Return_Status,
                           p_kanban_card_Id     => p_Kanban_Card_Id,
                           p_Supply_Status      => p_Supply_Status,
                           p_Document_type      => p_document_type,
                           p_Document_Header_Id => p_document_header_id,
                           p_Document_detail_Id => l_Document_detail_id);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Card_Supply_Status'
            );
        END IF;

End Update_Card_Supply_Status;
--
--
--  Valid_Kanban_Cards_Exist : This procedure checks whether "Active" or "Hold"
--                             Kanban cards exists for a pull sequence.
--
FUNCTION Valid_Kanban_Cards_Exist(p_Pull_sequence_id number)
Return Boolean
Is
l_dummy varchar2(1);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

        Select 'x'
        INTO   l_dummy
        FROM   MTL_KANBAN_CARDS
        WHERE  pull_sequence_id = p_pull_sequence_id
        AND    (card_status = INV_Kanban_PVT.G_Card_Status_Active or
                card_status = INV_Kanban_PVT.G_Card_Status_Hold);
        Raise Too_Many_Rows;

Exception
When No_data_found Then
  return FALSE;

When Too_many_rows Then
  return TRUE;
When Others Then

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Valid_kanban_Cards_exist'
            );
        END IF;

END Valid_kanban_Cards_exist;
--
-- Diff_Qty_Kanban_Cards_Exist : Check the existence of valid kanban cards for
--                               a pull sequence, which have the same Point of Supply
--                               but different quantity
--
-- For bug 5334353, changed return type of function to number
-- Retunns 0 : When card with supply status Wait or Inprocess exists
-- Returns 1 : When card with diff qty exists
-- Returns 2: When both 0 and 1 conditions does not satisfy
FUNCTION Diff_Qty_Kanban_Cards_Exist(
                                     p_pull_sequence_id       number,
                                     p_source_type            number,
                                     p_supplier_id            number,
                                     p_supplier_site_id       number,
                                     p_source_organization_id number,
                                     p_source_subinventory    varchar2,
                                     p_source_locator_id      number,
                                     p_wip_line_id            number,
                                     p_kanban_size            number)
Return Number
Is
   l_dummy varchar2(1);
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
        Select 'x'
        INTO   l_dummy
        FROM   MTL_KANBAN_CARDS
        WHERE  pull_sequence_id = p_pull_sequence_id
        AND    (card_status = INV_Kanban_PVT.G_Card_Status_Active or
                card_status = INV_Kanban_PVT.G_Card_Status_Hold)
--        AND    nvl(p_kanban_size,-1) > 0
--      AND    kanban_size <> nvl(p_kanban_size,-1)
        AND    source_type = nvl(p_source_type,-1)
        AND   (((source_type = 1 or source_type = 3)
                and nvl(source_organization_id,-1) = nvl(p_source_organization_id,-1)
                and nvl(source_subinventory,'#?#?') = nvl(p_source_subinventory,'#?#?')
                and nvl(source_locator_id,-1) = nvl(p_source_locator_id,-1))
               OR
               (source_type = 2
                and ((nvl(supplier_id,-1) = nvl(p_supplier_id,-1)
                      and nvl(supplier_site_id,-1) = nvl(p_supplier_site_id,-1))
                     or p_supplier_id is null))
               OR
               (source_type = 4
                and (nvl(wip_line_id,-1) = nvl(p_wip_line_id,-1)
                     or p_wip_line_id is null))
              )
        AND supply_status in (3,5) --sbitra
        ;
        Raise Too_Many_Rows;
Exception
When No_data_found Then
     begin
        Select 'x'
        INTO   l_dummy
        FROM   MTL_KANBAN_CARDS
        WHERE  pull_sequence_id = p_pull_sequence_id
        AND    (card_status = INV_Kanban_PVT.G_Card_Status_Active or
                card_status = INV_Kanban_PVT.G_Card_Status_Hold)
        AND    nvl(p_kanban_size,-1) > 0
        AND    kanban_size <> nvl(p_kanban_size,-1)
        AND    source_type = nvl(p_source_type,-1)
        AND   (((source_type = 1 or source_type = 3)
                and nvl(source_organization_id,-1) = nvl(p_source_organization_id,-1)
                and nvl(source_subinventory,'#?#?') = nvl(p_source_subinventory,'#?#?')
                and nvl(source_locator_id,-1) = nvl(p_source_locator_id,-1))
               OR
               (source_type = 2
                and ((nvl(supplier_id,-1) = nvl(p_supplier_id,-1)
                      and nvl(supplier_site_id,-1) = nvl(p_supplier_site_id,-1))
                     or p_supplier_id is null))
               OR
               (source_type = 4
                and (nvl(wip_line_id,-1) = nvl(p_wip_line_id,-1)
                     or p_wip_line_id is null))
              )
        ;
       Raise Too_Many_Rows;
    exception
        when no_data_found then
           return 2;  -----No cards with status wait/inprocess and diff qty
        when too_many_rows then
           return 1;  -----Cards exists with diff qty
    end;

When Too_many_rows Then
  return 0; -------Cards with status wait/inprocess exists
When Others Then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Diff_Qty_Kanban_Cards_Exist'
            );
        END IF;

END Diff_Qty_Kanban_Cards_Exist;
--
--
--  Ok_To_Create_Kanban_Cards : This procedure checks whether kanban cards can
--                              be generated for a pull sequences.
--
--
FUNCTION Ok_To_Create_Kanban_Cards(p_Pull_sequence_id number)
Return Boolean
IS

l_org_code      varchar2(3);
l_item_name     varchar2(100);
l_subinventory  varchar2(10);
l_loc_name      varchar2(100);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

        if Valid_Kanban_Cards_exist(p_pull_sequence_id)
        then
          Get_Pull_sequence_Tokens(p_pull_sequence_id,l_org_code,
                                  l_item_name,l_subinventory,l_loc_name);
          FND_MESSAGE.SET_NAME('INV','INV_CANT_GEN_CRDS_CARDS_EXIST');
          FND_MESSAGE.SET_TOKEN('ORG_CODE',l_org_code);
          FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
          FND_MESSAGE.SET_TOKEN('SUB_CODE',l_subinventory);
          FND_MESSAGE.SET_TOKEN('LOCATOR_NAME',l_loc_name);
          return false;
        end if;
      return TRUE;

END Ok_To_Create_Kanban_Cards;
--
--
--  Ok_To_Delete_Pull_Sequence : This procedure checks whether a pull
--                               sequence can be deleted.
--
--
FUNCTION Ok_To_Delete_Pull_Sequence(p_Pull_sequence_id number)
RETURN BOOLEAN
IS

l_org_code      varchar2(3);
l_item_name     varchar2(100);
l_subinventory  varchar2(10);
l_loc_name      varchar2(100);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
        if Valid_Kanban_Cards_exist(p_pull_sequence_id)
        then
          Get_Pull_sequence_Tokens(p_pull_sequence_id,l_org_code,
                                  l_item_name,l_subinventory,l_loc_name);
          FND_MESSAGE.SET_NAME('INV','INV_CANNOT_DELETE_PULLSEQ');
          FND_MESSAGE.SET_TOKEN('ORG_CODE',l_org_code);
          FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
          FND_MESSAGE.SET_TOKEN('SUB_CODE',l_subinventory);
          FND_MESSAGE.SET_TOKEN('LOCATOR_NAME',l_loc_name);
          return false;
        end if;
        return TRUE;

END Ok_To_Delete_Pull_sequence;

--
--
--  Get_Kanban_Tokens : This procedure gets the names required to
--                      build the message for Kanban Validation.
--
PROCEDURE Get_Kanban_Tokens
( p_kanban_id     Number,
  p_org_id        Number,
  p_item_id       Number,
  p_loc_id        Number,
  x_org_code         Out NOCOPY varchar2,
  x_item_name        Out NOCOPY varchar2,
  x_loc_name         Out NOCOPY varchar2,
  x_kanban_num       Out NOCOPY varchar2 )
IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
        Select concatenated_segments,organization_code,kanban_card_number
        into x_item_name,x_org_code,x_kanban_num
        from mtl_system_items_kfv a , mtl_parameters b, mtl_kanban_cards card
        where a.inventory_item_id   = p_item_id
        and   a.organization_id     = p_org_id
        and   b.organization_id     = p_org_id
        and   card.kanban_card_id   = p_kanban_id;

        if ( nvl(p_loc_id,0) <> 0 ) Then

           Select concatenated_segments
           into x_loc_name
           from mtl_item_locations_kfv
           where inventory_location_id = p_loc_id
           and   organization_id = p_loc_id;
        end if;
Exception

When Others Then
  Null;

End Get_kanban_Tokens;

--
-- Valid_Production_Kanban_Card : This function will check the validity of
--                                of a production  kanban Card.
--
FUNCTION Valid_Production_Kanban_Card( p_wip_entity_id  number,
                                       p_org_id         number,
                                       p_kanban_id      number,
                                       p_inv_item_id    number,
                                       p_subinventory   varchar2,
                                       p_locator_id     number   )
Return Boolean IS
l_kanban_card_id  number;
l_dummy           varchar2(1);
l_proceed         varchar2(1);
l_subinventory    varchar2(10);
l_loc_id          number;
l_item_id         number;
l_org_id          number;
l_source_type     number;
l_supply_status   number;
x_org_code        varchar2(3);
x_item_name       varchar2(200);
x_loc_name        varchar2(200);
x_kanban_num      varchar2(30);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
      begin
         select  subinventory_name, nvl(locator_id,0), inventory_item_id,
                 organization_id, source_type, supply_status
         into   l_subinventory, l_loc_id, l_item_id,
                l_org_id, l_source_type, l_supply_status
         from mtl_kanban_cards
         where  kanban_card_id      =  p_kanban_id;
      exception
         When NO_DATA_FOUND then
           FND_MESSAGE.SET_NAME('INV','INV_KANBAN_CARD_NOT_FOUND');
           FND_MESSAGE.SET_TOKEN('CARDID',to_char(p_kanban_id) );
           RETURN FALSE;
         When OTHERS then
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Valid_Production_Kanban_Card'
            );
           RETURN FALSE;
       end;

      Get_Kanban_Tokens(p_kanban_id , p_org_id , p_inv_item_id ,
                        p_locator_id , x_org_code , x_item_name ,
                        x_loc_name , x_kanban_num  );

        if ( (l_item_id = p_inv_item_id) AND (l_org_id = p_org_id) ) then
           l_proceed := 'Y';
        else
          FND_MESSAGE.SET_NAME('INV','INV_KANBAN_INVALID_ITEM_ORG');
          FND_MESSAGE.SET_TOKEN('CARD_NUM',x_kanban_num );
          FND_MESSAGE.SET_TOKEN('ORG_CODE',x_org_code );
          FND_MESSAGE.SET_TOKEN('ITEM',x_item_name );
          RETURN FALSE;
        end if;
        if ( ( l_subinventory = p_subinventory ) AND
                      ( l_loc_id = nvl(p_locator_id,l_loc_id)) ) then
           l_proceed := 'Y';
        else
          FND_MESSAGE.SET_NAME('INV','INV_KANBAN_INVALID_CMPL_DEST');
          FND_MESSAGE.SET_TOKEN('CARD_NUM',x_kanban_num );
          FND_MESSAGE.SET_TOKEN('SUB',p_subinventory);
          FND_MESSAGE.SET_TOKEN('LOC',x_loc_name);
          RETURN FALSE;
        end if;
        if ( l_source_type = INV_KANBAN_PVT.G_Source_Type_Production ) then
                   l_proceed := 'Y';
        else
          FND_MESSAGE.SET_NAME('INV','INV_KANBAN_NOT_PRODUCTION');
          FND_MESSAGE.SET_TOKEN('CARD_NUM',x_kanban_num );
          RETURN FALSE;
        end if;
        if ( l_supply_status in (INV_KANBAN_PVT.G_Supply_Status_Empty,
                                 INV_KANBAN_PVT.G_Supply_Status_InProcess ) ) then
                  Return TRUE;
        else
          begin
             select 'x' into l_dummy
             from   mtl_kanban_card_activity
             where  kanban_card_id = p_kanban_id
             and    organization_id = p_org_id
             and    document_header_id = p_wip_entity_id
             and    source_type    = INV_KANBAN_PVT.G_Source_Type_Production
             and    supply_status = INV_KANBAN_PVT.G_Supply_Status_Full;

             Raise Too_many_rows;

            exception
                When No_data_found Then
                      FND_MESSAGE.SET_NAME('INV','INV_KANBAN_INVALID_SUP_STATUS');
                      FND_MESSAGE.SET_TOKEN('CARD_NUM',x_kanban_num );
                      return FALSE;
                When Too_many_rows Then
                      return TRUE;
                When Others Then
                      FND_MSG_PUB.Add_Exc_Msg
                      (   G_PKG_NAME
                       ,   'Valid_Prod_kanban_Card'
                        );
                     return FALSE;
             end ;
        end if;

 END Valid_Production_Kanban_Card;

--
--
--  Delete_Kanban_Cards : This procedure deletes kanban cards for
--                        a pull sequence.
--
--
PROCEDURE Delete_Kanban_Cards(p_Pull_sequence_id  number)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    INV_KanbanCard_PKG.Delete_Cards_For_Pull_Seq(p_pull_sequence_id);

END Delete_Kanban_Cards;
--
--
--  Create_Kanban_Cards : This procedure generates kanban cards for
--                        a pull sequence.
--
--
PROCEDURE Create_Kanban_Cards
(  X_return_status    OUT NOCOPY VARCHAR2,
   X_Kanban_Card_Ids  OUT NOCOPY INV_Kanban_PVT.Kanban_Card_Id_Tbl_Type,
   P_Pull_Sequence_Rec    INV_Kanban_PVT.Pull_Sequence_Rec_Type,
   p_Supply_Status        NUMBER
)
IS
  l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_kanban_Card_tbl             INV_Kanban_PVT.Kanban_Card_Id_Tbl_Type;
  l_Kanban_Card_Id              number;
  l_Kanban_Card_Number          number;
  l_supply_status               Number;
  l_Card_status                 Number;
  l_Current_Replnsh_Cycle_Id    Number;
  l_card_count                  number := 0;
  l_item_name                   varchar2(2000);
  l_loc_name                    varchar2(2000);
  l_subinventory                varchar2(10);
  l_org_code                    varchar2(3);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  FND_MSG_PUB.initialize;
  l_kanban_Card_tbl.Delete;




  IF(p_pull_sequence_rec.release_kanban_flag =2) THEN
     l_card_status              := INV_Kanban_Pvt.G_Card_Status_Hold;
     l_supply_status            := inv_kanban_pvt.g_supply_status_full;
  ELSE
     l_card_status              := INV_Kanban_Pvt.G_Card_Status_Active;
     l_supply_status            := p_Supply_Status;
 END IF ;

  l_Current_Replnsh_Cycle_Id    := null;

  if nvl(P_Pull_Sequence_Rec.NUMBER_OF_CARDS,0) <= 0
  then

     Get_Pull_sequence_Tokens(p_pull_sequence_rec.pull_sequence_id,l_org_code,
                              l_item_name,l_subinventory,l_loc_name);
     FND_MESSAGE.SET_NAME('INV','INV_CANT_GEN_CRDS_NO_NUM_CARDS');
     FND_MESSAGE.SET_TOKEN('ORG_CODE',l_org_code);
     FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
     FND_MESSAGE.SET_TOKEN('SUB_CODE',l_Subinventory);
     FND_MESSAGE.SET_TOKEN('LOCATOR_NAME',l_loc_name);
     FND_MSG_PUB.Add;

     l_return_status :=  FND_API.G_RET_STS_ERROR;

  end if;

  if nvl(P_Pull_Sequence_Rec.Kanban_Size,0) <= 0
  then
     if l_org_code is null
     then
        Get_Pull_sequence_Tokens(p_pull_sequence_rec.pull_sequence_id,l_org_code,
                             l_item_name,l_subinventory,l_loc_name);
     end if;
     FND_MESSAGE.SET_NAME('INV','INV_CANT_GEN_CRDS_NO_KBN_SIZE');
     FND_MESSAGE.SET_TOKEN('ORG_CODE',l_org_code);
     FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
     FND_MESSAGE.SET_TOKEN('SUB_CODE',l_Subinventory);
     FND_MESSAGE.SET_TOKEN('LOCATOR_NAME',l_loc_name);
     FND_MSG_PUB.Add;
     l_return_status :=  FND_API.G_RET_STS_ERROR;

  end if;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;

  END IF;

  --Existing kanban cards need to be cancelled only when creating a
  --regular replenishable card
  IF p_pull_sequence_rec.kanban_card_type <>
    INV_Kanban_Pvt.g_card_type_nonreplenishable then
     -- we should not delete old kanban cards but change their status
     -- for historical purposes.
     --Delete_Kanban_Cards(p_Pull_Sequence_Rec.Pull_Sequence_Id);
     update_kanban_card_status
       (p_card_status => g_card_status_cancel,
        p_pull_sequence_id => p_Pull_Sequence_Rec.pull_sequence_id);
     X_Kanban_Card_Ids := l_kanban_Card_tbl;
  END IF;


  for l_card_count in 1..p_Pull_Sequence_Rec.Number_Of_Cards
    loop

       l_Kanban_Card_Id     := NULL;
       l_Kanban_Card_Number := NULL;

       INV_KanbanCard_PKG.Insert_Row(
           X_Return_Status           => l_Return_Status,
           P_Kanban_Card_Id          => l_Kanban_Card_Id,
           P_Kanban_Card_Number      => l_Kanban_Card_Number,
           P_Pull_Sequence_Id        => p_Pull_Sequence_Rec.Pull_Sequence_Id,
           P_Inventory_item_id       => p_Pull_Sequence_Rec.Inventory_item_id,
           P_Organization_id         => p_Pull_Sequence_Rec.Organization_id,
           P_Subinventory_name       => p_Pull_Sequence_Rec.Subinventory_name,
           P_Supply_Status           => l_Supply_Status,
           P_Card_Status             => l_Card_Status,
           P_Kanban_Card_Type        => Nvl(p_pull_sequence_rec.kanban_card_type,INV_Kanban_Pvt.g_card_type_replenishable),
           P_Source_type             => p_Pull_Sequence_Rec.Source_type,
           P_Kanban_size             => nvl(p_Pull_Sequence_Rec.Kanban_size,0),
           P_Last_Update_Date        => SYSDATE,
           P_Last_Updated_By         => FND_GLOBAL.USER_ID,
           P_Creation_Date           => SYSDATE,
           P_Created_By              => FND_GLOBAL.USER_ID,
           P_Last_Update_Login       => FND_GLOBAL.LOGIN_ID,
           P_Last_Print_Date         => NULL,
           P_Locator_id              => p_Pull_Sequence_Rec.Locator_id,
           P_Supplier_id             => p_Pull_Sequence_Rec.Supplier_id,
           P_Supplier_site_id        => p_Pull_Sequence_Rec.Supplier_site_id,
           P_Source_Organization_id  => p_Pull_Sequence_Rec.Source_Organization_id,
           P_Source_Subinventory     => p_Pull_Sequence_Rec.Source_Subinventory,
           P_Source_Locator_id       => p_Pull_Sequence_Rec.Source_Locator_id,
           P_wip_line_id             => p_Pull_Sequence_Rec.wip_line_id,
           P_Current_Replnsh_Cycle_Id=> l_Current_Replnsh_Cycle_Id,
           P_document_type           => NULL,
           P_document_header_id      => NULL,
           P_document_detail_id      => NULL,
           P_error_code              => NULL,
           P_Attribute_Category      => NULL,
           P_Attribute1              => NULL,
           P_Attribute2              => NULL,
           P_Attribute3              => NULL,
           P_Attribute4              => NULL,
           P_Attribute5              => NULL,
           P_Attribute6              => NULL,
           P_Attribute7              => NULL,
           P_Attribute8              => NULL,
           P_Attribute9              => NULL,
           P_Attribute10             => NULL,
           P_Attribute11             => NULL,
           P_Attribute12             => NULL,
           P_Attribute13             => NULL,
           P_Attribute14             => NULL,
           P_Attribute15             => NULL,
           P_Request_Id              => NULL,
           P_Program_application_Id  => NULL,
           P_Program_Id              => NULL,
         P_Program_Update_date     => NULL,
         p_release_kanban_flag    => p_Pull_Sequence_Rec.release_kanban_flag);

        if l_return_status = FND_API.G_RET_STS_ERROR
        Then
                Raise FND_API.G_EXC_ERROR;
        End if;

        if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        Then
                Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End If;

        X_Kanban_Card_Ids(l_card_count) := l_Kanban_Card_Id;

    end loop;

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Kanban_Cards'
            );
        END IF;

END Create_Kanban_Cards;

--
-- Get_Next_Replenish_Cycle_Id() : This function will generate and return
--                                 replenish_cycle_id
--

FUNCTION Get_Next_Replenish_Cycle_Id
Return Number
Is
l_next_replenish_cycle_Id  Number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

 Select MTL_KANBAN_REPLENISH_CYCLE_S.NextVal
 Into   l_next_replenish_cycle_Id
 From  Dual;
 Return(l_next_replenish_cycle_Id);

End Get_Next_Replenish_Cycle_Id;

--
--
--  Create_Requisition : This would create Internal/PO requisition
--                       for a kanban card.
--
Procedure Create_Requisition( p_buyer_id                IN NUMBER,
                              p_interface_source_code   IN VARCHAR2,
                              p_requisition_type        IN VARCHAR2,
                              p_approval                IN VARCHAR2,
                              p_source_type_code        IN VARCHAR2,
                              p_kanban_card_rec_tbl     IN Kanban_Card_Tbl_Type,
                              p_destination_type_code   IN VARCHAR2,
                              p_deliver_location_id     IN NUMBER,
                              p_revision                IN VARCHAR2,
                              p_item_description        IN VARCHAR2,
                              p_primary_uom_code        IN VARCHAR2,
                              p_need_by_date            IN DATE,
                              p_charge_account_id       IN NUMBER,
                              p_accrual_account_id      IN NUMBER,
                              p_invoice_var_account_id  IN NUMBER,
                              p_budget_account_id       IN NUMBER,
                              p_autosource_flag         IN VARCHAR2,
                              p_po_org_id               IN NUMBER ) IS

l_project_id NUMBER :=null;
l_task_id NUMBER := null;
l_project_reference_enabled NUMBER;
l_project_accounting_context VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin

  For l_order_count in 1..p_Kanban_Card_Rec_Tbl.Count
  Loop

-- Bug 1924497

      l_project_accounting_context := null;

       SELECT NVL(project_reference_enabled,2)
         INTO l_project_reference_enabled
         FROM mtl_parameters
         WHERE organization_id = p_kanban_card_rec_tbl(1).organization_id;

       IF (l_project_reference_enabled = 1)THEN
          IF (p_kanban_card_rec_tbl(1).locator_id IS NOT NULL)THEN
            SELECT project_id
            INTO l_project_id
            FROM mtl_item_locations
            WHERE inventory_location_id = p_kanban_card_rec_tbl(1).locator_id
            AND organization_id = p_kanban_card_rec_tbl(1).organization_id;
          END IF;
          IF (l_project_id IS NOT NULL)THEN
            l_project_accounting_context := 'Y';
            SELECT task_id
            INTO l_task_id
            FROM mtl_item_locations
            WHERE NVL(project_id,-999) = NVL(l_project_id, -111)
            AND inventory_location_id =p_kanban_card_rec_tbl(1).locator_id
            AND organization_id = p_kanban_card_rec_tbl(1).organization_id;
          END IF;
       END IF;

   mydebug('GB:Need by date ' || TO_CHAR((trunc(p_need_by_date) + 1 - (1/(24*60*60))),'DD-MON-YYYY HH24:MI:SS'));

   insert into po_requisitions_interface_all
        (
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        PREPARER_ID,
        INTERFACE_SOURCE_CODE,
        REQUISITION_TYPE,
        AUTHORIZATION_STATUS,
        SOURCE_TYPE_CODE,
        SOURCE_ORGANIZATION_ID,
        SOURCE_SUBINVENTORY,
        DESTINATION_ORGANIZATION_ID,
        DESTINATION_SUBINVENTORY,
        DELIVER_TO_REQUESTOR_ID,
        DESTINATION_TYPE_CODE,
        DELIVER_TO_LOCATION_ID,
        ITEM_ID,
        ITEM_REVISION,
        ITEM_DESCRIPTION,
        UOM_CODE,
        QUANTITY,
        NEED_BY_DATE,
        GL_DATE,
        CHARGE_ACCOUNT_ID,
        ACCRUAL_ACCOUNT_ID,
        VARIANCE_ACCOUNT_ID,
        BUDGET_ACCOUNT_ID,
        AUTOSOURCE_FLAG,
        ORG_ID,
        SUGGESTED_VENDOR_ID,
        SUGGESTED_VENDOR_SITE_ID,
--      SUGGESTED_BUYER_ID,       /* Bug 1456782  */
        Kanban_card_Id,
        Batch_Id,
        PROJECT_ID,
        TASK_ID,
        PROJECT_ACCOUNTING_CONTEXT
        )
   Values
        (
        sysdate,
        FND_GLOBAL.USER_ID,
        sysdate,
        FND_GLOBAL.USER_ID,
        p_buyer_Id,
        p_interface_Source_Code,
        p_requisition_type,
        p_approval,
        p_source_type_code,
        p_kanban_card_Rec_Tbl(1).Source_organization_Id,
        p_kanban_card_Rec_Tbl(1).Source_Subinventory,
        p_kanban_card_Rec_Tbl(1).organization_Id,
        p_kanban_card_Rec_Tbl(1).Subinventory_Name,
        p_buyer_Id,
        p_destination_type_code,
        p_deliver_location_id,
        p_kanban_card_Rec_Tbl(1).Inventory_Item_Id,
        p_revision,
        p_Item_description,
        p_Primary_uom_Code,
        p_kanban_card_rec_tbl(l_order_count).kanban_size,
        (trunc(p_need_by_date) + 1 - (1/(24*60*60))),
        SYSDATE,
        p_Charge_Account_Id,
        p_Accrual_Account_Id,
        p_Invoice_Var_Account_Id,
        p_Budget_Account_Id,
        p_autosource_flag,
        p_po_org_id,
        p_kanban_card_Rec_Tbl(1).Supplier_ID,
        p_kanban_card_Rec_Tbl(1).Supplier_Site_ID,
--      p_Buyer_ID,                                          /* Bug 1456782 */
        p_kanban_card_rec_tbl(l_order_count).kanban_card_id,
        p_kanban_card_rec_tbl(1).current_replnsh_cycle_id,
        l_project_id,
        l_task_id,
        l_project_accounting_context
        );
   end loop;


/*
Insert into po_requisition_interface_all with

Org_Id                      Operating Unit
Preparer ID                 Buyer ID
Item_Id                     Inventory_item_id
Item_Description            item_description
Accrual_account_id          Org level ap_accrual_account
Authorization_status        'APPROVED'
Autosource_Flag             'Y'
Budget_Account_id           Encumbrance_account Item Sub level/Sub level/Item level/Org level
Charge_Account_Id           For inventory_asset_flag='Y' use sub level/org level
                            material_account else use sub level/item level/org level expense
                            account
Variance_Account_Id         Org level - invoice_price_variance_account
Created_By                  Userid
Created_date                Sysdate
Last_Updated_By             Userid
Last_Update_Date            Sysdate
Default_to_location_Id      Default location for the org in HR_LOCATIONS
                            that has a customer in po_assosiation_locations
Deliver_to_requestor_ID     Buyer id of item
Destination_Organization_id Org_id
Destination_Subinventory    Subinventory
Destination_type_code       'INVENTORY'
Quantity                    Order Quantity
Requisition_Type            'INTERNAL'/'PURCHASE'
Source Organization Id      Source Org
Source Subinventory         Source Sub
Source Type Code            'INVENTORY'/'VENDOR'
GL_date                     sysdate
Interface_source_code       'INV'
UOM_CODE                    Primary UOM
Requisition_type            'INTERNAL'/'PURCHASE'
Suggested_vendor_id         Supplier_ID
Suggested_vendor_site       Supplier_Site_Id
Suggested_Buyer_Id          Buyer_Id
*/

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Requisition'
            );
        END IF;

       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

end Create_Requisition;

--
-- Create_Move_Order : This procedure would create a transfer order for
--                         for kanban card with source type Intra Org.
--

Procedure Create_Transfer_Order(
                        p_kanban_card_rec_tbl  IN OUT NOCOPY Kanban_Card_Tbl_Type,
                        p_need_by_date         IN DATE,
                        p_primary_uom_code     IN VARCHAR2 ) IS

l_x_trohdr_rec          INV_Move_Order_PUB.Trohdr_Rec_Type;
l_x_trolin_tbl          INV_Move_Order_PUB.Trolin_Tbl_Type;
l_trohdr_rec            INV_Move_Order_PUB.Trohdr_Rec_Type;
l_trolin_tbl            INV_Move_Order_PUB.Trolin_Tbl_Type;
l_return_status         VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);
msg                     VARCHAR2(2000);
l_header_id             Number := FND_API.G_MISS_NUM;
l_line_num              Number := 0;
l_item_locator_control_code NUMBER;
l_from_sub_locator_type NUMBER;
l_to_sub_locator_type   NUMBER;
l_org_locator_control_code NUMBER;
l_auto_allocate_flag  NUMBER; --Added for 3905884
l_mo_request_number   VARCHAR2(30); --Added for 3905884
l_secondary_uom_code  VARCHAR2(3);
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_proc_name        CONSTANT VARCHAR2(30) := 'Create_Transfer_Order';
l_secondary_qty       NUMBER;
begin

   l_trohdr_rec.created_by                 :=  FND_GLOBAL.USER_ID;
   l_trohdr_rec.creation_date              :=  sysdate;
   l_trohdr_rec.date_required              :=  p_need_by_date;
   l_trohdr_rec.from_subinventory_code     :=  p_kanban_card_rec_tbl(1).source_subinventory;
--   l_trohdr_rec.header_id                :=  l_header_id;
   l_trohdr_rec.header_status              :=  INV_Globals.G_TO_STATUS_PREAPPROVED;
   l_trohdr_rec.last_updated_by            :=  FND_GLOBAL.USER_ID;
   l_trohdr_rec.last_update_date           :=  sysdate;
   l_trohdr_rec.last_update_login          :=  FND_GLOBAL.LOGIN_ID;
   l_trohdr_rec.organization_id            :=  p_kanban_card_rec_tbl(1).organization_id;
--   l_trohdr_rec.request_number           :=  to_char(l_header_id);
   l_trohdr_rec.status_date                :=  sysdate;
   l_trohdr_rec.to_subinventory_code       :=  p_kanban_card_rec_tbl(1).subinventory_name;
   l_trohdr_rec.transaction_type_id        :=  INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
   l_trohdr_rec.move_order_type            :=  INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT;
   l_trohdr_rec.db_flag                    :=  FND_API.G_TRUE;
   l_trohdr_rec.operation                  :=  INV_GLOBALS.G_OPR_CREATE;

   select location_control_code,secondary_uom_code
   into l_item_locator_control_code,l_secondary_uom_code
   from mtl_system_items
   where organization_id = p_kanban_card_rec_tbl(1).organization_id
   and inventory_item_id = p_kanban_card_rec_tbl(1).inventory_item_id;

   select locator_type
   into l_from_sub_locator_type
   from mtl_secondary_inventories
   where organization_id = p_kanban_card_rec_tbl(1).organization_id
   and secondary_inventory_name = p_kanban_card_rec_tbl(1).source_subinventory;

   select locator_type
   into l_to_sub_locator_type
   from mtl_secondary_inventories
   where organization_id = p_kanban_card_rec_tbl(1).organization_id
   and secondary_inventory_name = p_kanban_card_rec_tbl(1).subinventory_name;

   select stock_locator_control_code
   into l_org_locator_control_code
   from mtl_parameters
   where organization_id = p_kanban_card_rec_tbl(1).organization_id;

   if l_org_locator_control_code = 1 then
      p_kanban_card_rec_tbl(1).source_locator_id := null;
      p_kanban_card_rec_tbl(1).locator_id := null;
   elsif l_org_locator_control_code = 4 then
      if l_from_sub_locator_type = 1 then
          p_kanban_card_rec_tbl(1).source_locator_id := null;
      elsif l_from_sub_locator_type = 5 then
          if l_item_locator_control_code = 1 then
            p_kanban_card_rec_tbl(1).source_locator_id := null;
          end if;
      end if;
      if l_to_sub_locator_type = 1 then
          p_kanban_card_rec_tbl(1).locator_id := null;
      elsif l_to_sub_locator_type = 5 then
          if l_item_locator_control_code = 1 then
             p_kanban_card_rec_tbl(1).locator_id := null;
          end if;
      end if;
   end if;

-- Bug 1673809
/*
   if( l_item_locator_control_code = 1 OR l_from_sub_locator_type = 1 ) then
     p_kanban_card_rec_tbl(1).source_locator_id := null;
   end if;

   if( l_item_locator_control_code = 1 OR l_to_sub_locator_type = 1) then
     p_kanban_card_rec_tbl(1).locator_id := null;
   end if;
*/



   For l_order_count in 1..p_Kanban_Card_Rec_Tbl.Count Loop
        l_line_num := l_line_num + 1;
        l_trolin_tbl(l_order_count).created_by          := FND_GLOBAL.USER_ID;
        l_trolin_tbl(l_order_count).creation_date       := sysdate;
        l_trolin_tbl(l_order_count).date_required       := p_need_by_date;
        l_trolin_tbl(l_order_count).from_locator_id     := p_kanban_card_rec_tbl(1).source_locator_id;
        l_trolin_tbl(l_order_count).from_subinventory_code := p_kanban_card_rec_tbl(1).source_subinventory;
        l_trolin_tbl(l_order_count).inventory_item_id   := p_kanban_card_rec_tbl(1).inventory_item_id;
        l_trolin_tbl(l_order_count).last_updated_by     := FND_GLOBAL.USER_ID;
        l_trolin_tbl(l_order_count).last_update_date    := sysdate;
        l_trolin_tbl(l_order_count).last_update_login   := FND_GLOBAL.LOGIN_ID;
        l_trolin_tbl(l_order_count).line_id             := FND_API.G_MISS_NUM;
        l_trolin_tbl(l_order_count).line_number         := l_line_num;
        l_trolin_tbl(l_order_count).line_status         := INV_Globals.G_TO_STATUS_PREAPPROVED;
        l_trolin_tbl(l_order_count).organization_id     := p_kanban_card_rec_tbl(1).organization_id;
        l_trolin_tbl(l_order_count).quantity            := p_kanban_card_rec_tbl(l_order_count).kanban_size;
        l_trolin_tbl(l_order_count).reference_id        := p_kanban_card_rec_tbl(l_order_count).kanban_card_id;
        l_trolin_tbl(l_order_count).reference_type_code := INV_Transfer_Order_PVT.G_Ref_Type_Kanban;
        l_trolin_tbl(l_order_count).status_date         := sysdate;
        l_trolin_tbl(l_order_count).to_locator_id       := p_kanban_card_rec_tbl(1).locator_id;
        -- By kkoothan for Bug Fix:2340651.
        BEGIN
            SELECT project_id,task_id
            INTO l_trolin_tbl(l_order_count).project_id,
                 l_trolin_tbl(l_order_count).task_id
            FROM mtl_item_locations
            WHERE  inventory_location_id = p_kanban_card_rec_tbl(1).source_locator_id and organization_id = p_kanban_card_rec_tbl(1).organization_id;
       EXCEPTION
         WHEN no_data_found THEN
           NULL;
       END;
       -- End of Bug Fix:2340651.



       /* bug4004567 The secondary quantity is calculated here for kanban replenishment while move order creation */
       IF l_secondary_uom_code IS NOT NULL THEN
          l_secondary_qty := inv_convert.inv_um_convert
            (item_id            => p_kanban_card_rec_tbl(1).inventory_item_id
             ,precision         => 5
             ,from_quantity      => p_kanban_card_rec_tbl(1).kanban_size
             ,from_unit          => p_primary_uom_code
             ,to_unit            => l_secondary_uom_code
             ,from_name          => NULL
             ,to_name            => NULL);
          /* UOM conversion failure check */
          IF l_secondary_qty < 0 THEN
             mydebug('Uom Conversion Failed for Creating Transfer Order:'||p_kanban_card_rec_tbl(1).inventory_item_id|| ', ' ||p_kanban_card_rec_tbl(1).organization_id||l_proc_name);
                RAISE FND_API.g_exc_error;
            END IF ;
          ELSE
                l_secondary_uom_code := NULL ;
                l_secondary_qty := NULL ;
        END IF;
     /* bug4004567 */


        l_trolin_tbl(l_order_count).to_subinventory_code:= p_kanban_card_rec_tbl(1).subinventory_name;
        l_trolin_tbl(l_order_count).uom_code            := p_primary_uom_code;
        l_trolin_tbl(l_order_count).transaction_type_id := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR;
        l_trolin_tbl(l_order_count).db_flag             := FND_API.G_TRUE;
        l_trolin_tbl(l_order_count).operation           := INV_GLOBALS.G_OPR_CREATE;
        l_trolin_tbl(l_order_count).secondary_quantity  := l_secondary_qty;
        l_trolin_tbl(l_order_count).secondary_uom       := l_secondary_uom_code;

   END LOOP;

   INV_Transfer_Order_PVT.Process_Transfer_Order
        (  p_api_version_number       => 1.0 ,
           p_init_msg_list            => FND_API.G_TRUE,
           x_return_status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data,
           p_trohdr_rec               => l_trohdr_rec,
           p_trolin_tbl               => l_trolin_tbl,
           x_trohdr_rec               => l_x_trohdr_rec,
           x_trolin_tbl               => l_x_trolin_tbl
        );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_transfer_order'
            );
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_transfer_order'
            );
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   For I in 1 .. l_x_trolin_tbl.count
   Loop
     p_kanban_card_rec_tbl(I).document_header_id := l_x_trolin_tbl(I).header_id;
     p_kanban_card_rec_tbl(I).document_detail_id := l_x_trolin_tbl(I).Line_id;
     p_kanban_card_rec_tbl(I).document_type := 4;
   End Loop;

   /*Fix for 3905884
     IF Auto_Allocate_Flag= 1 (Yes) , allocate move order   */
   BEGIN
       SELECT MKP.auto_allocate_flag INTO l_auto_Allocate_flag
        FROM Mtl_Kanban_Pull_Sequences MKP
        WHERE MKP.pull_sequence_id=p_kanban_card_rec_tbl(1).pull_sequence_id;
   EXCEPTION
        WHEN OTHERS THEN
         l_auto_Allocate_flag := 0;
   END;

   IF l_auto_allocate_flag = 1 THEN
      Auto_Allocate_Kanban(p_kanban_card_rec_tbl(1).document_header_id,l_return_status, l_msg_count,l_msg_data);

      SELECT MTRH.request_number INTO l_mo_request_number
      FROM Mtl_Txn_Request_Headers MTRH
      WHERE MTRH.Header_id = p_kanban_card_rec_tbl(1).document_header_id;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
        FND_MESSAGE.SET_NAME('INV','INV_KANBAN_MO_ALLOC_SUCCESS');
        FND_MESSAGE.SET_TOKEN('MOVE_ORDER',l_mo_request_number);
        FND_MSG_PUB.Add;
      ELSE
        FND_MESSAGE.SET_NAME('INV','INV_MO_ALLOC_FAIL');
        FND_MESSAGE.SET_TOKEN('MOVE_ORDER',l_mo_request_number);
        FND_MSG_PUB.Add;
      END IF;

   END IF;
  /* End of fix for 3905884*/

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Transfer_Order'
            );
        END IF;
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Create_Transfer_Order;

--
-- Launch_MLP() : This program will launch the WIP Mass load program to
--                to upload the data from WIP_JOB_SCHEDULE_INTERFACE
--                table.
--

Function  Launch_MLP(p_group_id  IN  Number) return BOOLEAN  IS

v_req_id  NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   v_req_id  := FND_REQUEST.SUBMIT_REQUEST( 'WIP', 'WICMLP',
                                        NULL, NULL, FALSE,
                                        TO_CHAR(p_group_id),  /* grp id*/
                                        '3',               /* validation lvl */
                                        '2' );             /* print report */
   commit;

   if v_req_id > 0  then
      return TRUE;
   else
      Raise FND_API.G_EXC_UNEXPECTED_ERROR ;
   end if;

 exception
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Launch_MLP'
            );
        END IF;
       Return FALSE;

end Launch_MLP;

--
--  Create_Wip_Discrete() :This procedure would create a WIP Discrete Job for a
--                          kanban card.
--

Procedure Create_Wip_Discrete(
                        p_kanban_card_rec_tbl  IN OUT   NOCOPY Kanban_Card_Tbl_Type,
                        p_fixed_lead_time      IN       NUMBER,
                        p_var_lead_time        IN       NUMBER) IS
l_group_id  Number;
v_launch    Boolean := TRUE;
l_project_id NUMBER :=null;
l_task_id NUMBER := null;
l_project_reference_enabled NUMBER;
l_first_unit_start_date DATE;
l_last_unit_completion_date DATE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin

  For l_order_count in 1..p_Kanban_Card_Rec_Tbl.Count
    LOOP

       SELECT NVL(project_reference_enabled,2)
         INTO l_project_reference_enabled
         FROM mtl_parameters
         WHERE organization_id = p_kanban_card_rec_tbl(1).organization_id;

       IF (l_project_reference_enabled = 1)THEN
          IF (p_kanban_card_rec_tbl(1).locator_id IS NOT NULL)THEN
            SELECT project_id
            INTO l_project_id
            FROM mtl_item_locations
            WHERE inventory_location_id = p_kanban_card_rec_tbl(1).locator_id
            AND organization_id = p_kanban_card_rec_tbl(1).organization_id;
          END IF;
          IF (l_project_id IS NOT NULL)THEN
            SELECT task_id
            INTO l_task_id
            FROM mtl_item_locations
            WHERE NVL(project_id,-999) = NVL(l_project_id, -111)
            AND inventory_location_id =p_kanban_card_rec_tbl(1).locator_id
            AND organization_id = p_kanban_card_rec_tbl(1).organization_id;
          END IF;
       END IF;
       --3100874 Outbound Flow Sequencing
       --if the need_by_date is passed completion date should be set to the
       --value passed, otherwise just set the start date to sysdate
       IF p_kanban_card_rec_tbl(l_order_count).need_by_date IS NOT NULL THEN
          l_first_unit_start_date := NULL;
          l_last_unit_completion_date :=
            p_kanban_card_rec_tbl(l_order_count).need_by_date;
        ELSE
           /* For bug 7721127 Start */
      --  l_first_unit_start_date := Sysdate;
          /* Bug 9437363. Changed the parameter (l_order_count) for record count to 1 */
          l_first_unit_start_date := Sysdate +
          get_preprocessing_lead_time(p_kanban_card_rec_tbl(1).organization_id , p_kanban_card_rec_tbl(1).inventory_item_id);
          /* End of Bug 9437363 */
        /* For bug 7721127 Start */
          l_last_unit_completion_date := NULL;
       END IF;


     Insert into WIP_JOB_SCHEDULE_INTERFACE
       (LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        GROUP_ID,
        PROCESS_PHASE,
        PROCESS_STATUS,
        SOURCE_CODE,
        ORGANIZATION_ID,
        LOAD_TYPE,
        FIRST_UNIT_START_DATE,
        LAST_UNIT_COMPLETION_DATE,
        PRIMARY_ITEM_ID,
        START_QUANTITY,
        STATUS_TYPE,
        LINE_ID,
        kanban_card_id,
        project_id,
        task_id
        )
     values
     (
      sysdate ,
      FND_GLOBAL.USER_ID,
      sysdate ,
      FND_GLOBAL.USER_ID,
      p_kanban_card_rec_tbl(1).current_replnsh_cycle_id,
      2,
      1,
      'INV',
      p_kanban_card_rec_tbl(1).organization_id,
      1,                     /*  Discrete job */
      l_first_unit_start_date,
      l_last_unit_completion_date,
      p_kanban_card_rec_tbl(1).inventory_item_id,
      p_kanban_card_rec_tbl(l_order_count).Kanban_size,
      3,
      p_kanban_card_rec_tbl(1).wip_line_id,
      p_kanban_card_rec_tbl(l_order_count).kanban_card_id,
      l_project_id,
      l_task_id
      );
     l_project_id := NULL;
     l_task_id := NULL;
  end loop;
  l_group_id := p_kanban_card_rec_tbl(1).current_replnsh_cycle_id;
  v_launch   := Launch_MLP( l_group_id );
  if ( Not v_launch ) then
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Wip_Discrete'
            );
        END IF;

       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Create_Wip_Discrete;

--
--      Create_Rep_Schedule() : This procedure would Create a WIP Repetetive
--                              schedule.
--
Procedure Create_Rep_Schedule(
                            p_kanban_card_rec_tbl IN OUT NOCOPY Kanban_Card_Tbl_Type,
                            p_fixed_lead_time     IN     NUMBER,
                            p_var_lead_time       IN     NUMBER ) IS

rep_sched_exist   varchar2(1) := 'N';
total_qty         Number      := 0;
processing_days   Number      := 0;
line_rate         Number      := 0;
l_group_id        Number;
v_launch          Boolean := TRUE;
l_project_id number := NULL;
l_task_id NUMBER :=NULL;
l_project_reference_enabled NUMBER;
l_first_unit_start_date DATE;
l_last_unit_completion_date DATE;
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  begin
     select MAXIMUM_RATE  into  line_rate
     from   WIP_LINES
     where
          LINE_ID       = p_kanban_card_rec_tbl(1).wip_line_id     AND
      organization_id   = p_kanban_card_rec_tbl(1).organization_id;
  exception
    When others then
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create Rep Sched|Wip Line Not Defined'
            );
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end;

/*
  begin
    select 'Y'  into  rep_sched_exist
    from  WIP_JOB_SCHEDULE_INTERFACE
    where
        primary_item_id  = p_kanban_card_rec_tbl(1).inventory_item_id AND
        organization_id  = p_kanban_card_rec_tbl(1).organization_id   AND
        line_id          = p_kanban_card_rec_tbl(1).wip_line_id       AND
        load_type        = 2                                          AND
        process_phase   <> 4                                          AND
        to_date(creation_date,'DD-MON-RR')    =  to_date(SYSDATE,'DD-MON-RR')
    For Update of start_quantity NOWAIT;
    Raise TOO_MANY_ROWS;
  exception
    When NO_DATA_FOUND then
        rep_sched_exist := 'N';
    When TOO_MANY_ROWS then
        rep_sched_exist := 'Y';
    When others then
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create Rep Sched|checking existing Schedules'
            );
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end;

   If ( rep_sched_exist = 'Y' )  then
      For l_order_count in 1..p_kanban_card_rec_tbl.Count
      Loop
          total_qty := total_qty + p_kanban_card_rec_tbl(l_order_count).Kanban_size;
      End Loop;
   Else
*/

      For l_order_count in 1..p_kanban_card_rec_tbl.Count
         Loop
            if ( l_order_count = 1 ) THEN

               SELECT NVL(project_reference_enabled,2)
                 INTO l_project_reference_enabled
                 FROM mtl_parameters
                 WHERE organization_id = p_kanban_card_rec_tbl(1).organization_id;

               IF (l_project_reference_enabled = 1)THEN
                  IF (p_kanban_card_rec_tbl(1).locator_id IS NOT NULL)THEN
                     SELECT project_id
                       INTO l_project_id
                       FROM mtl_item_locations
                       WHERE inventory_location_id = p_kanban_card_rec_tbl(1).locator_id
                       AND organization_id = p_kanban_card_rec_tbl(1).organization_id;
                  END IF;
                  IF (l_project_id IS NOT NULL)THEN
                     SELECT task_id
                       INTO l_task_id
                       FROM mtl_item_locations
                       WHERE NVL(project_id,-999) = NVL(l_project_id, -111)
                       AND inventory_location_id =p_kanban_card_rec_tbl(1).locator_id
                       AND organization_id = p_kanban_card_rec_tbl(1).organization_id;
                  END IF;
               END IF;
               --3100874 Outbound Flow Sequencing
               --if the need_by_date is passed completion date should be set to the
               --value passed, otherwise just set the start date to sysdate
               IF p_kanban_card_rec_tbl(l_order_count).need_by_date IS NOT NULL THEN
                  l_first_unit_start_date := NULL;
                  l_last_unit_completion_date :=
                    p_kanban_card_rec_tbl(l_order_count).need_by_date;
                ELSE
                  /* For bug 7721127 Start */
              --  l_first_unit_start_date := Sysdate;
                /* Bug 9437363. Changed the parameter (l_order_count) for record count to 1 */
                  l_first_unit_start_date := Sysdate +
                  get_preprocessing_lead_time(p_kanban_card_rec_tbl(1).organization_id , p_kanban_card_rec_tbl(1).inventory_item_id);
                /* End of Bug 9437363 */
                /* For bug 7721127 Start */
                  l_last_unit_completion_date := NULL;
               END IF;
             Insert into WIP_JOB_SCHEDULE_INTERFACE
             (  LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                GROUP_ID,
                PROCESS_PHASE,
                PROCESS_STATUS,
                SOURCE_CODE,
                ORGANIZATION_ID,
                LOAD_TYPE,
                FIRST_UNIT_START_DATE,
--                FIRST_UNIT_COMPLETION_DATE,
          LAST_UNIT_COMPLETION_DATE,
                DAILY_PRODUCTION_RATE,
                PROCESSING_WORK_DAYS,
                PRIMARY_ITEM_ID,
                START_QUANTITY,
                STATUS_TYPE,
                line_id,
                project_id,
                task_id
                )
             values
                (
                SYSDATE ,
                FND_GLOBAL.USER_ID,
                SYSDATE ,
                FND_GLOBAL.USER_ID,
                p_kanban_card_rec_tbl(1).current_replnsh_cycle_id,
                2,
                1,
                'INV',
                p_kanban_card_rec_tbl(1).organization_id,
                 2,                     /*  Rep schedule */
                 l_first_unit_start_date,
                 l_last_unit_completion_date,
--      SYSDATE,
--      SYSDATE+(p_fixed_lead_time +
--     (p_var_lead_time*p_kanban_card_rec_tbl(l_order_count).kanban_size)),
                line_rate,
                p_kanban_card_rec_tbl(l_order_count).Kanban_size / line_rate ,
                p_kanban_card_rec_tbl(1).inventory_item_id,
                p_kanban_card_rec_tbl(l_order_count).Kanban_size,
                1,
                 p_kanban_card_rec_tbl(1).wip_line_id,
                 l_project_id,
                 l_task_id
                 );
            else
              total_qty := total_qty + p_kanban_card_rec_tbl(l_order_count).Kanban_size;
              rep_sched_exist := 'Y';
           end if;
      End loop;
--  End if;

   p_kanban_card_rec_tbl(1).document_type := 6;
   if ( rep_sched_exist = 'Y' ) then
      Update WIP_JOB_SCHEDULE_INTERFACE
        set     START_QUANTITY          = START_QUANTITY + total_qty ,
--              LAST_UNIT_COMPLETION_DATE = SYSDATE + (p_fixed_lead_time +
--                                          p_var_lead_time*(START_QUANTITY + total_qty)),
              PROCESSING_WORK_DAYS      = (START_QUANTITY + total_qty)/ line_rate,
              GROUP_ID               = p_kanban_card_rec_tbl(1).current_replnsh_cycle_id
      where
        primary_item_id         = p_kanban_card_rec_tbl(1).inventory_item_id AND
        organization_id         = p_kanban_card_rec_tbl(1).organization_id   AND
        line_id                 = p_kanban_card_rec_tbl(1).wip_line_id       AND
        load_type               = 2                                          AND
        process_phase           = 2                                          AND
        group_id                = p_kanban_card_rec_tbl(1).current_replnsh_cycle_id;
    end if;

    l_group_id := p_kanban_card_rec_tbl(1).current_replnsh_cycle_id;
    v_launch   := Launch_MLP( l_group_id );
    if ( Not v_launch ) then
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Rep_Schedule'
            );
        END IF;
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Rep_Schedule;

--
--     Create_Flow_schedule : This procedure would create a Wip
--                            Flow schedule.
--

Procedure Create_Flow_Schedule(
                           p_kanban_card_rec_tbl  IN Out NOCOPY Kanban_Card_Tbl_Type,
                           p_fixed_lead_time      IN NUMBER,
                           p_var_lead_time        IN NUMBER     ) IS

l_flow_schedule_rec       MRP_Flow_Schedule_PUB.Flow_Schedule_Rec_Type;
l_x_flow_schedule_rec     MRP_Flow_Schedule_PUB.Flow_Schedule_Rec_Type;
l_x_flow_schedule_val_rec MRP_Flow_Schedule_PUB.Flow_Schedule_Val_Rec_Type;
l_return_status           VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(240);
msg                       VARCHAR2(2000);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

 For l_order_count in 1..p_kanban_card_rec_tbl.Count
 Loop

   l_flow_schedule_rec.created_by                 := FND_GLOBAL.USER_ID;
   l_flow_schedule_rec.creation_date              := sysdate;
   l_flow_schedule_rec.last_updated_by            := FND_GLOBAL.USER_ID;
   l_flow_schedule_rec.last_update_date           := sysdate;
   l_flow_schedule_rec.line_id                    :=
                    p_kanban_card_rec_tbl(1).wip_line_id;
   l_flow_schedule_rec.organization_id            :=
                    p_kanban_card_rec_tbl(1).organization_id;
   l_flow_schedule_rec.planned_quantity           :=
                    p_kanban_card_rec_tbl(l_order_count).kanban_size;
   l_flow_schedule_rec.primary_item_id            :=
                    p_kanban_card_rec_tbl(1).inventory_item_id;
   l_flow_schedule_rec.completion_subinventory    :=
                    p_kanban_card_rec_tbl(1).subinventory_name;
   l_flow_schedule_rec.completion_locator_id    :=
                    p_kanban_card_rec_tbl(1).locator_id;

   IF p_kanban_card_rec_tbl(l_order_count).need_by_date IS NOT NULL THEN
      l_flow_schedule_rec.scheduled_start_date := NULL;
      l_flow_schedule_rec.scheduled_completion_date :=
        p_kanban_card_rec_tbl(l_order_count).need_by_date;

    ELSE

      /* l_flow_schedule_rec.scheduled_start_date  := SYSDATE;
      --   l_flow_schedule_rec.scheduled_completion_date  :=
      --                                                SYSDATE+(p_fixed_lead_time+
      --             (p_var_lead_time*p_kanban_card_rec_tbl(l_order_count).kanban_size)); */
      /* For bug 7721127 Start */
      /* Bug 9437363. Changed the parameter (l_order_count) for record count to 1 */
          l_flow_schedule_rec.scheduled_start_date := Sysdate +
          get_preprocessing_lead_time(p_kanban_card_rec_tbl(1).organization_id , p_kanban_card_rec_tbl(1).inventory_item_id);
      /* End of Bug 9437363 */
      /* For bug 7721127 Start */
      l_flow_schedule_rec.scheduled_completion_date :=
        MRP_LINE_SCHEDULE_ALGORITHM.calculate_completion_time
        (p_kanban_card_rec_tbl(1).organization_id,
         p_kanban_card_rec_tbl(1).inventory_item_id,
         p_kanban_card_rec_tbl(l_order_count).kanban_size,
         p_kanban_card_rec_tbl(1).wip_line_id,
         l_flow_schedule_rec.scheduled_start_date);   -- Bug # 8583249 :Instead of sysdate,passing the start date calculated for fix done for bug 7721127
   END IF;


--  l_flow_schedule_rec.schedule_group_id          :=
--                  p_kanban_card_rec_tbl(1).current_replnsh_cycle_id;
--  l_flow_schedule_rec.scheduled_by               := FND_API.G_MISS_NUM;
    l_flow_schedule_rec.kanban_card_id             :=
                    p_kanban_card_rec_tbl(l_order_count).kanban_card_id;
   l_flow_schedule_rec.operation                  := MRP_GLOBALS.G_OPR_CREATE;

        /* Requested by Liye Ma to add a new parameter p_explode_bom to this call
      to fix Flow Schedule Report bug 2147361
      Dependency: The signature change is in MRPPWFSS.pls 115.13 */

    MRP_Flow_Schedule_PUB.Process_Flow_Schedule
      (
        p_api_version_number     => 1.0,
        p_init_msg_list          => FND_API.G_TRUE,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,
        p_flow_schedule_rec      => l_flow_schedule_rec,
        x_flow_schedule_rec      => l_x_flow_schedule_rec,
        x_flow_schedule_val_rec  => l_x_flow_schedule_val_rec,
                  p_explode_bom      => 'Y'
       );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     p_kanban_card_rec_tbl(l_order_count).document_header_id :=
                                l_x_flow_schedule_rec.wip_entity_id;
     p_kanban_card_rec_tbl(l_order_count).document_type := 7;

  end loop;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Flow_Schedule'
            );
        END IF;

       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Create_Flow_Schedule;



--
--     Create_lot_based_job : This procedure would create a osfm
--                            lot based job
--

Procedure Create_lot_based_job(
                           p_kanban_card_rec_tbl  IN Out NOCOPY Kanban_Card_Tbl_Type,
                           p_fixed_lead_time      IN NUMBER,
                           p_var_lead_time        IN NUMBER     ) IS

l_return_status             VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(240);
msg                         VARCHAR2(2000);
l_header_id                 NUMBER := NULL;
l_reqid                     NUMBER := NULL;
l_group_id                  NUMBER := NULL;
l_mode_flag                 NUMBER := NULL;
l_job_name                  VARCHAR2(255);
l_first_unit_start_date     DATE;
l_last_unit_completion_date DATE;
l_debug                     NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
-- Following variable is added as a part of bug fix for bug # 3301126
l_scheduling_method         NUMBER := 2;

BEGIN

-- Following IF_ELSE block is a part of bug fix for bug # 3301126
  IF(to_number(NVL(FND_PROFILE.VALUE('WSM_CREATE_LBJ_COPY_ROUTING'),0)) = 1 ) THEN
     l_scheduling_method := 1;
  ELSE
     l_scheduling_method := 2;
  END IF;

 For l_order_count in 1..p_kanban_card_rec_tbl.Count

   LOOP

      select wsm_lot_sm_ifc_header_s.nextval
        into l_header_id
        from dual;



      select wsm_lot_job_interface_s.NEXTVAL
        into l_group_id
        from dual;

      IF p_kanban_card_rec_tbl(l_order_count).lot_number IS NULL THEN
         l_mode_flag := 1;
       ELSE
         l_mode_flag := 2;
      END IF;

      select FND_Profile.value('WIP_JOB_PREFIX')||wip_job_number_s.nextval
        INTO l_job_name
      from dual;
      --3100874 Outbound Flow Sequencing
      --if the need_by_date is passed completion date should be set to the
      --value passed, otherwise just set the start date to sysdate
      IF p_kanban_card_rec_tbl(l_order_count).need_by_date IS NOT NULL THEN
         l_first_unit_start_date := NULL;
         l_last_unit_completion_date :=
           p_kanban_card_rec_tbl(l_order_count).need_by_date;
       ELSE
          /* For bug 7721127 Start */
      --  l_first_unit_start_date := Sysdate;
        /* Bug 9437363. Changed the parameter (l_order_count) for record count to 1 */
          l_first_unit_start_date := Sysdate +
          get_preprocessing_lead_time(p_kanban_card_rec_tbl(1).organization_id , p_kanban_card_rec_tbl(1).inventory_item_id);
        /* End of Bug 9437363 */
        /* For bug 7721127 Start */
         l_last_unit_completion_date := NULL;
      END IF;


      INSERT INTO WSM_LOT_JOB_INTERFACE
        (mode_flag,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         group_id,
         source_line_id,
         organization_id,
         load_type,
         status_type,
         primary_item_id,
         job_name,
         start_Quantity,
         process_Status,
         first_unit_start_date,
         last_unit_completion_date,
         scheduling_method,
         completion_subinventory,
         completion_locator_id,
         class_code,
         description,
         bom_revision_date,
         routing_revision_date,
         header_id,
         kanban_card_id)
        VALUES
        (l_mode_flag,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         fnd_global.login_id,
         l_group_id,
         Decode(l_mode_flag, 1,null,l_header_id),
         p_kanban_card_rec_tbl(1).organization_id,
         5, --job creation
         3, --1:unreleased, 3: released
         p_kanban_card_rec_tbl(1).inventory_item_id,
         l_job_name,
         Nvl(p_kanban_card_rec_tbl(l_order_count).replenish_quantity,p_kanban_card_rec_tbl(l_order_count).kanban_size),
         1,
         l_first_unit_start_date,
         l_last_unit_completion_date,
         l_scheduling_method,
         p_kanban_card_rec_tbl(1).subinventory_name,
         p_kanban_card_rec_tbl(1).locator_id,
         '',
         null,
         '',
         '',
         l_header_id,
         p_kanban_card_rec_tbl(l_order_count).kanban_card_id);


      IF p_kanban_card_rec_tbl(l_order_count).lot_number IS NOT NULL THEN
         insert into wsm_starting_lots_interface
           (header_id,
            lot_number,
            inventory_item_id,
            revision,
            organization_id,
            quantity,
            subinventory_code,
            locator_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login )
           values
           ( l_header_id,
             p_kanban_card_rec_tbl(l_order_count).lot_number,
             p_kanban_card_rec_tbl(l_order_count).lot_item_id,
             p_kanban_card_rec_tbl(l_order_count).lot_item_revision,
             p_kanban_card_rec_tbl(l_order_count).organization_id,
             p_kanban_card_rec_tbl(l_order_count).lot_quantity,
             p_kanban_card_rec_tbl(l_order_count).lot_subinventory_code,
             p_kanban_card_rec_tbl(l_order_count).lot_location_id ,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id);


      END IF;
      p_kanban_card_rec_tbl(l_order_count).document_header_id := null;
      p_kanban_card_rec_tbl(l_order_count).document_type := 8;


      l_reqid :=  FND_REQUEST.SUBMIT_REQUEST (
                                              application => 'WSM',
                                              program => 'WSMPLBJI',
                                              sub_request => FALSE,
                                              argument1 =>  l_group_id);
      if ( l_reqid <= 0 ) then
         Raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
   end loop;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      Raise FND_API.G_EXC_ERROR;

   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
               ,   'Create_lot_based_job'
               );
      END IF;

      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Create_lot_based_job;



--
--       Create_Wip_Job() : This procedure will decide about the creation
--                          of a WIP replnsh mode.
--
Procedure Create_Wip_Job( p_kanban_card_rec_tbl  IN  OUT NOCOPY Kanban_Card_Tbl_Type,
                          p_need_by_date         IN DATE ,
                          x_card_supply_status   IN OUT NOCOPY Number ) IS

v_rep_flag         varchar2(1);
v_fixed_lead_time  number;
v_var_lead_time    number;
v_cfm_flag         number;
v_priority         number;
v_wip_line_id      number := NULL;
l_is_lot_control   VARCHAR2(1) := NULL;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   begin
      select nvl(repetitive_planning_flag,'N'), nvl(fixed_lead_time,0),
             nvl(variable_lead_time,0)
      into v_rep_flag, v_fixed_lead_time, v_var_lead_time
      from MTL_SYSTEM_ITEMS_KFV
      where
        inventory_item_id = p_kanban_card_rec_tbl(1).inventory_item_id  AND
        organization_id   = p_kanban_card_rec_tbl(1).organization_id;
   exception
      when others then
            FND_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
            ,   'Ist SQL stmt'
            );
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end;
 IF p_Kanban_Card_Rec_Tbl(1).wip_line_id is NULL then
    begin
     select nvl(cfm_routing_flag,0),line_id into v_cfm_flag, v_wip_line_id
     from BOM_OPERATIONAL_ROUTINGS
     where
        assembly_item_id = p_kanban_card_rec_tbl(1).inventory_item_id  AND
        organization_id  = p_kanban_card_rec_tbl(1).organization_id AND
        alternate_routing_designator is NULL;
    exception
       when NO_DATA_FOUND then
         v_cfm_flag := 2;
       when others then
            FND_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
            ,   'wip line id IS NULL'
            );
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end;


   if v_cfm_flag = 1 THEN


      p_Kanban_Card_Rec_Tbl(1).wip_line_id := v_wip_line_id;
      create_flow_schedule(p_kanban_card_rec_tbl, v_fixed_lead_time,
                                                  v_var_lead_time );
      x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_InProcess;
    elsif (v_cfm_flag = 3) AND (wsmpvers.get_osfm_release_version > '110508')
           THEN

       BEGIN
          SELECT 'Y' INTO l_is_lot_control
            FROM dual WHERE exists
            (SELECT 1 FROM mtl_system_items
             WHERE
             organization_id = p_kanban_card_rec_tbl(1).organization_id
             AND inventory_item_id = p_kanban_card_rec_tbl(1).inventory_item_id
             AND lot_control_code = 2);
       EXCEPTION
          WHEN OTHERS THEN
             l_is_lot_control := 'N';
       END;

       IF l_is_lot_control = 'Y' then

       create_lot_based_job(p_kanban_card_rec_tbl, v_fixed_lead_time,
                            v_var_lead_time );
       x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_InProcess;

       END IF;

/* Code modification for 2186198 */
    elsif v_rep_flag =  'Y' THEN

      BEGIN
         select line_id
         into v_wip_line_id
         from wip_repetitive_items
         where load_distribution_priority =
                             (select min(load_distribution_priority)
                              from wip_repetitive_items
                              where organization_id = p_kanban_card_rec_tbl(1).organization_id
                              and primary_item_id = p_kanban_card_rec_tbl(1).inventory_item_id
                              group by organization_id,primary_item_id)
         and organization_id = p_kanban_card_rec_tbl(1).organization_id
         and primary_item_id = p_kanban_card_rec_tbl(1).inventory_item_id
         and rownum < 2;
          p_Kanban_Card_Rec_Tbl(1).wip_line_id := v_wip_line_id;
      exception
                   when NO_DATA_FOUND then
                  FND_MESSAGE.SET_NAME('INV','INV_ATTRIBUTE_REQUIRED');
                        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','INV_WIP_LINE');
                         FND_MSG_PUB.Add;
                         Raise FND_API.G_EXC_ERROR;
                   when others then
                         FND_MSG_PUB.Add_Exc_Msg
                         (G_PKG_NAME ,'wip line id IS NULL');
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end ;
      create_rep_schedule(p_kanban_card_rec_tbl, v_fixed_lead_time,
                                                 v_var_lead_time );
      x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_InProcess;

   else
        Create_Wip_Discrete(p_kanban_card_rec_tbl, v_fixed_lead_time,
                                                   v_var_lead_time);
      x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_Empty;

   end if;

  ELSE  /* wip line id IS not NULL */

    begin
     select nvl(cfm_routing_flag,0) into v_cfm_flag
     from BOM_OPERATIONAL_ROUTINGS
     where
        assembly_item_id = p_kanban_card_rec_tbl(1).inventory_item_id  AND
        organization_id  = p_kanban_card_rec_tbl(1).organization_id    AND
        line_id          = p_kanban_card_rec_tbl(1).wip_line_id        AND
        nvl(priority,0)  = ( select min(nvl(priority,0))
                             from bom_operational_routings
                             where
                             assembly_item_id = p_kanban_card_rec_tbl(1).inventory_item_id  AND
                             organization_id  = p_kanban_card_rec_tbl(1).organization_id    AND
                             line_id          = p_kanban_card_rec_tbl(1).wip_line_id )  AND
        rownum < 2  ;
    exception
       when NO_DATA_FOUND then
         v_cfm_flag := 2;
       when others then
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'wip line id IS not NULL'
            );
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end;
    IF v_cfm_flag = 1 THEN

        create_flow_schedule(p_kanban_card_rec_tbl, v_fixed_lead_time,
                                                    v_var_lead_time );
        x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_InProcess;

     elsif (v_cfm_flag = 3) AND (wsmpvers.get_osfm_release_version > '110508') THEN

       BEGIN
          SELECT 'Y' INTO l_is_lot_control
            FROM dual WHERE exists
            (SELECT 1 FROM mtl_system_items
             WHERE
             organization_id = p_kanban_card_rec_tbl(1).organization_id
             AND inventory_item_id = p_kanban_card_rec_tbl(1).inventory_item_id
             AND lot_control_code = 2);
       EXCEPTION
          WHEN OTHERS THEN
             l_is_lot_control := 'N';
       END;

       IF l_is_lot_control = 'Y' then

          create_lot_based_job(p_kanban_card_rec_tbl, v_fixed_lead_time,
                               v_var_lead_time );
          x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_InProcess;

       END IF;


     elsif v_rep_flag =  'Y' THEN

      create_rep_schedule(p_kanban_card_rec_tbl, v_fixed_lead_time,
                                                 v_var_lead_time );
      x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_InProcess;
     ELSE

        Create_Wip_Discrete(p_kanban_card_rec_tbl, v_fixed_lead_time,
                                                   v_var_lead_time);
      x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_Empty;
   end if;

  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Wip_Job'
            );
        END IF;

       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
end Create_Wip_Job;

--
--
-- Create Replenishment: This procedure would create kick off the replenishment
--                        cycle for the kanban cards.
--
PROCEDURE Create_Replenishment
(p_Kanban_Card_Rec_Tbl   In Out NOCOPY Kanban_Card_Tbl_Type,
 p_lead_time             Number,
 x_card_supply_status    Out NOCOPY Number)
IS

l_Item_Description              Varchar2(240);
l_Source_type_code              Varchar2(30);
l_Requisition_type              Varchar2(30);
l_Primary_Uom_Code              Varchar2(3);
l_deliver_location_Id           Number;
l_Buyer_Id                      Number;
l_Encumb_Account_Id             Number;
l_Charge_Account_Id             Number;
l_Budget_Account_Id             Number;
l_Accrual_Account_Id            Number;
l_Invoice_Var_Account_Id        Number;
l_Inventory_Asset_Flag          Varchar2(1);
l_Interface_source_code         Varchar2(30) := 'INV';
l_Destination_type_code         Varchar2(30) := 'INVENTORY';
l_Approval                      Varchar2(30) := 'APPROVED';
l_Autosource_Flag               Varchar2(1)  := 'P';
l_need_by_date                  Date;
l_need_by_time                  Number;
l_PreProcess_lead_Time          Number;
l_Process_lead_Time             Number;
l_PostProcess_lead_Time         Number;
l_Encumb_Flag                   Varchar2(1);
l_PO_Org_Id                     Number       := null;
l_sql_stmt_no                   Number;
l_Revision                      Varchar2(3);
l_Revision_qty_control_code     Number;
l_Kanban_Card_Rec_Tbl           Kanban_Card_Tbl_Type;
p_card_supply_status            Number;
revision_profile                Number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
   mydebug('Inside create_replenishment');

   l_Kanban_Card_Rec_Tbl := p_Kanban_Card_Rec_Tbl;

        l_sql_stmt_no := 10;
        -- Bug # 5568749, Removed Buyer_Id from the select statement
        Select msi.Description,Primary_Uom_Code,Inventory_Asset_Flag,
               nvl(mss.ENCUMBRANCE_ACCOUNT,
                   nvl(msi.Encumbrance_Account,Org.Encumbrance_Account)),
               decode(msi.inventory_asset_flag, 'Y', mss.material_account,
                     nvl(mss.expense_account,nvl(msi.expense_account,org.expense_account))),
               Org.Ap_accrual_account,
               Org.invoice_price_var_account,
               nvl(mss.preprocessing_lead_time,nvl(msi.preprocessing_lead_time,0)),
               nvl(mss.processing_lead_time,nvl(msi.full_lead_time,0)),
               nvl(mss.postprocessing_lead_time,nvl(msi.postprocessing_lead_time,0)),
               msi.revision_qty_control_code
        Into   l_Item_Description,
               l_Primary_Uom_Code,
               l_Inventory_Asset_Flag,
               l_Encumb_Account_Id,
               l_Charge_Account_Id,
               l_Accrual_Account_Id,
               l_Invoice_Var_Account_Id,
               l_PreProcess_lead_Time,
               l_Process_lead_Time,
               l_PostProcess_lead_Time,
               l_Revision_qty_control_code
        From   Mtl_System_Items msi,
               mtl_Parameters org,
               mtl_secondary_inventories mss
        Where  Msi.Organization_Id   = l_kanban_card_Rec_Tbl(1).Organization_id
        And    Msi.Inventory_Item_Id = l_kanban_card_Rec_Tbl(1).Inventory_Item_Id
        And    org.Organization_Id   = l_kanban_card_Rec_Tbl(1).Organization_Id
        And    mss.Organization_id   = l_kanban_card_Rec_Tbl(1).Organization_id
        And    mss.secondary_inventory_name = l_kanban_card_Rec_Tbl(1).Subinventory_Name;

        Begin
                Select nvl(ENCUMBRANCE_ACCOUNT,l_Encumb_Account_Id),
                     nvl(preprocessing_lead_time,l_PreProcess_lead_Time)
                   + nvl(processing_lead_time,l_Process_lead_Time)
                   + nvl(postprocessing_lead_time,l_PostProcess_lead_Time)
                Into l_budget_Account_Id,
                     l_need_by_time
                From mtl_item_sub_inventories
                Where Organization_id = l_kanban_card_Rec_Tbl(1).Organization_id
                And   Inventory_Item_Id = l_kanban_card_Rec_Tbl(1).Inventory_Item_Id
                And   secondary_inventory = l_kanban_card_Rec_Tbl(1).Subinventory_Name;
        Exception
        When No_data_found
        Then
                l_need_by_time := l_PreProcess_lead_Time
                                  + l_Process_lead_Time
                                  + l_PostProcess_lead_Time;
                l_budget_Account_Id := l_Encumb_Account_Id;
        End;

        l_sql_stmt_no := 20;
        select nvl(f.req_encumbrance_flag,'N'),o.operating_unit
        into l_encumb_flag,l_po_org_Id
        from financials_system_params_all f,
             org_organization_definitions o
        where o.organization_id = l_kanban_card_Rec_Tbl(1).Organization_id
        And  nvl(f.org_id,-99)  = nvl(o.operating_unit,-99);

        IF l_kanban_card_Rec_Tbl(1).need_by_date IS NOT NULL THEN
           l_need_by_date := l_kanban_card_Rec_Tbl(1).need_by_date;
         ELSE
           l_sql_stmt_no := 30;
           select c1.calendar_date
             into l_need_by_date
             from mtl_parameters o,
             bom_calendar_dates c1,
             bom_calendar_dates c
             where o.organization_id   = l_kanban_card_Rec_Tbl(1).Organization_id
             and   c1.calendar_code    = c.calendar_code
             and   c1.exception_set_id = c.exception_set_id
             and   c1.seq_num          = (c.next_seq_num + trunc(nvl(p_lead_time,l_need_by_time)))
             and   c.calendar_code     = o.CALENDAR_CODE
             and   c.exception_set_id  = o.CALENDAR_EXCEPTION_SET_ID
             and   c.calendar_date     = trunc(sysdate);
        END IF;
        if l_kanban_card_Rec_Tbl(1).source_Type =
           INV_Kanban_PVT.G_Source_Type_InterOrg
        Then

                -- MOAC: Replaced the po_location_associations
                -- view with a _ALL table.
                l_sql_stmt_no := 40;
                -- Bug Fix 5185446 : Added distinct
                select distinct org.location_id
                into l_deliver_location_id
                from hr_organization_units org,
                     hr_locations          loc,
                     po_location_associations_all pla
                where org.organization_id =
                      l_kanban_card_Rec_Tbl(1).Organization_id
                and   org.location_id     = loc.location_id
                and   pla.location_id     = loc.location_id;

        Elsif l_kanban_card_Rec_Tbl(1).source_Type =
              INV_Kanban_PVT.G_Source_Type_Supplier
        Then

                l_sql_stmt_no := 40;
                select org.location_id
                into l_deliver_location_id
                from hr_organization_units org,
                     hr_locations          loc
                where org.organization_id =
                      l_kanban_card_Rec_Tbl(1).Organization_id
                and   org.location_id     = loc.location_id;

        end if;

 /* Bug 971203. Do not check for revision control code.Get the value from the
 profile and if the profile is Yes, then get revision */

        revision_profile :=  fnd_profile.value('INV_PURCHASING_BY_REVISION') ;
        if revision_profile = 1 then

                l_sql_stmt_no := 50;

                select MAX(revision)
                into   l_revision
                from   mtl_item_revisions mir
                where inventory_item_id = l_kanban_card_Rec_Tbl(1).Inventory_Item_Id
                and   organization_id   = l_kanban_card_Rec_Tbl(1).organization_Id
                and    effectivity_date < SYSDATE
                and    implementation_date is not null  /* Added for bug 7110794 */
                and    effectivity_date =
                       (
                         select MAX(effectivity_date)
                         from   mtl_item_revisions mir1
                         where  mir1.inventory_item_id = mir.inventory_item_id
                         and    mir1.organization_id = mir.organization_id
                         and    implementation_date is not null  /* Added for bug 7110794 */
                         and    effectivity_date < SYSDATE
                       );

        end if;


          l_sql_stmt_no := 60;

          select employee_id
          into l_buyer_id
          from fnd_user
          where user_id = FND_GLOBAL.USER_ID;



/*  Need to error */
/*
  if (charge_acct is NULL) or
        (accru_acct is NULL)  or
        (ipv_acct is NULL)  or
        ((encum_flag <> 'N') and (budget_acct is null)) then
       select meaning into msg
       from mfg_lookups
       where lookup_type = 'INV_MMX_RPT_MSGS'
       and lookup_code = 1;

       return(msg);
--     return ('Unable to generate requisition');
  end if;
*/

        If l_kanban_card_Rec_Tbl(1).source_type = INV_Kanban_PVT.G_Source_Type_InterOrg
        then
                l_source_type_code      := 'INVENTORY';
                l_Requisition_type      := 'INTERNAL';
                mydebug('create requisition INVENTORY INTERNAL');
                    Create_Requisition( l_buyer_id, l_interface_source_code,
                                        l_requisition_type, l_approval,
                                        l_source_type_code, l_kanban_card_rec_tbl,
                                        l_destination_type_code, l_deliver_location_id,
                                        l_revision, l_item_description,
                                        l_primary_uom_code, l_need_by_date,
                                        l_charge_account_id, l_accrual_account_id,
                                        l_invoice_var_account_id, l_budget_account_id,
                                        l_autosource_flag, l_po_org_id );
                 x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_Empty;
        elsIf l_kanban_card_Rec_Tbl(1).source_type = INV_Kanban_PVT.G_Source_Type_Supplier
        Then
                l_source_type_code      := 'VENDOR';
                l_Requisition_type      := 'PURCHASE';
                mydebug('create requisition VENDOR PURCHASE');
                    Create_Requisition( l_buyer_id, l_interface_source_code,
                                        l_requisition_type, l_approval,
                                        l_source_type_code, l_kanban_card_rec_tbl,
                                        l_destination_type_code, l_deliver_location_id,
                                        l_revision, l_item_description,
                                        l_primary_uom_code, l_need_by_date,
                                        l_charge_account_id, l_accrual_account_id,
                                        l_invoice_var_account_id, l_budget_account_id,
                                        l_autosource_flag, l_po_org_id );
                 x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_Empty;
        elsIf l_kanban_card_Rec_Tbl(1).source_type =
                                        INV_Kanban_PVT.G_Source_Type_IntraOrg
        Then
                l_source_type_code      := 'INVENTORY';
                l_Requisition_type      := 'TRANSFER';
                mydebug('create transfer order INVENTORY TRANSFER');
                Create_Transfer_Order(p_kanban_card_rec_tbl,l_need_by_date,l_Primary_Uom_Code);
                x_card_supply_status := INV_Kanban_PVT.G_Supply_Status_InProcess;

        elsIf l_kanban_card_Rec_Tbl(1).source_type =
                                        INV_Kanban_PVT.G_Source_Type_Production
        Then
                l_source_type_code      := 'PRODUCTION';
                l_Requisition_type      := 'MAKE';
                mydebug('create wip job PRODUCTION MAKE ');
                  Create_Wip_Job(p_kanban_card_rec_tbl, l_need_by_date,
                                                        p_card_supply_status);
                  x_card_supply_status := p_card_supply_status;
        else
                Return;
        end if;

EXCEPTION

    WHEN NO_data_FOUND Then

        If l_sql_stmt_no = 10
        Then
                FND_MESSAGE.SET_NAME('INV','INV-NO ITEM RECORD');
        Elsif l_sql_stmt_no = 20
        then
                FND_MESSAGE.SET_NAME('INV','INV-NO ORG INFORMATION');
        Elsif l_sql_stmt_no = 30
        Then
                FND_MESSAGE.SET_NAME('INV','INV-NO CALENDAR DATE');
        Elsif l_sql_stmt_no = 40
        Then
                FND_MESSAGE.SET_NAME('INV','INV_DEFAULT_DELIVERY_LOC_REQD');
        Elsif l_sql_stmt_no = 50
        Then
                FND_MESSAGE.SET_NAME('INV','INV_INT_REVCODE');
        Elsif l_sql_stmt_no = 60
        Then
                FND_MESSAGE.SET_NAME('FND','CONC-FDWHOAMI INVALID USERID');
                FND_MESSAGE.SET_TOKEN('USERID',to_char(FND_GLOBAL.USER_ID));
        End If;
        FND_MSG_PUB.Add;
        Raise FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN

       Raise FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Replenishment'
            );
        END IF;

       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

End Create_Replenishment;

--
-- Check_And_Create_Replenishment() : This procedure will check whether it is
--                                   ok to start replenishment cycle for a card.
--

PROCEDURE Check_And_Create_Replenishment
(x_return_status                  Out NOCOPY Varchar2,
 X_Supply_Status                  Out NOCOPY Number,
 X_Current_Replenish_Cycle_Id     Out NOCOPY Number,
 P_Kanban_Card_Rec                In  Out NOCOPY INV_Kanban_PVT.Kanban_Card_Rec_Type)
IS

l_Pull_Sequence_Rec          Mtl_Kanban_Pull_Sequences%RowType;
l_Wait_Kanban_card_Tbl       Kanban_Card_Tbl_Type;
l_Kanban_Card_Rec            INV_Kanban_PVT.Kanban_Card_Rec_Type;
l_Wait_Kanban_Size           Number := 0;
l_Card_Count                 Number := 0;
l_Order_Count                Number := 0;
l_Current_replenish_cycle_Id Number;
l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Kanban_Card_tbl            Kanban_Card_Tbl_Type;
p_card_supply_status         Number;


Cursor Get_Cards_On_Wait
Is
   Select Kanban_card_Id,kanban_size,
     NULL lot_item_id,null lot_number,NULL lot_item_revision,
     NULL lot_subinventory_code,NULL lot_location_id,NULL lot_quantity,
     NULL replenish_quantity
        From   Mtl_Kanban_Cards
        Where  Pull_Sequence_Id = p_Kanban_Card_Rec.Pull_Sequence_Id
--      And    Card_Status      = INV_Kanban_PVT.G_Card_Status_Active
        And    Supply_Status    = INV_Kanban_PVT.G_Supply_Status_Wait
        And Nvl(Supplier_Id,-1) = Nvl(p_Kanban_Card_Rec.Supplier_Id,-1)
        And Nvl(Supplier_Site_Id,-1)       =
            Nvl(p_Kanban_Card_Rec.Supplier_Site_Id,-1)
        And Nvl(Source_Organization_Id,-1) =
            Nvl(p_Kanban_Card_Rec.Source_Organization_Id,-1)
        And Nvl(Source_Subinventory,'#?#')    =
            Nvl(p_Kanban_Card_Rec.Source_Subinventory,'#?#')
        And Nvl(Source_Locator_Id,-1)      =
            Nvl(p_Kanban_Card_Rec.Source_Locator_Id,-1)
        And Nvl(wip_line_id,-1)            =
            Nvl(p_Kanban_Card_Rec.wip_line_id,-1)
        -- Following condition added as a bugfix for bug#3389681 to prevent consideration of
        -- current card if it is in wait status as it will be considered twice.
        And Kanban_card_Id <> p_Kanban_Card_Rec.Kanban_card_Id
        For Update Of Supply_Status NoWait;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

        l_Kanban_Card_tbl.delete;
        l_Wait_Kanban_card_Tbl.Delete;

        l_Order_Count := 1;

        l_Kanban_Card_tbl(l_Order_Count) := p_kanban_card_rec;

        If P_Kanban_Card_rec.Pull_sequence_Id = INV_Kanban_PVT.G_No_Pull_Sequence
           OR (P_Kanban_Card_Rec.kanban_card_type = INV_Kanban_PVT.G_Card_Type_NonReplenishable)
          Then
            l_Current_Replenish_Cycle_Id :=  Get_Next_Replenish_Cycle_Id;
            l_Kanban_Card_tbl(l_Order_Count).current_replnsh_cycle_id :=
                                                 l_Current_Replenish_Cycle_Id;
            Create_Replenishment(l_Kanban_Card_tbl,null, p_card_supply_status);
                X_Supply_Status              :=  p_card_supply_status;
                X_Current_Replenish_Cycle_Id :=  l_Current_Replenish_Cycle_Id;
        else
                Select *
                Into l_Pull_Sequence_Rec
                From Mtl_Kanban_Pull_Sequences
                Where Pull_Sequence_Id = P_Kanban_Card_Rec.Pull_Sequence_Id
                For Update Of Minimum_Order_Quantity NOWait;

                If nvl(l_Pull_Sequence_Rec.Minimum_Order_Quantity,0) = 0
                Then
                        l_Current_Replenish_Cycle_Id :=  Get_Next_Replenish_Cycle_Id;
                        l_Kanban_Card_tbl(l_Order_Count).current_replnsh_cycle_id :=  l_Current_Replenish_Cycle_Id;
                        Create_Replenishment(l_Kanban_Card_tbl,l_pull_sequence_rec.replenishment_lead_time, p_card_supply_status);
                        X_Supply_Status              :=  p_card_supply_status;
                        X_Current_Replenish_Cycle_Id :=  l_Current_Replenish_Cycle_Id;

                Elsif (P_Kanban_Card_Rec.Kanban_Size >=
                       l_Pull_Sequence_Rec.minimum_order_quantity)
                  OR (P_Kanban_Card_Rec.lot_number IS NOT NULL)
                Then

                        l_Current_Replenish_Cycle_Id :=  Get_Next_Replenish_Cycle_Id;
                        l_Kanban_Card_tbl(l_Order_Count).current_replnsh_cycle_id :=
                                l_Current_Replenish_Cycle_Id;
                        Create_Replenishment(l_Kanban_Card_tbl,l_pull_sequence_rec.replenishment_lead_time, p_card_supply_status);
                        X_Supply_Status              :=  p_card_supply_status;
                        X_Current_Replenish_Cycle_Id :=  l_Current_Replenish_Cycle_Id;

                Else

                    For l_kanban_card in Get_Cards_On_Wait
                    Loop

                        l_card_count       := l_card_count + 1;
                        l_Wait_Kanban_card_Tbl(l_card_count).Kanban_card_Id := l_kanban_card.Kanban_Card_Id;
                        l_Wait_Kanban_card_Tbl(l_card_count).Kanban_Size := l_kanban_card.Kanban_Size;
                        l_Wait_Kanban_Size := l_Wait_Kanban_Size + l_kanban_card.Kanban_Size;

                        l_Wait_Kanban_card_Tbl(l_card_count).lot_item_id := l_kanban_card.lot_item_id;
                        l_Wait_Kanban_card_Tbl(l_card_count).lot_number := l_kanban_card.lot_number;
                        l_Wait_Kanban_card_Tbl(l_card_count).lot_item_revision := l_kanban_card.lot_item_revision;
                        l_Wait_Kanban_card_Tbl(l_card_count).lot_subinventory_code := l_kanban_card.lot_subinventory_code;
                        l_Wait_Kanban_card_Tbl(l_card_count).lot_location_id := l_kanban_card.lot_location_id;
                        l_Wait_Kanban_card_Tbl(l_card_count).lot_quantity := l_kanban_card.lot_quantity;
                        l_Wait_Kanban_card_Tbl(l_card_count).replenish_quantity := l_kanban_card.replenish_quantity;

                    End Loop;

                    if (l_Wait_Kanban_Size + p_kanban_Card_rec.kanban_Size) >=
                        l_Pull_Sequence_Rec.Minimum_Order_Quantity
                    Then

                        l_Current_replenish_Cycle_Id := Get_Next_Replenish_Cycle_Id;
                        For l_card_Count in 1..l_Wait_Kanban_card_Tbl.Count
                        Loop

                            l_order_count := l_order_count + 1;
                            l_Kanban_card_Tbl(l_Order_Count).Kanban_card_Id :=
                                        l_Wait_Kanban_card_Tbl(l_Card_Count).Kanban_Card_Id;
                            l_Kanban_card_Tbl(l_Order_Count).Kanban_Size    :=
                                        l_Wait_Kanban_card_Tbl(l_Card_Count).Kanban_Size;

                        End Loop;

                        l_Kanban_Card_tbl(1).current_replnsh_cycle_id :=
                                                l_Current_Replenish_Cycle_Id;
          create_Replenishment(l_Kanban_card_Tbl,l_pull_sequence_rec.replenishment_lead_time, p_card_supply_status);
                X_Supply_Status              :=  p_card_supply_status;
                X_Current_Replenish_Cycle_Id :=  l_Current_Replenish_Cycle_Id;

                For l_card_Count in 2..l_Kanban_card_Tbl.Count
                Loop
                         Update Mtl_Kanban_Cards
                             Set  Supply_Status   = p_card_supply_status,
                                  Current_Replnsh_Cycle_Id = l_Current_Replenish_Cycle_Id,
                                     Last_Update_Date = SYSDATE,
                                     Last_Updated_By  =  FND_GLOBAL.USER_ID
                             Where Kanban_Card_Id = l_Kanban_card_Tbl(l_Card_Count).Kanban_card_Id;

          l_Kanban_Card_Rec.Kanban_card_Id :=
                           l_Kanban_card_Tbl(l_Card_Count).Kanban_card_Id;
           l_kanban_card_rec :=
                INV_KanbanCard_PKG.Query_Row( p_Kanban_Card_id  =>
                          l_Kanban_card_Tbl(l_Card_Count).Kanban_card_Id);
           l_kanban_card_rec.document_type :=
                    l_Kanban_card_Tbl(l_Card_Count).document_type;
           l_kanban_card_rec.document_header_id :=
                    l_Kanban_card_Tbl(l_Card_Count).document_header_id;
           l_kanban_card_rec.document_detail_id :=
                    l_Kanban_card_Tbl(l_Card_Count).document_detail_id;

           INV_KanbanCard_PKG.Insert_Activity_For_Card(l_Kanban_Card_Rec);

             End Loop;
          Else

                        X_Supply_Status              :=  INV_Kanban_PVT.G_Supply_Status_Wait;
                        X_Current_Replenish_Cycle_Id :=  Null;

                    End If;
                End If;
        End If;
        x_return_status := l_return_status;

        p_kanban_card_rec.document_type :=
                    l_Kanban_card_Tbl(1).document_type;
        p_kanban_card_rec.document_header_id :=
                    l_Kanban_card_Tbl(1).document_header_id;
        p_kanban_card_rec.document_detail_id :=
                    l_Kanban_card_Tbl(1).document_detail_id;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_And_Create_Replenishment'
            );
        END IF;

End Check_And_Create_Replenishment;

Procedure test  IS
   i                NUMBER := 0;
   l_pull_seq_id_tbl  INV_kanban_PVT.pull_sequence_id_Tbl_Type;
   l_return_status    VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
   l_operation_tbl    INV_Kanban_PVT.operation_tbl_type;/*This new local var has been added to
   keep in synch with the call to procedure update_pull_sequence_tbl */
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin

   For pull_seq_rec IN (select pull_sequence_id from MTL_KANBAN_PULL_SEQUENCES
                        Where Kanban_plan_id = -1 ) LOOP
      i := i + 1;
      l_pull_seq_id_tbl(i) := pull_seq_rec.pull_sequence_id ;
      l_operation_tbl(i) := 0; --Storing 0 for update
   END LOOP;

   update_pull_sequence_tbl( l_return_status, l_pull_seq_id_tbl, 'Y',l_operation_tbl );

   IF l_return_status IN ( FND_API.G_RET_STS_ERROR,
                        FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      Raise FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'test'
            );
        END IF;

END test;

PROCEDURE update_kanban_card_status
  (p_Card_Status                    IN Number,
   p_pull_sequence_id               IN Number)

  IS
     l_kanban_card_rec             INV_Kanban_PVT.kanban_card_rec_type;
     CURSOR get_kanban_card_ids IS
        SELECT kanban_card_id
        FROM mtl_kanban_cards
        WHERE pull_sequence_id = p_pull_sequence_id ;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   for kanban_cards_ids in get_kanban_card_ids
   LOOP
      l_kanban_card_rec := inv_kanbancard_pkg.query_row(kanban_cards_ids.kanban_card_id);
      inv_kanbancard_pkg.update_card_status
        (p_kanban_card_rec =>l_kanban_card_rec,
         p_card_status     => p_card_status);
   END LOOP;

END update_kanban_card_status;

PROCEDURE return_att_quantity(p_org_id       IN NUMBER,
                              p_item_id      IN NUMBER,
                              p_rev          IN VARCHAR2,
                              p_lot_no       IN VARCHAR2,
                              p_subinv       IN VARCHAR2,
                              p_locator_id   IN NUMBER,
                              x_qoh          OUT NOCOPY NUMBER,
                              x_atr          OUT NOCOPY NUMBER,
                              x_att          OUT NOCOPY NUMBER,
                              x_err_code     OUT NOCOPY NUMBER,
                              x_err_msg      OUT NOCOPY VARCHAR2)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   wsmputil.return_att_quantity(p_org_id       => p_org_id
                                ,p_item_id     => p_item_id
                                ,p_rev         => p_rev
                                ,p_lot_no      => p_lot_no
                                ,p_subinv      => p_subinv
                                ,p_locator_id  => p_locator_id
                                ,p_qoh         => x_qoh
                                ,p_atr         => x_atr
                                ,p_att         => x_att
                                ,p_err_code    => x_err_code
                                ,p_err_msg     => x_err_msg);

EXCEPTION
   WHEN OTHERS THEN
      x_qoh := NULL;
      x_atr := NULL;
      x_att := NULL;
      x_err_code := -1;
      x_err_msg  := Substr(Sqlerrm,1,255);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
               ,'return_att_quantity'
            );
      END IF;

END return_att_quantity;

PROCEDURE get_max_kanban_asmbly_qty
  ( p_bill_seq_id        IN NUMBER,
    P_COMPONENT_ITEM_ID  IN NUMBER,
    P_BOM_REVISION_DATE  IN DATE,
    P_START_SEQ_NUM      IN NUMBER,
    P_AVAILABLE_QTY      IN NUMBER,
    X_MAX_ASMBLY_QTY     OUT NOCOPY NUMBER,
    X_ERROR_CODE         OUT NOCOPY NUMBER,
    X_error_msg          OUT NOCOPY VARCHAR2)
  IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    wsmputil.get_max_kanban_asmbly_qty
        ( P_BILL_SEQ_ID                 => p_bill_seq_id,
          P_COMPONENT_ITEM_ID           => p_component_item_id,
          P_BOM_REVISION_DATE           => Nvl(p_bom_revision_date,Sysdate),
          P_START_SEQ_NUM               => p_start_seq_num,
          P_AVAILABLE_QTY               => p_available_qty,
          P_MAX_ASMBLY_QTY              => x_max_asmbly_qty,
          P_ERROR_CODE                  => x_error_code,
          p_error_msg                   => x_error_msg);
EXCEPTION
   WHEN OTHERS THEN
      x_max_asmbly_qty := NULL;
      x_error_code := -1;
      x_error_msg  := Substr(Sqlerrm,1,255);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
               ,'return_max_kanban_asmbly_qty'
            );
      END IF;

END get_max_kanban_asmbly_qty;

FUNCTION eligible_for_lbj
  (p_organization_id IN NUMBER,
   p_inventory_item_id IN NUMBER,
   p_source_type_id    IN NUMBER,
   p_kanban_card_id    IN NUMBER)
  RETURN VARCHAR2 IS
   l_source_type_id NUMBER := p_source_type_id;
   l_rep_flag  VARCHAR2(1) := NULL;
   l_lot_control NUMBER := NULL;
   l_cfm_flag NUMBER := NULL;
   l_assembly_item_id NUMBER := p_inventory_item_id;
   l_organization_id NUMBER := p_organization_id;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   --fnd_message.debug('Inside eligible');

   IF wsmpvers.get_osfm_release_version <= '110508' THEN
      RETURN 'N';
   ELSIF l_source_type_id = inv_kanban_pvt.g_source_type_production THEN
      --Source type production
      BEGIN
         select
           Nvl(repetitive_planning_flag,'N'), lot_control_code
           into
           l_rep_flag, l_lot_control
           from MTL_SYSTEM_ITEMS
           where
           inventory_item_id = l_assembly_item_id AND
           organization_id   = l_organization_id;
      EXCEPTION
         when others THEN
            RAISE fnd_api.g_exc_unexpected_error;
      end;

      --lot controlled
      IF l_rep_flag = 'N' AND l_lot_control = 2 THEN

         BEGIN
            SELECT nvl(cfm_routing_flag,0)
              into l_cfm_flag
              from BOM_OPERATIONAL_ROUTINGS
              where
              assembly_item_id = l_assembly_item_id AND
              organization_id  = l_organization_id AND
              alternate_routing_designator is NULL;
         EXCEPTION
            when no_data_found THEN
                 l_cfm_flag := 2;
            WHEN  OTHERS THEN
               RAISE fnd_api.g_exc_unexpected_error;
           END;



           IF l_cfm_flag = 3 THEN
              -- network routing hence return true
              RETURN 'Y';
      ELSE          --Bug# 3249105
         RETURN 'N';
           END IF;

       ELSE --rep_flag = 'Y' or not lot controlled
               RETURN 'N';
      END IF;

    ELSE --source_type <> production
               RETURN 'N';
   END IF;

   --fnd_message.debug(' end ');

EXCEPTION
   WHEN OTHERS  THEN
      RETURN 'N';
END eligible_for_lbj;

PROCEDURE GET_KANBAN_REC_GRP_INFO
  (p_organization_id     IN NUMBER,
   p_kanban_assembly_id  IN NUMBER,
   p_rtg_rev_date        IN DATE,
   x_bom_seq_id          OUT NOCOPY NUMBER,
   x_start_seq_num       OUT NOCOPY NUMBER,
   X_error_code          OUT NOCOPY NUMBER,
   X_error_msg           OUT NOCOPY VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   wsmputil.GET_KANBAN_REC_GRP_INFO(p_organization_id      => p_organization_id,
                                    p_kanban_assembly_id   => p_kanban_assembly_id,
                                    p_rtg_rev_date         => p_rtg_rev_date,
                                    p_bom_seq_id           => x_bom_seq_id,
                                    p_start_seq_num        => x_start_seq_num,
                                    p_error_code           => x_error_code,
                                    p_error_msg            => x_error_msg);

EXCEPTION
   WHEN OTHERS THEN
      x_error_code := -1;
      x_error_msg  := Substr(Sqlerrm,1,255);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         FND_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
               ,'GET_KANBAN_REC_GRP_INFO'
               );
      END IF;

END get_kanban_rec_grp_info;


/*Bug 3740514--New procedure to check if the card status should be updated.*/

/*Added arguements in the procedure for bug 7133795 */
PROCEDURE update_card_and_card_status(p_kanban_card_id IN NUMBER, p_supply_status IN NUMBER, p_document_detail_Id IN NUMBER, p_document_header_id IN NUMBER, p_update OUT NOCOPY BOOLEAN) IS

  CURSOR mtl_kca IS
      SELECT replenishment_cycle_id
           , document_header_id
           , document_detail_id
        FROM mtl_kanban_card_activity
       WHERE kanban_card_id = p_kanban_card_id
         AND document_header_id IS NOT NULL
    ORDER BY kanban_activity_id DESC;


  -- MOAC: Changed po_distributions to po_distributions_all.

  CURSOR po_dist(po_rel_id NUMBER, po_dist_id NUMBER) IS
    SELECT NVL(quantity_delivered, 0)
      FROM po_distributions_all
     WHERE po_release_id = po_rel_id
       AND po_distribution_id = po_dist_id;

  l_rep_cycl_id    NUMBER;
  l_crd_doc_hdr_id NUMBER;
  l_crd_doc_det_id NUMBER;
  l_max_rep_id     NUMBER;
  l_del_qty        NUMBER := -33;
  l_doc_type_id    NUMBER;
  -- l_max_req        NUMBER;/*Bug#4490269*/ /* Bug 7133795 */
  l_req            NUMBER;/*Bug#4490269*/


BEGIN

  p_update  := TRUE;   -- By Default update the kanban card and kanban card activity

  -- Bug 3987589; Added the AND condition 'AND document_type <> fnd_api.g_miss_num' and the exception block
  IF p_supply_status = INV_Kanban_PVT.G_Supply_Status_Full THEN /*Bug 4490269*/

  BEGIN
    SELECT document_type
        , replenishment_cycle_id
      INTO l_doc_type_id
         , l_max_rep_id
      FROM mtl_kanban_card_activity
     WHERE kanban_card_id = p_kanban_card_id
       AND document_type IS NOT NULL
       AND document_type <> fnd_api.g_miss_num
       AND replenishment_cycle_id = (SELECT MAX(replenishment_cycle_id)
                                       FROM mtl_kanban_card_activity
                                      WHERE kanban_card_id = p_kanban_card_id);
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      mydebug('Multiple document types and maximum replenishment cycle id returned for kanban card Id ' || p_kanban_card_id||' ;Hence disallowing Supply status update');
      p_update  := FALSE;
      RETURN;
  END;

  mydebug('Document type, maximum Replenishment cycle Id for kanban card Id ' || p_kanban_card_id || ': ' || l_doc_type_id || ', '
    || l_max_rep_id);

  /* Only if the document type is Blanket Release, then continue */

  IF (l_doc_type_id IN (inv_kanban_pvt.g_doc_type_release,INV_kanban_PVT.G_Doc_type_PO)) THEN
    OPEN mtl_kca;

    FETCH mtl_kca
     INTO l_rep_cycl_id
        , l_crd_doc_hdr_id
        , l_crd_doc_det_id;

    CLOSE mtl_kca;

    IF (l_rep_cycl_id IS NOT NULL
        AND l_crd_doc_hdr_id IS NOT NULL
        AND l_crd_doc_det_id IS NOT NULL) THEN
      IF l_rep_cycl_id = l_max_rep_id THEN
        OPEN po_dist(l_crd_doc_hdr_id, l_crd_doc_det_id);

        FETCH po_dist
         INTO l_del_qty;

        CLOSE po_dist;
      ELSE
        p_update  := FALSE;
      END IF;

      /* If the delivered quantity is 0, then Correction/Return/Receipt/Receiving Transaction of some other
         Release is trying to update the card and card activity status, which should not be allowed */
      IF (l_del_qty = 0) THEN
        p_update  := FALSE;
      END IF;
    END IF;   -- if l_rep_cycl_id IS NOT NULL ....
  END IF;   -- if l_doc_type_id = INV_kanban_PVT.G_Doc_type_Release

   /*Bug#4490268--If InProcess, then need to check for any pending requsitions/PO/Release*/
    ELSIF p_supply_status = INV_Kanban_PVT.G_Supply_Status_InProcess THEN

        -- Commented the below code for the bug # 7133795
  /*   SELECT max(requisition_line_id) into l_max_req
       FROM po_requisition_lines
       WHERE kanban_card_id = p_kanban_card_id;

        BEGIN
         SELECT 1 INTO l_req
         FROM po_requisitions_interface
         WHERE kanban_card_id = p_kanban_card_id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
         BEGIN
          SELECT 1 INTO l_req
          FROM po_requisition_lines
          WHERE kanban_card_id = p_kanban_card_id
          AND requisition_line_id = l_max_req
          AND line_location_id IS NULL;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
          BEGIN
           SELECT 1 INTO l_req
           FROM po_requisition_lines prl1
           WHERE prl1.kanban_card_id = p_kanban_card_id
           AND prl1.requisition_line_id = l_max_req
           AND prl1.line_location_id IS NOT NULL
           AND (EXISTS (SELECT '1' FROM po_headers poh
                        WHERE EXISTS ( SELECT '1' FROM po_line_locations pll
                                         WHERE pll.line_location_id = prl1.line_location_id
                                       AND   pll.po_header_id = poh.po_header_id
                                       AND   nvl(poh.authorization_status,'%%') <> 'APPROVED'))
                OR EXISTS (SELECT '1' FROM po_releases pr
                           WHERE EXISTS ( SELECT '1' FROM po_line_locations pll
                                          WHERE pll.line_location_id = prl1.line_location_id
                                            AND   pll.po_release_id = pr.po_release_id
                                          AND   nvl(pr.authorization_status,'%%') <> 'APPROVED')));
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
           l_req := 0;
          END;
         END;
        END;  */  -- Added the below code for the bug # 7133795

         IF ( p_document_detail_Id IS NOT NULL AND p_document_header_id IS NOT NULL)  THEN
            BEGIN
                SELECT 1 INTO l_req
                FROM mtl_kanban_card_activity
                WHERE kanban_card_id = p_kanban_card_id AND
                document_detail_Id = p_document_detail_Id AND
                Document_header_id = p_Document_header_id;
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
             l_req := 0;
             END;
          END IF;

        IF l_req = 1 THEN
           p_update := FALSE;
        END IF;
   -- End of changes for bug # 7133795
    END IF;

END update_card_and_card_status;


/* The following procedure Auto_Allocate_Kanban is added for 3905884.
   This procedure automatically allocates the move order created for a Kanaban
   Replenishment if the auto_allocate flag is set to "Yes" */

PROCEDURE Auto_Allocate_Kanban (
 p_mo_header_id    IN            NUMBER   ,
 x_return_status   OUT NOCOPY    VARCHAR2 ,
 x_msg_count       OUT NOCOPY    NUMBER  ,
 x_msg_data        OUT NOCOPY    VARCHAR2
 ) IS

      l_txn_header_id       NUMBER;
      l_txn_temp_id         NUMBER;
      l_number_of_rows      NUMBER        := 0;
      l_detailed_quantity   NUMBER        := 0;
      l_revision            VARCHAR2(100) := NULL;
      l_from_locator_id     NUMBER        := 0;
      l_to_locator_id       NUMBER        := 0;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
      l_lot_number          VARCHAR2(80);
      l_expiration_date     DATE;
      l_serial_control_code VARCHAR2(1)  ;
      l_move_order_type     NUMBER        := INV_GLOBALS.G_MOVE_ORDER_REPLENISHMENT;
      l_failed_lines        NUMBER        := 0;
      l_return_status       VARCHAR2(1);
      l_msg_count           NUMBER  ;
      l_msg_data            VARCHAR2(2000);
      l_debug               NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


       /*Cursor to get mo line informations */
      CURSOR mo_lines_cur IS
        SELECT MTRL.line_id , MTRL.inventory_item_id,MTRL.organization_id,MTRL.quantity
        FROM MTL_TXN_REQUEST_LINES MTRL
        WHERE MTRL.header_id = p_mo_header_id;

      l_mo_line_rec mo_lines_cur%ROWTYPE;
BEGIN
     IF (l_debug = 1 ) THEN
       inv_pick_wave_pick_confirm_pub.tracelog('In Auto_Allocate_Kanban ...','INV_KANBAN_PVT');
     END IF;

     OPEN mo_lines_cur;

     LOOP
            FETCH mo_lines_cur INTO l_mo_line_rec;
            EXIT WHEN mo_lines_cur%NOTFOUND;

            /*Get the next header id*/
            SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_txn_header_id
            FROM DUAL;

             /* Check whether item is serial controlled or not */
            SELECT DECODE(serial_number_control_code,1,'F','T')
            INTO   l_serial_control_code
            FROM   mtl_system_items
            WHERE  inventory_item_id = l_mo_line_rec.inventory_item_id
            AND    organization_id = l_mo_line_rec.organization_id;

            INV_Replenish_Detail_PUB.Line_Details_PUB (
              p_line_id              => l_mo_line_rec.line_id,
              x_number_of_rows       => l_number_of_rows,
              x_detailed_qty         => l_detailed_quantity,
              x_return_status        => x_return_status,
              x_msg_count            => l_msg_count,
              x_msg_data             => l_msg_data ,
              x_revision             => l_revision,
              x_locator_id           => l_from_locator_id ,
              x_transfer_to_location => l_to_locator_id,
              x_lot_number           => l_lot_number,
              x_expiration_date      => l_expiration_date,
              x_transaction_temp_id  => l_txn_temp_id,
              p_transaction_header_id=> l_txn_header_id,
              p_transaction_mode     => NULL ,
              p_move_order_type      => l_move_order_type,
              p_serial_flag          => l_serial_control_code,
              p_plan_tasks           => FALSE  ,
              p_commit               => TRUE
           );

           update mtl_txn_request_lines
           set quantity_detailed = l_detailed_quantity
           where line_id=l_mo_line_rec.line_id;

           IF (l_debug = 1 ) THEN
             inv_pick_wave_pick_confirm_pub.tracelog('In Auto_Allocate_Kanban : the  line '||l_mo_line_rec.line_id ||' return status :'||
                 x_return_status ||  'number_of_rows:' || l_number_of_rows ||' detailed_qty:'||l_detailed_quantity ||
                ' revision:'||l_revision||' from_locator_id:'||l_from_locator_id||' to_location:'||l_to_locator_id ||
                'lot_number:' || l_lot_number || ' transaction_temp_id' || l_txn_header_id ,'INV_KANBAN_PVT');
            END IF;

           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS
               OR  l_mo_line_rec.quantity <> l_detailed_quantity )
           THEN
              l_failed_lines := l_failed_lines + 1;   --count the unallocated lines.
           END IF;
     END LOOP;
     CLOSE mo_lines_cur;

     IF  l_failed_lines > 0 THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
         x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF;

     IF (l_debug = 1 ) THEN
      inv_pick_wave_pick_confirm_pub.tracelog('In Auto_Allocate_Kanban : return status :'||x_return_status||' msg:'||x_msg_data,'INV_KANBAN_PVT');
     END IF;
EXCEPTION
   WHEN OTHERS THEN
     IF (l_debug = 1 ) THEN
       inv_pick_wave_pick_confirm_pub.tracelog('In Auto_Allocate_Kanban : Exception : When Others','INV_KANBAN_PVT');
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
END Auto_Allocate_Kanban;

/* Added below function for bug 7721127 */
FUNCTION get_preprocessing_lead_time( p_organization_id   IN NUMBER,
                                 p_inventory_item_id IN NUMBER)
        RETURN NUMBER
IS
        l_preprocessing_lead_time NUMBER;
BEGIN

        SELECT NVL(preprocessing_lead_time,0)
        INTO   l_preprocessing_lead_time
        FROM   mtl_system_items_b
        WHERE  inventory_item_id = p_inventory_item_id
           AND organization_id   = p_organization_id ;

        mydebug('In get_preprocessing_lead_time : l_preprocessing_lead_time :'||l_preprocessing_lead_time);

        RETURN l_preprocessing_lead_time ;
EXCEPTION
WHEN OTHERS THEN
       mydebug('In get_preprocessing_lead_time : Exception : When Others'|| sqlerrm);
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
END get_preprocessing_lead_time;


END INV_Kanban_PVT;

/
