--------------------------------------------------------
--  DDL for Package Body MTL_INV_VALIDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_INV_VALIDATE_GRP" AS
/* $Header: INVGIVVB.pls 120.2 2005/06/22 09:57:14 appldev ship $ */
  Current_Error_Code		VARCHAR2(30) := NULL;
  --
  G_PKG_NAME CONSTANT		VARCHAR2(30) := 'MTL_INV_VALIDATE_GRP';


procedure mdebug(msg in varchar2)
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
--dbms_output.put_line(msg);
   null;
--inv_debug.message(msg);
end;
--Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data
--OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
procedure Get_Offset_Date(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_start_date IN DATE,
  p_offset_days IN NUMBER,
  p_calendar_code IN VARCHAR2,
  p_exception_set_id IN NUMBER,
  x_result_date OUT NOCOPY DATE)
    -- Start OF comments
    -- API name  : Get_Offset_Date
    -- TYPE      : Group
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Computes work day which is p_offset work days away from p_start_date
    --
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
  --  p_start_date IN DATE (Required)
  --               date from which offset is computed
  --  p_offset_days IN NUMBER (Required)
  --               number of work days till the date we're looking for
  --
  --  p_calendar_code IN VARCHAR (Required) valid calendar code
  --  p_exception_set_id IN NUMBER (Required) valid exception set
  -- if no such date can be found (incorrect calendar_code,exception_set_id,
  -- date out of calendar range, etc.)
  -- then x_return_status will be set to ret_sts_unexp_error
    --  the RECORD parameter includes the
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
  --  x_result_date OUT DATE - work date which is p_offset_days working days
  --                           away from p_start_date
  -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
is

   l_api_version NUMBER := 0.9;
   l_api_name VARCHAR2(30) := 'Get_Offset_Date';

   l_counter NUMBER := 0;

   cursor l_date_csr is
     select calendar_date
     from bom_calendar_dates
     where calendar_code = p_calendar_code
     and exception_set_id = p_exception_set_id
     and seq_num in
     (select seq_num + p_offset_days
     from bom_calendar_dates
     where calendar_code = p_calendar_code
     and exception_set_id = p_exception_set_id
     and next_date = trunc(p_start_date));


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   -- Standard start of API savepoint
   SAVEPOINT Get_Offset_Date;
   --
   -- Standard Call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version
     , p_api_version
     , l_api_name
     , G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   -- Initialize message list if p_init_msg_list is set to true
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --
   -- Initialisize API return status to access
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- API body
   --

   for c_rec in l_date_csr loop
      x_result_date := c_rec.calendar_date;
      l_counter := l_counter + 1;
   end loop;

   if (l_counter <> 1) then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   --
   -- END of API body
   -- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
   END IF;
   -- Standard call to get message count and if count is 1, get message info
   FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
     , p_data => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     --
     ROLLBACK TO Get_Offset_Date;
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
       --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     ROLLBACK TO Get_Offset_Date;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
   WHEN OTHERS THEN
     --
       ROLLBACK TO Get_Offset_Date;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
end;


  -- XXX this procedure is not ever used and looks rather silly
  -- we should get rid of that
  -- Derive Count Uom
  PROCEDURE Get_CountUom(
  p_uom_code IN VARCHAR2 )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  :Get_CountUom
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Stores the COUNT UOM IN
    -- package variables to use the information within this PGA session
    -- Parameters:
    --     IN    :
    --     p_uom_code IN  VARCHAR2  (required)
    --     Cycle COUNT UOM code
    --
    -- END OF comments
    DECLARE
       --
    BEGIN
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Getting UOM');
END IF;
          MTL_CCEOI_VAR_PVT.G_UOM_CODE := p_uom_code;
       --
    END;
  END;
  --
  -- Dervies Item and SKU information from the given Count List Sequence
  PROCEDURE Get_Item_SKU(
  p_cycle_count_entry_rec IN  MTL_CYCLE_COUNT_ENTRIES%ROWTYPE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  :Get_Item_SKU
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Stores the cycle COUNT entries item and SKU  information IN
    -- package variables to use the information within this PGA session
    -- Parameters:
    --     IN    :
    --     p_cycle_count_entry_rec IN  mtl_cycle_count_entries%rowtype  (required)
    --     Cycle COUNT entries RECORD information
    --
    -- END OF comments
    DECLARE
       --
       CURSOR L_Item_Csr(org NUMBER, id NUMBER) IS
          SELECT *
          FROM mtl_system_items
       WHERE
          organization_id = org
          AND inventory_item_id = id;
       --
    BEGIN
       --
       FOR c_rec IN L_Item_Csr(p_cycle_count_entry_rec.organization_id,
             p_cycle_count_entry_rec.inventory_item_id) LOOP
          --
	  IF (l_debug = 1) THEN
   	  MDEBUG( 'Getting Control Codes');
	  END IF;

	  -- flag indicating inventory item
          MTL_CCEOI_VAR_PVT.G_SKU_REC.INVENTORY_ITEM_FLAG :=
	    c_rec.INVENTORY_ITEM_FLAG;

	  -- lot control code for this item (1 - none, 2 - full)
	  MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE := c_rec.LOT_CONTROL_CODE;
	  -- revision qty control code (1 - not under revision qty control,
	  -- 2 under revision qty control)
          MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION_QTY_CONTROL_CODE :=
	    c_rec.REVISION_QTY_CONTROL_CODE;

	  -- serial number control code
	  -- 1 - no serial control, 2 - predefined, 5 - dynamic at receipt
	  -- 6 - dynamic at issue
          MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE :=
	    c_rec.SERIAL_NUMBER_CONTROL_CODE;

	  -- allowed unit of measure conversion type
	  -- 1 - item specific, 2 - standard, 3 - both standard and item spec
          MTL_CCEOI_VAR_PVT.G_SKU_REC.ALLOWED_UNITS_LOOKUP_CODE :=
          c_rec.ALLOWED_UNITS_LOOKUP_CODE;
          --
       END LOOP;
       --
    END;
  END;
  --
  -- Get the STOCK_LOCATOR_CONTROL_CODE from the given ORG_ID
  PROCEDURE Get_StockLocatorControlCode(
  p_organization_id IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Get_StockLocatorControlCode
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Gets the stock_locator_control_code FOR the given
    -- organization
    -- Parameters:
    --     IN    :
    --             p_organization_id IN NUMBER (required)
    --                organization id OF the current cycle COUNT
    -- END OF comments
    DECLARE
       L_Stock_Locator_Control_code NUMBER;
    BEGIN
       --
       SELECT
          stock_locator_control_code
       INTO
          L_Stock_Locator_Control_code
       FROM
          MTL_PARAMETERS
       WHERE
          organization_id = p_organization_id;
       --
    IF (l_debug = 1) THEN
       MDEBUG( 'Getting Locator Control code');
    END IF;
       MTL_CCEOI_VAR_PVT.G_STOCK_LOCATOR_CONTROL_CODE :=
       L_Stock_Locator_Control_code;
       --
    END;
  END;
  --
  -- Validates the adjustment account
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_AdjustAccount(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_adjustaccount_rec IN MTL_CCEOI_VAR_PVT.ADJUSTACCOUNT_REC_TYPE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_AdjustAccount
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the adjust account information against
    -- the TABLE gl_code_combinations
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_adjustaccount_rec IN MTL_CCEOI_VAR_PVT.ADJUSTACCOUNT_REC_TYPE (required)
    --  the RECORD parameter includes the
    --  adjustment account
    --  segments
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       -- CURSOR FOR the adjustment_account_id
       CURSOR L_AdjAccountID_Crs(ID IN NUMBER) IS
          SELECT
          code_combination_id
          FROM gl_code_combinations
       WHERE
          code_combination_id = id;
       --
       -- curosr FOR the individual segments
       CURSOR L_AdjAccountSeg_Crs(seg1 IN VARCHAR2,
             seg2 IN VARCHAR2,
             seg3 IN VARCHAR2,
             seg4 IN VARCHAR2,
             seg5 IN VARCHAR2,
             seg6 IN VARCHAR2,
             seg7 IN VARCHAR2,
             seg8 IN VARCHAR2,
             seg9 IN VARCHAR2,
             seg10 IN VARCHAR2,
             seg11 IN VARCHAR2,
             seg12 IN VARCHAR2,
             seg13 IN VARCHAR2,
             seg14 IN VARCHAR2,
             seg15 IN VARCHAR2,
             seg16 IN VARCHAR2,
             seg17 IN VARCHAR2,
             seg18 IN VARCHAR2,
             seg19 IN VARCHAR2,
             seg20 IN VARCHAR2,
             seg21 IN VARCHAR2,
             seg22 IN VARCHAR2,
             seg23 IN VARCHAR2,
             seg24 IN VARCHAR2,
             seg25 IN VARCHAR2,
             seg26 IN VARCHAR2,
             seg27 IN VARCHAR2,
             seg28 IN VARCHAR2,
             seg29 IN VARCHAR2,
             seg30 IN VARCHAR2) IS
          SELECT
          code_combination_id
          FROM gl_code_combinations
       WHERE
          NVL(segment1, '@') = NVL(seg1, '@')
          AND NVL(segment2, '@') = NVL(seg2, '@')
          AND NVL(segment3, '@') = NVL(seg3, '@')
          AND NVL(segment4, '@') = NVL(seg4, '@')
          AND NVL(segment5, '@') = NVL(seg5, '@')
          AND NVL(segment6, '@') = NVL(seg6, '@')
          AND NVL(segment7, '@') = NVL(seg7, '@')
          AND NVL(segment8, '@') = NVL(seg8, '@')
          AND NVL(segment9, '@') = NVL(seg9, '@')
          AND NVL(segment10, '@') = NVL(seg10, '@')
          AND NVL(segment11, '@') = NVL(seg11, '@')
          AND NVL(segment12, '@') = NVL(seg12, '@')
          AND NVL(segment13, '@') = NVL(seg13, '@')
          AND NVL(segment14, '@') = NVL(seg14, '@')
          AND NVL(segment15, '@') = NVL(seg15, '@')
          AND NVL(segment16, '@') = NVL(seg16, '@')
          AND NVL(segment17, '@') = NVL(seg17, '@')
          AND NVL(segment18, '@') = NVL(seg18, '@')
          AND NVL(segment19, '@') = NVL(seg19, '@')
          AND NVL(segment20, '@') = NVL(seg20, '@')
          AND NVL(segment21, '@') = NVL(seg21, '@')
          AND NVL(segment22, '@') = NVL(seg22, '@')
          AND NVL(segment23, '@') = NVL(seg23, '@')
          AND NVL(segment24, '@') = NVL(seg24, '@')
          AND NVL(segment25, '@') = NVL(seg25, '@')
          AND NVL(segment26, '@') = NVL(seg26, '@')
          AND NVL(segment27, '@') = NVL(seg27, '@')
          AND NVL(segment28, '@') = NVL(seg28, '@')
          AND NVL(segment29, '@') = NVL(seg29, '@')
          AND NVL(segment30, '@') = NVL(seg30, '@');
       --
       L_counter integer := 0;
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_AdjustAccount';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_AdjustAccount;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
       -- Check OF existence
       IF p_adjustaccount_rec.adjustment_account_id IS NOT NULL THEN
          --
          FOR c_rec IN L_AdjAccountID_Crs(
                p_adjustaccount_rec.adjustment_account_id) LOOP
             --
      IF (l_debug = 1) THEN
         MDEBUG( 'Validating Adj Account ID');
      END IF;
             MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID :=
             c_rec. code_combination_id;
             --
             L_counter := L_counter + 1;
             IF L_counter > 1 THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             --
          END LOOP;
          --
       ELSE
          --
          FOR c_rec IN L_AdjAccountSeg_Crs(p_adjustaccount_rec.account_segment1,
                p_adjustaccount_rec.account_segment2,
                p_adjustaccount_rec.account_segment3,
                p_adjustaccount_rec.account_segment4,
                p_adjustaccount_rec.account_segment5,
                p_adjustaccount_rec.account_segment6,
                p_adjustaccount_rec.account_segment7,
                p_adjustaccount_rec.account_segment8,
                p_adjustaccount_rec.account_segment9,
                p_adjustaccount_rec.account_segment10,
                p_adjustaccount_rec.account_segment11,
                p_adjustaccount_rec.account_segment12,
                p_adjustaccount_rec.account_segment13,
                p_adjustaccount_rec.account_segment14,
                p_adjustaccount_rec.account_segment15,
                p_adjustaccount_rec.account_segment16,
                p_adjustaccount_rec.account_segment17,
                p_adjustaccount_rec.account_segment18,
                p_adjustaccount_rec.account_segment19,
                p_adjustaccount_rec.account_segment20,
                p_adjustaccount_rec.account_segment21,
                p_adjustaccount_rec.account_segment22,
                p_adjustaccount_rec.account_segment23,
                p_adjustaccount_rec.account_segment24,
                p_adjustaccount_rec.account_segment25,
                p_adjustaccount_rec.account_segment26,
                p_adjustaccount_rec.account_segment27,
                p_adjustaccount_rec.account_segment28,
                p_adjustaccount_rec.account_segment29,
                p_adjustaccount_rec.account_segment30) LOOP
             --
             MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID :=
             c_rec. code_combination_id;
             --
             L_counter := L_counter + 1;
             IF L_counter > 1 THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             --
          END LOOP;
          --
       END IF;
       --
       IF L_counter = 0 THEN
          -- the Adjustment account does NOT exist
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_AdjustAccount;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_AdjustAccount;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_AdjustAccount;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validates the count date (good for any date)
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountDate(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_count_date IN DATE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CountDate
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the COUNT date.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_count_date IN DATE (required)
    -- DATE OF the COUNT
    --
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_period_id NUMBER;
       L_open_past_period BOOLEAN := FALSE;
       L_profile_value NUMBER := 0;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CountDate';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CountDate;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Count Date ');
END IF;
       -- no null DATE
       IF p_count_date IS NULL  THEN
          x_errorcode := 59;
          FND_MESSAGE.SET_NAME('INV', 'INV_COUNT_DATE_FUTURE');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- no future DATE
       IF TRUNC(p_count_date) > TRUNC(SYSDATE) THEN
          x_errorcode := 23;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_COUNT_DATE_FUTURE');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
       -- within a accounting period
       IF(fnd_profile.defined('TRANSACTION_DATE')) THEN
          L_profile_value := TO_NUMBER(fnd_profile.value('TRANSACTION_DATE'));
          /* Profile value of:
          1 = Any open period
          2 = No past date
          3 = No past periods
          4 = Warn when past period
          */
          IF L_profile_value = 3 THEN
             L_open_past_period := TRUE;
          END IF;
       ELSE
          x_errorcode := 24;
          FND_MESSAGE.SET_NAME('FND', 'PROFILES-CANNOT READ');
          FND_MESSAGE.SET_TOKEN('OPTION', 'TRANSACTION_DATE', TRUE);
          FND_MESSAGE.SET_TOKEN('ROUTINE',
             'MTL_CC_TRANSACT_PKG.CC_TRANSACT ', TRUE);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF L_profile_value = 2 THEN
          IF trunc(p_count_date) < TRUNC(sysdate) THEN
             x_errorcode := 24;
             FND_MESSAGE.SET_NAME('INV', 'INV_NO_PAST_TXN_DATES');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
	  END IF;
       END IF;

       INVTTMTX.TDATECHK(
	 MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID,
	 p_count_date,
	 L_period_id,
	 L_open_past_period);
       IF L_period_id = 0 THEN
	  x_errorcode := 24;
	  FND_MESSAGE.SET_NAME('INV', 'INV_NO_OPEN_PERIOD');
	  FND_MSG_PUB.Add;
	  RAISE FND_API.G_EXC_ERROR;
       ELSIF L_period_id = -1 THEN
	  x_errorcode := 24;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
	  IF(L_profile_value = 3) AND
	    NOT(L_open_past_period) THEN
	     x_errorcode := 24;
	     FND_MESSAGE.SET_NAME('INV', 'INV_NO_PAST_TXN_PERIODS');
	     FND_MSG_PUB.Add;
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;
       END IF;


       -- if we're here then the validation went ok so we can store the date
       MTL_CCEOI_VAR_PVT.G_COUNT_DATE := p_count_date;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_CountDate;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_CountDate;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_CountDate;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validate count header
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountHeader(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY VARCHAR2 ,
  p_cycle_count_header_id IN NUMBER DEFAULT NULL,
  p_cycle_count_header_name IN VARCHAR2 DEFAULT NULL)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CountHeader
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the cycle COUNT header information. IF this cycle COUNT exists
    -- IN the system, THEN error = 0, ELSE error = 1,2
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_cycle_count_header_id IN  NUMBER default NULL (required - defaulted NULL)
    --   Cycle COUNT header ID
    --
    --   p_cycle_count_header_name IN VARCHAR2 (optional)
    --   Default = NULL
    --   cycle COUNT header name, only IF ID IS missing
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --   RETURN value OF the Error status
    --   0 = exists
    --   -1= all other error exceptions
    --   1 = don't exists
    --   2 = invalid header
    --  45 = more THEN one cycle COUNT
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       CURSOR L_CCHeader_Csr(ID NUMBER, NAME VARCHAR2) IS
          SELECT *
          FROM mtl_cycle_count_headers
       WHERE
          (cycle_count_header_id = ID
             OR cycle_count_header_name= NAME);
       --
       L_Cycle_Count_Header_ID MTL_CYCLE_COUNT_HEADERS.Cycle_Count_Header_ID%type;
       L_Cycle_Count_Header_Name
       MTL_CYCLE_COUNT_HEADERS.Cycle_Count_Header_Name%type;
       rec_counter integer := 0;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CountHeader';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CountHeader;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating CC Header ID');
END IF;
       -- The ID gets presedence FOR the name
       IF(P_Cycle_Count_Header_ID IS NOT NULL) THEN
          L_Cycle_Count_Header_ID := P_Cycle_Count_Header_ID;
          L_Cycle_Count_Header_Name := NULL;
       ELSE
          L_Cycle_Count_Header_ID := NULL;
          L_Cycle_Count_Header_Name := P_Cycle_Count_Header_Name;
       END IF;
       --
       FOR c_rec IN L_CCHeader_Csr(L_Cycle_Count_Header_ID,
             L_Cycle_Count_Header_Name) LOOP
          --
	  MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID := c_rec.cycle_count_header_id;
          MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC := c_rec;
          --
          rec_counter := rec_counter + 1;
          IF(rec_counter > 1) THEN
             -- error Cycle COUNT must be unique
             EXIT;
          END IF;
       END LOOP;
       --
       IF(rec_counter = 1) THEN
          -- Cycle COUNT must be valid, IF NOT error OUT
          IF(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.DISABLE_DATE IS NOT NULL AND
                MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.DISABLE_DATE <= sysdate)
          THEN
             FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_HEADER');
             FND_MSG_PUB.Add;
             x_errorcode :=2;
             RAISE FND_API.G_EXC_ERROR;
	  ELSE
             FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_SUCCESS');
             FND_MSG_PUB.Add;
          END IF;
       ELSIF
          (rec_counter = 0) THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_HEADER');
          FND_MSG_PUB.Add;
          x_errorcode := 1;
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
          (rec_counter > 1) THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_MULT_HEADER');
          FND_MSG_PUB.Add;
          x_errorcode := 45;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_CountHeader;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_CountHeader;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_CountHeader;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validate count_list_sequence
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountListSequence(
  p_api_version  NUMBER ,
  p_init_msg_list  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit  VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY number ,
  p_cycle_count_header_id IN number ,
  p_cycle_count_entry_id IN number ,
  p_count_list_sequence IN number ,
  p_organization_id IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CountListSequence
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the cycle COUNT list sequence for the specified
    -- header information.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --      0 = FOR Export validation
    --
    --   p_cycle_count_header_id IN  NUMBER (required -)
    --   Cycle COUNT header ID
    --
    --   p_count_list_sequence IN NUMBER (required)
    --   COUNT list sequence
    --
    --   p_organization_id IN NUMBER (required)
    --   ID OF the organization
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --   RETURN value OF the Error status
    --   0 = exists
    --   -1= all other error exceptions
    --   3 = multiple matches found
    --   46 = do NOT exist
    --   65 = Unschedule Entry Seq can be null
    --   66 = Unschedule Entry Seq can be New
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       -- Exists an OPEN request Status (uncounted=1,recount=3)
       CURSOR L_CCListSequence_Csr(ID NUMBER, Seq NUMBER, org NUMBER) IS
          SELECT *
          FROM mtl_cycle_count_entries
       WHERE
          cycle_count_header_id = ID
          AND organization_id = org
          AND count_list_sequence= seq
          AND entry_status_code IN(1, 2, 3);
       --
       rec_counter integer := 0;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CountListSequence';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CountListSequence;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
       IF P_Count_List_Sequence <= 0 THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_POSITIVE_NUMBER');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Seq '||to_char(P_Count_List_Sequence));
   MDEBUG( 'Validating Seq '||to_char(P_Cycle_Count_Header_ID));
   MDEBUG( 'Validating Seq '||to_char(p_organization_id));
END IF;
       FOR c_rec IN L_CCListSequence_Csr(P_Cycle_Count_Header_ID,
             P_Count_List_Sequence, p_organization_id) LOOP
          --
          MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC := c_rec;
          MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION := c_rec.revision;
          MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER := c_rec.LOT_NUMBER;
          MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE := c_rec.LOT_CONTROL;
          MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER := c_rec.SERIAL_NUMBER;
	  MTL_CCEOI_VAR_PVT.G_OPEN_REQUEST := TRUE;

          --
          rec_counter := rec_counter + 1;
          IF(rec_counter > 1 or c_rec.entry_status_code = 2) THEN
             -- error Cycle COUNT must be unique
             FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_MULT_MATCH_REQ');
             FND_MSG_PUB.Add;
             x_errorcode := 3;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END LOOP;
       --
       IF(rec_counter = 0) THEN
          IF p_cycle_count_entry_id IS NULL THEN
             IF P_Count_List_Sequence is NULL THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Seq Assign 65 ');
END IF;
                x_errorcode := 65;
             ELSE
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Seq Assign 66 ');
END IF;
                x_errorcode := 66;
             END IF;
          ELSE
            FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_UNMATCH_LISTSEQ');
            FND_MSG_PUB.Add;
            x_errorcode := 46;
            RAISE FND_API.G_EXC_ERROR;
	  END IF;
       ELSIF -- XXX why do we post success message?
          (rec_counter = 1) THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_SUCCESS');
          FND_MSG_PUB.Add;
          x_errorcode := 0;
       END IF;
       --
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_CountListSequence;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_CountListSequence;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_CountListSequence;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validate the count quantity (if negative)
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountQuantity(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_count_quantity IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CountQuantity
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates IF the COUNT quanitity IS negative. IF NOT
    -- it will be stored INTO the package variable
    -- MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_count_quantity IN NUMBER (required)
    -- the COUNT quantity
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CountQuantity';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CountQuantity;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
       -- With Serialized items
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Count Qty');
   MDEBUG('SRLNoCCD '||to_char(MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE ));
END IF;
       IF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE in (2,5)
       THEN
          IF p_count_quantity > 1 or p_count_quantity IS NULL THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating CQty > 1 or NULL');
END IF;
             x_errorcode := 60;
             FND_MESSAGE.SET_NAME('INV', 'INV_SERIAL_QTY_MUST_BE_1');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       ELSE
          IF p_count_quantity IS NULL THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating CQty is NULL');
END IF;
             x_errorcode := 61;
             FND_MESSAGE.SET_NAME('INV', 'INV_GREATER_EQUAL_ZERO');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
       --
       IF p_count_quantity < 0 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating CQty < 0');
END IF;
          x_errorcode := 22;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NEG_QTY');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          MTL_CCEOI_VAR_PVT.G_COUNT_QUANTITY := p_count_quantity;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_CountQuantity;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
IF (l_debug = 1) THEN
   MDEBUG( 'Error CntQty-Stat= '||x_return_status);
END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_CountQuantity;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_CountQuantity;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validates Control information this item
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Ctrol(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_inventory_item_id IN NUMBER ,
  p_organization_id IN NUMBER ,
  p_locator_rec IN MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE ,
  p_lot_number IN VARCHAR2 ,
  p_revision IN VARCHAR2 ,
  p_serial_number IN VARCHAR2 ,
  p_locator_control IN NUMBER )   -- XXX not used inside!
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_Ctrol
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates SKU information. It will be determined IF the item level control
    -- IS specified AND the input parameter are populated.
    -- E.g. IF the item IS under lot control, so the lot NUMBER
    -- must be populated.
    -- The control information will be selected FROM the TABLE
    -- MTL_SYSTEM_ITEMS, but IF the global variables OF the
    -- package MTL_CCEOI_VAR_PVT are populated, no selection
    -- IS neccessary.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_inventory _item_id IN NUMBER (required)
    --  inventory item id
    --
    --  p_organization_id IN NUMBER (required)
    --
    --  p_locator_rec MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC (required)
    --  Locator information with segments
    --
    -- p_lot_number IN VARCHAR2 (required)
    -- Lot NUMBER
    --
    -- p_revision IN VARCHAR2 (required)
    -- Revision information
    --
    --  p_serial_number IN VARCHAR2 (required)
    --  serial NUMBER
    --
    -- p_locator_control IN NUMBER (required)
    -- IS item unter locator control
    -- This flag IS used to know IF the item is under locator control
    -- no care, IF it IS at organization-, subinventory- , OR item level
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --  -1= Unexpected error
    --  9 = No Locator
    -- 11 = No revision
    -- 13 = No Lot
    -- 15 = No Serial
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       CURSOR L_ItemCtrlInfo_Csr(id IN NUMBER, org in number) IS
          SELECT
          location_control_code,
          serial_number_control_code,
          revision_qty_control_code,
          lot_control_code FROM mtl_system_items
       WHERE
          inventory_item_id = id
          and organization_id = org;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_Ctrol';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_Ctrol;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating all control ');
   MDEBUG( 'Validating all control-Loc '||to_char(p_locator_rec.locator_id));
   MDEBUG( 'Validating all control -Rev'||p_revision);
END IF;
       -- SELECT information FROM MTL_SYSTEM_ITEMS
       FOR x IN L_ItemCtrlInfo_Csr(p_inventory_item_id,
             p_organization_id) LOOP
IF (l_debug = 1) THEN
   MDEBUG( 'Loc Ctrl1'||to_char(MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE));
END IF;
             if MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE
               is null then
               MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE := x.LOCATION_CONTROL_CODE;
IF (l_debug = 1) THEN
   MDEBUG( 'Loc Ctrl2'||to_char(MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE));
END IF;
             END IF;
               MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE := x.LOCATION_CONTROL_CODE;
IF (l_debug = 1) THEN
   MDEBUG( 'Loc Ctrl X '||to_char(x.LOCATION_CONTROL_CODE));
END IF;
             --
             IF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE
                IS NULL THEN
                MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE :=
                  x.SERIAL_NUMBER_CONTROL_CODE;
             END IF;
             IF MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION_QTY_CONTROL_CODE
                IS NULL THEN
                MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION_QTY_CONTROL_CODE :=
                  x.REVISION_QTY_CONTROL_CODE;
             END IF;
             IF MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE IS NULL THEN
               MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE :=
                 x.LOT_CONTROL_CODE;
             END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Ctrl Loop');
END IF;
       END LOOP;
IF (l_debug = 1) THEN
   mdebug('Locator Ctrl Code '||to_char(p_locator_control));
   mdebug('segments are1 '||p_locator_rec.locator_segment1);
   mdebug('segments are2 '||p_locator_rec.locator_segment2);
   mdebug('segments are3 '||p_locator_rec.locator_segment3);
   mdebug('segments are19 '||p_locator_rec.locator_segment19);
   mdebug('segments are20 '||p_locator_rec.locator_segment20);
END IF;

       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Ctrl Loop'||to_char(p_locator_rec.locator_id));
END IF;
       --
       -- Check IF all VALUES are populated
-- IF  MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE IN(2, 3)
       IF p_locator_control in (2, 3) then
          IF (p_locator_rec.locator_id IS NULL  AND
             p_locator_rec.locator_segment1 IS NULL and
             p_locator_rec.locator_segment2 IS NULL  and
             p_locator_rec.locator_segment3 IS NULL  and
             p_locator_rec.locator_segment4 IS NULL and
             p_locator_rec.locator_segment5 IS NULL and
             p_locator_rec.locator_segment6 IS NULL and
             p_locator_rec.locator_segment7 IS NULL and
             p_locator_rec.locator_segment8 IS NULL and
             p_locator_rec.locator_segment9 IS NULL and
             p_locator_rec.locator_segment10 IS NULL and
             p_locator_rec.locator_segment11 IS NULL and
             p_locator_rec.locator_segment12 IS NULL and
             p_locator_rec.locator_segment13 IS NULL and
             p_locator_rec.locator_segment14 IS NULL and
             p_locator_rec.locator_segment15 IS NULL and
             p_locator_rec.locator_segment16 IS NULL and
             p_locator_rec.locator_segment17 IS NULL and
             p_locator_rec.locator_segment18 IS NULL and
             p_locator_rec.locator_segment19 IS NULL and
             p_locator_rec.locator_segment20 IS NULL) THEN
          --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator_control but no locator');
END IF;
          x_errorcode := 9;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_LOC');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
          --
         END IF;
       END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'End of Validating Ctrl'||to_char(p_locator_rec.locator_id));
END IF;
       -- XXX should we make g_locator_id null in else clause



       -- SERIAL


       IF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE IN (2,5)
          AND p_serial_number IS NULL THEN

IF (l_debug = 1) THEN
   MDEBUG( 'Validating serial_control but no serial number');
   mdebug('serial_control but no serial number');
END IF;
          x_errorcode := 15;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_SERIAL');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

       ELSIF MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE = 0 THEN
	  --XXX it should not ever be 0
             MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER := NULL;
       END IF;


       -- REVISION


       IF MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION_QTY_CONTROL_CODE = 2
          AND p_revision IS NULL THEN

IF (l_debug = 1) THEN
   MDEBUG( 'Validating revision_control but no revision');
END IF;
          x_errorcode := 11;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_REV');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
          --
        ELSIF MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION_QTY_CONTROL_CODE = 1 THEN
                 MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION := NULL;
       END IF;


       --  LOT


       IF MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE= 2
          AND p_lot_number IS NULL THEN
          --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating lot_control but no lot');
END IF;
          x_errorcode := 13;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_LOT');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
          --
        ELSIF MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE= 1 THEN
                 MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER := NULL;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_Ctrol;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_Ctrol;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_Ctrol;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validates Count UOM or/and Unit of Measure (not specific to cc)
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_CountUOM(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_count_uom IN VARCHAR2 DEFAULT NULL,
  p_count_unit_of_measure IN VARCHAR2 DEFAULT NULL,
  p_organization_id IN NUMBER ,
  p_inventory_item_id IN NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CountUOM
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Look IN the TABLE MTL_ITEM_UOMS_VIEW
    -- IF the count_uom OR count_unit_of_measure IS
    -- presented, IF NOT it errors out.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_count_uom IN VARCHAR2 (required - defaulted)
    --  default = NULL
    --  unit OF measure code OF the current cycle COUNT entry
    --
    -- p_count_unit_of_measure IN VARCHAR2 (optional- defaulted)
    -- default NULL
    -- Name OF the unit OF measure
    --
    -- p_organization_id IN NUMBER (required)
    -- ID OF the organization
    --
    -- p_inventory_item_id IN NUMBER (required)
    -- ID OF the inventory item
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --   19 = no uom populated
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_unit_of_measure MTL_ITEM_UOMS_VIEW.unit_of_measure%type;
       L_uom MTL_ITEM_UOMS_VIEW.uom_code%type;
       L_counter integer := 0;
       --
       CURSOR L_ItemUom_Csr(code IN VARCHAR2, name IN VARCHAR2,
             org IN NUMBER, itemid IN NUMBER) IS
          SELECT
          UOM_CODE
          FROM mtl_item_uoms_view
       WHERE
          organization_id = org
          AND inventory_item_id = itemid
          AND(uom_code = code OR
             unit_of_measure = name);
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CountUOM';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CountUOM;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating CountUOM');
END IF;
       IF p_count_uom IS NULL AND p_count_unit_of_measure IS NULL THEN
          --
          x_errorcode := 19;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_UOM');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
          --
       ELSIF
          p_count_uom IS NOT NULL AND p_count_unit_of_measure IS NULL THEN
          --
          L_uom := p_count_uom;
          L_unit_of_measure := NULL;
          --
       ELSIF
          p_count_uom IS NULL AND p_count_unit_of_measure IS NOT NULL THEN
          --
          L_uom := NULL;
          L_unit_of_measure := p_count_unit_of_measure;
          --
       END IF;
       --
       FOR c_rec IN L_ItemUom_Csr(L_uom, L_unit_of_measure, p_organization_id,
             p_inventory_item_id) LOOP
          --
          MTL_CCEOI_VAR_PVT.G_UOM_CODE := c_rec.uom_code;
          L_counter := L_counter + 1;
          --
       END LOOP;
       --
       IF L_counter < 1 THEN
          x_errorcode := 20;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_UOM');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_CountUOM;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_CountUOM;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_CountUOM;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validates Item information
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Item(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  P_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_inventory_item_rec IN MTL_CCEOI_VAR_PVT.INV_ITEM_REC_TYPE ,
  p_organization_id IN NUMBER ,
  p_cycle_count_header_id IN NUMBER DEFAULT NULL)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_Item
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- This PROCEDURE validates the item information AND store the control
    -- information to package variables.
    -- The id takes presedence over the concatenated segment, which
    -- takes presedence over the individual segments. IS the item present
    -- IN the TABLE mtl_system_items, it will be checked IF it IS present IN TABLE
    -- mtl_cycle_count_items.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_inventory_item_rec IN MTL_CCEOI_VAR_PVT.INV_ITEM_REC_TYPE (required)
    --  Item information with segments
    --
    --  p_organization_id IN NUMBER (required)
    --  organization ID
    --
    --  p_cycle_count_header_id IN NUMBER (optional - defaulted)
    -- Cycle count header id. If a values is given, check if this item
    -- exists for this cycle count
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --        4 = NOT item
    --        5 = item NOT specified with cycle COUNT
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       CURSOR L_CCItemsID_Crs(id IN VARCHAR2, cchead IN NUMBER) IS
          SELECT
          inventory_item_id
          FROM MTL_CYCLE_COUNT_ITEMS
       WHERE
          inventory_item_id = id
          AND cycle_count_header_id = cchead;
       --
       L_org  INV_Validate.ORG;
       L_item INV_Validate.ITEM;
       --
       L_counter integer := 0;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_Item';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_Item;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Item');
END IF;
       --
       -- Assigning variables to l_item record type to call
       -- INV_Validate.inventory_item procedure
       l_org.organization_id := p_organization_id;
       l_item.organization_id := p_organization_id;
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Item-1');
END IF;
       l_item.inventory_item_id := p_inventory_item_rec.inventory_item_id;
       l_item.segment1 := p_inventory_item_rec.item_segment1;
       l_item.segment2 := p_inventory_item_rec.item_segment2;
       l_item.segment3 := p_inventory_item_rec.item_segment3;
       l_item.segment4 := p_inventory_item_rec.item_segment4;
       l_item.segment5 := p_inventory_item_rec.item_segment5;
       l_item.segment6 := p_inventory_item_rec.item_segment6;
       l_item.segment7 := p_inventory_item_rec.item_segment7;
       l_item.segment8 := p_inventory_item_rec.item_segment8;
       l_item.segment9 := p_inventory_item_rec.item_segment9;
       l_item.segment10 := p_inventory_item_rec.item_segment10;
       l_item.segment11 := p_inventory_item_rec.item_segment11;
       l_item.segment12 := p_inventory_item_rec.item_segment12;
       l_item.segment13 := p_inventory_item_rec.item_segment13;
       l_item.segment14 := p_inventory_item_rec.item_segment14;
       l_item.segment15 := p_inventory_item_rec.item_segment15;
       l_item.segment16 := p_inventory_item_rec.item_segment16;
       l_item.segment17 := p_inventory_item_rec.item_segment17;
       l_item.segment18 := p_inventory_item_rec.item_segment18;
       l_item.segment19 := p_inventory_item_rec.item_segment19;
       l_item.segment20 := p_inventory_item_rec.item_segment20;
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Item-2');
END IF;
       --
       IF INV_Validate.Inventory_Item(L_item,
                                      L_org
                                      ) = INV_Validate.T then

IF (l_debug = 1) THEN
   MDEBUG( 'Validating Item-3');
END IF;
             MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID :=
               l_item.inventory_item_id;
             MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION_QTY_CONTROL_CODE :=
               l_item.REVISION_QTY_CONTROL_CODE;
             MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_CONTROL_CODE :=
               l_item.LOT_CONTROL_CODE;
             MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER_CONTROL_CODE :=
               l_item.SERIAL_NUMBER_CONTROL_CODE;
             MTL_CCEOI_VAR_PVT.G_SKU_REC.ALLOWED_UNITS_LOOKUP_CODE :=
               l_item.ALLOWED_UNITS_LOOKUP_CODE;
             MTL_CCEOI_VAR_PVT.G_SKU_REC.LOCATION_CONTROL_CODE :=
               l_item.LOCATION_CONTROL_CODE;
             MTL_CCEOI_VAR_PVT.G_SKU_REC.RESTRICT_LOCATORS_CODE :=
               l_item.RESTRICT_LOCATORS_CODE;
             MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE := l_item.primary_uom_code;
             L_counter := L_counter + 1;
             x_errorcode := 0;
       END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Item-4');
END IF;
       IF L_counter = 0 THEN
          x_errorcode := 4;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_ITEM');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       ELSIF
          l_counter = 1 THEN
          L_counter := 0;
          --
          -- check IF the item IS present IN mtl_cycle_count_items
         if p_cycle_count_header_id is not null then
          FOR c_rec IN L_CCItemsID_Crs(MTL_CCEOI_VAR_PVT.G_inventory_item_id,
                p_cycle_count_header_id) LOOP
             --
             L_counter := L_counter +1;
             IF L_counter > 1 THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             --
          END LOOP;
          --
          IF L_counter = 0 THEN
             x_errorcode := 5;
             FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_ITEM');
             FND_MSG_PUB.Add;
          ELSE
             x_errorcode := 0;
          END IF;
        end if;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_Item;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_Item;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_Item;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validates locator information
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Locator(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_locator_rec IN MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE ,
  p_organization_id IN NUMBER ,
  P_subinventory IN VARCHAR2 ,
  p_inventory_item_id IN NUMBER ,
  p_locator_control IN NUMBER ,
  p_control_level IN NUMBER ,
  p_restrict_control IN NUMBER,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_Locator
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_locator_rec MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE (required)
    -- Locator information with segments
    --
    -- p_organization_id IN NUMBER (required)
    -- organization ID
    --
    -- p_subinventory IN VARCHAR2 (required)
    -- Subinventory OF the item
    --
    -- p_inventory_item_id IN NUMBER (required)
    -- Item ID
    --
    -- p_locator_control IN NUMBER (required)
    -- IS the item under locator control
    --
    -- p_control_level IN NUMBER (required)
    -- which level controlled the locator
    --
    -- p_restrict_control IN NUMBER
    -- IS the item under rstrict locator control
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_org  INV_VALIDATE.ORG;
       L_item INV_VALIDATE.ITEM;
       L_sub  INV_VALIDATE.SUB;
       L_loc  INV_VALIDATE.LOCATOR;
       --
       L_dynamic_ok CONSTANT VARCHAR2(20) := INV_Validate.EXISTS_OR_CREATE;
       L_dynamic_not_ok CONSTANT VARCHAR2(20) := INV_Validate.EXISTS_ONLY;
       --
       L_counter NUMBER := 0;
       L_Location_Id NUMBER;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_Locator';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_Locator;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
          l_org.organization_id := p_organization_id;
          l_sub.secondary_inventory_name := p_subinventory;
          l_item.inventory_item_id := MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID;
          l_loc.inventory_location_id := p_locator_rec.locator_id;
          l_loc.segment1 := p_locator_rec.locator_segment1;
          l_loc.segment2 := p_locator_rec.locator_segment2;
          l_loc.segment3 := p_locator_rec.locator_segment3;
          l_loc.segment4 := p_locator_rec.locator_segment4;
          l_loc.segment5 := p_locator_rec.locator_segment5;
          l_loc.segment6 := p_locator_rec.locator_segment6;
          l_loc.segment7 := p_locator_rec.locator_segment7;
          l_loc.segment8 := p_locator_rec.locator_segment8;
          l_loc.segment9 := p_locator_rec.locator_segment9;
          l_loc.segment10 := p_locator_rec.locator_segment10;
          l_loc.segment11 := p_locator_rec.locator_segment11;
          l_loc.segment12 := p_locator_rec.locator_segment12;
          l_loc.segment13 := p_locator_rec.locator_segment13;
          l_loc.segment14 := p_locator_rec.locator_segment14;
          l_loc.segment15 := p_locator_rec.locator_segment15;
          l_loc.segment16 := p_locator_rec.locator_segment16;
          l_loc.segment17 := p_locator_rec.locator_segment17;
          l_loc.segment18 := p_locator_rec.locator_segment18;
          l_loc.segment19 := p_locator_rec.locator_segment19;
          l_loc.segment20 := p_locator_rec.locator_segment20;
IF (l_debug = 1) THEN
   mdebug(l_loc.inventory_location_id);
   mdebug ('one='||l_loc.segment1);
   mdebug ('two='||l_loc.segment2);
   mdebug ('thr='||l_loc.segment3);
   mdebug ('four='||l_loc.segment4);
   mdebug ('five='||l_loc.segment5);
   mdebug ('six='||l_loc.segment6);
   mdebug ('19 ='||l_loc.segment19);
   mdebug ('20 ='||l_loc.segment20);
END IF;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator Id and Segments ');
END IF;
         IF INV_Validate.validateLocator(l_loc,l_org,l_sub,L_dynamic_not_ok)
                          = INV_Validate.T then
            MTL_CCEOI_VAR_PVT.G_LOCATOR_ID := l_loc.inventory_location_id;
IF (l_debug = 1) THEN
   MDEBUG( 'Valid Locator Id and Segments ');
END IF;
            L_counter := L_counter + 1;
         END IF;
         --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator DynLoc1'||to_char(p_locator_control));
   MDEBUG( 'Validating Locator DynLoc2'||to_char(MTL_CCEOI_VAR_PVT.G_STOCK_LOCATOR_CONTROL_CODE));
END IF;
       IF L_counter = 0 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator DynLocLvl '||to_char(p_restrict_control));
END IF;
          -- the locator does NOT exist AND no dynamic entry allowed
          -- dynmaic NOT allowed FOR restriced locators on item level
            IF p_locator_control = 2 OR
               (p_restrict_control = 1 AND p_control_level=1) THEN
               x_errorcode := 10;
               FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_LOC');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
	  -- Dynamic locator creation
	   IF p_locator_control = 3 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator DynLoc - Yes' );
END IF;
             IF INV_Validate.validateLocator(l_loc,l_org,l_sub,l_dynamic_ok)
                          = INV_Validate.T then
                MTL_CCEOI_VAR_PVT.G_LOCATOR_ID := l_loc.inventory_location_id;
             ELSE
                IF (l_debug = 1) THEN
                   mdebug('Error ');
                END IF;
                x_errorcode := 10;
                FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_LOC');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF;
        ELSE
          --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator Restricted Loc ' );
END IF;
          -- IF restriced locators on item level, check IF the locator IS
          -- present IN TABLE MTL_SECONDARY_LOCATORS
          IF p_restrict_control = 1 AND p_control_level = 1 THEN
             -- the locator must be present IN a predefined locator list
             L_counter := 0;
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator Id and Segments ');
END IF;
            IF INV_Validate.validateLocator(l_loc,l_org,l_sub,l_item)
                          = INV_Validate.T then
                L_counter := L_counter + 1;
            END IF;

             IF L_counter = 0 THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Locator Restricted Loc - Error ' );
END IF;
                x_errorcode := 47;
                FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_LOC_NOT_IN_LIST');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
          x_errorcode := 0;
       END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_Locator;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_Locator;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_Locator;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validate the primary uom quantity
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_PrimaryUomQuantity(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_primary_uom_quantity IN NUMBER ,
  p_primary_uom_code IN VARCHAR2 )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_PrimaryUomQuantity
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the primary quantity.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- p_primary_uom_quantity IN NUMBER (required)
    -- Primary quantity
    --
    -- p_primary_uom_code IN varchar2 (required)
    -- Primary uom code of the current item
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --   19 = no primary uom quantity
    --   22 = negative primary uom quantity was specified
    --   60 = Count Qty is more than 1 for Single Serialized item
    --   61 = Count Qty is NULL
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_PrimaryUomQuantity';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_PrimaryUomQuantity;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
IF (l_debug = 1) THEN
   MDEBUG( 'Validating PUOM Qty');
END IF;

       IF p_primary_uom_quantity is NULL THEN
          x_errorcode := 19;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_UOM');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       ELSE
	  MTL_CCEOI_VAR_PVT.G_UOM_CODE := MTL_CCEOI_VAR_PVT.G_PRIMARY_UOM_CODE;
	  Validate_CountQuantity(
	    p_api_version => 0.9,
	    x_return_status => x_return_status,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data,
	    x_errorcode => x_errorcode,
	    p_count_quantity => p_primary_uom_quantity);
       END IF;

       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_PrimaryUomQuantity;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_PrimaryUomQuantity;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_PrimaryUomQuantity;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;
  --
  -- Validates subinventory
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Validate_Subinv(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER ,
  p_subinventory IN VARCHAR2 ,
  p_organization_id IN NUMBER,
  p_orientation_code IN NUMBER DEFAULT MTL_CCEOI_VAR_PVT.G_ORIENTATION_CODE,
  p_cycle_count_header_id IN NUMBER DEFAULT MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_SubInv
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- This PROCEDURE validates the subinventory. There two level
    -- validate on organization level OR on subinventory level
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_subinventory IN NUMBER (required)
    --  subinventory OF the item
    --
    -- p_orientation_code IN NUMBER (required - defaulted)
    --    defaulted =
    --    MTL_CCEOI_VAR_PVT.G_ORIENTATION_CODE,
    --    1 = organization level
    --    2 = subinventory level
    --
    --  p_cycle_count_header_id  IN NUMBER (required - defaulted)
    --  default =
    --  MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID
    --
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   X_ErrorCode        OUT NUMBER
    --   6 = Subinv IS missing
    --   7 = NOT assiociated with this cycle COUNT
    --   8 = NOT quantity tracked
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       CURSOR L_CCSubs_Csr(sub IN VARCHAR2, CCId IN NUMBER) IS
          SELECT
          SUBINVENTORY
          FROM MTL_CC_SUBINVENTORIES
       WHERE
          SUBINVENTORY = sub
          AND cycle_count_header_id = CCId;
       --
       l_org INV_Validate.ORG;
       l_sub INV_Validate.SUB;
       L_counter integer := 0;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_SubInv';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_SubInv;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       x_errorcode := 0;
       --
       -- API body
       IF p_subinventory IS NULL THEN
          x_errorcode := 6;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_SUB');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating Subinv ');
END IF;
       -- Cycle COUNT organization level
       IF p_orientation_code=1 or p_orientation_code=2 THEN
          --
          l_org.organization_id := p_organization_id;
          l_sub.secondary_inventory_name := p_subinventory ;
          --
          IF INV_Validate.subinventory(L_sub,L_org) = INV_Validate.T then
             MTL_CCEOI_VAR_PVT.G_SUB_LOCATOR_TYPE := l_sub.LOCATOR_TYPE;
             IF l_sub.QUANTITY_TRACKED <> 1 THEN
                x_errorcode := 8;
                FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NON_QTY_TRKD_SUB');
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
             L_counter := L_counter + 1;
          END IF;

          --
          IF L_counter < 1 THEN
             x_errorcode := 6;
             FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_SUB');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          --
       END IF;
          -- Cycle COUNT subinventory
       IF p_orientation_code=2 THEN
          --
          FOR c_rec IN L_CCSubs_Csr(p_subinventory,
                                    p_cycle_count_header_id) LOOP
             L_counter := L_counter + 1;
             --
          END LOOP;
          --
          IF L_counter < 1 THEN
             x_errorcode := 7;
             FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_SUB');
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       -- if validation went ok set global subinventory variable to
       -- the current validated subinventory
       mtl_cceoi_var_pvt.G_SUBINVENTORY := p_subinventory;
       --
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Validate_SubInv;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Validate_SubInv;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       x_errorcode := -1;
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Validate_SubInv;
       --
       x_errorcode := -1;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;

  -- This function seems to be pasted from INVCORE.pld
  -- along with no_neg_balance and it seems that they carried over some
  -- extra unnecessary stuff (no_neg_balance always returns G_FALSE because of
  -- the way this function is called it is never passed p_restrict, p_action
  -- p_neg_balance. What exactly did we try to achieve here?

  -- Is the item under Locator control
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data
  --x_locator_control,x_level OUT parameters to comply with GSCC File.Sql.39
  --standard. Bug:4410902
  PROCEDURE Locator_Control(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_org_control IN NUMBER ,
  p_sub_control IN NUMBER ,
  p_item_control IN NUMBER DEFAULT NULL,
  p_restrict_flag IN NUMBER DEFAULT NULL,
  p_neg_flag IN NUMBER DEFAULT NULL,
  p_action IN NUMBER DEFAULT NULL,
  x_locator_control OUT NOCOPY NUMBER ,
  x_level OUT NOCOPY NUMBER )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Locator_Control
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_list   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_org_control      IN    NUMBER (required)
    --   org level control (stock_locator_control_code)
    --
    --  p_sub_control      IN    number (required)
    --  Subinventory locator control (locator_type)
    --
    --  p_item_control     IN    number (optional)
    --     default NULL
    --    item locator control
    --
    --  p_restrict_flag    IN    Number (optional)
    --    default NULL
    --
    --  p_Neg_flag         IN    Number (optional)
    --    default NULL
    --
    --  p_action           IN    Number (optional)
    --   default NULL
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   x_locator_control OUT NUMBER
    --   Locator control statement
    --
    --   x_level OUT NUMBER
    --   1 = organization level
    --   2 = Subinventory level
    --   3 = Item level
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       --
       VALUE VARCHAR2(2000);
       locator_control NUMBER := 0;
       control_level integer := 0;
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Locator_Control';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Locator_Control;
       --
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       --
       -- Initialize message list if p_init_msg_list is set to true
       IF FND_API.to_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
       END IF;
       --
       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Validating locator control ');
   mdebug('org_control '||to_char(p_org_control));
   mdebug('sub_control'||to_char(p_sub_control));
   mdebug('item_control'||to_char(p_item_control));
END IF;
       IF(p_org_control = 1) THEN
          locator_control := 1;
          control_level := 1;
       ELSIF
          (p_org_control = 2) THEN
          locator_control := 2;
          control_level := 1;
       ELSIF
          (p_org_control = 3) THEN
          locator_control := 3;
          IF(no_neg_balance(p_restrict_flag,
                   p_neg_flag, p_action)= FND_API.G_TRUE) THEN
             locator_control := 2;
IF (l_debug = 1) THEN
   mdebug('2.LOCATOR control (locator control) '||x_return_status);
END IF;
          END IF;
          control_level := 1;
       ELSIF
          (p_org_control = 4) THEN
          IF(p_sub_control = 1) THEN
             locator_control := 1;
             control_level := 2;
          ELSIF
             (p_sub_control = 2) THEN
             locator_control := 2;
             control_level := 2;
          ELSIF
             (p_sub_control = 3) THEN
             locator_control := 3;
             IF(no_neg_balance(p_restrict_flag,
                      p_neg_flag, p_action)= FND_API.G_TRUE) THEN
                locator_control := 2;
IF (l_debug = 1) THEN
   mdebug('3.LOCATOR control (locator control) '||x_return_status);
END IF;
             END IF;
             control_level := 2;
          ELSIF
             (p_sub_control = 5) THEN
             IF(p_item_control = 1) THEN
                locator_control := 1;
                control_level := 3;
             ELSIF
                (p_item_control = 2) THEN
                locator_control := 2;
                control_level := 3;
             ELSIF
                (p_item_control = 3) THEN
                locator_control := 3;
                IF(no_neg_balance(p_restrict_flag,
                         p_neg_flag, p_action)= FND_API.G_TRUE) THEN
                   locator_control := 2;
IF (l_debug = 1) THEN
   mdebug('4.LOCATOR control (locator control) '||x_return_status);
END IF;
                END IF;
                control_level := 3;
             ELSIF
                (p_item_control IS NULL) THEN
                locator_control := p_sub_control;
                control_level := 2;
             ELSE
                VALUE := p_item_control;
                app_exception.invalid_argument('LOCATOR.CONTROL',
                   'ITEM_LOCATOR_CONTROL',
                   VALUE);
             END IF;
          ELSE
             VALUE := p_sub_control;
             app_exception.invalid_argument('LOCATOR.CONTROL',
                'SUB_LOCATOR_CONTROL',
                VALUE);
	  END IF;

       ELSE
          VALUE := p_org_control;
          app_exception.invalid_argument('LOCATOR.CONTROL',
             'ORG_LOCATOR_CONTROL',
             VALUE);
       END IF;
       x_locator_control := locator_control;
       x_level := control_level;
IF (l_debug = 1) THEN
   mdebug('2.LOCATOR control (locator control) '||x_return_status);
END IF;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Locator_Control;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Locator_Control;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Locator_Control;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;

  --
  -- XXX ??? very strange function
  -- the name does not seem to coincide with whatever it is doing
  FUNCTION No_Neg_Balance(
  restrict_flag IN NUMBER ,
  neg_flag IN NUMBER DEFAULT 38,
  action IN NUMBER DEFAULT 38)
  RETURN VARCHAR2 IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    DECLARE
       VALUE VARCHAR2(2000);
       DO_NOT VARCHAR2(10);
    BEGIN
IF (l_debug = 1) THEN
   MDEBUG( 'Validating No Neg Bal ');
END IF;
       IF(restrict_flag = 2 OR restrict_flag IS NULL) THEN
          IF(neg_flag = 2) THEN
             IF(action = 1 OR action = 2 OR action = 3 OR
                   action = 21 OR action = 30 OR action = 32) THEN
                DO_NOT := FND_API.G_TRUE;
             ELSE
                DO_NOT := FND_API.G_FALSE;
             END IF;
          ELSE
             DO_NOT := FND_API.G_FALSE;
             --             VALUE :=  neg_flag;
             --             app_exception.invalid_argument('LOCATOR.NO_NEG_BALACE',
             --                                    'NEG_FLAG',VALUE);
          END IF;
       ELSIF
          (restrict_flag = 1) THEN
          DO_NOT := FND_API.G_TRUE;
       ELSE
          VALUE := restrict_flag;
          app_exception.invalid_argument('LOCATOR.NO_NEG_BALANCE',
             'RESTRICT_FLAG',
             VALUE);
       END IF;
       RETURN DO_NOT;
    END;
  END;
  --
  --
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data,x_errorcode
  --P_Location_id OUT parameters to comply with GSCC File.Sql.39 standard .Bug:4410902
  PROCEDURE Inv_Dlocator_Create(
  P_Api_Version IN NUMBER ,
  P_Init_Msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  P_Commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  P_Validation_Level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  X_Return_Status OUT NOCOPY VARCHAR2 ,
  X_Msg_Count OUT NOCOPY NUMBER ,
  X_Msg_Data OUT NOCOPY VARCHAR2 ,
  X_Errorcode OUT NOCOPY NUMBER ,
  P_Location_id OUT NOCOPY NUMBER,
  P_Segment1 IN VARCHAR2 DEFAULT NULL,
  P_Segment2 IN VARCHAR2 DEFAULT NULL,
  P_Segment3 IN VARCHAR2 DEFAULT NULL,
  P_Segment4 IN VARCHAR2 DEFAULT NULL,
  P_Segment5 IN VARCHAR2 DEFAULT NULL,
  P_Segment6 IN VARCHAR2 DEFAULT NULL,
  P_Segment7 IN VARCHAR2 DEFAULT NULL,
  P_Segment8 IN VARCHAR2 DEFAULT NULL,
  P_Segment9 IN VARCHAR2 DEFAULT NULL,
  P_Segment10 IN VARCHAR2 DEFAULT NULL,
  P_Segment11 IN VARCHAR2 DEFAULT NULL,
  P_Segment12 IN VARCHAR2 DEFAULT NULL,
  P_Segment13 IN VARCHAR2 DEFAULT NULL,
  P_Segment14 IN VARCHAR2 DEFAULT NULL,
  P_Segment15 IN VARCHAR2 DEFAULT NULL,
  P_Segment16 IN VARCHAR2 DEFAULT NULL,
  P_Segment17 IN VARCHAR2 DEFAULT NULL,
  P_Segment18 IN VARCHAR2 DEFAULT NULL,
  P_Segment19 IN VARCHAR2 DEFAULT NULL,
  P_Segment20 IN VARCHAR2 DEFAULT NULL,
  P_Subinv IN VARCHAR2,
  P_Organization_Id IN NUMBER,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE
  ) IS
  -- end of parameter
  --
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Get_Item_Cost
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- selects the cost OF the specific item
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_level   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    -- Locator Segments 1..20 (optional)
    --
    -- P_Subinv IN VARCHAR2  (required)
    -- p_organization_id IN NUMBER (required)
    -- ID OF the organization
    --
    --     OUT   :
    -- P_Location_Id       OUT NUMBER
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   x_errorcode        OUT NUMBER ,
    --
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments


    DECLARE
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Inv_Dlocator_Create';
       L_structure_number NUMBER := 101;
       L_success BOOLEAN;
       L_appl_short_name VARCHAR2(10) := 'INV';
       L_new_ccid NUMBER;
       L_keyval_mode VARCHAR2(20); -- := 'CREATE_COMBINATION';
       L_key_flex_code VARCHAR2(20) :=  'MTLL';
       L_keystat_val BOOLEAN ;
       L_concat_segs VARCHAR2(2000) ;
       L_n_segments NUMBER ;
       L_i NUMBER := 0;
       L_j NUMBER := 0;
       L_Tsegment_array FND_FLEX_EXT.SegmentArray;
       L_segment_array FND_FLEX_EXT.SegmentArray;
       L_delim varchar2(10) := fnd_flex_ext.get_delimiter(L_appl_short_name,
                                                           L_key_flex_code,
                                                           L_structure_number);
    BEGIN

       -- Standard start of API savepoint
       SAVEPOINT Inv_Dlocator_Create;
       --
       -- for Testing marked by suresh
       -- Standard Call to check for call compatibility
       IF NOT FND_API.Compatible_API_Call(l_api_version
             , p_api_version
             , l_api_name
             , G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- Initialize message list if p_init_msg_list is set to true
      IF FND_API.to_Boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;


       -- Initialisize API return status to access
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
       BEGIN

	  -- in case of simulation just check validity of locator
	  IF FND_API.to_Boolean(p_simulate) THEN
	     l_keyval_mode := 'CHECK_COMBINATION';
	  ELSE
	     --l_keyval_mode := 'CREATE_COMBINATION';
	     l_keyval_mode := 'CREATE_COMB_NO_AT';
	  END IF;
	 /* Commented the above statement of l_keyval_mode for bug 1881366 .
            INstead of CREATE_COMBINATIO,used new operation code CREATE_COMB_NO_AT*/

          SELECT count(segment_num) into L_n_segments from
          fnd_id_flex_segments
          where application_id = 401
          and id_flex_code = L_key_flex_code
          and enabled_flag = 'Y'
          order by segment_num;
       EXCEPTION
       WHEN OTHERS THEN NULL;
       END;
       IF L_delim is NULL then
          IF (l_debug = 1) THEN
             mdebug('Delimeter is NULL...Error');
          END IF;
       END IF;
      IF (l_debug = 1) THEN
         mdebug('6');
      END IF;
       L_Tsegment_array(1):= P_segment1;
       L_Tsegment_array(2):= P_segment2;
       L_Tsegment_array(3):= P_segment3;
       L_Tsegment_array(4):= P_segment4;
       L_Tsegment_array(5):= P_segment5;
       L_Tsegment_array(6):= P_segment6;
       L_Tsegment_array(7):= P_segment7;
       L_Tsegment_array(8):= P_segment8;
       L_Tsegment_array(9):= P_segment9;
       L_Tsegment_array(10):= P_segment10;
       L_Tsegment_array(11):= P_segment11;
       L_Tsegment_array(12):= P_segment12;
       L_Tsegment_array(13):= P_segment13;
       L_Tsegment_array(14):= P_segment14;
       L_Tsegment_array(15):= P_segment15;
       L_Tsegment_array(16):= P_segment16;
       L_Tsegment_array(17):= P_segment17;
       L_Tsegment_array(18):= P_segment18;
       L_Tsegment_array(19):= P_segment19;
       L_Tsegment_array(20):= P_segment20;
       --
       L_j := 1;
       LOOP
          EXIT WHEN  L_j > L_n_segments;
          L_segment_array(L_j) := NULL ;
          L_j := L_j + 1;
       END LOOP;
       --
       L_i := 1;
       L_j := 1;
       LOOP
          EXIT WHEN  L_i > 20;
          IF L_Tsegment_array(L_i) IS NOT NULL THEN
             L_segment_array(L_j) := L_Tsegment_array(L_i);
             L_j := L_j + 1;
          END IF;
          L_i := L_i + 1;
       END LOOP;
       -- Use the FND_FLEX_EXT pacakge to concatenate the segments
       --
       L_concat_segs := fnd_flex_ext.concatenate_segments(L_n_segments,
                                                          L_segment_array,
                                                          L_delim);
       IF (l_debug = 1) THEN
          mdebug('Concat_segs : '||L_concat_segs);
          mdebug('Concat_segs Delim : '||L_delim);
          mdebug('Concat_segs Nsegments: '||to_char(L_n_segments));
       END IF;
       --

       L_keystat_val := FND_FLEX_KEYVAL.Validate_Segs(
                        OPERATION       => L_keyval_mode,
                        APPL_SHORT_NAME => 'INV',
                        KEY_FLEX_CODE   => L_key_flex_code,
                        STRUCTURE_NUMBER=> L_structure_number,
                        CONCAT_SEGMENTS => L_Concat_Segs,
                        VALUES_OR_IDS   => 'V',
                        DATA_SET        => P_Organization_Id
                        );

       x_msg_data :=  fnd_flex_keyval.error_segment;
       x_msg_data :=  fnd_flex_keyval.error_message;
       IF (l_debug = 1) THEN
          mdebug('Error Mess- If - '||x_msg_data);
       END IF;

       if L_keystat_val then
	  L_new_ccid := FND_FLEX_KEYVAL.combination_id;

	  IF (l_debug = 1) THEN
   	  mdebug('Validate Seg CCid: '||to_char(L_new_ccid));
	  END IF;
	  IF NOT FND_API.to_Boolean(p_simulate) THEN
	     UPDATE mtl_item_locations
	       SET subinventory_code = p_subinv
	       WHERE inventory_location_id = l_new_ccid
	       AND   organization_id = P_Organization_Id ;
	     IF SQL%NOTFOUND THEN
		IF (l_debug = 1) THEN
   		mdebug('Table is not Updated');
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
	  END IF;
	     IF (l_debug = 1) THEN
   	     mdebug('Create New Seg CCid: '||to_char(L_new_ccid));
	     END IF;
	  else

	     x_msg_data :=  fnd_flex_keyval.error_segment;
	     IF (l_debug = 1) THEN
   	     mdebug('Errored out procedure');
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	  end if;
	  P_Location_Id := L_new_ccid ;
       --
       -- END of API body
       -- Standard check of p_commit
       IF FND_API.to_Boolean(p_commit) THEN
          COMMIT;
       END IF;
       -- Standard call to get message count and if count is 1, get message info
       FND_MSG_PUB.Count_And_Get
       (p_count => x_msg_count
          , p_data => x_msg_data);
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       --
       ROLLBACK TO Inv_Dlocator_Create;
       --
--MDEBUG( 'Exception Error ');
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Inv_Dlocator_Create;
       --
--MDEBUG( 'UNexp Exception Error ');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
--MDEBUG( 'Others Exception Error ');
       ROLLBACK TO Inv_Dlocator_Create;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
    END;
  END;

-- BEGIN INVCONV
PROCEDURE validate_secondarycountuom (
   p_api_version                 IN         NUMBER
 , p_init_msg_list               IN         VARCHAR2 DEFAULT fnd_api.g_false
 , p_commit                      IN         VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_level            IN         NUMBER DEFAULT fnd_api.g_valid_level_full
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 , x_errorcode                   OUT NOCOPY NUMBER
 , p_organization_id             IN         NUMBER
 , p_inventory_item_id           IN         NUMBER
 , p_secondary_uom               IN         VARCHAR2
 , p_secondary_unit_of_measure   IN         VARCHAR2
 , p_tracking_quantity_ind       IN         VARCHAR2) IS
   --
   CURSOR l_itemuom_csr (
      code     IN   VARCHAR2
    , NAME     IN   VARCHAR2
    , org      IN   NUMBER
    , itemid   IN   NUMBER) IS
      SELECT uom_code
        FROM mtl_item_uoms_view
       WHERE organization_id = org
         AND inventory_item_id = itemid
         AND (uom_code = code OR unit_of_measure = NAME);

   --
   l_api_version        CONSTANT NUMBER        := 0.9;
   l_api_name           CONSTANT VARCHAR2 (30) := 'Validate_SecondaryCountUOM';
   l_secondary_unit_of_measure   mtl_item_uoms_view.unit_of_measure%TYPE;
   l_secondary_uom               mtl_item_uoms_view.uom_code%TYPE;
BEGIN
   -- Standard start of API savepoint
   SAVEPOINT validate_secondarycountuom;

   --
   -- Standard Call to check for call compatibility
   IF NOT fnd_api.compatible_api_call (l_api_version
                                     , p_api_version
                                     , l_api_name
                                     , g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   --
   -- Initialisize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   x_errorcode := 0;

   --
   IF p_secondary_uom IS NULL AND p_secondary_unit_of_measure IS NULL THEN
      MTL_CCEOI_VAR_PVT.g_secondary_count_uom := MTL_CCEOI_VAR_PVT.g_secondary_uom_code;
   ELSIF p_secondary_uom IS NOT NULL AND p_secondary_unit_of_measure IS NULL THEN
      l_secondary_uom := p_secondary_uom;
      l_secondary_unit_of_measure := NULL;
   ELSIF p_secondary_uom IS NULL AND p_secondary_unit_of_measure IS NOT NULL THEN
      l_secondary_uom := NULL;
      l_secondary_unit_of_measure := p_secondary_unit_of_measure;

      OPEN l_itemuom_csr (l_secondary_uom
                        , l_secondary_unit_of_measure
                        , p_organization_id
                        , p_inventory_item_id);

      FETCH l_itemuom_csr INTO l_secondary_uom;
      CLOSE l_itemuom_csr;
   END IF;

   IF l_secondary_uom <> MTL_CCEOI_VAR_PVT.g_secondary_uom_code THEN
      x_errorcode := 20;
      fnd_message.set_name ('INV', 'INV_INCORRECT_SECONDARY_UOM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
   END IF;

   --
   MTL_CCEOI_VAR_PVT.g_secondary_count_uom := l_secondary_uom;

   IF fnd_api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO validate_secondarycountuom;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO validate_secondarycountuom;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_errorcode := -1;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO validate_secondarycountuom;
      x_errorcode := -1;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END validate_secondarycountuom;

PROCEDURE validate_secondarycountqty (
   p_api_version                 IN         NUMBER
 , p_init_msg_list               IN         VARCHAR2 DEFAULT fnd_api.g_false
 , p_commit                      IN         VARCHAR2 DEFAULT fnd_api.g_false
 , p_validation_level            IN         NUMBER DEFAULT fnd_api.g_valid_level_full
 , p_precision                   IN         NUMBER DEFAULT 5
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_msg_count                   OUT NOCOPY NUMBER
 , x_msg_data                    OUT NOCOPY VARCHAR2
 , x_errorcode                   OUT NOCOPY NUMBER
 , p_organization_id             IN         NUMBER
 , p_inventory_item_id           IN         NUMBER
 , p_lot_number                  IN         VARCHAR2
 , p_count_uom                   IN         VARCHAR2
 , p_count_quantity              IN         NUMBER
 , p_secondary_uom               IN         VARCHAR2
 , p_secondary_quantity          IN         VARCHAR2
 , p_tracking_quantity_ind       IN         VARCHAR2
 , p_secondary_default_ind       IN         VARCHAR2)
 IS
   --
   l_api_version        CONSTANT NUMBER        := 0.9;
   l_api_name           CONSTANT VARCHAR2 (30) := 'Validate_SecondaryCountQty';
   l_converted_qty      NUMBER;
   l_error_message      VARCHAR2(2000);

BEGIN
   -- Standard start of API savepoint
   SAVEPOINT validate_secondarycountqty;

   -- Standard Call to check for call compatibility
   IF NOT fnd_api.compatible_api_call (l_api_version
                                     , p_api_version
                                     , l_api_name
                                     , g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to true
   IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialisize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   x_errorcode := 0;
   --
   IF p_secondary_quantity IS NULL OR p_secondary_quantity = 0 THEN
      l_converted_qty := INV_CONVERT.inv_um_convert(
                             organization_id => p_organization_id
                           , item_id => p_inventory_item_id
                           , lot_number => p_lot_number
			   , precision => p_precision
			   , from_quantity => p_count_quantity
                           , from_unit => p_count_uom
			   , to_unit => p_secondary_uom
                           , from_name => NULL
			   , to_name => NULL
			   );

      IF (l_converted_qty = -99999) THEN
          x_errorcode := 50;
          FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END IF;

      MTL_CCEOI_VAR_PVT.g_secondary_count_quantity := l_converted_qty;

   ELSE -- p_secondary_quantity IS NOT NULL
      IF p_secondary_quantity < 0 THEN
          x_errorcode := 52;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NEG_QTY');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( INV_CONVERT.within_deviation(
                p_organization_id     => p_organization_id
              , p_inventory_item_id   => p_inventory_item_id
              , p_lot_number          => p_lot_number
              , p_precision           => p_precision
              , p_quantity            => p_count_quantity
              , p_uom_code1           => p_count_uom
              , p_quantity2           => p_secondary_quantity
              , p_uom_code2           => p_secondary_uom
              , p_unit_of_measure1    => NULL
              , p_unit_of_measure2    => NULL) = 0) THEN

	 x_errorcode := 51;
	 FND_MESSAGE.SET_NAME('INV','INV_DEVIATION_CHECK_ERR');
	 -- An error occurred in call to INV_CONVERT.within_deviation
	 fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      MTL_CCEOI_VAR_PVT.g_secondary_count_quantity := p_secondary_quantity;
   END IF;

   IF fnd_api.to_boolean (p_commit) THEN
      COMMIT;
   END IF;

   fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO validate_secondarycountqty;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO validate_secondarycountqty;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_errorcode := -1;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO validate_secondarycountqty;
      x_errorcode := -1;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END validate_secondarycountqty;

-- END INVCONV

END MTL_INV_VALIDATE_GRP;

/
