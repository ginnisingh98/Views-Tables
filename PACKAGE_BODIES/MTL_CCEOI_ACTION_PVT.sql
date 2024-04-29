--------------------------------------------------------
--  DDL for Package Body MTL_CCEOI_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CCEOI_ACTION_PVT" AS
/* $Header: INVVCCAB.pls 120.2 2005/06/22 09:50:38 appldev ship $ */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_CCEOI_ACTION_PVT';


procedure mdebug(msg in varchar2)
is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
   --dbms_output.put_line(msg);
   null;
end;
--Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
--parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
PROCEDURE Process_Error(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
  p_commit IN VARCHAR2 := FND_API.G_FALSE,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE,
  p_message_name IN MTL_CC_INTERFACE_ERRORS.ERROR_MESSAGE%TYPE,
  p_error_column_name IN MTL_CC_INTERFACE_ERRORS.ERROR_COLUMN_NAME%TYPE,
  p_error_table_name IN MTL_CC_INTERFACE_ERRORS.ERROR_TABLE_NAME%TYPE,
  p_flags IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 )
IS
   L_api_version CONSTANT NUMBER := 0.9;
   L_api_name CONSTANT VARCHAR2(30) := 'Process_Error';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   -- Standard start of API savepoint
   SAVEPOINT Process_Error;
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

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --
   -- API body
   --

   FND_MESSAGE.SET_NAME('INV', p_message_name);
   FND_MSG_PUB.Add;

   IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = FALSE THEN

      MTL_CCEOI_PROCESS_PVT.Insert_CCIEntry(
	p_interface_rec=> p_interface_rec,
	x_return_status => x_return_status);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	 -- TODO: post FND message about not being able to create
	 -- a cycle count entry
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   --
   -- SET the flags
   MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
     p_api_version => 0.9,
     x_return_status => x_return_status,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data,
     p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
     p_flags => p_flags);

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- TODO: post FND message about not being able to set flags
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Write INTO Error TABLE
   MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
     p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
     p_error_column_name => p_error_column_name,
     p_error_table_name => p_error_table_name,
     p_message_name => p_message_name );
   --

   --
   -- END of API body
   --

   -- Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
     , p_data => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     --
     ROLLBACK TO Process_Error;
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     ROLLBACK TO Process_Error;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
   WHEN OTHERS THEN
     --
     ROLLBACK TO Process_Error;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);

END Process_Error;


--
  -- Insert the given row into the interface table.
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Export_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Export_CountRequest
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- INSERT the interface RECORD INTO the MTL_CC_ENTRIES_INTERFACE
    -- TABLE AND locks the original RECORD IN the TABLE
    -- MTL_CYCLE_COUNT_ENTRIES
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --                API Version of this procedure
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                           DEFAULT = FND_API.G_FALSE,
    --             p_commit           IN  VARCHAR2 (optional)
    --                           DEFAULT = FND_API.G_FALSE,
    --             p_validation_level IN  NUMBER (optional)
    --                           DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --             p_interface_rec    IN  CCEOI_Rec_Type (required)
    --                complete interface RECORD
    --     OUT   : X_return_status    OUT NUMBER
    --                Result of all the operations
    --             x_msg_count        OUT NUMBER,
    --             x_msg_data         OUT VARCHAR2,
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the Error status
    -- Version: Current Version 0.9
    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       -- FOR export
       L_EXPORT_FLAG NUMBER := 1;
       --
       L_return_status VARCHAR2(30);
       L_msg_count NUMBER;
       L_msg_data VARCHAR2(240);
       --
       -- FOR this API PROCEDURE
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Export_CountRequest';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Export_CountRequest_PVT;
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
       -- Delete all error records first
       MTL_CCEOI_PROCESS_PVT.Delete_CCEOIError(
          p_interface_rec.cc_entry_interface_id);
       --
       -- INSERT the RECORD INTO the TABLE MTL_CC_ENTRIES_INTERFACE
       MTL_CCEOI_PROCESS_PVT.Insert_CCIEntry(
          p_interface_rec=> p_interface_rec,
          x_return_status => L_return_status);
       --
       -- Set EXPORT FLAG= 1 in MTL_CYCLE_COUNT_ENTRIES
       MTL_CCEOI_PROCESS_PVT.Set_CCExport(
          p_api_version => 0.9,
          X_return_status=> L_return_status,
          x_msg_count => L_msg_count,
          x_msg_data => L_msg_data,
          p_cycle_count_entry_id =>
          p_interface_rec.cycle_count_entry_id,
          p_export_flag=> L_export_flag);
       --
       x_msg_count := L_msg_count;
       x_msg_data := L_msg_data;
       x_return_status := L_return_status;
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
       ROLLBACK TO Export_CountRequest_PVT;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Export_CountRequest_PVT;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO Export_CountRequest_PVT;
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
  -- Create unscheduled count requests
--Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
--parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
PROCEDURE Create_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
  IS
     L_api_version CONSTANT NUMBER := 0.9;
     L_api_name CONSTANT VARCHAR2(30) := 'Create_CountRequest';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Create_CountRequest
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- This PROCEDURE creates COUNT requests INTO TABLE
    -- mtl_cycle_count_entries only IF unscheduled request
    -- are allowed.
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_l   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    -- p_validation_level IN NUMBER (optional)
    --   DEFAULT = FND_API.G_VALID_LEVEL_FULL
    --   currently unused
    --
    --  p_simulate IN  VARCHAR2 (optional)
    --  determines whether to do do actual processing or just simulate it
    --      DEFAULT = FND_API.G_FALSE
    --         create record in mtl_cycle_count_entries
    --      FND_API.G_TRUE
    --          do not insert records into mtl_cycle_count_entries
    --
    --
    --  p_interface_rec MTL_CC_ENTRIES_INTERFACE%ROWTYPE (required)
    --  the interface RECORD
    --
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

       --
--       L_errorcode NUMBER := 0;
--       L_return_status VARCHAR2(1);
--       L_msg_count NUMBER;
--       L_msg_data VARCHAR2(240);

     -- Standard start of API savepoint
     SAVEPOINT Create_CountRequest;
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
        MDEBUG( 'Create_CountRequest');
     END IF;

     -- Delete all error records first
     MTL_CCEOI_PROCESS_PVT.Delete_CCEOIError(
       p_interface_rec.cc_entry_interface_id);


     MTL_CCEOI_ACTION_PVT.Validate_CountRequest
       (p_api_version => 0.9
       , x_return_status => x_return_status
       , x_msg_count => x_msg_count
       , x_msg_data => x_msg_data
       , p_interface_rec => p_interface_rec
       );

     IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	--
	IF (l_debug = 1) THEN
   	MDEBUG( 'Process: Begin Unsch? '||to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.UNSCHEDULED_COUNT_ENTRY));
	END IF;

	-- Unscheduled entries NOT allowed
	IF MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.UNSCHEDULED_COUNT_ENTRY=2 THEN
	   --
	   IF (l_debug = 1) THEN
   	   MDEBUG( 'Process: No Unsch ');
	   END IF;
	   Process_Error(
	     p_api_version => 0.9,
	     p_interface_rec => p_interface_rec,
	     p_message_name => 'INV_CCEOI_NO_UNSCHD_COUNTS',
	     p_error_column_name => 'UNSCHEDULED_COUNT_ENTRY',
	     p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS',
	     p_flags => '1$2$',
	     x_return_status => x_return_status,
	     x_msg_count => x_msg_count,
	     x_msg_data => x_msg_data);
	   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

	   x_return_status := FND_API.G_RET_STS_ERROR;
	   RAISE FND_API.G_EXC_ERROR;
	   --
	   -- Validation ok AND OPEN request exists
	ELSIF MTL_CCEOI_VAR_PVT.G_OPEN_REQUEST = TRUE THEN
	   --

	   IF (l_debug = 1) THEN
   	   MDEBUG( 'Process: No Unsch -Open Request ');
	   END IF;
	   Process_Error(
	     p_api_version => 0.9,
	     p_interface_rec => p_interface_rec,
	     p_message_name => 'INV_CCEOI_COUNT_REQ_EXISTS',
	     p_error_column_name => 'CYCLE_COUNT_ENTRY_ID',
	     p_error_table_name => 'MTL_CYCLE_COUNT_ENTRIES',
	     p_flags => '1$2$',
	     x_return_status => x_return_status,
	     x_msg_count => x_msg_count,
	     x_msg_data => x_msg_data);
	   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

	   x_return_status := FND_API.G_RET_STS_ERROR;
	   --
	   -- all ok. It IS an unscheduled entry, AND the information IS correct
	ELSE
	   IF (l_debug = 1) THEN
   	   MDEBUG( 'Create_CountRequest: Inserting CC Request');
	   END IF;

	   -- set unscheduled count type code
	   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.COUNT_TYPE_CODE := 2;

	   -- create count request if not in simulation mode
	   IF (p_simulate = FND_API.G_FALSE) THEN


	      -- insert count request into mtl_cycle_count_entries
	      MTL_CCEOI_PROCESS_PVT.Insert_CCEntry(
		p_interface_rec=> p_interface_rec);

	      declare
		 l_interface_rec MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE :=
		   p_interface_rec;
		 l_cycle_count_entry_id number :=
		   MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID;
	      begin

		 -- make sure we save id's inside interface record because
		 -- open interface forms only works with id's
		 l_interface_rec.inventory_item_id :=
		   MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID;
		 l_interface_rec.locator_id := MTL_CCEOI_VAR_PVT.G_LOCATOR_ID;

		 l_interface_rec.cycle_count_header_id :=
		   MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID;

		 l_interface_rec.count_list_sequence :=
		   nvl(p_interface_rec.COUNT_LIST_SEQUENCE,
		   MTL_CCEOI_VAR_PVT.G_Seq_No);

		 l_interface_rec.cycle_count_entry_id := null;

		 -- update CCI entry with cycle count entry id
		 -- from that point no SKU changes can be made
		 MTL_CCEOI_PROCESS_PVT.Update_CCIEntry(l_interface_rec,
		   x_return_status);

		 if (x_return_status <> fnd_api.g_ret_sts_success) then
		    raise fnd_api.g_exc_unexpected_error;
		 end if;

		 IF (l_debug = 1) THEN
   		 mdebug('updating ccei_id='||l_interface_rec.cc_entry_interface_id||' with cce_id='|| l_cycle_count_entry_id);
		 END IF;
		 -- make additional changes to interface rec sku impossible
		 update mtl_cc_entries_interface
		   set
		   cycle_count_entry_id =
		     l_cycle_count_entry_id
		   where cc_entry_interface_id =
		     l_interface_rec.cc_entry_interface_id;
	      end;

	   END IF;

	   IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = TRUE THEN
	      MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
		p_api_version => 0.9,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data => x_msg_data,
		p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
		p_flags => '2$0$');
	      -- the flag means no errors,  successful processed
	   END IF; -- if record is in system
	   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;

	   IF (l_debug = 1) THEN
   	   MDEBUG( 'Process: End of Unsch ');
	   END IF;
	END IF;
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
       ROLLBACK TO Create_CountRequest;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
	 , p_data => x_msg_data);
	 --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO Create_CountRequest;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
	 , p_data => x_msg_data);
       --
     WHEN OTHERS THEN
       --
       ROLLBACK TO Create_CountRequest;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	  FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
       END IF;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
	 , p_data => x_msg_data);

END Create_CountRequest;



--
-- processed count request from the interface table
--Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
--parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
PROCEDURE Process_CountRequest
  (
   p_api_version IN NUMBER ,
   p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status OUT NOCOPY VARCHAR2 ,
   x_msg_count OUT NOCOPY NUMBER ,
   x_msg_data OUT NOCOPY VARCHAR2 ,
   p_simulate IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
IS
   L_error_code NUMBER;
   --
   L_api_version CONSTANT NUMBER := 0.9;
   L_err_count NUMBER := 0;
   L_api_name CONSTANT VARCHAR2(30) := 'Process_CountRequest';

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Start OF comments
   -- API name  : Process_CountRequest
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
   -- p_validation_level IN NUMBER (optional)
   --   DEFAULT = FND_API.G_VALID_LEVEL_FULL
   --   currently unused
   --
   --  p_simulate IN  VARCHAR2 (optional)
   --  determines whether to do do actual processing or just simulate it
   --      DEFAULT = FND_API.G_FALSE
   --        - update processed info in mtl_cycle_count_entries (and any
   --          other table necessary)
   --      FND_API.G_TRUE
   --        - do not insert record into mtl_cycle_count_entries
   --
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

   --MDEBUG( 'Process: CCEId '||to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID));
   -- Standard start of API savepoint
   SAVEPOINT Process_CountRequest;
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
      MDEBUG( 'Process: Process count request ');
   END IF;

   IF (l_debug = 1) THEN
      MDEBUG( 'Count Qty '||to_char(p_interface_rec.count_quantity));
      MDEBUG( 'Level number '||to_char(FND_API.G_VALID_LEVEL_FULL));
   END IF;

   IF (l_debug = 1) THEN
      MDEBUG( 'Process: Delete all errors ');
   END IF;
   -- Delete all error records first
   MTL_CCEOI_PROCESS_PVT.Delete_CCEOIError(
     p_interface_rec.cc_entry_interface_id);

   IF (l_debug = 1) THEN
      MDEBUG( 'Process: Validate countrequest ');
   END IF;
   MTL_CCEOI_ACTION_PVT.Validate_CountRequest
     (p_api_version => 0.9
     , x_return_status => x_return_status
     , x_msg_count => x_msg_count
     , x_msg_data => x_msg_data
     , p_validation_level => 1        -- Validate for processing
     , p_interface_rec => p_interface_rec
     );

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF MTL_CCEOI_VAR_PVT.G_OPEN_REQUEST = FALSE
	AND MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.UNSCHEDULED_COUNT_ENTRY=2
      THEN
	 IF (l_debug = 1) THEN
   	 MDEBUG('Process: After Validate in Process NOSCHED');
	 END IF;
	 Process_Error(
	   p_api_version => 0.9,
	   p_interface_rec => p_interface_rec,
	   p_message_name => 'INV_CCEOI_NO_UNSCHD_COUNTS',
	   p_error_column_name => 'UNSCHEDULED_COUNT_ENTRY',
	   p_error_table_name => 'MTL_CYCLE_COUNT_HEADERS',
	   p_flags => '1$2$',
	   x_return_status => x_return_status,
	   x_msg_count => x_msg_count,
	   x_msg_data => x_msg_data);
	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;

      ELSIF MTL_CCEOI_VAR_PVT.G_OPEN_REQUEST = FALSE AND
	MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.UNSCHEDULED_COUNT_ENTRY=1
      THEN

	 IF (l_debug = 1) THEN
   	 MDEBUG('Process : Create Unscheduled Entries');
	 END IF;
	 -- Create all unscheduled entries
	 MTL_CCEOI_ACTION_PVT.Create_CountRequest(
	   p_api_version => 0.9,
	   p_simulate => p_simulate,
	   x_return_status => x_return_status,
	   x_msg_count => x_msg_count,
	   x_msg_data => x_msg_data,
	   p_interface_rec => p_interface_rec );

	 --
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	 -- process the data
	 MTL_CCEOI_PROCESS_PVT.Process_Data
	   (p_api_version => 0.9
	   , p_simulate => p_simulate
	   , x_return_status => x_return_status
	   , x_msg_count => x_msg_count
	   , x_errorcode => l_error_code
	   , x_msg_data => x_msg_data
	   , p_interface_rec => p_interface_rec);

	   IF (l_debug = 1) THEN
   	   MDEBUG('Process : After process Data '||x_return_status);
	   END IF;

	   IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	      -- count errors (left over from previous code which
	      -- had to count errors even in successful case because
	      -- of poor error handling that would lose error status
	      -- after insertion of errors
	      -- XXX this whole thing will have to go once
	      -- we verify that return status is working ok
	      L_err_count := 0;
	      BEGIN
		 select count(*)
		   into L_err_count
		   from mtl_cc_interface_errors
		   where cc_entry_interface_id =
		   p_interface_rec.cc_entry_interface_id;

	      EXCEPTION
		 WHEN OTHERS THEN
		   L_err_count := 0;
	      END;

	      IF (l_err_count <> 0) THEN
		 IF (l_debug = 1) THEN
   		 mdebug('Return status success while there are errors in the table');
		 END IF;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
/*
		 IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = TRUE THEN
		    MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
		      p_api_version => 0.9,
		      x_return_status => x_return_status,
		      x_msg_count => x_msg_count,
			x_msg_data => x_msg_data,
			p_cc_entry_interface_id =>
			MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
			p_flags => '1$22');

		 END IF;

		 x_return_status := FND_API.G_RET_STS_ERROR;
		 */
	      ELSE
		 IF MTL_CCEOI_VAR_PVT.G_CC_ENTRY_REC_TMP.ENTRY_STATUS_CODE = 3
		 THEN
		    -- Added by suresh
		    IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = TRUE THEN
		       MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
			 p_api_version => 0.9,
			 x_return_status => x_return_status,
			 x_msg_count => x_msg_count,
			 x_msg_data => x_msg_data,
			   p_cc_entry_interface_id =>
			   MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
			   p_flags => '2$3$');
		    END IF;

		 ELSE

		    IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = TRUE THEN
		       MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
			 p_api_version => 0.9,
			 x_return_status => x_return_status,
			 x_msg_count => x_msg_count,
			 x_msg_data => x_msg_data,
			 p_cc_entry_interface_id=>
			 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
			 p_flags => '2$0$');
		    END IF;

		 END IF;

		 IF (p_simulate = FND_API.G_FALSE) THEN

		    -- XXX this is leftover from previous poor error
		    -- processing. This line should go
		    IF MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID is NULL THEN
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		    END IF;

		    MTL_CCEOI_PROCESS_PVT.Update_CCEntry(
		      MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID);

		 END IF;

	      END IF;

	   ELSE

	      IF (l_error_code = 70) THEN
		 Process_Error(
		   p_api_version => 0.9,
		   p_interface_rec => p_interface_rec,
		   p_message_name => 'INV_SERIAL_UNAVAILABLE',
		   p_error_column_name => 'SERIAL_NUMBER',
		   p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE',
		   p_flags => '1$2$',
		   x_return_status => x_return_status,
		   x_msg_count => x_msg_count,
		   x_msg_data => x_msg_data);

		 RAISE FND_API.G_EXC_ERROR;
	      ELSE
		 -- XXX this is clearly a strange message
		 Process_Error(
		   p_api_version => 0.9,
		   p_interface_rec => p_interface_rec,
		   p_message_name => 'UNEXPECTED ERROR',
		   p_error_column_name => 'UNEXPECTED ERROR',
		   p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE',
		   p_flags => '1$2$',
		   x_return_status => x_return_status,
		   x_msg_count => x_msg_count,
		   x_msg_data => x_msg_data);

		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF; -- error_code of unsuccessful process_data
	   END IF;  -- process_data return status

      END IF;  -- x_return_status = true/create's return status

   END IF;  -- validation's return status

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
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
     IF (l_debug = 1) THEN
        MDEBUG('Process : Exc Err' || sqlerrm);
     END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
     IF (l_debug = 1) THEN
        MDEBUG('Process : Exc Unexp Err ' || sqlerrm);
     END IF;

   WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     IF (l_debug = 1) THEN
        MDEBUG('Process_CountRequest : Exc_Others ' || sqlerrm);
     END IF;

END Process_CountRequest;

  -- Validate the records in the interface table
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Validate_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_NONE,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Validate_CountRequest
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- Validates the COUNT request information OF the given
    -- interface RECORD
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
    --  p_validation_level IN  NUMBER DEFAULT 0 (optional- defaulted)
    --      0 = FND_API.G_VALID_LEVEL_NONE (no processing),
    --      1 = Validate FOR processing
    --
    --
    --  p_interface_rec IN  MTL_CC_ENTRIES_INTERFACE%ROWTYPE (required)
    --   Cycle COUNT entries interface RECORD
    --
    --     OUT   :
    --  X_return_status    OUT NUMBER
    --  Result of all the operations
    --
    --   x_msg_count        OUT NUMBER,
    --
    --   x_msg_data         OUT VARCHAR2,
    --
    --   RETURN value OF the Error status
    --   0 = successful
    -- Version: Current Version 0.9

    --              Changed : Nothing
    --          No Previous Version 0.0
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       L_inventory_rec MTL_CCEOI_VAR_PVT.Inv_Item_rec_type;
       L_sku_rec MTL_CCEOI_VAR_PVT.INV_SKU_REC_TYPE;
       L_locator_rec MTL_CCEOI_VAR_PVT.INV_LOCATOR_REC_TYPE;
       L_subinventory MTL_CYCLE_COUNT_ENTRIES.SUBINVENTORY%TYPE;
       l_derivable_item_sku BOOLEAN := TRUE;
       L_errorcode NUMBER := 0;
       L_return_status VARCHAR2(30);
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Validate_CountRequest';
       l_simulate varchar2(1);
       l_same_seq_not_closed_entries NUMBER;  -- to count open count_list_seq
       -- so that we do not attempt to create count_list_sequence with already
       -- existing number

       -- BEGIN INVCONV
       CURSOR cur_get_item_attr (
          cp_inventory_item_id                NUMBER
        , cp_organization_id                  NUMBER
       ) IS
          -- tracking_quantity_ind (P-Primary, PS-Primary and Secondary)
          -- secondary_default_ind (F-Fixed, D-Default, N-No Default)
          SELECT msi.tracking_quantity_ind
               , msi.secondary_default_ind
               , msi.secondary_uom_code
               , msi.process_costing_enabled_flag
               , mtp.process_enabled_flag
            FROM mtl_system_items msi, mtl_parameters mtp
           WHERE mtp.organization_id = cp_organization_id
             AND msi.organization_id = mtp.organization_id
             AND msi.inventory_item_id = cp_inventory_item_id;
       -- END INVCONV

    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Validate_CountRequest;
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
       L_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --

       -- determine whether this is a simulation run in which we
       -- shall not modify non-interface related tables
       if (p_interface_rec.action_code = mtl_cceoi_var_pvt.g_valsim) then
	  l_simulate := fnd_api.g_true;
       else
	  l_simulate := fnd_api.g_false;
       end if;

       -- Delete all error records first
       MTL_CCEOI_PROCESS_PVT.Delete_CCEOIError(
	 p_interface_rec.cc_entry_interface_id);

       IF (l_debug = 1) THEN
          mdebug('Validate_CountRequest: Deleted errors');
       END IF;
       --
       IF p_interface_rec.cc_entry_interface_id IS NULL THEN
          L_errorcode := 21;
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_IFACE_ID');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Current processed interface RECORD
       MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID :=
       p_interface_rec.cc_entry_interface_id;
       --
       IF (l_debug = 1) THEN
          MDEBUG( 'G_CC_ENTRY_INTERFACE_ID ='|| MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID);
       END IF;



IF (l_debug = 1) THEN
   MDEBUG( 'Validation Level ='|| to_char(p_validation_level));
END IF;
--mdebug('Check Cycle Count Header: ' || to_char(p_interface_rec.cycle_count_header_id) || '.');

       -- Check the cycle COUNT header Process Step 1
       MTL_CCEOI_PROCESS_PVT.Validate_CHeader(
          p_api_version => 0.9,
          x_return_status => L_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          X_ErrorCode => L_errorcode,
          p_cycle_count_header_id => p_interface_rec.cycle_count_header_id,
          p_cycle_count_header_name => p_interface_rec.cycle_count_header_name
       );
IF (l_debug = 1) THEN
   mdebug('Return CHeader='||L_return_status);
END IF;
       IF L_errorcode <>0 AND L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          GOTO end_VALIDATE;
IF (l_debug = 1) THEN
   mdebug('Cycle Count Header Error');
END IF;
       END IF;
       --
IF (l_debug = 1) THEN
   MDEBUG( 'Sequence Count List');
END IF;
       -- Check the COUNT list sequence Step 2
       MTL_CCEOI_PROCESS_PVT.Validate_CountListSeq(
          p_api_version => 0.9,
          x_return_status => L_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          X_ErrorCode => L_errorcode,
--          p_cycle_count_header_id => p_interface_rec.cycle_count_header_id,
	  p_cycle_count_header_id => MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID,
          p_cycle_count_entry_id => p_interface_rec.cycle_count_entry_id,
	 p_count_list_sequence => p_interface_rec.count_list_sequence,
	 p_organization_id =>
	 MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID
--          p_organization_id => p_interface_rec.organization_id
       );
       --
IF (l_debug = 1) THEN
   mdebug('Return Sequence Count List='||L_return_status);
END IF;

      -- this is added for unschedule entry
      MTL_CCEOI_VAR_PVT.G_Seq_No := p_interface_rec.count_list_sequence ;
      IF L_errorcode = 65 then  -- NEW NULL count_list_sequence
        begin
	    l_derivable_item_sku := FALSE;


	    select next_user_count_sequence
	      into MTL_CCEOI_VAR_PVT.G_Seq_No
	      FROM mtl_cycle_count_headers where
	      cycle_count_header_id = MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID;


	    -- the following piece of code makes sure that count list sequence
	    -- which we just derived is not conflicting with another already
	    -- existing count list sequence that is still not closed
	    -- (not counted, counted, waiting for approval, marked for recount)
	    l_same_seq_not_closed_entries := 1;
	    MTL_CCEOI_VAR_PVT.G_Seq_No := MTL_CCEOI_VAR_PVT.G_Seq_No - 1;

	    while  (l_same_seq_not_closed_entries <> 0) loop
	       MTL_CCEOI_VAR_PVT.G_Seq_No := MTL_CCEOI_VAR_PVT.G_Seq_No + 1;
	       select count(*)
		 into l_same_seq_not_closed_entries
		 from mtl_cycle_count_entries
		 where count_list_sequence = MTL_CCEOI_VAR_PVT.G_Seq_No
		 and cycle_count_header_id =  MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID
		 and entry_status_code not in (4, 5);
	       IF (l_debug = 1) THEN
   	       mdebug(l_same_seq_not_closed_entries||' not processed requests found for count list sequence=' || MTL_CCEOI_VAR_PVT.G_Seq_No);
	       END IF;
	    end loop;

           --
IF (l_debug = 1) THEN
   MDEBUG( 'Create New Sequence ='||to_char(MTL_CCEOI_VAR_PVT.G_Seq_No));
END IF;
           --
           update mtl_cycle_count_headers
           set next_user_count_sequence = MTL_CCEOI_VAR_PVT.G_Seq_No + 1
           where cycle_count_header_id = p_interface_rec.cycle_count_header_id;
           L_errorcode := 0;
           L_return_status := FND_API.G_RET_STS_SUCCESS ;
         exception
         when others then null;
         end;
      ELSIF L_errorcode = 66 then -- new count_list_sequence not found in CCE
         L_errorcode := 0;
         L_return_status := FND_API.G_RET_STS_SUCCESS ;
IF (l_debug = 1) THEN
   MDEBUG( 'Existing New Sequence ='||to_char(MTL_CCEOI_VAR_PVT.G_Seq_No));
END IF;
	l_derivable_item_sku := FALSE;
      END IF;
      IF (l_debug = 1) THEN
         MDEBUG( 'New Sequence ='||to_char(MTL_CCEOI_VAR_PVT.G_Seq_No));
      END IF;
      -- Else condition is introduced by suresh to errored out with correct status
      IF L_errorcode <>0 AND L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 IF (l_debug = 1) THEN
   	 mdebug('Error Sequence Count List');
	 END IF;
	 GOTO end_VALIDATE;
      ELSE
	IF l_derivable_item_sku = FALSE THEN

          --
          -- Item information
          L_inventory_rec.INVENTORY_ITEM_ID :=
          p_interface_rec.INVENTORY_ITEM_ID;
          L_inventory_rec.ITEM_SEGMENT1 := p_interface_rec.ITEM_SEGMENT1;
          L_inventory_rec.ITEM_SEGMENT2 := p_interface_rec.ITEM_SEGMENT2;
          L_inventory_rec.ITEM_SEGMENT3 := p_interface_rec.ITEM_SEGMENT3;
          L_inventory_rec.ITEM_SEGMENT4 := p_interface_rec.ITEM_SEGMENT4;
          L_inventory_rec.ITEM_SEGMENT5 := p_interface_rec.ITEM_SEGMENT5;
          L_inventory_rec.ITEM_SEGMENT6 := p_interface_rec.ITEM_SEGMENT6;
          L_inventory_rec.ITEM_SEGMENT7 := p_interface_rec.ITEM_SEGMENT7;
          L_inventory_rec.ITEM_SEGMENT8 := p_interface_rec.ITEM_SEGMENT8;
          L_inventory_rec.ITEM_SEGMENT9 := p_interface_rec.ITEM_SEGMENT9;
          L_inventory_rec.ITEM_SEGMENT10 := p_interface_rec.ITEM_SEGMENT10;
          L_inventory_rec.ITEM_SEGMENT11 := p_interface_rec.ITEM_SEGMENT11;
          L_inventory_rec.ITEM_SEGMENT12 := p_interface_rec.ITEM_SEGMENT12;
          L_inventory_rec.ITEM_SEGMENT13 := p_interface_rec.ITEM_SEGMENT13;
          L_inventory_rec.ITEM_SEGMENT14 := p_interface_rec.ITEM_SEGMENT14;
          L_inventory_rec.ITEM_SEGMENT15 := p_interface_rec.ITEM_SEGMENT15;
          L_inventory_rec.ITEM_SEGMENT16 := p_interface_rec.ITEM_SEGMENT16;
          L_inventory_rec.ITEM_SEGMENT17 := p_interface_rec.ITEM_SEGMENT17;
          L_inventory_rec.ITEM_SEGMENT18 := p_interface_rec.ITEM_SEGMENT18;
          L_inventory_rec.ITEM_SEGMENT19 := p_interface_rec.ITEM_SEGMENT19;
          L_inventory_rec.ITEM_SEGMENT20 := p_interface_rec.ITEM_SEGMENT20;
          --
          -- SKU information
          L_sku_rec.REVISION := p_interface_rec.REVISION;
          L_sku_rec.LOT_NUMBER := p_interface_rec.LOT_NUMBER;
          L_sku_rec.SERIAL_NUMBER := p_interface_rec.SERIAL_NUMBER;
          --
          -- Locator information
          L_LOCATOR_REC.LOCATOR_ID := P_INTERFACE_REC.LOCATOR_ID;
          L_LOCATOR_REC.LOCATOR_SEGMENT1 := P_INTERFACE_REC.LOCATOR_SEGMENT1;
          L_LOCATOR_REC.LOCATOR_SEGMENT2 := P_INTERFACE_REC.LOCATOR_SEGMENT2;
          L_LOCATOR_REC.LOCATOR_SEGMENT3 := P_INTERFACE_REC.LOCATOR_SEGMENT3;
          L_LOCATOR_REC.LOCATOR_SEGMENT4 := P_INTERFACE_REC.LOCATOR_SEGMENT4;
          L_LOCATOR_REC.LOCATOR_SEGMENT5 := P_INTERFACE_REC.LOCATOR_SEGMENT5;
          L_LOCATOR_REC.LOCATOR_SEGMENT6 := P_INTERFACE_REC.LOCATOR_SEGMENT6;
          L_LOCATOR_REC.LOCATOR_SEGMENT7 := P_INTERFACE_REC.LOCATOR_SEGMENT7;
          L_LOCATOR_REC.LOCATOR_SEGMENT8 := P_INTERFACE_REC.LOCATOR_SEGMENT8;
          L_LOCATOR_REC.LOCATOR_SEGMENT9 := P_INTERFACE_REC.LOCATOR_SEGMENT9;
          L_LOCATOR_REC.LOCATOR_SEGMENT10 := P_INTERFACE_REC.LOCATOR_SEGMENT10;
          L_LOCATOR_REC.LOCATOR_SEGMENT11 := P_INTERFACE_REC.LOCATOR_SEGMENT11;
          L_LOCATOR_REC.LOCATOR_SEGMENT12 := P_INTERFACE_REC.LOCATOR_SEGMENT12;
          L_LOCATOR_REC.LOCATOR_SEGMENT13 := P_INTERFACE_REC.LOCATOR_SEGMENT13;
          L_LOCATOR_REC.LOCATOR_SEGMENT14 := P_INTERFACE_REC.LOCATOR_SEGMENT14;
          L_LOCATOR_REC.LOCATOR_SEGMENT15 := P_INTERFACE_REC.LOCATOR_SEGMENT15;
          L_LOCATOR_REC.LOCATOR_SEGMENT16 := P_INTERFACE_REC.LOCATOR_SEGMENT16;
          L_LOCATOR_REC.LOCATOR_SEGMENT17 := P_INTERFACE_REC.LOCATOR_SEGMENT17;
          L_LOCATOR_REC.LOCATOR_SEGMENT18 := P_INTERFACE_REC.LOCATOR_SEGMENT18;
          L_LOCATOR_REC.LOCATOR_SEGMENT19 := P_INTERFACE_REC.LOCATOR_SEGMENT19;
          L_LOCATOR_REC.LOCATOR_SEGMENT20 := P_INTERFACE_REC.LOCATOR_SEGMENT20;

	-- subinventory info
	  L_subinventory := p_interface_rec.subinventory;

	ELSE  -- if can derive item and sku info

	   IF (l_debug = 1) THEN
   	   MDEBUG('Validate_CountRequest: Derived item id: ' || 	  L_INVENTORY_REC.inventory_item_id);
	   END IF;

	  l_inventory_rec.inventory_item_id :=
		MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.inventory_item_id;

	  l_sku_rec.revision :=
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.REVISION;

	  l_sku_rec.lot_number :=
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.LOT_NUMBER;

	  l_sku_rec.serial_number :=
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.SERIAL_NUMBER;

	  l_locator_rec.locator_id :=
		MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.locator_id;

	  l_subinventory :=
		MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.subinventory;

	END IF;  -- IF l_derivable_item_sku = FALSE


          --
IF (l_debug = 1) THEN
   mdebug('Check ITEM SKU');
END IF;
          -- Check the item AND SKU information Step 3
          MTL_CCEOI_PROCESS_PVT.Validate_ItemSKU(
	     p_api_version => 0.9,
             x_return_status => L_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             x_ErrorCode => L_errorcode,
             p_cycle_count_header_id => mtl_cceoi_var_pvt.g_cc_header_id,
             p_inventory_item_rec => L_inventory_rec,
             p_sku_rec => L_sku_rec,
             p_subinventory => L_subinventory,
             p_locator_rec => L_locator_rec,
	     p_organization_id =>
	    MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID,
	    p_simulate => l_simulate
--             p_organization_id => p_interface_rec.organization_id
          );
          --
          IF L_errorcode<>0 AND L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Error ItemSKU');
END IF;

             GOTO end_VALIDATE;
          END IF;
       END IF;
       --
      IF (l_debug = 1) THEN
         MDEBUG( 'Just before Validate for processing');
         MDEBUG( 'validation_level='||p_validation_level);
      END IF;

      -- BEGIN INVCONV
      OPEN cur_get_item_attr
      (
          MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID,
	  MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID
      );

      FETCH cur_get_item_attr
       INTO MTL_CCEOI_VAR_PVT.g_tracking_quantity_ind,
            MTL_CCEOI_VAR_PVT.g_secondary_default_ind,
            MTL_CCEOI_VAR_PVT.g_secondary_uom_code,
            MTL_CCEOI_VAR_PVT.g_process_costing_enabled_flag,
            MTL_CCEOI_VAR_PVT.g_process_enabled_flag;

      CLOSE cur_get_item_attr;
      -- END INVCONV

       IF p_validation_level = 1 THEN
          --
IF (l_debug = 1) THEN
   mdebug('Valdite for processing');
END IF;

/*mdebug('UOMQuantity');
IF (l_debug = 1) THEN
   mdebug('msg_data'||x_msg_data);
   mdebug('return'||L_return_status);
   mdebug('count'||to_char(x_msg_count));
   mdebug('L_errorcode'||to_char(L_errorcode));
   mdebug('PrQTY'||to_char(p_interface_rec.primary_uom_quantity));
   mdebug('count_uom'||p_interface_rec.count_uom);
   mdebug('count_unit_of_measure'||p_interface_rec.count_unit_of_measure);
   mdebug('ORGANIZATION_ID'||to_char(MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID));
   mdebug('NVENTORY_ITEM_ID'||to_char(MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID));
   mdebug('count_quantity'||to_char(p_interface_rec.count_quantity));
   mdebug('SERIAL_NUMBER'||MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER);
   mdebug('subinventory'||p_interface_rec.subinventory);
   mdebug('REVISION'||MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION);
   mdebug('LOT_NUMBER'||MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER);
   mdebug('system_quantity'||to_char(p_interface_rec.system_quantity));
END IF;
*/          -- Check the UOM AND quantity information Step 4
          MTL_CCEOI_PROCESS_PVT.Validate_UOMQuantity(
             p_api_version => 0.9,
             x_return_status => L_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             x_ErrorCode => L_errorcode,
             p_primary_uom_quantity=>p_interface_rec.primary_uom_quantity,
             p_count_uom=> p_interface_rec.count_uom,
             p_count_unit_of_measure=>p_interface_rec.count_unit_of_measure,
             p_organization_id=>
             MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID,
             p_inventory_item_id=> MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID,
             p_count_quantity=>p_interface_rec.count_quantity,
             p_serial_number => MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER,
             p_subinventory =>  MTL_CCEOI_VAR_PVT.G_SUBINVENTORY,
             p_revision => MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION,
             p_lot_number => MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER,
             p_system_quantity => p_interface_rec.system_quantity,
             p_secondary_system_quantity => p_interface_rec.secondary_system_quantity -- INVCONV
          );
          --
IF (l_debug = 1) THEN
   mdebug('UOMQunatity Error ='||to_char(L_errorcode));
   mdebug('Errortext ='||x_msg_data);
END IF;

          IF L_errorcode <>0 AND L_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
IF (l_debug = 1) THEN
   mdebug('Error UOM Quantity');
END IF;
             GOTO end_VALIDATE;
          END IF;

          -- BEGIN INVCONV
          IF (l_debug = 1) THEN
             mdebug('Validate Secondary UOM and Quantity');
          END IF;

          MTL_CCEOI_PROCESS_PVT.Validate_SecondaryUOMQty(
              p_api_version                 => 0.9
            , x_return_status               => l_return_status
            , x_msg_count                   => x_msg_count
            , x_msg_data                    => x_msg_data
            , x_errorcode                   => l_errorcode
            , p_organization_id             => MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.ORGANIZATION_ID
            , p_inventory_item_id           => MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID
            , p_serial_number               => MTL_CCEOI_VAR_PVT.G_SKU_REC.SERIAL_NUMBER
            , p_subinventory                => MTL_CCEOI_VAR_PVT.G_SUBINVENTORY
            , p_revision                    => MTL_CCEOI_VAR_PVT.G_SKU_REC.REVISION
            , p_lot_number                  => MTL_CCEOI_VAR_PVT.G_SKU_REC.LOT_NUMBER
            , p_secondary_uom               => p_interface_rec.secondary_uom
            , p_secondary_unit_of_measure   => p_interface_rec.secondary_unit_of_measure
            , p_secondary_count_quantity    => p_interface_rec.secondary_count_quantity
            , p_secondary_system_quantity   => p_interface_rec.secondary_system_quantity
            , p_tracking_quantity_ind       => MTL_CCEOI_VAR_PVT.G_TRACKING_QUANTITY_IND
            , p_secondary_default_ind       => MTL_CCEOI_VAR_PVT.G_SECONDARY_DEFAULT_IND
          );

	  IF (l_debug = 1) THEN
             mdebug('Secondary UOM Quantity Error = '||to_char(L_errorcode));
             mdebug('Errortext = '||x_msg_data);
          END IF;

          IF L_errorcode <>0 AND L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF (l_debug = 1) THEN
                mdebug('Error Secondary UOM Quantity');
             END IF;
             GOTO end_VALIDATE;
          END IF;
	  -- END INVCONV

          --
IF (l_debug = 1) THEN
   mdebug('Count Date'  || to_char(p_interface_rec.employee_id));
END IF;
          -- Check the counter AND DATE information Step 5
          MTL_CCEOI_PROCESS_PVT.Validate_CDate_Counter(
             p_api_version => 0.9,
             x_return_status => L_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             x_ErrorCode => L_errorcode,
             p_count_date => p_interface_rec.count_date,
             p_employee_id => p_interface_rec.employee_id,
             p_employee_name => p_interface_rec.employee_full_name
          );
          --
          IF L_errorcode <>0 AND L_return_status <> FND_API.G_RET_STS_SUCCESS
          THEN
IF (l_debug = 1) THEN
   MDEBUG( 'Error Count Date '||to_char(l_errorcode));
END IF;
             GOTO end_VALIDATE;
          END IF;
       END IF;
       --
       -- if procedures returned successfully marked for deletion
       -- only if action code = Validate
       --
       <<end_VALIDATE>>
       x_return_status := L_return_status;
IF (l_debug = 1) THEN
   MDEBUG( 'Return= '||x_return_status);
   MDEBUG( 'Validation_level ='||to_number(p_validation_level));
END IF;

       --
       -- UPDATE the interface TABLE flags
       IF L_return_status = FND_API.G_RET_STS_SUCCESS
          AND p_validation_level=1 THEN
	   IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = TRUE THEN
            MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
             p_api_version => 0.9,
             x_return_status => L_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID, --p_interface_rec.cc_entry_interface_id,
	       p_flags => '2$51');
	   END IF; -- record is stored in the interface
IF (l_debug = 1) THEN
   MDEBUG( 'Successfully Validated ');
END IF;
          -- the flag means no errors, successful validated, valid
       ELSIF
          L_return_status = FND_API.G_RET_STS_SUCCESS
          AND p_validation_level=0 THEN
	   IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = TRUE THEN
            MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
             p_api_version => 0.9,
             x_return_status => L_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID, --p_interface_rec.cc_entry_interface_id,
             p_flags => '2$51');
          -- the flag means no errors,marked FOR deletion,
          -- successful validated, valid
	   END IF;
IF (l_debug = 1) THEN
   MDEBUG( 'Successfully Validated-');
END IF;
       ELSE
          -- IF error AND online, INSERT the interface RECORD
	  IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = FALSE THEN

	     IF (l_debug = 1) THEN
   	     MDEBUG('Inserting interface entry');
	     END IF;
             MTL_CCEOI_PROCESS_PVT.Insert_CCIEntry(
              p_interface_rec => p_interface_rec,
              x_return_status => L_return_status);
          END IF;
          --
          -- SET the flags
          MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
             p_api_version => 0.9,
             x_return_status => L_return_status,
             x_msg_count => x_msg_count,
             x_msg_data => x_msg_data,
             p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID, --p_interface_rec.cc_entry_interface_id,
             p_flags => '1$22');
IF (l_debug = 1) THEN
   MDEBUG( 'Processed with errors ');
END IF;
          -- the flag means errors, processed with errors, not valid
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
       --ROLLBACK TO Validate_CountRequest;
	 --
	 IF (l_debug = 1) THEN
   	 mdebug('Validate_CountRequest: Error' || sqlerrm);
	 END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       --ROLLBACK TO Validate_CountRequest;
       --
       IF (l_debug = 1) THEN
          mdebug('Validate_CountRequest: Error' || sqlerrm);
       END IF;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       --ROLLBACK TO Validate_CountRequest;
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
  -- validates and simulates records from interface table
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  Procedure ValSim_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : ValSim_CountRequest
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
    --
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
       L_return_status VARCHAR2(30);
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'ValSim_CountRequest';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT ValSim_CountRequest;
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
       L_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
       -- Delete all error records first
       MTL_CCEOI_PROCESS_PVT.Delete_CCEOIError(
          p_interface_rec.cc_entry_interface_id);
       --
       MTL_CCEOI_ACTION_PVT.Process_CountRequest
       -- Prozedur
       (p_api_version => 0.9
          , p_validation_level => 1
          -- withoutsaving
          , x_return_status => L_return_status
          , x_msg_count => x_msg_count
          , x_msg_data => x_msg_data
          , p_interface_rec => p_interface_rec
       );
       --
       IF L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --
          -- If online mode insert interface record first
	  IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = FALSE THEN
	     MTL_CCEOI_PROCESS_PVT.Insert_CCIEntry(
	       p_interface_rec => p_interface_rec,
	       x_return_status => L_return_status);
	  END IF;
          --
          MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags
          -- Prozedur
          (p_api_version => 0.9
             , x_return_status => L_return_status
             , x_msg_count => x_msg_count
             , x_msg_data => x_msg_data
             , p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID, --p_interface_rec.cc_entry_interface_id
             p_flags => '1$2$');
          -- error, processed with errors
          --
       ELSE
	IF MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = TRUE THEN
          MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags
          (p_api_version => 0.9
             , x_return_status => L_return_status
             , x_msg_count => x_msg_count
             , x_msg_data => x_msg_data
             , p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID, --p_interface_rec.cc_entry_interface_id
             p_flags => '2$6$');
          -- no error,  succesfully validated and simulated
        END IF;
       END IF;
       --
       x_return_status := L_return_status;
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
       ROLLBACK TO ValSim_CountRequest;
       --
       x_return_status := FND_API.G_RET_STS_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --
       ROLLBACK TO ValSim_CountRequest;
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       --
       FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
          , p_data => x_msg_data);
       --
       WHEN OTHERS THEN
       --
       ROLLBACK TO ValSim_CountRequest;
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
  -- Updated or inserted the interface record table
  --Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data OUT
  --parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
  PROCEDURE Update_Insert_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  x_return_status OUT NOCOPY VARCHAR2 ,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE )
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : UpdateInsert_CountRequest
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  :
    -- This PROCEDURE IS CALLED FROM Import Public API.
    -- FOR Background mode it IS possible to INSERT OR UPDATE
    -- the interface TABLE
    -- Parameters:
    --     IN    :
    --  p_api_version      IN  NUMBER (required)
    --  API Version of this procedure
    --
    --  p_init_msg_l   IN  VARCHAR2 (optional)
    --    DEFAULT = FND_API.G_FALSE,
    --
    -- p_commit           IN  VARCHAR2 (optional)
    --     DEFAULT = FND_API.G_FALSE
    --
    --  p_validation_level IN  NUMBER (optional)
    --      DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --
    --  p_interface_rec MTL_CC_ENTRIES_INTERFACE%ROWTYPE (required)
    --  the interface RECORD
    --
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
       L_dummy NUMBER := TO_NUMBER(NULL);
       L_return_status VARCHAR2(30);
       L_msg_count NUMBER;
       L_msg_data VARCHAR2(100);
       --
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'UpdateInsert_CountRequest';
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT UpdateInsert_CountRequest;
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
       L_return_status := FND_API.G_RET_STS_SUCCESS;
       --
       -- API body
       --
       -- If the validation error out, because the values
       -- are wrong the system quantity is updated to NULL
       MTL_CCEOI_ACTION_PVT.Validate_CountRequest(
       p_api_version => 0.9,
       x_msg_count => L_msg_count,
       x_msg_data => L_msg_data,
       x_return_status => x_return_status,
       p_interface_rec => p_interface_rec);
       --
    BEGIN
       SELECT cc_entry_interface_id
       INTO
          L_dummy
       FROM
          mtl_cc_entries_interface
       WHERE
          cc_entry_interface_id =
          p_interface_rec.cc_entry_interface_id;
       --
       --
       MTL_CCEOI_PROCESS_PVT.Update_CCIEntry(
          p_interface_rec => p_interface_rec
          , x_return_status => L_return_status);
       --
       IF L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_UPDATE_FAILED');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       IF (l_debug = 1) THEN
          Mdebug('Before Insert_CCIEntry');
       END IF;

       MTL_CCEOI_PROCESS_PVT.Insert_CCIEntry(
          p_interface_rec => p_interface_rec
          , x_return_status => L_return_status);
       --
       IF (l_debug = 1) THEN
          Mdebug('After Insert_CCIEntry');
       END IF;
       IF L_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INSERT_FAILED');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END;
    --
    x_return_status := L_return_status;
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
    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
    --
    x_return_status := FND_API.G_RET_STS_ERROR;
    --
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
    --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
    --
    WHEN OTHERS THEN
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    --
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data); END;
  END;
END MTL_CCEOI_ACTION_PVT;

/
