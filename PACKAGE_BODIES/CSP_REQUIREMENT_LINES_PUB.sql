--------------------------------------------------------
--  DDL for Package Body CSP_REQUIREMENT_LINES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_REQUIREMENT_LINES_PUB" AS
/* $Header: cspprqlb.pls 120.0.12010000.1 2010/03/17 16:46:33 htank noship $ */
-- Start of Comments
-- Package name     : CSP_REQUIREMENT_LINES_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_LINES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspprqlb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public REQUIREMENT_LINES record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private REQUIREMENT_LINES record is returned for the private
-- API call.
--
-- Conversions:
--
-- Notes
--
-- 1. IDs take precedence over values. If both are present for a field, ID is used,
--    the value based parameter is ignored and a warning message is created.
-- 2. This is automatically generated procedure, it converts public record type to
--    private record type for all attributes.
--    Developer must manually add conversion logic to the attributes.
--
-- End of Comments
PROCEDURE Convert_RQL_Values_To_Ids(
         P_RQL_Tbl        IN   CSP_REQUIREMENT_LINES_PUB.RQL_Tbl_Type,
         x_pvt_RQL_tbl    OUT  NOCOPY   CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Tbl_Type
)
IS
l_any_errors       BOOLEAN   := FALSE;
l_pvt_RQL_rec       CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type;
l_RQL_rec           CSP_REQUIREMENT_LINES_PUB.RQL_Rec_Type;
l_inventory_item_id           Number;
 -- Hint: Declare cursor and local variables
 CURSOR C_Get_Item_Id IS
   SELECT inventory_item_id
   FROM   mtl_system_items_b
   WHERE  decode(nvl(l_RQL_rec.SEGMENT1, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT1) = nvl(SEGMENT1, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT2, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT2) = nvl(SEGMENT2, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT3, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT3) = nvl(SEGMENT3, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT4, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT4) = nvl(SEGMENT4, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT5, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT5) = nvl(SEGMENT5, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT6, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT6) = nvl(SEGMENT6, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT7, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT7) = nvl(SEGMENT7, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT8, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT8) = nvl(SEGMENT8, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT9, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT9) = nvl(SEGMENT9, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT10, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT10) = nvl(SEGMENT10, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT11, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT11) = nvl(SEGMENT11, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT12, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT12) = nvl(SEGMENT12, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT13, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT13) = nvl(SEGMENT13, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT14, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT14) = nvl(SEGMENT14, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT15, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT15) = nvl(SEGMENT15, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT16, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT16) = nvl(SEGMENT16, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT17, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT17) = nvl(SEGMENT17, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT18, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT18) = nvl(SEGMENT18, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT19, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT19) = nvl(SEGMENT19, '####')
   AND decode(nvl(l_RQL_rec.SEGMENT20, FND_API.G_MISS_CHAR), FND_API.G_MISS_CHAR, '####', l_RQL_rec.SEGMENT20) = nvl(SEGMENT20, '####')
   AND organization_id = cs_std.get_item_valdn_orgzn_id;
  EXCP_USER_DEFINED EXCEPTION;
BEGIN
  FOR I IN 1..p_RQL_Tbl.count LOOP
    l_RQL_rec := P_RQL_Tbl(I);
    If(l_RQL_rec.inventory_item_id is NOT NULL and l_RQL_rec.inventory_item_id <> FND_API.G_MISS_NUM) THEN
       x_pvt_RQL_Tbl(I).inventory_item_id := l_RQL_rec.inventory_item_id;
    ELSIF((l_RQL_rec.SEGMENT1 is NOT NULL and l_RQL_rec.SEGMENT1 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT2 is NOT NULL and l_RQL_rec.SEGMENT2 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT3 is NOT NULL and l_RQL_rec.SEGMENT3 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT4 is NOT NULL and l_RQL_rec.SEGMENT4 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT5 is NOT NULL and l_RQL_rec.SEGMENT5 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT6 is NOT NULL and l_RQL_rec.SEGMENT6 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT7 is NOT NULL and l_RQL_rec.SEGMENT7 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT8 is NOT NULL and l_RQL_rec.SEGMENT8 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT9 is NOT NULL and l_RQL_rec.SEGMENT9 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT10 is NOT NULL and l_RQL_rec.SEGMENT10 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT11 is NOT NULL and l_RQL_rec.SEGMENT11 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT12 is NOT NULL and l_RQL_rec.SEGMENT12 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT13 is NOT NULL and l_RQL_rec.SEGMENT13 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT14 is NOT NULL and l_RQL_rec.SEGMENT14 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT15 is NOT NULL and l_RQL_rec.SEGMENT15 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT16 is NOT NULL and l_RQL_rec.SEGMENT16 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT17 is NOT NULL and l_RQL_rec.SEGMENT17 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT18 is NOT NULL and l_RQL_rec.SEGMENT18 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT19 is NOT NULL and l_RQL_rec.SEGMENT19 <> FND_API.G_MISS_CHAR) OR
          (l_RQL_rec.SEGMENT20 is NOT NULL and l_RQL_rec.SEGMENT20 <> FND_API.G_MISS_CHAR))
     THEN
       OPEN C_Get_Item_Id;
       FETCH C_Get_Item_Id INTO l_inventory_item_id;
       IF  C_Get_Item_Id%NOTFOUND THEN
          FND_MESSAGE.SET_NAME ('INV', 'INV_INVALID_ITEM');
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
       END IF;
       CLOSE C_Get_Item_Id;
       x_pvt_RQL_Tbl(I).inventory_item_id := l_inventory_item_id;
    ELSE
       x_pvt_RQL_Tbl(I).inventory_item_id := nvl(p_RQL_Tbl(I).inventory_item_id, NULL);
    END IF;

  -- Now copy the rest of the columns to the private record
  -- Hint: We provide copy all columns to the private record.
  --       Developer should delete those fields which are used by Value-Id conversion above
    -- Hint: Developer should remove some of the following statements because of inconsistent column name between table and view.

    x_pvt_RQL_Tbl(I).REQUIREMENT_LINE_ID := p_RQL_Tbl(I).REQUIREMENT_LINE_ID;
    x_pvt_RQL_Tbl(I).CREATED_BY := p_RQL_Tbl(I).CREATED_BY;
    x_pvt_RQL_Tbl(I).CREATION_DATE := p_RQL_Tbl(I).CREATION_DATE;
    x_pvt_RQL_Tbl(I).LAST_UPDATED_BY := p_RQL_Tbl(I).LAST_UPDATED_BY;
    x_pvt_RQL_Tbl(I).LAST_UPDATE_DATE := p_RQL_Tbl(I).LAST_UPDATE_DATE;
    x_pvt_RQL_Tbl(I).LAST_UPDATE_LOGIN := p_RQL_Tbl(I).LAST_UPDATE_LOGIN;
    x_pvt_RQL_Tbl(I).REQUIREMENT_HEADER_ID := p_RQL_Tbl(I).REQUIREMENT_HEADER_ID;
    --x_pvt_RQL_Tbl(I).INVENTORY_ITEM_ID := p_RQL_Tbl(I).INVENTORY_ITEM_ID;
    x_pvt_RQL_Tbl(I).UOM_CODE := p_RQL_Tbl(I).UOM_CODE;
    x_pvt_RQL_Tbl(I).REQUIRED_QUANTITY := p_RQL_Tbl(I).REQUIRED_QUANTITY;
    x_pvt_RQL_Tbl(I).SHIP_COMPLETE_FLAG := p_RQL_Tbl(I).SHIP_COMPLETE_FLAG;
    x_pvt_RQL_Tbl(I).LIKELIHOOD := p_RQL_Tbl(I).LIKELIHOOD;
    x_pvt_RQL_Tbl(I).REVISION := p_RQL_Tbl(I).REVISION;
    x_pvt_RQL_Tbl(I).SOURCE_ORGANIZATION_ID := p_RQL_Tbl(I).SOURCE_ORGANIZATION_ID;
    x_pvt_RQL_Tbl(I).SOURCE_SUBINVENTORY := p_RQL_Tbl(I).SOURCE_SUBINVENTORY;
    x_pvt_RQL_Tbl(I).ORDERED_QUANTITY := p_RQL_Tbl(I).ORDERED_QUANTITY;
    x_pvt_RQL_Tbl(I).ORDER_LINE_ID := p_RQL_Tbl(I).ORDER_LINE_ID;
    x_pvt_RQL_Tbl(I).RESERVATION_ID := p_RQL_Tbl(I).RESERVATION_ID;
    x_pvt_RQL_Tbl(I).ATTRIBUTE_CATEGORY := p_RQL_Tbl(I).ATTRIBUTE_CATEGORY;
    x_pvt_RQL_Tbl(I).ATTRIBUTE1 := p_RQL_Tbl(I).ATTRIBUTE1;
    x_pvt_RQL_Tbl(I).ATTRIBUTE2 := p_RQL_Tbl(I).ATTRIBUTE2;
    x_pvt_RQL_Tbl(I).ATTRIBUTE3 := p_RQL_Tbl(I).ATTRIBUTE3;
    x_pvt_RQL_Tbl(I).ATTRIBUTE4 := p_RQL_Tbl(I).ATTRIBUTE4;
    x_pvt_RQL_Tbl(I).ATTRIBUTE5 := p_RQL_Tbl(I).ATTRIBUTE5;
    x_pvt_RQL_Tbl(I).ATTRIBUTE6 := p_RQL_Tbl(I).ATTRIBUTE6;
    x_pvt_RQL_Tbl(I).ATTRIBUTE7 := p_RQL_Tbl(I).ATTRIBUTE7;
    x_pvt_RQL_Tbl(I).ATTRIBUTE8 := p_RQL_Tbl(I).ATTRIBUTE8;
    x_pvt_RQL_Tbl(I).ATTRIBUTE9 := p_RQL_Tbl(I).ATTRIBUTE9;
    x_pvt_RQL_Tbl(I).ATTRIBUTE10 := p_RQL_Tbl(I).ATTRIBUTE10;
    x_pvt_RQL_Tbl(I).ATTRIBUTE11 := p_RQL_Tbl(I).ATTRIBUTE11;
    x_pvt_RQL_Tbl(I).ATTRIBUTE12 := p_RQL_Tbl(I).ATTRIBUTE12;
    x_pvt_RQL_Tbl(I).ATTRIBUTE13 := p_RQL_Tbl(I).ATTRIBUTE13;
    x_pvt_RQL_Tbl(I).ATTRIBUTE14 := p_RQL_Tbl(I).ATTRIBUTE14;
    x_pvt_RQL_Tbl(I).ATTRIBUTE15 := p_RQL_Tbl(I).ATTRIBUTE15;
    x_pvt_RQL_Tbl(I).ARRIVAL_DATE := p_RQL_Tbl(I).ARRIVAL_DATE;
    x_pvt_RQL_Tbl(I).ITEM_SCRATCHPAD := p_RQL_Tbl(I).ITEM_SCRATCHPAD;
    x_pvt_RQL_Tbl(I).SHIPPING_METHOD_CODE := p_RQL_Tbl(I).SHIPPING_METHOD_CODE;
    x_pvt_RQL_Tbl(I).LOCAL_RESERVATION_ID := p_RQL_Tbl(I).LOCAL_RESERVATION_ID;
    x_pvt_RQL_Tbl(I).SOURCED_FROM := p_RQL_Tbl(I).SOURCED_FROM;

  END LOOP;
  -- If there is an error in conversion precessing, raise an error.
/*    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;
*/
END Convert_RQL_Values_To_Ids;

PROCEDURE Validate_Requirement_Lines(l_pvt_RQL_Tbl IN CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Tbl_Type) IS
l_count NUMBER;
EXCP_USER_DEFINED EXCEPTION;
BEGIN
  FOR I IN 1..l_pvt_RQL_TBL.COUNT LOOP
    IF (l_pvt_RQL_Tbl(I).requirement_header_id IS NOT NULL
        AND l_pvt_RQL_Tbl(I).requirement_header_id <> FND_API.G_MISS_NUM)THEN
      BEGIN
        SELECT count(requirement_header_id)
        INTO l_count
        FROM csp_requirement_headers
        WHERE requirement_header_id = l_pvt_RQL_Tbl(I).requirement_header_id;
        IF (l_count <= 0) THEN
          fnd_message.set_name('CSP', 'CSP_INVALID_RQMT_HEADER');
          fnd_message.set_token('HEADER_ID', to_char(l_pvt_RQL_Tbl(I).requirement_header_id), FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;
      EXCEPTION
        when no_Data_found then
          null;
      END;
    END IF;
    IF (l_pvt_RQL_Tbl(I).inventory_item_id IS NOT NULL
        AND l_pvt_RQL_Tbl(I).inventory_item_id <> FND_API.G_MISS_NUM) THEN
      BEGIN
        SELECT count(inventory_item_id)
        INTO l_count
        FROM mtl_system_items_b
        WHERE inventory_item_id = l_pvt_RQL_Tbl(I).inventory_item_id;
        IF (l_count <= 0) THEN
          FND_MESSAGE.SET_NAME ('INV', 'INV_INVALID_ITEM');
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;
      EXCEPTION
        when no_Data_found then
          null;
      END;
    END IF;
    IF (l_pvt_RQL_Tbl(I).source_organization_id IS NOT NULL
        AND l_pvt_RQL_Tbl(I).source_organization_id <> FND_API.G_MISS_NUM) THEN
      BEGIN
        SELECT count(organization_id)
        INTO l_count
        FROM mtl_parameters
        WHERE organization_id = l_pvt_RQL_Tbl(I).source_organization_id;
        IF (l_count <= 0) THEN
          FND_MESSAGE.SET_NAME ('INV', 'INV_IOI_SOURCE_ORG_ID');
          --FND_MESSAGE.SET_TOKEN ('PARAMETER', 'SOURCE_ORGANIZATION', FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;
      EXCEPTION
        when no_Data_found then
          null;
      END;
    END IF;
    IF (l_pvt_RQL_Tbl(I).uom_code IS NOT NULL
        AND l_pvt_RQL_Tbl(I).uom_code <> FND_API.G_MISS_CHAR) THEN
      BEGIN
        SELECT count(uom_code)
        INTO l_count
        FROM mtl_item_uoms_view
        WHERE inventory_item_id = l_pvt_RQL_Tbl(I).inventory_item_id
        AND organization_id =
              decode(nvl(l_pvt_RQL_Tbl(I).source_organization_id, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, organization_id, l_pvt_RQL_Tbl(I).source_organization_id)
        AND uom_code = l_pvt_RQL_Tbl(I).uom_code;
        IF (l_count <= 0) THEN
          FND_MESSAGE.SET_NAME ('WSH', 'WSH_OI_INVALID_UOM');
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;
      EXCEPTION
        when no_Data_found then
          null;
      END;
    END IF;
    IF (l_pvt_RQL_Tbl(I).revision IS NOT NULL
        AND l_pvt_RQL_Tbl(I).revision <> FND_API.G_MISS_CHAR) THEN
      BEGIN
        SELECT count(revision)
        INTO l_count
        FROM mtl_item_revisions
        WHERE inventory_item_id = l_pvt_RQL_Tbl(I).inventory_item_id
        AND organization_id =
            decode(nvl(l_pvt_RQL_Tbl(I).source_organization_id, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, organization_id, l_pvt_RQL_Tbl(I).source_organization_id)
        AND revision = l_pvt_RQL_Tbl(I).revision;
        IF (l_count <= 0) THEN
          FND_MESSAGE.SET_NAME ('INV', 'INV_INT_REVCODE');
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;
      EXCEPTION
        when no_Data_found then
          null;
      END;
    END IF;
  END LOOP;
END;

PROCEDURE Create_REQUIREMENT_LINES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQL_Tbl                    IN   RQL_Tbl_Type  := G_MISS_RQL_Tbl,
  --Hint: Add detail tables as parameter lists if it's master-detail relationship.
    X_REQUIREMENT_LINE_TBL       OUT NOCOPY  RQL_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_REQUIREMENT_LINES';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_RQL_rec             CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type;
l_pvt_RQL_tbl             CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Tbl_Type;
l_pvt_RQL_tbl1            CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Tbl_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_REQUIREMENT_LINES_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_RQL_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RQL_Values_To_Ids (
            p_RQL_tbl       =>  p_RQL_tbl,
            x_pvt_RQL_tbl   =>  l_pvt_RQL_tbl
      );

      Validate_Requirement_Lines(l_pvt_RQL_Tbl);

    -- Calling Private package: Create_Requirement_Lines
    -- Hint: Primary key needs to be returned
      CSP_REQUIREMENT_LINES_PVT.Create_REQUIREMENT_LINES(
        P_Api_Version_Number         => 1.0,
        P_Init_Msg_List              => FND_API.G_FALSE,
        P_Commit                     => FND_API.G_FALSE,
        P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
        P_REQUIREMENT_LINE_Tbl       => l_pvt_RQL_Tbl ,
        -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
        X_REQUIREMENT_LINE_TBL       => l_pvt_RQL_tbl1,
        X_Return_Status              => x_return_status,
        X_Msg_Count                  => x_msg_count,
        X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FOR I IN 1..l_pvt_rql_tbl.COUNT LOOP
        x_requirement_line_tbl(I).REQUIREMENT_LINE_ID := l_pvt_Rql_tbl(I).REQUIREMENT_LINE_ID;
        x_requirement_line_tbl(I).CREATED_BY := l_pvt_Rql_tbl(I).CREATED_BY;
        x_requirement_line_tbl(I).CREATION_DATE := l_pvt_Rql_tbl(I).CREATION_DATE;
        x_requirement_line_tbl(I).LAST_UPDATED_BY := l_pvt_Rql_tbl(I).LAST_UPDATED_BY;
        x_requirement_line_tbl(I).LAST_UPDATE_DATE := l_pvt_Rql_tbl(I).LAST_UPDATE_DATE;
        x_requirement_line_tbl(I).LAST_UPDATE_LOGIN := l_pvt_Rql_tbl(I).LAST_UPDATE_LOGIN;
        x_requirement_line_tbl(I).REQUIREMENT_HEADER_ID := l_pvt_Rql_tbl(I).REQUIREMENT_HEADER_ID;
        x_requirement_line_tbl(I).UOM_CODE := l_pvt_Rql_tbl(I).UOM_CODE;
        x_requirement_line_tbl(I).REQUIRED_QUANTITY := l_pvt_Rql_tbl(I).REQUIRED_QUANTITY;
        x_requirement_line_tbl(I).SHIP_COMPLETE_FLAG := l_pvt_Rql_tbl(I).SHIP_COMPLETE_FLAG;
        x_requirement_line_tbl(I).LIKELIHOOD := l_pvt_Rql_tbl(I).LIKELIHOOD;
        x_requirement_line_tbl(I).REVISION := l_pvt_Rql_tbl(I).REVISION;
        x_requirement_line_tbl(I).SOURCE_ORGANIZATION_ID := l_pvt_Rql_tbl(I).SOURCE_ORGANIZATION_ID;
        x_requirement_line_tbl(I).SOURCE_SUBINVENTORY := l_pvt_Rql_tbl(I).SOURCE_SUBINVENTORY;
        x_requirement_line_tbl(I).ORDERED_QUANTITY := l_pvt_Rql_tbl(I).ORDERED_QUANTITY;
        x_requirement_line_tbl(I).ORDER_LINE_ID := l_pvt_Rql_tbl(I).ORDER_LINE_ID;
        x_requirement_line_tbl(I).RESERVATION_ID := l_pvt_Rql_tbl(I).RESERVATION_ID;
        x_requirement_line_tbl(I).ATTRIBUTE_CATEGORY := l_pvt_Rql_tbl(I).ATTRIBUTE_CATEGORY;
        x_requirement_line_tbl(I).ATTRIBUTE1 := l_pvt_Rql_tbl(I).ATTRIBUTE1;
        x_requirement_line_tbl(I).ATTRIBUTE2 := l_pvt_Rql_tbl(I).ATTRIBUTE2;
        x_requirement_line_tbl(I).ATTRIBUTE3 := l_pvt_Rql_tbl(I).ATTRIBUTE3;
        x_requirement_line_tbl(I).ATTRIBUTE4 := l_pvt_Rql_tbl(I).ATTRIBUTE4;
        x_requirement_line_tbl(I).ATTRIBUTE5 := l_pvt_Rql_tbl(I).ATTRIBUTE5;
        x_requirement_line_tbl(I).ATTRIBUTE6 := l_pvt_Rql_tbl(I).ATTRIBUTE6;
        x_requirement_line_tbl(I).ATTRIBUTE7 := l_pvt_Rql_tbl(I).ATTRIBUTE7;
        x_requirement_line_tbl(I).ATTRIBUTE8 := l_pvt_Rql_tbl(I).ATTRIBUTE8;
        x_requirement_line_tbl(I).ATTRIBUTE9 := l_pvt_Rql_tbl(I).ATTRIBUTE9;
        x_requirement_line_tbl(I).ATTRIBUTE10 := l_pvt_Rql_tbl(I).ATTRIBUTE10;
        x_requirement_line_tbl(I).ATTRIBUTE11 := l_pvt_Rql_tbl(I).ATTRIBUTE11;
        x_requirement_line_tbl(I).ATTRIBUTE12 := l_pvt_Rql_tbl(I).ATTRIBUTE12;
        x_requirement_line_tbl(I).ATTRIBUTE13 := l_pvt_Rql_tbl(I).ATTRIBUTE13;
        x_requirement_line_tbl(I).ATTRIBUTE14 := l_pvt_Rql_tbl(I).ATTRIBUTE14;
        x_requirement_line_tbl(I).ATTRIBUTE15 := l_pvt_Rql_tbl(I).ATTRIBUTE15;
        x_requirement_line_tbl(I).ARRIVAL_DATE := l_pvt_Rql_tbl(I).ARRIVAL_DATE;
        x_requirement_line_tbl(I).ITEM_SCRATCHPAD := l_pvt_Rql_tbl(I).ITEM_SCRATCHPAD;
        x_requirement_line_tbl(I).SHIPPING_METHOD_CODE := l_pvt_Rql_tbl(I).SHIPPING_METHOD_CODE;
        x_requirement_line_tbl(I).LOCAL_RESERVATION_ID := l_pvt_Rql_tbl(I).LOCAL_RESERVATION_ID;
        x_requirement_line_tbl(I).SOURCED_FROM := l_pvt_Rql_tbl(I).SOURCED_FROM;

      END LOOP;
      --
      -- End of API body.
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_REQUIREMENT_LINES;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_REQUIREMENT_LINES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQL_Tbl                    IN   RQL_Tbl_Type := G_MISS_RQL_TBL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_REQUIREMENT_LINES';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_RQL_rec             CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type;
l_pvt_RQL_Tbl             CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Tbl_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Packlist_Headers_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_RQL_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RQL_Values_To_Ids (
            p_RQL_Tbl       =>  p_RQL_Tbl,
            x_pvt_RQL_Tbl   =>  l_pvt_RQL_Tbl
      );

      Validate_Requirement_Lines(l_pvt_RQL_Tbl);

    CSP_REQUIREMENT_LINES_PVT.Update_REQUIREMENT_LINES(
        P_Api_Version_Number         => 1.0,
        P_Init_Msg_List              => FND_API.G_FALSE,
        P_Commit                     => p_commit,
        P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
        P_Requirement_Line_Tbl       =>  l_pvt_RQL_Tbl ,
        X_Return_Status              => x_return_status,
        X_Msg_Count                  => x_msg_count,
        X_Msg_Data                   => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_REQUIREMENT_LINES;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_REQUIREMENT_LINES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_RQL_Tbl                    IN   RQL_Tbl_Type,
    X_Return_Status              OUT  NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY  NUMBER,
    X_Msg_Data                   OUT  NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_REQUIREMENT_LINES';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_pvt_RQL_rec             CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Rec_Type;
l_pvt_RQL_Tbl             CSP_REQUIREMENT_LINES_PVT.Requirement_Line_Tbl_Type;
l_count                   NUMBER;
EXCP_USER_DEFINED        EXCEPTION;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_REQUIREMENT_LINES_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'AS: Public API: Convert_RQL_Values_To_Ids');

      -- Convert the values to ids
      --
      Convert_RQL_Values_To_Ids (
            p_RQL_Tbl       =>  p_RQL_Tbl,
            x_pvt_RQL_Tbl   =>  l_pvt_RQL_Tbl
      );
    -- Make sure there are no requirement line details before deleteing requirement lines
    FOR I IN 1..P_RQL_TBL.COUNT LOOP
      BEGIN
        SELECT count(requirement_line_id)
        INTO l_count
        FROM csp_Req_line_details
        where requirement_line_id = P_RQL_Tbl(I).requirement_line_id;

        IF l_count > 0 THEN
          FND_MESSAGE.SET_NAME ('CSP', 'CSP_RQMT_LINE_DELETE_ERROR');
          FND_MESSAGE.SET_TOKEN ('PARAMETER', P_RQL_Tbl(I).requirement_line_id, FALSE);
          FND_MSG_PUB.ADD;
          RAISE EXCP_USER_DEFINED;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
      END;
    END LOOP;

    CSP_REQUIREMENT_LINES_PVT.Delete_REQUIREMENT_LINES(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => p_commit,
    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
    P_Requirement_Line_Tbl       => l_pvt_RQL_Tbl,
    X_Return_Status              => x_return_status,
    X_Msg_Count                  => x_msg_count,
    X_Msg_Data                   => x_msg_data);



      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      --JTF_PLSQL_API.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'CSP', 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_REQUIREMENT_LINES;

END CSP_REQUIREMENT_LINES_PUB;

/
