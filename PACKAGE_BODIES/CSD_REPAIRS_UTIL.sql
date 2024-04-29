--------------------------------------------------------
--  DDL for Package Body CSD_REPAIRS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIRS_UTIL" AS
/* $Header: csdxutlb.pls 120.14.12010000.8 2010/05/06 01:31:03 takwong ship $ */
--
-- Package name     : CSD_REPAIRS_UTIL
-- Purpose          : This package contains utility programs for the Depot
--                    Repair module. Access is restricted to Oracle Depot
--                    Repair Internal Development.
-- History          :
-- Version       Date       Name        Description
-- 115.0         12/18/99   pkdas       Created.
-- 115.1         01/04/00   pkdas       Added some program units.
-- 115.2         01/18/00   pkdas       Added DATE_CLOSED to Convert_to_Repln_Rec_Type procedure.
-- 115.3         02/23/00   pkdas       Added CONTRACT_LINE_ID to Convert_to_Repln_Rec_Type procedure.
-- 115.4         11/30/01   travi       Added AUTO_PROCESS_RMA, OBJECT_VERSION_NUMBER and REPAIR_MODE
--                                      to Convert_to_Repln_Rec_Type
-- 115.5         01/14/02   travi       Added Item_REVISION col
-- 115.19        05/19/05   vparvath    Added check_task_n_wipjob proc for
--                                      R12 development.
-- 120.2         07/13/05   vparvath   Added utility proc for webservice
--
-- NOTE             :
--
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSD_REPAIRS_UTIL';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'csdxutlb.pls';
g_debug NUMBER := Csd_Gen_Utility_Pvt.g_debug_level;

procedure debug( l_msg in varchar2)
is
--pragma autonomous_transaction;
begin
--dbms_output.put_line(substr(l_msg,1,255));
--dbms_output.put_line(substr(l_msg,255,255));
--insert into apps.vijay_debug(log_msg, timestamp) values(l_msg, sysdate);
--commit;
null;
end;
--
PROCEDURE Check_Reqd_Param (
  p_param_value   IN NUMBER,
  p_param_name    IN VARCHAR2,
  p_api_name      IN VARCHAR2
  )
IS
--
BEGIN
--
  IF (NVL(p_param_value,Fnd_Api.G_MISS_NUM) = Fnd_Api.G_MISS_NUM) THEN
    Fnd_Message.SET_NAME('CSD','CSD_API_MISSING_PARAM');
    Fnd_Message.SET_TOKEN('API_NAME',p_api_name);
    Fnd_Message.SET_TOKEN('MISSING_PARAM',p_param_name);
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;
END Check_Reqd_Param;

PROCEDURE Check_Reqd_Param (
  p_param_value   IN VARCHAR2,
  p_param_name    IN VARCHAR2,
  p_api_name      IN VARCHAR2
  )
IS
--
BEGIN
--
  IF (NVL(p_param_value,Fnd_Api.G_MISS_CHAR) = Fnd_Api.G_MISS_CHAR) THEN
    Fnd_Message.SET_NAME('CSD','CSD_API_MISSING_PARAM');
    Fnd_Message.SET_TOKEN('API_NAME',p_api_name);
    Fnd_Message.SET_TOKEN('MISSING_PARAM',p_param_name);
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;
END Check_Reqd_Param;

PROCEDURE Check_Reqd_Param (
  p_param_value   IN DATE,
  p_param_name    IN VARCHAR2,
  p_api_name      IN VARCHAR2
  )
IS
--
BEGIN
--
  IF (NVL(p_param_value,Fnd_Api.G_MISS_DATE) = Fnd_Api.G_MISS_DATE) THEN
    Fnd_Message.SET_NAME('CSD','CSD_API_MISSING_PARAM');
    Fnd_Message.SET_TOKEN('API_NAME',p_api_name);
    Fnd_Message.SET_TOKEN('MISSING_PARAM',p_param_name);
    Fnd_Msg_Pub.ADD;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;
END Check_Reqd_Param;

--
-- bug#7151536, subhat.
-- changed the p_attr_values to IN OUT from IN
-- added a new parameter p_validate_only. This parameter would
-- indicate if we wish to default the required values or not.
-- If we need to validate and default then pass FND_API.G_FALSE
-- For validate only it will be default FND_API.G_TRUE.

FUNCTION Is_DescFlex_Valid
( p_api_name			  IN	VARCHAR2,
	p_desc_flex_name	IN	VARCHAR2,
	p_attr_values			IN OUT NOCOPY	CSD_REPAIRS_UTIL.DEF_Rec_Type,
-- bug#7151536, subhat.
  p_validate_only   IN VARCHAR2 := FND_API.G_TRUE
) RETURN BOOLEAN IS
--
  l_error_message         VARCHAR2(2000);
  l_return_status         BOOLEAN := TRUE;
-- bug#7151536, subhat. new variables added
  l_segment_count         NUMBER;
  l_column_name           VARCHAR2(30);
  l_values_or_ids         varchar2(3);
-- end bug#7151536, subhat.
--
BEGIN
--
  fnd_flex_descval.set_context_value(p_attr_values.attribute_category);
  fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attr_values.attribute1);
  fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attr_values.attribute2);
  fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attr_values.attribute3);
  fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attr_values.attribute4);
  fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attr_values.attribute5);
  fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attr_values.attribute6);
  fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attr_values.attribute7);
  fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attr_values.attribute8);
  fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attr_values.attribute9);
  fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attr_values.attribute10);
  fnd_flex_descval.set_column_value('ATTRIBUTE11', p_attr_values.attribute11);
  fnd_flex_descval.set_column_value('ATTRIBUTE12', p_attr_values.attribute12);
  fnd_flex_descval.set_column_value('ATTRIBUTE13', p_attr_values.attribute13);
  fnd_flex_descval.set_column_value('ATTRIBUTE14', p_attr_values.attribute14);
  fnd_flex_descval.set_column_value('ATTRIBUTE15', p_attr_values.attribute15);
  -- additional DFF columns(bug#7497907)
  fnd_flex_descval.set_column_value('ATTRIBUTE16', p_attr_values.attribute16);
  fnd_flex_descval.set_column_value('ATTRIBUTE17', p_attr_values.attribute17);
  fnd_flex_descval.set_column_value('ATTRIBUTE18', p_attr_values.attribute18);
  fnd_flex_descval.set_column_value('ATTRIBUTE19', p_attr_values.attribute19);
  fnd_flex_descval.set_column_value('ATTRIBUTE20', p_attr_values.attribute20);
  fnd_flex_descval.set_column_value('ATTRIBUTE21', p_attr_values.attribute21);
  fnd_flex_descval.set_column_value('ATTRIBUTE22', p_attr_values.attribute22);
  fnd_flex_descval.set_column_value('ATTRIBUTE23', p_attr_values.attribute23);
  fnd_flex_descval.set_column_value('ATTRIBUTE24', p_attr_values.attribute24);
  fnd_flex_descval.set_column_value('ATTRIBUTE25', p_attr_values.attribute25);
  fnd_flex_descval.set_column_value('ATTRIBUTE26', p_attr_values.attribute26);
  fnd_flex_descval.set_column_value('ATTRIBUTE27', p_attr_values.attribute27);
  fnd_flex_descval.set_column_value('ATTRIBUTE28', p_attr_values.attribute28);
  fnd_flex_descval.set_column_value('ATTRIBUTE29', p_attr_values.attribute29);
  fnd_flex_descval.set_column_value('ATTRIBUTE30', p_attr_values.attribute30);
--
 --
-- bug#7151536, subhat.
-- Flex engine doesnt default the values if we pass default value for
-- values_or_ids.
-- need to pass in 'V' (refer bug#2221725)
-- Pass in values_or_ids = 'V' only if p_validate_only is False.
if p_validate_only = FND_API.G_FALSE  then
  l_values_or_ids := 'V';
else
  l_values_or_ids := 'I';
end if;
--
  If NOT fnd_flex_descval.validate_desccols
         (appl_short_name => 'CSD',
          desc_flex_name  => p_desc_flex_name,
          values_or_ids   => l_values_or_ids)
-- end bug#7151536, subhat.
  then
    l_error_message := fnd_flex_descval.error_message;
    If fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('CSD', 'CSD_API_DESC_FLEX_ERR');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('DESC_FLEX_MSG', l_error_message);
      fnd_msg_pub.add;
    end if;
    l_return_status := FALSE;
-- bug#7043215, subhat
-- added else to populate the derived/validated value to the global collection
-- Note: In case any new columns are added to CSD_REPAIRS DFF, they need to be added here too.
  else
  -- populate the out rec only if its in create mode.
     if l_values_or_ids = 'V' then
      l_segment_count := fnd_flex_descval.segment_count;
      for i in 1 ..l_segment_count
        loop
          l_column_name := fnd_flex_descval.segment_column_name(i);

          CASE l_column_name
            WHEN 'ATTRIBUTE_CATEGORY' then
              p_attr_values.attribute_category := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE1' then
              p_attr_values.attribute1 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE2' then
              p_attr_values.attribute2 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE3' then
              p_attr_values.attribute3 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE4' then
              p_attr_values.attribute4 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE5' then
              p_attr_values.attribute5 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE6' then
              p_attr_values.attribute6 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE7' then
              p_attr_values.attribute7 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE8' then
              p_attr_values.attribute8 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE9' then
              p_attr_values.attribute9 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE10' then
              p_attr_values.attribute10 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE11' then
              p_attr_values.attribute11 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE12' then
              p_attr_values.attribute12 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE13' then
              p_attr_values.attribute13 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE14' then
              p_attr_values.attribute14 := fnd_flex_descval.segment_value(i);
            WHEN 'ATTRIBUTE15' then
              p_attr_values.attribute15 := fnd_flex_descval.segment_value(i);
            --* additional DFF attributes, subhat(bug#7497907)
      			WHEN 'ATTRIBUTE16' then
              p_attr_values.attribute16 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE17' then
              p_attr_values.attribute17 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE18' then
              p_attr_values.attribute18 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE19' then
              p_attr_values.attribute19 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE20' then
              p_attr_values.attribute20 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE21' then
              p_attr_values.attribute21 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE22' then
              p_attr_values.attribute22 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE23' then
              p_attr_values.attribute23 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE24' then
              p_attr_values.attribute24 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE25' then
              p_attr_values.attribute25 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE26' then
              p_attr_values.attribute26 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE27' then
              p_attr_values.attribute27 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE28' then
              p_attr_values.attribute28 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE29' then
              p_attr_values.attribute29 := fnd_flex_descval.segment_value(i);
      			WHEN 'ATTRIBUTE30' then
              p_attr_values.attribute30 := fnd_flex_descval.segment_value(i);
            ELSE
              null;
          END CASE;
        end loop;
      end if;
 END IF;
--
  RETURN (l_return_status);
--
END Is_DescFlex_Valid;

PROCEDURE Convert_to_Repln_Rec_Type
(
  p_REPAIR_NUMBER             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_INCIDENT_ID               IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_INVENTORY_ITEM_ID         IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_CUSTOMER_PRODUCT_ID       IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_UNIT_OF_MEASURE           IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_REPAIR_TYPE_ID            IN      NUMBER := Fnd_Api.G_MISS_NUM,
-- RESOURCE_GROUP Added by Vijay 10/28/2004
  p_RESOURCE_GROUP            IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_RESOURCE_ID               IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_PROJECT_ID                IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_TASK_ID                   IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_UNIT_NUMBER               IN      VARCHAR2 := FND_API.G_MISS_CHAR, -- rfieldma, project_integration
  p_CONTRACT_LINE_ID          IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_AUTO_PROCESS_RMA          IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_REPAIR_MODE               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_OBJECT_VERSION_NUMBER     IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_ITEM_REVISION             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_INSTANCE_ID               IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_STATUS                    IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_STATUS_REASON_CODE        IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_DATE_CLOSED               IN      DATE := Fnd_Api.G_MISS_DATE,
  p_APPROVAL_REQUIRED_FLAG    IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_APPROVAL_STATUS           IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_SERIAL_NUMBER             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_PROMISE_DATE              IN      DATE := Fnd_Api.G_MISS_DATE,
  p_ATTRIBUTE_CATEGORY        IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE1                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE2                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE3                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE4                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE5                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE6                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE7                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE8                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE9                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE10               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE11               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE12               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE13               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE14               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE15               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  P_ATTRIBUTE16               IN      VARCHAR2 := FND_API.G_MISS_CHAR,-- SUBHAT, DFF CHANGES(bug#7497907)
  P_ATTRIBUTE17               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE18               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE19               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE20               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE21               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE22               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE23               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE24               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE25               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE26               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE27               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE28               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE29               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE30               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_QUANTITY                  IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_QUANTITY_IN_WIP           IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_QUANTITY_RCVD             IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_QUANTITY_SHIPPED          IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_CURRENCY_CODE             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_DEFAULT_PO_NUM            IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_REPAIR_GROUP_ID           IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_RO_TXN_STATUS             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ORDER_LINE_ID             IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_ORIGINAL_SOURCE_REFERENCE  IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ORIGINAL_SOURCE_HEADER_ID  IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  p_ORIGINAL_SOURCE_LINE_ID    IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  p_PRICE_LIST_HEADER_ID       IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  p_INVENTORY_ORG_ID           IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  -- swai: bug 4666344 added problem description
  p_PROBLEM_DESCRIPTION        IN     VARCHAR2   := Fnd_Api.G_MISS_CHAR,
  p_RO_PRIORITY_CODE           IN     VARCHAR2   := Fnd_Api.G_MISS_CHAR,  -- swai: R12
  p_RESOLVE_BY_DATE            IN     DATE       := Fnd_Api.G_MISS_DATE, -- rfieldma: 5355051
  p_BULLETIN_CHECK_DATE        IN     DATE     := Fnd_Api.G_MISS_DATE,
  p_ESCALATION_CODE            IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_RO_WARRANTY_STATUS_CODE    IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  x_Repln_Rec                 OUT NOCOPY     Csd_Repairs_Pub.Repln_Rec_Type
) IS
--
BEGIN

IF (g_debug > 0 ) THEN
Csd_Gen_Utility_Pvt.ADD( 'at begin convert rec');
END IF;


  x_Repln_Rec.REPAIR_NUMBER := p_REPAIR_NUMBER;
  x_Repln_Rec.INCIDENT_ID := p_INCIDENT_ID;
  x_Repln_Rec.INVENTORY_ITEM_ID  := p_INVENTORY_ITEM_ID;
  x_Repln_Rec.CUSTOMER_PRODUCT_ID := p_CUSTOMER_PRODUCT_ID;
  x_Repln_Rec.UNIT_OF_MEASURE := p_UNIT_OF_MEASURE;
  x_Repln_Rec.REPAIR_TYPE_ID := p_REPAIR_TYPE_ID;
-- RESOURCE_GROUP Added by Vijay 10/28/2004
  x_Repln_Rec.RESOURCE_GROUP := p_RESOURCE_GROUP;
  x_Repln_Rec.RESOURCE_ID := p_RESOURCE_ID;
  x_Repln_Rec.PROJECT_ID := p_PROJECT_ID;
  x_Repln_Rec.TASK_ID := p_TASK_ID;
  x_Repln_Rec.UNIT_NUMBER := p_UNIT_NUMBER; -- rfieldma, project integration
  x_Repln_Rec.CONTRACT_LINE_ID := p_CONTRACT_LINE_ID;
  x_Repln_Rec.AUTO_PROCESS_RMA := p_AUTO_PROCESS_RMA;
  x_Repln_Rec.REPAIR_MODE := p_REPAIR_MODE;
  x_Repln_Rec.OBJECT_VERSION_NUMBER := p_OBJECT_VERSION_NUMBER;
  x_Repln_Rec.ITEM_REVISION := p_ITEM_REVISION;
  x_Repln_Rec.INSTANCE_ID := p_INSTANCE_ID;
  x_Repln_Rec.STATUS := p_STATUS;
  x_Repln_Rec.STATUS_REASON_CODE := p_STATUS_REASON_CODE;
  x_Repln_Rec.DATE_CLOSED := p_DATE_CLOSED;
  x_Repln_Rec.APPROVAL_REQUIRED_FLAG := p_APPROVAL_REQUIRED_FLAG;
  x_Repln_Rec.APPROVAL_STATUS := p_APPROVAL_STATUS;
  x_Repln_Rec.SERIAL_NUMBER := p_SERIAL_NUMBER;
  x_Repln_Rec.PROMISE_DATE := p_PROMISE_DATE;
  x_Repln_Rec.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
  x_Repln_Rec.ATTRIBUTE1  := p_ATTRIBUTE1;
  x_Repln_Rec.ATTRIBUTE2  := p_ATTRIBUTE2;
  x_Repln_Rec.ATTRIBUTE3  := p_ATTRIBUTE3;
  x_Repln_Rec.ATTRIBUTE4  := p_ATTRIBUTE4;
  x_Repln_Rec.ATTRIBUTE5  := p_ATTRIBUTE5;
  x_Repln_Rec.ATTRIBUTE6  := p_ATTRIBUTE6;
  x_Repln_Rec.ATTRIBUTE7  := p_ATTRIBUTE7;
  x_Repln_Rec.ATTRIBUTE8  := p_ATTRIBUTE8;
  x_Repln_Rec.ATTRIBUTE9  := p_ATTRIBUTE9;
  x_Repln_Rec.ATTRIBUTE10 := p_ATTRIBUTE10;
  x_Repln_Rec.ATTRIBUTE11 := p_ATTRIBUTE11;
  x_Repln_Rec.ATTRIBUTE12 := p_ATTRIBUTE12;
  x_Repln_Rec.ATTRIBUTE13 := p_ATTRIBUTE13;
  x_Repln_Rec.ATTRIBUTE14 := p_ATTRIBUTE14;
  x_Repln_Rec.ATTRIBUTE15 := p_ATTRIBUTE15;
  x_Repln_Rec.QUANTITY    := p_QUANTITY;
  x_Repln_Rec.QUANTITY_IN_WIP  :=  p_QUANTITY_IN_WIP;
  x_Repln_Rec.QUANTITY_RCVD    := p_QUANTITY_RCVD;
  x_Repln_Rec.QUANTITY_SHIPPED := p_QUANTITY_SHIPPED;
  x_Repln_Rec.CURRENCY_CODE    := p_CURRENCY_CODE;
  x_Repln_Rec.DEFAULT_PO_NUM    := p_DEFAULT_PO_NUM;
  x_Repln_Rec.REPAIR_GROUP_ID  := p_REPAIR_GROUP_ID;
  x_Repln_Rec.RO_TXN_STATUS    := p_RO_TXN_STATUS;
  x_Repln_Rec.ORDER_LINE_ID    := p_ORDER_LINE_ID;
  x_Repln_Rec.ORIGINAL_SOURCE_REFERENCE := p_ORIGINAL_SOURCE_REFERENCE;
  x_Repln_Rec.ORIGINAL_SOURCE_HEADER_ID := p_ORIGINAL_SOURCE_HEADER_ID;
  x_Repln_Rec.ORIGINAL_SOURCE_LINE_ID   := p_ORIGINAL_SOURCE_LINE_ID;
  x_Repln_Rec.PRICE_LIST_HEADER_ID      := p_PRICE_LIST_HEADER_ID;
  x_Repln_Rec.INVENTORY_ORG_ID          := p_INVENTORY_ORG_ID;
  -- swai: bug 4666344 added problem description
  x_Repln_Rec.PROBLEM_DESCRIPTION       := p_PROBLEM_DESCRIPTION;
  x_Repln_Rec.RO_PRIORITY_CODE          := p_RO_PRIORITY_CODE;  -- swai: R12
  x_Repln_Rec.RESOLVE_BY_DATE           := p_RESOLVE_BY_DATE;   -- rfieldma: 5355051
  x_Repln_Rec.BULLETIN_CHECK_DATE       := p_BULLETIN_CHECK_DATE;
  x_Repln_Rec.ESCALATION_CODE           := p_ESCALATION_CODE;
  x_Repln_Rec.RO_WARRANTY_STATUS_CODE   := p_RO_WARRANTY_STATUS_CODE;
  -- additional DFF attributes, subhat(bug#7497907)
  x_Repln_Rec.ATTRIBUTE16 := p_ATTRIBUTE16;
  x_Repln_Rec.ATTRIBUTE17 := p_ATTRIBUTE17;
  x_Repln_Rec.ATTRIBUTE18 := p_ATTRIBUTE18;
  x_Repln_Rec.ATTRIBUTE19 := p_ATTRIBUTE19;
  x_Repln_Rec.ATTRIBUTE20 := p_ATTRIBUTE20;
  x_Repln_Rec.ATTRIBUTE21 := p_ATTRIBUTE21;
  x_Repln_Rec.ATTRIBUTE22 := p_ATTRIBUTE22;
  x_Repln_Rec.ATTRIBUTE23 := p_ATTRIBUTE23;
  x_Repln_Rec.ATTRIBUTE24 := p_ATTRIBUTE24;
  x_Repln_Rec.ATTRIBUTE25 := p_ATTRIBUTE25;
  x_Repln_Rec.ATTRIBUTE26 := p_ATTRIBUTE26;
  x_Repln_Rec.ATTRIBUTE27 := p_ATTRIBUTE27;
  x_Repln_Rec.ATTRIBUTE28 := p_ATTRIBUTE28;
  x_Repln_Rec.ATTRIBUTE29 := p_ATTRIBUTE29;
  x_Repln_Rec.ATTRIBUTE30 := p_ATTRIBUTE30;

END Convert_to_Repln_Rec_Type;

PROCEDURE Convert_to_DEF_Rec_Type
(
  p_attribute_category        IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute1                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute2                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute3                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute4                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute5                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute6                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute7                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute8                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute9                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute10               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute11               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute12               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute13               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute14               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute15               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute16               IN      VARCHAR2 := FND_API.G_MISS_CHAR, -- subhat, dff changes(bug#7497907)
  p_attribute17               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute18               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute19               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute20               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute21               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute22               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute23               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute24               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute25               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute26               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute27               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute28               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute29               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute30               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  x_DEF_Rec                   OUT NOCOPY     Csd_Repairs_Util.DEF_Rec_Type
) IS
--
BEGIN
--
  x_DEF_Rec.attribute_category := p_attribute_category;
  x_DEF_Rec.attribute1 := p_attribute1;
  x_DEF_Rec.attribute2 := p_attribute2;
  x_DEF_Rec.attribute3 := p_attribute3;
  x_DEF_Rec.attribute4 := p_attribute4;
  x_DEF_Rec.attribute5 := p_attribute5;
  x_DEF_Rec.attribute6 := p_attribute6;
  x_DEF_Rec.attribute7 := p_attribute7;
  x_DEF_Rec.attribute8 := p_attribute8;
  x_DEF_Rec.attribute9 := p_attribute9;
  x_DEF_Rec.attribute10 := p_attribute10;
  x_DEF_Rec.attribute11 := p_attribute11;
  x_DEF_Rec.attribute12 := p_attribute12;
  x_DEF_Rec.attribute13 := p_attribute13;
  x_DEF_Rec.attribute14 := p_attribute14;
  x_DEF_Rec.attribute15 := p_attribute15;
  x_DEF_Rec.attribute16 := p_attribute16; -- subhat, DFF changes(bug#7497907).
  x_DEF_Rec.attribute17 := p_attribute17;
  x_DEF_Rec.attribute18 := p_attribute18;
  x_DEF_Rec.attribute19 := p_attribute19;
  x_DEF_Rec.attribute20 := p_attribute20;
  x_DEF_Rec.attribute21 := p_attribute21;
  x_DEF_Rec.attribute22 := p_attribute22;
  x_DEF_Rec.attribute23 := p_attribute23;
  x_DEF_Rec.attribute24 := p_attribute24;
  x_DEF_Rec.attribute25 := p_attribute25;
  x_DEF_Rec.attribute26 := p_attribute26;
  x_DEF_Rec.attribute27 := p_attribute27;
  x_DEF_Rec.attribute28 := p_attribute28;
  x_DEF_Rec.attribute29 := p_attribute29;
  x_DEF_Rec.attribute30 := p_attribute30;
--
END Convert_to_DEF_Rec_Type;

PROCEDURE GET_ENTITLEMENTS
(
  P_API_VERSION_NUMBER     IN      NUMBER,
  P_INIT_MSG_LIST          IN      VARCHAR2 := 'F',
  P_COMMIT                 IN      VARCHAR2 := 'F',
  P_CONTRACT_NUMBER        IN      VARCHAR2 := NULL,
  P_SERVICE_LINE_ID        IN      NUMBER := NULL,
  P_CUSTOMER_ID            IN      NUMBER := NULL,
  P_SITE_ID                IN      NUMBER := NULL,
  P_CUSTOMER_ACCOUNT_ID    IN      NUMBER := NULL,
  P_SYSTEM_ID              IN      NUMBER := NULL,
  P_INVENTORY_ITEM_ID      IN      NUMBER := NULL,
  P_CUSTOMER_PRODUCT_ID    IN      NUMBER := NULL,
  P_REQUEST_DATE           IN      DATE := NULL,
  P_VALIDATE_FLAG          IN      VARCHAR2 := 'Y',
--Begin forwardporting bug fix for 2806199,2806661,2802141 By Vijay
  P_BUSINESS_PROCESS_ID    IN      NUMBER DEFAULT NULL,
  P_SEVERITY_ID            IN      NUMBER DEFAULT NULL,
  P_TIME_ZONE_ID           IN      NUMBER DEFAULT NULL,
  P_CALC_RESPTIME_FLAG     IN      VARCHAR2 DEFAULT NULL,
--End forwardporting bug fix for 2806199,2806661,2802141 By Vijay
  X_ENT_CONTRACTS          OUT NOCOPY     Oks_Entitlements_Pub.GET_CONTOP_TBL,
  X_RETURN_STATUS          OUT NOCOPY     VARCHAR2,
  X_MSG_COUNT              OUT NOCOPY     NUMBER,
  X_MSG_DATA               OUT NOCOPY     VARCHAR2
)
IS
--
  l_api_name                      VARCHAR2(30) := 'GET_ENTITLEMENTS';
  l_input_param_rec               Oks_Entitlements_Pub.get_contin_rec;
  l_api_version_number   CONSTANT NUMBER := 1.0;
--
 BEGIN
--
  SAVEPOINT Get_Entitlements_Pvt;
-- Standard call to check for call compatibility.
  IF NOT Fnd_Api.Compatible_API_Call
    (l_api_version_number,
     p_api_version_number,
     l_api_name,
     G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
  IF Fnd_Api.to_Boolean(p_init_msg_list)
  THEN
    Fnd_Msg_Pub.initialize;
  END IF;
-- Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
--
-- API body
--
  l_input_param_rec.contract_number := p_contract_number;
  l_input_param_rec.service_line_id := p_service_line_id;
  l_input_param_rec.party_id := p_customer_id;
  l_input_param_rec.site_id := p_site_id;
  l_input_param_rec.cust_acct_id := p_customer_account_id;
  l_input_param_rec.system_id := p_system_id;
  l_input_param_rec.item_id := p_inventory_item_id;
  l_input_param_rec.product_id := p_customer_product_id;
  l_input_param_rec.request_date := p_request_date;
  l_input_param_rec.validate_flag := p_validate_flag;
--Begin forwardporting bug fix for 2806199,2806661,2802141 By Vijay
  l_input_param_rec.calc_resptime_flag := NVL(p_calc_resptime_flag,'N');
  l_input_param_rec.business_process_id := p_business_process_id;
  l_input_param_rec.severity_id := p_severity_id;
  l_input_param_rec.time_zone_id := p_time_zone_id;
--End forwardporting bug fix for 2806199,2806661,2802141 By Vijay
--
-- If the validate_flag is 'Y' then only the valid contract lines as of
-- 'request_date' are returned. If the validate_flag is 'N' then
-- all the contract lines - valid and invalid- are returned.
--
  Oks_Entitlements_Pub.GET_CONTRACTS
  (p_api_version => p_api_version_number,
   p_init_msg_list => p_init_msg_list,
   p_inp_rec => l_input_param_rec,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_ent_contracts => x_ent_contracts);
--
   IF (x_return_status = Fnd_Api.G_RET_STS_ERROR) THEN
     RAISE Fnd_Api.G_EXC_ERROR ;
   ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR) THEN
     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
   END IF ;
--
-- End of API body.
--
-- Standard check for p_commit
   IF Fnd_Api.to_Boolean(p_commit)
   THEN
      COMMIT WORK;
   END IF;
-- Standard call to get message count and if count is 1, get message info.
   Fnd_Msg_Pub.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
    );
--
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--  RAISE;
--
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--  RAISE;
--
  WHEN OTHERS THEN
    Jtf_Plsql_Api.HANDLE_EXCEPTIONS
      (P_API_NAME => L_API_NAME
      ,P_PKG_NAME => G_PKG_NAME
      ,P_EXCEPTION_LEVEL => Jtf_Plsql_Api.G_EXC_OTHERS
      ,P_PACKAGE_TYPE => Jtf_Plsql_Api.G_PVT
      ,X_MSG_COUNT => X_MSG_COUNT
      ,X_MSG_DATA => X_MSG_DATA
      ,X_RETURN_STATUS => X_RETURN_STATUS);
--  RAISE;
--
END GET_ENTITLEMENTS;

PROCEDURE Get_KB_Element_Description
(
  p_element_id           IN  NUMBER,
  p_element_description  OUT NOCOPY VARCHAR2
)
IS
--
  l_element_desc     CLOB;
  l_amount           BINARY_INTEGER := 32767;
  l_position         INTEGER := 1;
  l_buffer           VARCHAR2(32767);
  l_chunksize        INTEGER;
--
BEGIN
--
  SELECT description
  INTO l_element_desc
  FROM cs_kb_elements_vl
  WHERE element_id = p_element_id;
--
  l_chunksize := DBMS_LOB.getchunksize(l_element_desc);
  IF l_chunksize IS NOT NULL THEN
    IF l_chunksize < l_amount THEN
      l_amount := (l_amount/l_chunksize) * l_chunksize;
    END IF;
  END IF;
  IF l_element_desc IS NOT NULL THEN
    DBMS_LOB.READ
    (lob_loc => l_element_desc,
   amount  => l_amount,
   offset  => l_position,
   buffer  => l_buffer
    );
  ELSE
    l_buffer := NULL;
  END IF;
--
  p_element_description := l_buffer;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_element_description := NULL;
  WHEN TOO_MANY_ROWS THEN
    p_element_description := NULL;
  WHEN OTHERS THEN
    p_element_description := NULL;
--
END Get_KB_Element_Description;

-- R12 Development Begin
--   *******************************************************
--   API Name:  check_task_n_wip
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_repair_line_id            IN     VARCHAR2,
--     p_repair_status             IN     VARCHAR2,
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API checks if there are any open tasks or wip jobs
--                  for the repair order if the status is 'C'. If there are
--                 open tasks or wipjobs depending on the mode, this api
--                 returns FAILURE otherwise SUCCESS.
--
--
-- ***********************************************************
PROCEDURE Check_Task_N_Wipjob
(
  p_repair_line_id        IN  NUMBER,
  p_repair_status         IN  VARCHAR2,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 ) IS

  -- Local variables
  l_api_name            CONSTANT  VARCHAR2(30) := 'CHECK_TASK_N_WIPJOB';
  l_debug_level                   NUMBER ;
  l_repair_mode                   VARCHAR2(10);
  l_tmp_char                      VARCHAR2(1);
  C_TASK_MODE           CONSTANT  VARCHAR2(4) := 'TASK';
  C_WIP_MODE            CONSTANT  VARCHAR2(3) := 'WIP';
  C_CLOSED_STATUS       CONSTANT  VARCHAR2(1) := 'C';

  --Cursor definitions

  -- Cursor to check if there are open tasks for the
  -- repair order.
  CURSOR task_cur IS
  SELECT 'x'
  FROM   jtf_tasks_b  TASK,   jtf_task_statuses_b  status
  WHERE  TASK.source_object_id      = p_repair_line_id
         AND    TASK.source_object_type_code = 'DR'
         AND    TASK.task_status_id          = status.task_status_id
         AND    NVL(status.closed_flag,'N')   <> 'Y'
       AND    ROWNUM =1;

  -- Cursor to check open wip jobs for the repair order
  CURSOR wipjob_cur IS
  SELECT 'x'  /* crx.repair_job_xref_id */
  FROM   csd_repair_job_xref crx,  wip_discrete_jobs   wdj
  WHERE crx.repair_line_id = p_repair_line_id
        AND crx.wip_entity_id = wdj.wip_entity_id
      AND wdj.status_type NOT IN (4,5,7,12)
  /*  4: Complete,5: Complete-No charges,7: Cancelled,12: Closed */
  UNION ALL
  SELECT 'x' /* repair_job_xref_id*/
  FROM csd_repair_job_xref
  WHERE repair_line_id  = p_repair_line_id
        AND wip_entity_id IS NULL;

  -- Cursor to get the repair mode
  CURSOR repair_details_cur IS
  SELECT repair_mode FROM csd_repairs
  WHERE repair_line_id = p_repair_line_id;



BEGIN

    -- Initialize local variables.
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      l_debug_level   := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;

      IF (Fnd_Log.LEVEL_PROCEDURE >= l_debug_level) THEN
         Fnd_Log.STRING (Fnd_Log.LEVEL_PROCEDURE, 'csd.plsql.csd_repairs_util.check_task_n_wipjob.begin',
                         '-------------Entered check_task_n_wipjob----------------');
      END IF;


    -- Get the repair mode
    OPEN repair_details_cur ;
    FETCH repair_details_cur INTO l_repair_mode;
    IF(repair_details_cur%NOTFOUND) THEN
       CLOSE repair_details_Cur;
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    CLOSE repair_details_cur;

    /****
    If the repair status is going to be closed, then if the mode is wip check for open wip jobs,
    if the mode is task, check for open tasks. Return failure if there are open items, return
    success if not.
    ****/
      IF( p_repair_status = C_CLOSED_STATUS) THEN

       IF (Fnd_Log.LEVEL_EVENT >= l_debug_level) THEN
          Fnd_Log.STRING (Fnd_Log.LEVEL_EVENT, 'csd.plsql.csd_repairs_util.check_task_n_wipjob',
                  '-------------status is being changed to close,ro['||p_repair_line_id||']-----');
       END IF;

       IF (l_repair_mode = C_WIP_MODE) THEN

         IF (Fnd_Log.LEVEL_STATEMENT >= l_debug_level) THEN
             Fnd_Log.STRING (Fnd_Log.LEVEL_STATEMENT, 'csd.plsql.csd_repairs_util.check_task_n_wipjob',
                     '-------------checking for open jobs---------------');
         END IF;

         OPEN wipjob_cur;
         FETCH wipjob_cur INTO l_tmp_char;
         IF(wipjob_cur%NOTFOUND) THEN
            CLOSE wipjob_cur;
            IF (Fnd_Log.LEVEL_STATEMENT >= l_debug_level) THEN
               Fnd_Log.STRING (Fnd_Log.LEVEL_STATEMENT, 'csd.plsql.csd_repairs_util.check_task_n_wipjob',
                        '-------------there are open jobs---------------');
            END IF;
            Fnd_Message.set_name('CSD', 'CSD_API_OPEN_WIP_JOBS');
            Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR ;
         END IF;
         CLOSE wipjob_cur;
       ELSIF (l_repair_mode = C_TASK_MODE) THEN

         IF (Fnd_Log.LEVEL_STATEMENT >= l_debug_level) THEN
             Fnd_Log.STRING (Fnd_Log.LEVEL_STATEMENT, 'csd.plsql.csd_repairs_util.check_task_n_wipjob',
                     '-------------checking for open tasks---------------');
         END IF;

         OPEN task_cur;
         FETCH task_cur INTO l_tmp_char;
         IF(task_cur%NOTFOUND) THEN
            CLOSE task_cur;
            IF (Fnd_Log.LEVEL_STATEMENT >= l_debug_level) THEN
                Fnd_Log.STRING (Fnd_Log.LEVEL_STATEMENT, 'csd.plsql.csd_repairs_util.check_task_n_wipjob',
                        '-------------there are open tasks---------------');
            END IF;
            Fnd_Message.set_name('CSD', 'CSD_API_OPEN_TASKS');
            Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR ;
         END IF;
         CLOSE task_cur;
       END IF;
      END IF;

      IF (Fnd_Log.level_procedure >= l_debug_level) THEN
         Fnd_Log.STRING (Fnd_Log.level_procedure, 'csd.plsql.csd_repairs_util.check_task_n_wipjob.end',
                         '-------------Leaving check_task_n_wipjob----------------');
      END IF;

   EXCEPTION
      WHEN Fnd_Api.G_EXC_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR ;
      Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count, p_data   =>  x_msg_data);
      IF ( Fnd_Log.LEVEL_ERROR >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_ERROR,
            'csd.plsql.csd_repairs_util.check_task_n_wipjob',
            'EXC_ERROR ['||x_msg_data||']');
      END IF;

      WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
      Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count, p_data   =>  x_msg_data );
      IF ( Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,
            'csd.plsql.csd_repairs_util.check_task_n_wipjob',
            'EXC_UNEXPECTED_ERROR ['||x_msg_data||']');
      END IF;

      WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR ;
      IF  Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
      THEN
         Fnd_Msg_Pub.Add_Exc_Msg (G_PKG_NAME , l_api_name  );
      END IF;
      Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count, p_data   =>  x_msg_data );

      IF ( Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL ) THEN
         Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,
            'csd.plsql.csd_repairs_util.check_task_n_wipjob',
            'SQL Message ['||SQLERRM||']');
      END IF;


END Check_Task_N_Wipjob;


--   *******************************************************
--   API Name:  convert_Status_val_to_Id
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_status_rec            IN    CSD_REPAIRS_PUB.REPAIR_STATUS_REC_TYPE ,
--   OUT
--     x_status_rec            OUT    CSD_REPAIRS_PUB.REPAIR_STATUS_REC_TYPE ,
--     x_return_status
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description :  Converts value to Ids in the input repair status record.
--
-- ***********************************************************

PROCEDURE Convert_status_Val_to_Id(p_repair_status_rec IN Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE,
                     x_repair_status_rec OUT NOCOPY Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE,
                     x_return_status OUT NOCOPY VARCHAR2)
IS
 l_debug_level NUMBER;

 --Value to id conversion cursor
 CURSOR repair_id_conv_cur(p_repair_number VARCHAR2) IS
 SELECT REPAIR_LINE_ID
 FROM CSD_REPAIRS
 WHERE repair_number = p_repair_number;

 -- Get status_id from status_Code
 CURSOR flow_stat_cur(p_repair_status VARCHAR2) IS
 SELECT FLOW_STATUS_ID
 FROM CSD_FLOW_STATUSES_B
 WHERE FLOW_STATUS_CODE = p_repair_status;


BEGIN


   -- Initialize local variables.
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   l_debug_level   := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;

   IF (Fnd_Log.LEVEL_PROCEDURE >= l_debug_level) THEN
      Fnd_Log.STRING (Fnd_Log.LEVEL_PROCEDURE, 'csd.plsql.csd_repairs_util.Convert_Status_val_to_Id.begin',
            '-------------Entered Convert_Status_val_to_Id----------------');
   END IF;



   x_repair_status_rec := p_repair_status_rec;

   IF (p_repair_status_rec.repair_line_id IS NULL) THEN
   -- ID based attribute is NULL or MISSING
      IF (p_repair_status_rec.repair_number IS NULL) THEN
      -- value based parameter is also NULL or MISSING
         Fnd_Message.SET_NAME ('CSD', 'CSD_API_INV_REP_NUM');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
      ELSE
         OPEN repair_id_conv_cur(p_repair_status_rec.repair_number);
         FETCH repair_id_conv_cur INTO x_repair_status_rec.repair_line_id;
         IF repair_id_conv_cur%NOTFOUND THEN
            -- Id fetch was not successful
            -- Conversion failed.
            CLOSE repair_id_conv_cur;
            Fnd_Message.SET_NAME ('CSD', 'CSD_API_INV_REP_NUM');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         CLOSE repair_id_conv_cur;
      END IF;
   ELSIF p_repair_status_rec.repair_line_id IS NOT NULL THEN
   -- ID based attribute is present
      x_repair_status_rec.repair_line_id:= p_repair_status_rec.repair_line_id ;
   -- If the value based parameter is also passed, generate an
   -- informational message.
      IF (p_repair_status_rec.repair_number IS NOT NULL) THEN
         Fnd_Message.SET_NAME('CSD', 'CSD_API_INPUT_IGNORE');
         Fnd_Msg_Pub.ADD;
      END IF;
   END IF;


   IF (p_repair_status_rec.repair_status_id IS NULL) THEN
   -- ID based attribute is NULL or MISSING
      IF (p_repair_status_rec.repair_status IS NULL) THEN
      -- value based parameter is also NULL or MISSING
         Fnd_Message.SET_NAME('CSD','CSD_INVALID_FLOW_STATUS');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
      ELSE
         OPEN flow_stat_cur(p_repair_status_Rec.repair_status);
         FETCH flow_stat_cur INTO x_repair_status_Rec.repair_status_id;
         IF(flow_stat_cur%NOTFOUND) THEN
            CLOSE flow_stat_cur;
            Fnd_Message.SET_NAME('CSD','CSD_INVALID_FLOW_STATUS');
            Fnd_Msg_Pub.ADD;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         CLOSE flow_stat_cur;
      END IF;
   ELSIF p_repair_status_rec.repair_status_id IS NOT NULL THEN
   -- ID based attribute is present
      x_repair_status_rec.repair_status_id:= p_repair_status_rec.repair_line_id ;
   -- If the value based parameter is also passed, generate an
   -- informational message.
      IF (p_repair_status_rec.repair_status IS NOT NULL) THEN
         Fnd_Message.SET_NAME('CSD', 'CSD_API_INPUT_IGNORE');
         Fnd_Msg_Pub.ADD;
      END IF;
   END IF;



   IF (Fnd_Log.level_procedure >= l_debug_level) THEN
      Fnd_Log.STRING (Fnd_Log.level_procedure, 'csd.plsql.csd_repairs_util.Convert_Status_Val_to_Id.end',
            '-------------Leaving Convert_Status_Val_to_Id----------------');
   END IF;

END Convert_status_Val_to_Id;

-- ***********************************************************
--   API Name:  Check_WebSrvc_Security
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_repair_line_id            IN     VARCHAR2,
--   OUT
--     x_return_status
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API checks the security for the web service
--                 call. The security is setup as the permission
--                 to the current logged in user. If the logged in
--                 user has access to 1) account on SR
--                 returns true otherwise it returns false.
--                  The two other permisions for 3rd party scenario's
--                 are not developed for now. We need to design
--                 that in conjunction with logistics enhancements
--                 for the 3rd scenario.
--                  2) bill to party on SR
--                  3) ship to party on SR
--
---- ***********************************************************
PROCEDURE Check_WebSrvc_Security
(
  p_repair_line_id        IN  NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2
 ) IS
 l_return_Status VARCHAR2(1);
 l_predicate VARCHAR2(4000);
 l_table_alias VARCHAR2(80);
 l_Sql_str VARCHAR(8000);
 l_tmp_str VARCHAR2(30);
   C_CUST_PROD_ACTION_CODE CONSTANT VARCHAR2(30) := 'CUST_PROD';
   C_3RDPARTY_RMA_ACTION_TYPE CONSTANT VARCHAR2(30) := '3RDPARTY_RMA';
   C_3RDPARTY_SHIP_ACTION_TYPE CONSTANT VARCHAR2(30) := '3RDPARTY_SHIP';


 BEGIN
/******************
   Call FND_DATA_SECURITY.GET_PREDICATE to get the SQL predicate for checking the permission for the current logged in user for the account ch''x'' eck.  Parameters,
    p_object_name => Repair Order,
     p_grant_instance_type => 'SET',
     p_statement_type =>  'EXISTS'

*****************/

     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	/*!!!!!!!!!! Temporarily disabling the security
	return ;!!!!!*******/

   l_table_alias   := 'ro';
   debug('Calling getSecurity_predicate');
    Fnd_Data_Security.GET_SECURITY_PREDICATE(
               p_api_version          => 1.0,
                  p_function          => NULL,
                  p_object_name          => 'CSD_RO_OBJ',
                  p_grant_instance_type  => 'SET',
                  p_statement_type       => 'EXISTS',
                  x_predicate            => l_predicate,
                  x_return_status        => l_return_status,
                  p_table_alias          => l_table_alias );


   debug('getSecurity_predicate return value['||l_Return_status||']');
   debug('success['||FND_API.G_RET_STS_SUCCESS||']');
   debug('getSecurity_predicate predicate value['||l_predicate||']');

   IF(l_return_status <> FND_API.G_TRUE) THEN
      debug('returning l_return_status['||l_return_status||']');
      x_return_status := FND_API.G_RET_STS_ERROR;
   ELSE
      IF(l_predicate IS NOT NULL AND l_predicate <> '(1=1)') THEN

        debug('forming sql str');
        l_sql_str :=    'Select ''x'' from csd_repairs ro '
                  || ' Where  ro.repair_line_id = :1 and '
			   || l_predicate ;

        debug('l_sql before['||l_sql_str||']');
	   BEGIN
        EXECUTE IMMEDIATE l_sql_str INTO l_tmp_Str
                          USING p_repair_line_id ;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
        END;
        debug('l_tmp_Str after['||l_tmp_str||']');
        IF(l_tmp_str IS NULL ) THEN
         debug('returning failure because l_tmp_Str['||l_tmp_str||']');
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
        END IF;

      ELSE
           x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
      END IF;
    END IF;

    /************************
   Call FND_DATA_SECURITY.GET_PREDICATE to get the SQL predicate for checking
    the permission for the current logged in user for the bill to check.  Parameters,
    p_object_name         => 'Repair Logistics Line BillTo',
    p_grant_instance_type => 'SET',
    p_statement_type      => 'EXISTS'

    ************************/
    /********** Not done for R12 first release
    *********************************************
    Fnd_Data_Security.GET_SECURITY_PREDICATE(
                  p_api_version          => 1.0,
                  p_function             => NULL,
                  p_object_name          => 'Repair LogisticsLine BillTo',
                  p_grant_instance_type  => 'SET',
                  p_user_name            => Fnd_Global.USER_ID,
                  p_statement_type       => 'EXISTS',
                  x_predicate            => l_predicate,
                  x_return_status        => l_return_status,
                  p_table_alias          => l_table_alias );

    IF(l_predicate IS NULL OR l_predicate <> '(1=1)') THEN

        l_sql_str :=    ' Select ''x'' from csd_repairs_v ro, csd_product_txns_v prd, '
                  + ' cs_estimate_details csd   Where  ro.repair_line_id = :1'
                  + ' And prd.repair_line_id = ro.repair_line_id '
                  + ' And prd.action_code = :2 '
                  + ' And prd.action_type = :3 '
                  + ' And csd.estimate_detail_id = prd.estimate_detail_id '
                  + ' And ' + l_predicate
 ;

        EXECUTE IMMEDIATE l_sql_str INTO l_tmp_Str
                          USING TO_CHAR(p_repair_line_id),
                             C_CUST_PROD_ACTION_CODE ,
                             C_3RDPARTY_RMA_ACTION_TYPE ;
        IF(l_tmp_str IS NULL ) THEN
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
        END IF;

    END IF;
    ************************************************
    ***********************************************/


    /************************
      Call FND_DATA_SECURITY.GET_PREDICATE to get the SQL predicate for checking the permission for the current logged in user for the ship to check.  Parameters,
    p_object_name => 'Repair Logistics Line ShipTo',
     p_grant_instance_type => 'SET',
     p_statement_type =>  'EXISTS'
    ************************/
    /************************************ Not done for
    R12 first release
    ***************************************
    Fnd_Data_Security.GET_SECURITY_PREDICATE(
                  p_api_version          => 1.0,
                  p_function             => NULL,
                  p_object_name          => 'Repair LogisticsLine ShipTo',
                  p_grant_instance_type  => 'SET',
                  p_user_name            => Fnd_Global.USER_ID,
                  p_statement_type       => 'EXISTS',
                  x_predicate            => l_predicate,
                  x_return_status        => l_return_status,
                  p_table_alias          => l_table_alias );

    IF(l_predicate IS NULL OR l_predicate <> '(1=1)') THEN

        l_sql_str :=    ' Select ''x'' from csd_repairs_v ro, csd_product_txns_v prd, '
                  + ' cs_estimate_details csd   Where  ro.repair_line_id = :1'
                  + ' And prd.repair_line_id = ro.repair_line_id '
                  + ' And prd.action_code = :2 '
                  + ' And prd.action_type = :3 '
                  + ' And csd.estimate_detail_id = prd.estimate_detail_id '
                  + ' And ' + l_predicate ;

        EXECUTE IMMEDIATE l_sql_str INTO l_tmp_Str
                          USING TO_CHAR(p_repair_line_id),
                             C_CUST_PROD_ACTION_CODE ,
                             C_3RDPARTY_SHIP_ACTION_TYPE ;
        IF(l_tmp_str IS NULL ) THEN
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
        END IF;

    END IF;
    ************************************************
    ***********************************************/

   debug('returning success');
     EXCEPTION
      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         debug('sqlca.sqlcode ['||sqlcode ||']');
         debug('sqlca.sqlerrm['||sqlerrm||']');


 END check_Websrvc_security;
-- R12 Development End


/*-----------------------------------------------------------------*/
/* procedure name: change_item_ib_owner                            */
/* description   : Procedure to Change the Install Base Owner for  */
/*                 a single item                                   */
/*-----------------------------------------------------------------*/
PROCEDURE CHANGE_ITEM_IB_OWNER
(
 p_create_tca_relation    IN         VARCHAR2 := NULL,
 p_instance_id            IN         NUMBER,
 p_new_owner_party_id     IN         NUMBER,
 p_new_owner_account_id   IN         NUMBER,
 p_current_owner_party_id IN         NUMBER,
 x_return_status         OUT  NOCOPY VARCHAR2,
 x_msg_count             OUT  NOCOPY NUMBER,
 x_msg_data              OUT  NOCOPY VARCHAR2,
 x_tca_relation_id       OUT  NOCOPY NUMBER
)
IS

  -- variables for update instance
  l_csiip_inst_party_id    Number     := NULL;
  l_csiip_obj_ver_num      Number     := NULL;
  l_instance_account_id    Number     := NULL;
  l_inst_acct_obj_ver_num  Number     := NULL;
  l_object_version_number  Number     := NULL;
  l_instance_rec           csi_datastructures_pub.instance_rec;
  l_party_tbl              csi_datastructures_pub.party_tbl;
  l_ext_attrib_values_tbl  csi_datastructures_pub.extend_attrib_values_tbl;
  l_account_tbl            csi_datastructures_pub.party_account_tbl;
  l_pricing_attrib_tbl     csi_datastructures_pub.pricing_attribs_tbl;
  l_org_assignments_tbl    csi_datastructures_pub.organization_units_tbl;
  l_asset_assignment_tbl   csi_datastructures_pub.instance_asset_tbl;
  l_txn_rec                csi_datastructures_pub.transaction_rec;
  x_instance_id_lst        csi_datastructures_pub.id_tbl;

  -- variables for create TCA relationship
  l_current_owner_party_type Varchar2(150)   := NULL;
  l_new_owner_party_type     Varchar2(150)   := NULL;
  l_relationship_rec         hz_relationship_v2pub.relationship_rec_type;
  l_rel_party_id             Number;
  l_rel_party_number         Varchar2(150);
  l_tca_rel_in_params        csd_ib_chown_cuhk.tca_rel_info_in_rec_type;
  l_tca_rel_out_params       csd_ib_chown_cuhk.tca_rel_info_out_rec_type;
  l_tca_rel_count            Number;

  --bug#8508030
  l_bill_to_address          Number;
  l_ship_to_address          Number;
  --bug#8508030

  -- API variables
  l_api_name               CONSTANT Varchar(30)   := 'CHANGE_ITEM_IB_OWNER';
  l_api_version            CONSTANT Number        := 1.0;

  -- Cursor to select the Instance party id
  Cursor c_instance_party(p_instance_id number) IS
  Select instance_party_id,
         object_version_number
  from csi_i_parties
  where instance_id = p_instance_id
  and relationship_type_code = 'OWNER'
  and sysdate between nvl(active_start_date, sysdate-1)
                  and nvl(active_end_date, sysdate+1);

  -- Cursor to derive the Instance details
  Cursor c_instance_details(p_instance_id number) IS
  Select object_version_number from csi_item_instances
  where instance_id = p_instance_id;

  -- Cursor to derive the Instance Account Id
  Cursor c_instance_account(p_instance_party_id number) is
  Select ip_account_id,
         object_version_number
  from csi_ip_accounts
  where instance_party_id = p_instance_party_id;

  -- Cursor to derive party information from hz_parties
  Cursor c_hz_parties_info(p_party_id number) is
  Select party_type
  from hz_parties
  where party_id = p_party_id;

  -- cursor to get the number of party relationships for the given criteria
  Cursor c_tca_rel_count(p_subject_id number, p_subject_type varchar2,
                         p_object_id number, p_object_type varchar2,
                         p_relationship_code varchar2) is
  Select count(relationship_id)
  from hz_relationships
  where subject_id = p_subject_id
    and subject_type = p_subject_type
    and subject_table_name = 'HZ_PARTIES'
    and object_id = p_object_id
    and object_type = p_object_type
    and object_table_name = 'HZ_PARTIES'
    and relationship_code = p_relationship_code
    and sysdate between nvl(start_date, sysdate-1)
                    and nvl(end_date, sysdate+1);

  --bug#8508030
  Cursor get_bill_to_ship_to_address(p_instance_id number) IS
    SELECT bill_to_address,ship_to_address
    FROM CSI_IP_ACCOUNTS
    WHERE INSTANCE_PARTY_ID =
            (SELECT instance_party_id FROM CSI_I_PARTIES
            WHERE INSTANCE_ID=p_instance_id
            AND relationship_type_code='OWNER');
  --bug#8508030

BEGIN

  savepoint CHANGE_ITEM_IB_OWNER;

  if (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_REPAIRS_UTIL.CHANGE_ITEM_IB_OWNER.BEGIN',
                    'Enter - Change Item IB Owner');
  end if;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- create a TCA relationship between the current owner and
  -- new owner, if desired
  if(p_create_tca_relation = fnd_api.g_true) then

    -- get info for original owner
    Open c_hz_parties_info(p_current_owner_party_id);
    Fetch c_hz_parties_info
    into l_current_owner_party_type;
    Close c_hz_parties_info;

    -- get info for new owner
    Open c_hz_parties_info(p_new_owner_party_id);
    Fetch c_hz_parties_info into l_new_owner_party_type;
    Close c_hz_parties_info;

    -- get relationship type and code from custom hook procedure
    l_tca_rel_in_params.instance_id := p_instance_id;
    l_tca_rel_in_params.new_owner_party_id := p_new_owner_party_id;
    l_tca_rel_in_params.new_owner_account_id := p_new_owner_account_id;
    l_tca_rel_in_params.current_owner_party_id := p_current_owner_party_id;
    csd_ib_chown_cuhk.get_tca_rel_info (
            p_in_param => l_tca_rel_in_params,
            x_out_param => l_tca_rel_out_params
    );
    if NOT(l_tca_rel_out_params.return_status = FND_API.G_RET_STS_SUCCESS) then
      RAISE FND_API.G_EXC_ERROR;
    end if;

    -- populate the relationship rec before calling API
    -- Assumption: the owners will always be from hz_parties
    l_relationship_rec.subject_id := p_new_owner_party_id;
    l_relationship_rec.subject_type := l_new_owner_party_type;
    l_relationship_rec.subject_table_name := 'HZ_PARTIES';
    l_relationship_rec.object_id := p_current_owner_party_id;
    l_relationship_rec.object_type := l_current_owner_party_type;
    l_relationship_rec.object_table_name := 'HZ_PARTIES';
    l_relationship_rec.relationship_code := l_tca_rel_out_params.relationship_code;
    l_relationship_rec.relationship_type := l_tca_rel_out_params.relationship_type;
    l_relationship_rec.start_date := SYSDATE;
    l_relationship_rec.created_by_module := 'CSDSR';
    l_relationship_rec.application_id := 516;

    -- check if TCA relationship already exists
    Open c_tca_rel_count(l_relationship_rec.subject_id, l_relationship_rec.subject_type,
                         l_relationship_rec.object_id, l_relationship_rec.object_type,
                         l_relationship_rec.relationship_code);
    Fetch c_tca_rel_count
    into l_tca_rel_count;
    Close c_tca_rel_count;

    -- only create the TCA relationship if one does not exist already
    if (l_tca_rel_count = 0 ) then
        -- create the TCA relation
        hz_relationship_v2pub.create_relationship(
            p_init_msg_list => fnd_api.g_false,
            p_relationship_rec => l_relationship_rec,
            x_relationship_id => x_tca_relation_id,
            x_party_id => l_rel_party_id,
            x_party_number => l_rel_party_number,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_create_org_contact => 'Y'
        );
        if NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
          RAISE FND_API.G_EXC_ERROR;
        end if;
    end if; -- l_tca_rel_count = 0
  End If; -- p_create_tca_relation = true

  -- Get the current instance info
  Open c_instance_party(p_instance_id);
  Fetch c_instance_party into l_csiip_inst_party_id,
                              l_csiip_obj_ver_num;
  Close c_instance_party;

  -- Get the current owner's account information
  Open c_instance_account(l_csiip_inst_party_id);
  Fetch c_instance_account into l_instance_account_id,
                          l_inst_acct_obj_ver_num;
  Close c_instance_account;

  -- Get additional information about the IB instancee
  Open c_instance_details(p_instance_id);
  Fetch c_instance_details into l_object_version_number;
  Close c_instance_details;


  -- Assign / Initialize values to the IB Rec type
  l_instance_rec.instance_id              := p_instance_id;
  l_instance_rec.object_version_number    := l_object_version_number;

  l_party_tbl(1).instance_party_id        := l_csiip_inst_party_id;
  l_party_tbl(1).instance_id              := p_instance_id;
  l_party_tbl(1).party_source_table       := 'HZ_PARTIES';
  l_party_tbl(1).party_id                 := p_new_owner_party_id;
  l_party_tbl(1).relationship_type_code   := 'OWNER';
  l_party_tbl(1).contact_flag             := 'N';
  l_party_tbl(1).object_version_number    := l_csiip_obj_ver_num;

  l_account_tbl(1).ip_account_id          := l_instance_account_id;
  l_account_tbl(1).parent_tbl_index       := 1;
  l_account_tbl(1).instance_party_id      := l_csiip_inst_party_id;
  l_account_tbl(1).party_account_id       := p_new_owner_account_id;
  l_account_tbl(1).relationship_type_code := 'OWNER';
  l_account_tbl(1).object_version_number  := l_inst_acct_obj_ver_num;

  --bug#8508030
  -- Get existing bill_to and ship_to address of the IB instancee
  Open get_bill_to_ship_to_address(p_instance_id);
  Fetch get_bill_to_ship_to_address into l_bill_to_address, l_ship_to_address;
  Close get_bill_to_ship_to_address;

  --pass the original bill_to and ship_to address back. If this not pass,
  --it will set the bill to and shipp to address to null value
  l_account_tbl(1).bill_to_address := l_bill_to_address;
  l_account_tbl(1).ship_to_address := l_ship_to_address;
  --bug#8508030

  l_txn_rec.transaction_date        := sysdate;
  l_txn_rec.source_transaction_date := sysdate;
  l_txn_rec.transaction_type_id     := 1;

  -- Call the Update item instance API
  csi_item_instance_pub.update_item_instance
  (
    p_api_version           =>  1.0,
    p_commit                =>  fnd_api.g_false,
    p_init_msg_list         =>  fnd_api.g_true,
    p_validation_level      =>  fnd_api.g_valid_level_full,
    p_instance_rec          =>  l_instance_rec,
    p_ext_attrib_values_tbl =>  l_ext_attrib_values_tbl,
    p_party_tbl             =>  l_party_tbl,
    p_account_tbl           =>  l_account_tbl,
    p_pricing_attrib_tbl    =>  l_pricing_attrib_tbl,
    p_org_assignments_tbl   =>  l_org_assignments_tbl,
    p_asset_assignment_tbl  =>  l_asset_assignment_tbl,
    p_txn_rec               =>  l_txn_rec,
    x_instance_id_lst       =>  x_instance_id_lst,
    x_return_status         =>  x_return_status,
    x_msg_count             =>  x_msg_count,
    x_msg_data              =>  x_msg_data
  );

  If NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  End If;

  COMMIT WORK;

  If (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) then
    fnd_log.STRING (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_REPAIRS_UTIL.CHANGE_ITEM_IB_OWNER.END',
                    'Exit - Change Item IB Owner');
  End if;

EXCEPTION
  When FND_API.G_EXC_ERROR then
    Rollback To change_item_ib_owner;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data  );

  When FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    ROLLBACK TO change_item_ib_owner;
    FND_MSG_PUB.Count_And_Get
      ( p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

  When OTHERS then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    Rollback To change_item_ib_owner;
    If  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
      FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name  );
     End If;
     FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

END CHANGE_ITEM_IB_OWNER;

--bug#5874431
Procedure create_csd_index (p_sql_stmt IN	varchar2,
                            p_object   IN   varchar2
						   ) is

lv_dummy1            VARCHAR2(2000);
lv_dummy2            VARCHAR2(2000);
lv_retval            BOOLEAN;
v_applsys_schema     VARCHAR2(200);
lv_prod_short_name   VARCHAR2(30);

begin
	lv_retval := FND_INSTALLATION.GET_APP_INFO(
				'FND', lv_dummy1,lv_dummy2, v_applsys_schema);

	lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(512);
	ad_ddl.do_ddl(  applsys_schema => v_applsys_schema,
					application_short_name => lv_prod_short_name,
					statement_type => AD_DDL.CREATE_INDEX,
					statement => p_sql_stmt,
					object_name => p_object
				  );

	EXCEPTION
		WHEN OTHERS THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
			RAISE;
end  create_csd_index;

--   *******************************************************
--   API Name:  get_contract_resolve_by_date
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN                                               required?
--     p_contract_line_id            IN     NUMBER,   Y
--     p_bus_proc_id                 IN     NUMBER,   Y
--     p_severity_id                 IN     NUMBER,   Y
--     p_request_date                IN     NUMBER,   N - if not passed, use sysdate
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--     x_resolve_by_date             OUT    DATE
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : rfieldma: 5355051
--                 calls oks_entitlements_pub.get_react_resolve_by
--                 return resolve_by_date
--
--
--
--
-- ***********************************************************
PROCEDURE get_contract_resolve_by_date
(
  p_contract_line_id        IN  NUMBER,
  p_bus_proc_id             IN  NUMBER,
  p_severity_id             IN  NUMBER,
  p_request_date            IN  DATE := sysdate,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  x_resolve_by_date       OUT NOCOPY    DATE
 ) IS
    -- define constants
    lc_api_name CONSTANT VARCHAR2(50) := 'csd_repairs_util.get_contract_resolve_by_date';

    -- define variables
    l_server_timezone_id  NUMBER;

    subtype r_input_rec is oks_entitlements_pub.grt_inp_rec_type;
    l_inp_rec     r_input_rec;

    subtype r_react_rec is oks_entitlements_pub.rcn_rsn_rec_type;
    l_react_rec     r_react_rec;

    subtype r_resolve_rec is oks_entitlements_pub.rcn_rsn_rec_type;
    l_resolve_rec     r_resolve_rec;


BEGIN
    SAVEPOINT get_contract_resolve_by_date;
    x_resolve_by_date := null; -- default this field to null before logic begins

    -- call PROCEDURE Check_Reqd_Param (p_param_value   IN NUMBER,
    --                                  p_param_name    IN VARCHAR2,
    --                                  p_api_name      IN VARCHAR2
    -- ) to check p_contract_line_id, p_bus_proc_id, p_severity

    Check_Reqd_Param(p_contract_line_id,
                     'p_contract_line_id',
				 lc_api_name);

    Check_Reqd_Param(p_bus_proc_id,
                     'p_bus_proc_id',
				 lc_api_name);

    Check_Reqd_Param(p_severity_id,
                     'p_severity_id',
				 lc_api_name);

    -- profile option for server_timezone_id must be set
    l_server_timezone_id := fnd_profile.value('SERVER_TIMEZONE_ID');
    IF (NVL(l_server_timezone_id,Fnd_Api.G_MISS_NUM) = Fnd_Api.G_MISS_NUM) THEN
        Fnd_Message.SET_NAME('CSD','CSD_CANNOT_GET_PROFILE_VALUE');
        Fnd_Message.SET_TOKEN('PROFILE',get_user_profile_option_name('SERVER_TIMEZONE_ID'));
        Fnd_Msg_Pub.ADD;
        RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    l_inp_rec.contract_line_id         := p_contract_line_id ;
    l_inp_rec.business_process_id      := p_bus_proc_id ;
    l_inp_rec.severity_id              := p_severity_id ;
    l_inp_rec.request_date             := p_request_date ;
    l_inp_rec.time_zone_id             := l_server_timezone_id ;
    l_inp_rec.category_rcn_rsn         := OKS_ENTITLEMENTS_PUB.G_RESOLUTION;
    l_inp_rec.compute_option           := OKS_ENTITLEMENTS_PUB.G_BEST ;
    l_inp_rec.dates_in_input_tz        := 'N' ;

    oks_entitlements_pub.get_react_resolve_by_time(
           p_api_version          => 1.0,
           p_init_msg_list        => FND_API.G_TRUE,
           p_inp_rec              => l_inp_rec,
           x_return_status        => x_return_status,
           x_msg_count            => x_msg_count,
           x_msg_data             => x_msg_data,
           x_react_rec            => l_react_rec,
           x_resolve_rec          => l_resolve_rec);

    IF (x_return_status = Fnd_Api.G_RET_STS_ERROR) THEN
        RAISE Fnd_Api.G_EXC_ERROR ;
    ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    x_resolve_by_date := l_resolve_rec.by_date_end;

    EXCEPTION
      When FND_API.G_EXC_ERROR then
        Rollback To get_contract_resolve_by_date;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data  );

      When FND_API.G_EXC_UNEXPECTED_ERROR then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        ROLLBACK TO get_contract_resolve_by_date;
        FND_MSG_PUB.Count_And_Get
          ( p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      When OTHERS then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        Rollback To get_contract_resolve_by_date;
        If  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
          FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             lc_api_name  );
         End If;
         FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

 END get_contract_resolve_by_date;

--   *******************************************************
--   API Name:  get_user_profile_option_name
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN                                           required?
--     p_profile_name            IN     VARHAR2   Y
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : rfieldma: utility function
--                 returns language specific user profile
--                 option name
--
--
--
--
-- ***********************************************************
FUNCTION get_user_profile_option_name
(
  p_profile_name         IN VARCHAR2
) RETURN VARCHAR2
IS
    -- define variables
    l_user_prof_name VARCHAR2(240);

    -- define cursors
    CURSOR c_user_prof_name(p_profile_name VARCHAR2) IS
        SELECT user_profile_option_name
	   FROM fnd_profile_options_tl
	   WHERE profile_option_name = p_profile_name
	   AND   language = userenv('lang');

BEGIN
    OPEN c_user_prof_name(p_profile_name);
    FETCH c_user_prof_name
     INTO l_user_prof_name;
    CLOSE c_user_prof_name;

    RETURN l_user_prof_name;

END get_user_profile_option_name;

-- bug#7497790, 12.1 FP,subhat.
-- ***************************************************
-- Automatically update the RO status when the item is received.
-- The API receives the Repair line id and updates the RO status if the conditions are met.
-- Parameters:
-- p_event : Specify the event that is calling this program. Based on the event, the program logic might change.
-- p_reason_code: The reason code for the status change defaulted to null
-- p_comments: The comments for the flow status, defaulted to null
-- p_validation_level: validation level for the routine. Pass fnd_api.g_valid_level_full to get the messages from the API
-- 			     pass fnd_api.g_valid_level_none will ignore all error messages and return success always. The error messages
--			    will be logged in the fnd_log_messages if logging is enabled
--*****************************************************

procedure auto_update_ro_status(
                  p_api_version    in number,
                  p_commit         in varchar2,
                  p_init_msg_list  in varchar2,
                  p_repair_line_id in number,
                  x_return_status  out nocopy varchar2,
                  x_msg_count      out nocopy number,
                  x_msg_data       out nocopy varchar2,
                  p_event          in varchar2,
				          p_reason_code    in varchar2 default null,
				          p_comments       in varchar2 default null,
				          p_validation_level in number)
is
  l_from_flow_status_id number;
  l_to_flow_status_id number;
  x_object_version_number number;
  l_repair_type_id  number;
  l_object_version_number number;
  lc_log_level number := fnd_log.g_current_runtime_level;
  lc_procedure_level number := fnd_log.level_procedure;
  lc_mod_name varchar2(100) := 'csd.plsql.csd_repairs_util.auto_update_ro_status';
  lc_api_version_number number := 1.0;
  lc_api_name  varchar2(60) := 'auto_update_ro_status';
  l_un_rcvd_lines_exists  varchar2(3);

begin

  -- standard API compatibility check.
  IF NOT Fnd_Api.Compatible_API_Call
    (lc_api_version_number,
     p_api_version,
     lc_api_name,
     G_PKG_NAME)
  THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  IF fnd_api.to_boolean(p_init_msg_list)
  THEN
        -- initialize message list
         fnd_msg_pub.initialize;
  END IF;

  if lc_log_level >= lc_procedure_level then
    fnd_log.string(lc_log_level,lc_mod_name,'Begin auto_update_ro_status');
  end if;

  -- set the return status
 x_return_status := fnd_api.g_ret_sts_success;
  -- check if the profile to enable the auto update of RO status is set to yes.

 if p_event = 'RECEIVE' then
 -- check if all the RMA -- CUST_PROD and RMA-EXCHANGE combination is received.
 -- only update the RO status if all RMA -- CUST_PROD combination is received
 --
 if nvl(fnd_profile.value('CSD_ENABLE_AUTO_UPD_RO_STAT'),'N') = 'N'
	then
		if lc_log_level >= lc_procedure_level then
			fnd_log.string(lc_log_level,lc_mod_name,'Profile CSD: Enable Auto Update of Repair
			Order Status upon Receiving is not set to yes.');
		end if;
		if p_validation_level = fnd_api.g_valid_level_full then
		-- to do: If the caller API needs this API to raise the errors, set a message into message stack and raise an error to exception block.
			null;
		else
			return; -- return to the caller.
		end if;
 end if;

 begin
 select 'x'
 into l_un_rcvd_lines_exists
 from (
  select 'x'
  from csd_product_transactions cpt
  where cpt.repair_line_id = p_repair_line_id and
        cpt.action_type = 'RMA' and
        cpt.action_code in ('CUST_PROD','EXCHANGE') and
        cpt.prod_txn_status <> 'RECEIVED'
        and rownum < 2
	) where rownum < 2 ;
 exception
  when no_data_found then
    l_un_rcvd_lines_exists := null;
 end;

if l_un_rcvd_lines_exists is null then

 l_to_flow_status_id := fnd_profile.value('CSD_DEF_RO_STAT_FR_RCV');
 if l_to_flow_status_id is null then
  if lc_log_level >= lc_procedure_level then
    fnd_log.string(lc_log_level,lc_mod_name,'Profile CSD: Default Repair Order Status After
	Receving is not set');
  end if;
  if p_validation_level = fnd_api.g_valid_level_full then
	-- to do: set a message and raise an error for the caller API.
	   null;
  else
	 return; -- exit the procedure. With the success status.
  end if;
 end if;

  -- get the 'from' flow status id.
  --
  begin
        select distinct cr.flow_status_id,
               cr.repair_type_id,
               cr.object_version_number
        into  l_from_flow_status_id,
              l_repair_type_id,
              l_object_version_number
        from csd_repairs cr
        where cr.repair_line_id = p_repair_line_id;
        exception
			when no_data_found then
          -- should never get in here.
			  null;
  end;

  if l_to_flow_status_id = l_from_flow_status_id then
    -- to and from are same. Do not update.
    if lc_log_level >= lc_procedure_level then
		  fnd_log.string(lc_log_level,lc_mod_name,'the new status is same as the old status. Do not update the status');
    end if;
    if p_validation_level = fnd_api.g_valid_level_full then
		-- to do: set a message and raise an error.
		  null;
	  else
		  return;
	  end if;
  end if;
  -- call the update flow status API to update the RO status.
  if lc_log_level >= lc_procedure_level then
    fnd_log.string(lc_log_level,lc_mod_name,'calling csd_repairs_pvt.update_flow_status API');
  end if;

  csd_repairs_pvt.update_flow_status(p_api_version        => 1,
                                   p_commit               => fnd_api.g_false,
                                   p_init_msg_list        => fnd_api.g_false,
                                   p_validation_level     => fnd_api.g_valid_level_full,
                                   x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data,
                                   p_repair_line_id       => p_repair_line_id,
                                   p_repair_type_id       => l_repair_type_id,
                                   p_from_flow_status_id  => l_from_flow_status_id,
                                   p_to_flow_status_id    => l_to_flow_status_id,
                                   p_reason_code          => p_reason_code,
                                   p_comments             => p_comments,
                                   p_check_access_flag    => 'Y',
                                   p_object_version_number =>  l_object_version_number,
                                   x_object_version_number => x_object_version_number );
  if x_return_status <> fnd_api.g_ret_sts_success then
    if lc_log_level >= lc_procedure_level then
      fnd_log.string(lc_log_level,lc_mod_name,'Error in csd_repairs_pvt.update_flow_status
	                   ['||x_msg_data||']');
    end if;

	 if p_validation_level = fnd_api.g_valid_level_full then
		-- to do: set a message and raise an error;
	   	null;
	 else
		-- set the return to status to success.
		  x_return_status := fnd_api.g_ret_sts_success;
		  return;
	 end if;
  end if;

 end if; -- l_all_lines_rcvd
end if; -- p_event = 'RECEIVE'

 if p_commit = fnd_api.g_true then
  commit;
 end if;

exception
  when fnd_api.g_exc_error then
    -- raising a error may not be a good idea, as it can potentially roll back
    -- entire transaction. For now, we can prefer to do nothing.
    x_return_status := fnd_api.g_ret_sts_success;
	  null;
end auto_update_ro_status;
-- end bug#7497790, 12.1 FP, subhat.

--   *******************************************************
--   API Name:  default_ro_attrs_from_rule
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN OUT                                           required?
--     px_repln_rec  in out nocopy CSD_REPAIRS_PUB.REPLN_REC_TYPE   Y
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : swai: utility procedure added for bug 7657379
--                 defaults Repair Order attributes from defaulting
--                 rules into px_repln_rec if the field is not already
--                 set.  Uses existing values in px_repln_rec to populate
--                 the rule input rec for defaulting rules.
--                 Currently, the following fields are defaulted if
--                 they are passed in as G_MISS:
--                   Inventory Org
--                   Repair Org
--                   Repair Owner
--                   Repair Priority
--                   Repair Type
--                 Note that the profile option value will be returned
--                 if no applicable rules exist.  For Repair Types,
--                 the profile value returned in for profile
--                 'CSD_DEFAULT_REPAIR_TYPE'
-- ***********************************************************
PROCEDURE DEFAULT_RO_ATTRS_FROM_RULE (
                  p_api_version    in number,
                  p_commit         in varchar2,
                  p_init_msg_list  in varchar2,
                  px_repln_rec     in out nocopy csd_repairs_pub.repln_rec_type,
                  x_return_status  out nocopy varchar2,
                  x_msg_count      out nocopy number,
                  x_msg_data       out nocopy varchar2)
IS
  cursor c_def_wip (p_repair_type_id number) is
  select distinct repair_mode, nvl(auto_process_rma,'N')
  from csd_repair_types_vl
  where repair_type_id = p_repair_type_id;

  CURSOR c_get_sr_info(p_incident_id number) is
    select customer_id,
           account_id,
           bill_to_site_use_id,
           ship_to_site_use_id,
           inventory_item_id,
           category_id,
           contract_id,
           problem_code,
           customer_product_id
    from CS_INCIDENTS_ALL_VL
    where incident_id = p_incident_id;

  l_rule_input_rec   CSD_RULES_ENGINE_PVT.CSD_RULE_INPUT_REC_TYPE;
  l_attr_type        VARCHAR2(25);
  l_attr_code        VARCHAR2(25);
  l_default_val_num  NUMBER;
  l_default_val_str  VARCHAR(30);
  l_default_rule_id  NUMBER;
  l_inv_org          NUMBER;
  l_repair_org       NUMBER;                -- repair org id
  l_repair_type_id   NUMBER;                -- repair type id
  l_repair_mode      VARCHAR2(30)  := '';   -- repair mode display name
  l_auto_process_rma VARCHAR2(30)  := '';
  lc_log_level number := fnd_log.g_current_runtime_level;
  lc_procedure_level number := fnd_log.level_procedure;
  lc_mod_name varchar2(100) := 'csd.plsql.csd_repairs_util.default_ro_attrs_from_rule';
  lc_api_version_number number := 1.0;
  lc_api_name  varchar2(60) := 'default_ro_attrs_from_rule';

BEGIN
    -- standard API compatibility check.
    if NOT FND_API.Compatible_API_Call
        (lc_api_version_number,
         p_api_version,
         lc_api_name,
         G_PKG_NAME)
    then
        RAISE Fnd_Api.G_EXC_ERROR;
    end if;

    if FND_API.to_boolean(p_init_msg_list) then
        -- initialize message list
        fnd_msg_pub.initialize;
    end if;

    if lc_log_level >= lc_procedure_level then
        fnd_log.string(lc_log_level,lc_mod_name,'Begin default_ro_attrs_from_rule');
    end if;

    -- set the return status
    x_return_status := fnd_api.g_ret_sts_success;

    -- Assume SR Incident Id is available to get info for defaulting RO attributes
    open c_get_sr_info(px_repln_rec.incident_id);
        fetch c_get_sr_info into
            l_rule_input_rec.SR_CUSTOMER_ID,
            l_rule_input_rec.SR_CUSTOMER_ACCOUNT_ID,
            l_rule_input_rec.SR_BILL_TO_SITE_USE_ID,
            l_rule_input_rec.SR_SHIP_TO_SITE_USE_ID,
            l_rule_input_rec.SR_ITEM_ID,
            l_rule_input_rec.SR_ITEM_CATEGORY_ID,
            l_rule_input_rec.SR_CONTRACT_ID,
            l_rule_input_rec.SR_PROBLEM_CODE,
            l_rule_input_rec.SR_INSTANCE_ID;
    close c_get_sr_info;

    l_rule_input_rec.RO_ITEM_ID                 :=  px_repln_rec.INVENTORY_ITEM_ID;

    /****************************** DEFAULT INVENTORY ORG ******************************/
    if (px_repln_rec.inventory_org_id = FND_API.G_MISS_NUM) then
        l_attr_type := 'CSD_DEF_ENTITY_ATTR_RO';
        l_attr_code := 'INV_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
            p_api_version_number    => 1.0,
            p_init_msg_list         => fnd_api.g_false,
            p_commit                => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_entity_attribute_type => l_attr_type,
            p_entity_attribute_code => l_attr_code,
            p_rule_input_rec        => l_rule_input_rec,
            x_default_value         => l_default_val_num,
            x_rule_id               => l_default_rule_id,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
        );

        if (x_return_status = fnd_api.g_ret_sts_success) then
            if (l_default_val_num is not null) then
                l_inv_org := l_default_val_num;
            else
                l_inv_org := to_number(fnd_profile.value('CSD_DEF_REP_INV_ORG'));
            end if;
        else
            RAISE FND_API.G_EXC_ERROR;
        end if;

        if l_inv_org is not null then
            px_repln_rec.inventory_org_id := l_inv_org;
        end if;
    end if;

    /****************************** DEFAULT REPAIR ORG  ******************************/
    if (px_repln_rec.resource_group = FND_API.G_MISS_NUM) then
        l_attr_type := 'CSD_DEF_ENTITY_ATTR_RO';
        l_attr_code := 'REPAIR_ORG';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
            p_api_version_number    => 1.0,
            p_init_msg_list         => fnd_api.g_false,
            p_commit                => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_entity_attribute_type => l_attr_type,
            p_entity_attribute_code => l_attr_code,
            p_rule_input_rec        => l_rule_input_rec,
            x_default_value         => l_default_val_num,
            x_rule_id               => l_default_rule_id,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
        );
        if (x_return_status = fnd_api.g_ret_sts_success) then
            if (l_default_val_num is not null) then
                l_repair_org := l_default_val_num;
            else
                l_repair_org := to_number(fnd_profile.value('CSD_DEFAULT_REPAIR_ORG'));
            end if;
        else
            RAISE FND_API.G_EXC_ERROR;
        end if;

        if l_repair_org is not null then
          px_repln_rec.resource_group := l_repair_org;
        end if;
    end if;

    /****************************** DEFAULT REPAIR OWNER  ******************************/
    if (px_repln_rec.resource_id = FND_API.G_MISS_NUM) then
        l_attr_type := 'CSD_DEF_ENTITY_ATTR_RO';
        l_attr_code := 'REPAIR_OWNER';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
            p_api_version_number    => 1.0,
            p_init_msg_list         => fnd_api.g_false,
            p_commit                => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_entity_attribute_type => l_attr_type,
            p_entity_attribute_code => l_attr_code,
            p_rule_input_rec        => l_rule_input_rec,
            x_default_value         => l_default_val_num,
            x_rule_id               => l_default_rule_id,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
        );
        if (x_return_status = fnd_api.g_ret_sts_success) then
            if (l_default_val_num is not null) then
                px_repln_rec.resource_id := l_default_val_num;
            end if;
        else
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    /****************************** DEFAULT REPAIR PRIORITY  ******************************/
    if (px_repln_rec.ro_priority_code = FND_API.G_MISS_CHAR) then
        l_attr_type := 'CSD_DEF_ENTITY_ATTR_RO';
        l_attr_code := 'REPAIR_PRIORITY';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
            p_api_version_number    => 1.0,
            p_init_msg_list         => fnd_api.g_false,
            p_commit                => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_entity_attribute_type => l_attr_type,
            p_entity_attribute_code => l_attr_code,
            p_rule_input_rec        => l_rule_input_rec,
            x_default_value         => l_default_val_str,
            x_rule_id               => l_default_rule_id,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
        );
        if (x_return_status = fnd_api.g_ret_sts_success) then
            if (l_default_val_str is not null) then
                px_repln_rec.ro_priority_code := l_default_val_str;
            end if;
        else
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    /****************************** DEFAULT REPAIR TYPE  ******************************/
    if (px_repln_rec.repair_type_id = FND_API.G_MISS_NUM) then
        l_attr_type := 'CSD_DEF_ENTITY_ATTR_RO';
        l_attr_code := 'REPAIR_TYPE';
        l_default_val_num := null;
        CSD_RULES_ENGINE_PVT.GET_DEFAULT_VALUE_FROM_RULE(
            p_api_version_number    => 1.0,
            p_init_msg_list         => fnd_api.g_false,
            p_commit                => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_full,
            p_entity_attribute_type => l_attr_type,
            p_entity_attribute_code => l_attr_code,
            p_rule_input_rec        => l_rule_input_rec,
            x_default_value         => l_default_val_num,
            x_rule_id               => l_default_rule_id,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data
        );

        if (x_return_status = fnd_api.g_ret_sts_success) then
            if (l_default_val_num is not null) then
                l_repair_type_id := l_default_val_num;
            else
                l_repair_type_id := to_number(fnd_profile.value('CSD_DEFAULT_REPAIR_TYPE'));
            end if;

            if l_repair_type_id is not null then
                open c_def_wip (l_repair_type_id);
                fetch c_def_wip into l_repair_mode, l_auto_process_rma;
                close c_def_wip;

                px_repln_rec.repair_type_id   := l_repair_type_id;

                -- repair mode must be the same as what is defined for the
                -- repair type, so override any value that was already there
                px_repln_rec.repair_mode      := l_repair_mode;

                -- allow user to override auto process default, so only default
                -- if no value specified.
                if (px_repln_rec.auto_process_rma = FND_API.G_MISS_NUM) then
                    px_repln_rec.auto_process_rma := l_auto_process_rma;
                end if;
            end if;
        else
            RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    if p_commit = fnd_api.g_true then
        commit;
    end if;

EXCEPTION
      When FND_API.G_EXC_ERROR then
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data  );

      When FND_API.G_EXC_UNEXPECTED_ERROR then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
          ( p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );

      When OTHERS then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        If  FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)then
          FND_MSG_PUB.Add_Exc_Msg
            (G_PKG_NAME,
             lc_api_name  );
         End If;
         FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );
END DEFAULT_RO_ATTRS_FROM_RULE;

/**************************************************************************/
/* Procedure: create_requisition										  */
/* Description: This will insert the records into requisition interface   */
/*              table and subsequently launches the concurrent request to */
/*              create the requisitions.If the concurrent program is      */
/*              launched successfully then the concurrent request id is   */
/*			    is returned.											  */
/* Created by: subhat - 02-09-09                                          */
/**************************************************************************/

PROCEDURE create_requisition
(
    p_api_version_number                 IN NUMBER,
    p_init_msg_list                      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_Status                      OUT NOCOPY VARCHAR2,
    x_msg_count                          OUT NOCOPY NUMBER,
    x_msg_data                           OUT NOCOPY VARCHAR2,
    p_wip_entity_id_tbl                  IN  JTF_NUMBER_TABLE,
    p_quantity_tbl                       IN  JTF_NUMBER_TABLE,
    p_uom_code_tbl                       IN  VARCHAR2_TABLE_100,
    p_op_seq_num_tbl                     IN  JTF_NUMBER_TABLE,
    p_item_id_tbl                        IN  JTF_NUMBER_TABLE,
    p_item_description_tbl               IN  VARCHAR2_TABLE_100,
    p_organization_id                    IN  NUMBER,
    x_request_id                         OUT NOCOPY NUMBER

) IS

l_person_id number;
lc_api_version constant number default 1.0;
lc_api_name constant varchar2(30) := 'CREATE_REQUISITION';
lc_mod_name constant varchar2(40) := 'csd_repairs_util.create_requisition';

l_material_account        JTF_NUMBER_TABLE;
l_material_variance_account    JTF_NUMBER_TABLE;
l_currency       VARCHAR2(30);
l_project_id     JTF_NUMBER_TABLE;
l_task_id        JTF_NUMBER_TABLE;
l_location_id    JTF_NUMBER_TABLE;
l_ou_id          NUMBER;

lc_time_out number := 300;
l_outcome   varchar2(200);
l_message   FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
l_synch_status number;
l_previous_wip_entity number;
l_previous_op_seq_num number;
l_needby_date DATE;
l_dummy number;
begin
    savepoint create_requisition;
    -- standard check.
	IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
		 lc_mod_name,
		 'Begin Create_requisition');
	END IF;
    if not fnd_api.compatible_api_call(
                    lc_api_version,
                    p_api_version_number,
                    lc_api_name,
                    g_pkg_name) then
        raise fnd_api.g_exc_unexpected_error;
    end if;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    -- initialize return status.
    x_return_status := FND_API.g_ret_sts_success;
    -- get the person_id for the current user.
    select employee_id
    into l_person_id
    from fnd_user
    where user_id = fnd_global.user_id;

	IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
		 lc_mod_name,
		 'Fetched the person_id '||l_person_id||' for user_id '||fnd_global.user_id);
	END IF;

	-- check if the need by date profile is set up properly. The requisition import program
	-- needs the need by date for MRP or INV planned items. Right now we assume that all items
	-- are planned.
	-- the need by date can possibly be left null only when INVENTORY_PLANNED_FLAG = 6 and
	-- MRP_PLANNED_FLAG = 6 in mtl_system_items_b for a particular item.
	l_dummy := to_number(fnd_profile.value('CSD_REQUISITION_LEAD_TIME'));

	if nvl(l_dummy,-1) <= -1 then
		FND_MESSAGE.SET_NAME('CSD','CSD_REQ_LEAD_TIME_NOT_SET');
		FND_MSG_PUB.ADD;
		raise fnd_api.g_exc_error;
	end if;

	l_needby_date := sysdate + l_dummy;
    --
    -- initialize the collections used for bulk binding.
    l_project_id := JTF_NUMBER_TABLE();
    l_task_id    := JTF_NUMBER_TABLE();
    l_material_account := JTF_NUMBER_TABLE();
    l_material_variance_account:= JTF_NUMBER_TABLE();
    l_location_id := JTF_NUMBER_TABLE();

   -- populate the material variance and project details.
	IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
		 lc_mod_name,
		 'Fetching material variance and project details along with deliver to location');
	END IF;
   for i in 1 ..p_wip_entity_id_tbl.count
   loop
           -- extend it everytime.
           l_project_id.extend;
	       l_task_id.extend;
	       l_material_account.extend;
	       l_material_variance_account.extend;
	       l_location_id.extend;

       -- execute the sql only if wip_entity_id is different from previous execution.
       if ( nvl(l_previous_wip_entity,-1) = p_wip_entity_id_tbl(i)) then
       	   l_material_account(i) := l_material_account(i-1);
       	   l_material_variance_account(i) := l_material_variance_account(i-1);
       	   l_project_id(i) := l_project_id(i-1);
       	   l_task_id(i) := l_task_id(i-1);
       else
		   select wdj.material_account, wdj.material_variance_account, wdj.project_id, wdj.task_id
		   into l_material_account(i),l_material_variance_account(i), l_project_id(i), l_task_id(i)
		   from wip_discrete_jobs wdj
		   where wdj.wip_entity_id = p_wip_entity_id_tbl(i)
		   and wdj.organization_id = p_organization_id;
	   end if;

       -- get the deliver_to location
       if ( nvl(l_previous_wip_entity,-1) = p_wip_entity_id_tbl(i) and
       		nvl(l_previous_op_seq_num,-1) = p_op_seq_num_tbl(i) ) then
       		l_location_id(i) := l_location_id(i-1);
       else
		   select bd.location_id
		   into l_location_id(i)
		   from bom_departments bd, wip_operations wo
		   where bd.department_id = wo.department_id
		   and bd.organization_id = wo.organization_id
		   and wo.wip_entity_id = p_wip_entity_id_tbl(i)
		   and wo.operation_seq_num = p_op_seq_num_tbl(i)
		   and wo.organization_id = p_organization_id;
	   end if;
   	   l_previous_wip_entity := p_wip_entity_id_tbl(i);
   	   l_previous_op_seq_num := p_op_seq_num_tbl(i);
   end loop;

   -- get the currency code and the ou_id.
	IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
		 lc_mod_name,
		 'Fetching currency code and OU');
	END IF;

   select gb.currency_code, to_number(ho.ORG_INFORMATION3)
   into l_currency, l_ou_id
   from hr_organization_information ho, gl_sets_of_books  gb
   where gb.set_of_books_id = ho.ORG_INFORMATION1
   and ho.organization_id = p_organization_id
   and ho.ORG_INFORMATION_CONTEXT = 'Accounting Information';

   -- bulk bind the variables for the insert.
	IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
		 lc_mod_name,
		 'Just before calling the FORALL insert to po_requisitions_interface_all');
	END IF;
   forall j in 1 ..p_wip_entity_id_tbl.count
   	insert into po_requisitions_interface_all (
             interface_source_code,
             destination_type_code,
             authorization_status,
             preparer_id,  -- person id of the user name
             quantity,
             destination_organization_id,
             deliver_to_location_id,
             deliver_to_requestor_id,
             source_type_code,
             category_id,
             item_description,
             uom_code,
             unit_price,
             need_by_date,
             wip_entity_id,
             wip_operation_seq_num,
             charge_account_id,
             variance_account_id,
             item_id,
             wip_resource_seq_num,
             suggested_vendor_id,
             suggested_vendor_name,
             suggested_vendor_site,
             suggested_vendor_phone,
             suggested_vendor_item_num,
             currency_code,
             project_id,
             task_id,
	     	 project_accounting_context,
             last_updated_by,
             last_update_date,
             created_by,
             creation_date,
             org_id,
	     	 reference_num )
   values (
             'CSD',
             'INVENTORY',
             'INCOMPLETE',
             l_person_id,
             p_quantity_tbl(j),
             p_organization_id,
             l_location_id(j),
             l_person_id,
             'VENDOR',
             null,
             p_item_description_tbl(j),
             p_uom_code_tbl(j),
             0,
             l_needby_date ,
             p_wip_entity_id_tbl(j),
             p_op_seq_num_tbl(j),
             l_material_account(j),
             l_material_variance_account(j),
             p_item_id_tbl(j),
             null,
             null,
             null,
             null,
             null,
             null,
             l_currency,
             l_project_id(j),
             l_task_id(j),
	         decode(nvl(l_project_id(j),-1),-1, 'N','Y'),
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             l_ou_id,
	         null
            );

-- submit asynchronous request to create the requisition.
-- post MOAC, we need to set the org context for the concurrent request.
fnd_request.set_org_id (l_ou_id);

IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
	 lc_mod_name,
	 'Before calling fnd_request.submit_request to launch REQIMPORT ');
END IF;

l_synch_status := fnd_request.submit_request(
        'PO', 'REQIMPORT', NULL, NULL, FALSE,'CSD', NULL, 'ALL',
        NULL ,'N', 'Y' , chr(0), NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        ) ;

If l_synch_status <= 0 then
 -- error during concurrent request submission.
	IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(    FND_LOG.LEVEL_EVENT,
		 lc_mod_name,
		 'An error occured while trying to submit REQIMPORT concurrent program. Please contact system administrator');
	END IF;

 	raise fnd_api.g_exc_error;
end if;

x_request_id := l_synch_status;

if fnd_api.to_boolean(p_commit) then
	commit work;
end if;
exception
	when fnd_api.g_exc_error then
		IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
			 lc_mod_name,
			 'Execution error in the API');
		END IF;
		Fnd_Msg_Pub.Count_And_Get (p_count  =>  x_msg_count, p_data   =>  x_msg_data );
		x_return_Status := fnd_api.g_ret_sts_error;
		rollback to create_requisition;
    when fnd_api.g_exc_unexpected_error then
		IF ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
			 lc_mod_name,
			 'Unexpected error');
		END IF;
		x_return_status := fnd_api.g_ret_sts_error;
    	rollback to create_requisition;
    when others then
    	raise;
END create_requisition;

END Csd_Repairs_Util;

/
