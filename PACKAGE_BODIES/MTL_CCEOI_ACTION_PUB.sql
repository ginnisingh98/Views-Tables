--------------------------------------------------------
--  DDL for Package Body MTL_CCEOI_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CCEOI_ACTION_PUB" AS
 /* $Header: INVPCCAB.pls 120.1.12010000.6 2010/01/12 06:52:10 avuppala ship $ */
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_CCEOI_ACTION_PUB';

 procedure mdebug(msg in varchar2)
 is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 begin
    --dbms_output.put_line(msg);
    inv_log_util.trace(msg , g_pkg_name || ' ',9);

 end;



 -- finds interface id of an interface record that is created for processing
 -- cycle count entry whose id is stored inside mtl_cceoi_var_pvt.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID
 -- pre: mtl_var_cceoi_pvt.g_cycle_count_entry_rec is filled out by call to
 -- mtl_cceoi_prcess_pvt.validate_countlistseq
 -- this function relies on invariant: at any time there shall be no more than
 -- one interface record that contains pointer to exported cycle count entry
 -- and at the same time is not marked for deletion and is not processed yet.
 -- note: we need to get rid of simulation mode because it breaks this rule
 function find_iface_id return number is
    cursor l_mcei_csr(p_cce_id NUMBER) is
      select cc_entry_interface_id
	from mtl_cc_entries_interface
	where cycle_count_entry_id = p_cce_id and
	(delete_flag <> 1 or delete_flag is null
	OR not (status_flag in (0,1)));

      p_cei_id NUMBER := -1;
      counter number := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 begin
    for c_rec in l_mcei_csr(mtl_cceoi_var_pvt.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID) loop
       p_cei_id := c_rec.cc_entry_interface_id;
       counter := counter + 1;
    end loop;

    if counter <> 1 then
       raise fnd_api.g_exc_unexpected_error;
    end if;

    return p_cei_id;
 end;

 PROCEDURE Unlock_CCI_Row(p_iface_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2)
 IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    update mtl_cc_entries_interface
      set
      lock_flag = 2
      , last_update_date = sysdate
      , last_updated_by = MTL_CCEOI_VAR_PVT.G_UserID
      , last_update_login = MTL_CCEOI_VAR_PVT.G_LoginID
      , request_id = MTL_CCEOI_VAR_PVT.G_RequestID
      , program_application_id = MTL_CCEOI_VAR_PVT.G_ProgramAppID
      , program_id = MTL_CCEOI_VAR_PVT.G_ProgramID
      , program_update_date = sysdate
      where
      cc_entry_interface_id = p_iface_id;

 EXCEPTION
    WHEN  OTHERS  THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
 END;


 -- derives SKU and CCE data from cycle_count_entry row into
 -- the interface row
 -- pre: p_cce_rec is a copy of valid mtl_cycle_count_entry record
 PROCEDURE derive_CCE_Info
   (
    x_iface_rec IN  OUT NOCOPY  MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE,
    p_cce_rec IN MTL_CYCLE_COUNT_ENTRIES%ROWTYPE )
 IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN

    -- organization
    x_iface_rec.organization_id := p_cce_rec.organization_id;

    -- derive item id and overwrite item_segments just in case they existed
    x_iface_rec.inventory_item_id := p_cce_rec.inventory_item_id;
    x_iface_rec.item_segment1 := null;
    x_iface_rec.item_segment2 := null;
    x_iface_rec.item_segment3 := null;
    x_iface_rec.item_segment4 := null;
    x_iface_rec.item_segment5 := null;
    x_iface_rec.item_segment6 := null;
    x_iface_rec.item_segment7 := null;
    x_iface_rec.item_segment8 := null;
    x_iface_rec.item_segment9 := null;
    x_iface_rec.item_segment10 := null;
    x_iface_rec.item_segment11 := null;
    x_iface_rec.item_segment12 := null;
    x_iface_rec.item_segment13 := null;
    x_iface_rec.item_segment14 := null;
    x_iface_rec.item_segment15 := null;
    x_iface_rec.item_segment16 := null;
    x_iface_rec.item_segment17 := null;
    x_iface_rec.item_segment18 := null;
    x_iface_rec.item_segment19 := null;
    x_iface_rec.item_segment20 := null;

    -- subinv
    x_iface_rec.subinventory := p_cce_rec.subinventory;

    -- locator
    x_iface_rec.locator_id := p_cce_rec.locator_id;
    x_iface_rec.locator_segment1 := null;
    x_iface_rec.locator_segment2 := null;
    x_iface_rec.locator_segment3 := null;
    x_iface_rec.locator_segment4 := null;
    x_iface_rec.locator_segment5 := null;
    x_iface_rec.locator_segment6 := null;
    x_iface_rec.locator_segment7 := null;
   x_iface_rec.locator_segment8 := null;
   x_iface_rec.locator_segment9 := null;
   x_iface_rec.locator_segment10 := null;
   x_iface_rec.locator_segment11 := null;
   x_iface_rec.locator_segment12 := null;
   x_iface_rec.locator_segment13 := null;
   x_iface_rec.locator_segment14 := null;
   x_iface_rec.locator_segment15 := null;
   x_iface_rec.locator_segment16 := null;
   x_iface_rec.locator_segment17 := null;
   x_iface_rec.locator_segment18 := null;
   x_iface_rec.locator_segment19 := null;
   x_iface_rec.locator_segment20 := null;

   -- revision
   x_iface_rec.revision := p_cce_rec.revision;

   -- lot
   x_iface_rec.lot_number := p_cce_rec.lot_number;

   -- serial number
   x_iface_rec.serial_number := p_cce_rec.serial_number;

   -- attributes
   x_iface_rec.attribute_category := p_cce_rec.attribute_category;
   x_iface_rec.attribute1 := p_cce_rec.attribute1;
   x_iface_rec.attribute2 := p_cce_rec.attribute2;
   x_iface_rec.attribute3 := p_cce_rec.attribute3;
   x_iface_rec.attribute4 := p_cce_rec.attribute4;
   x_iface_rec.attribute5 := p_cce_rec.attribute5;
   x_iface_rec.attribute6 := p_cce_rec.attribute6;
   x_iface_rec.attribute7 := p_cce_rec.attribute7;
   x_iface_rec.attribute8 := p_cce_rec.attribute8;
   x_iface_rec.attribute9 := p_cce_rec.attribute9;
   x_iface_rec.attribute10 := p_cce_rec.attribute10;
   x_iface_rec.attribute11 := p_cce_rec.attribute11;
   x_iface_rec.attribute12 := p_cce_rec.attribute12;
   x_iface_rec.attribute13 := p_cce_rec.attribute13;
   x_iface_rec.attribute14 := p_cce_rec.attribute14;
   x_iface_rec.attribute15 := p_cce_rec.attribute15;

   -- account
   x_iface_rec.adjustment_account_id := mtl_cceoi_var_pvt.g_cycle_count_header_rec.inventory_adjustment_account;
   x_iface_rec.account_segment1 := null;
   x_iface_rec.account_segment2 := null;
   x_iface_rec.account_segment3 := null;
   x_iface_rec.account_segment4 := null;
   x_iface_rec.account_segment5 := null;
   x_iface_rec.account_segment6 := null;
   x_iface_rec.account_segment7 := null;
   x_iface_rec.account_segment8 := null;
   x_iface_rec.account_segment9 := null;
   x_iface_rec.account_segment10 := null;
   x_iface_rec.account_segment11 := null;
   x_iface_rec.account_segment12 := null;
   x_iface_rec.account_segment13 := null;
   x_iface_rec.account_segment14 := null;
   x_iface_rec.account_segment15 := null;
   x_iface_rec.account_segment16 := null;
   x_iface_rec.account_segment17 := null;
   x_iface_rec.account_segment18 := null;
   x_iface_rec.account_segment19 := null;
   x_iface_rec.account_segment20 := null;
   x_iface_rec.account_segment21 := null;
   x_iface_rec.account_segment22 := null;
   x_iface_rec.account_segment23 := null;
   x_iface_rec.account_segment24 := null;
   x_iface_rec.account_segment25 := null;
   x_iface_rec.account_segment26 := null;
   x_iface_rec.account_segment27 := null;
   x_iface_rec.account_segment28 := null;
   x_iface_rec.account_segment29 := null;
   x_iface_rec.account_segment30 := null;

   -- cycle count header id?
   x_iface_rec.cycle_count_header_id := p_cce_rec.cycle_count_header_id;

   -- cycle count entry id is already derived
   x_iface_rec.cycle_count_entry_id := p_cce_rec.cycle_count_entry_id;

END;

-- this procedure gets called for interface records that are not
-- connected to cycle_count_enrty yet, and it makes sure that
-- either data in the interface correspond to an existing unexported
-- cycle count entry or that the data in the interface does not correspond
-- to any existing entries. If the interface record corresponds to some
-- open entry in mtl_cycle_count_entries then this entry is going
-- to be exported and interface record fields that can be derived from
-- cycle_count_entry will be overwritten by data from there.
PROCEDURE Enforce_SKU_CountEntry_Match
  (p_api_version IN NUMBER,
   p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status OUT NOCOPY VARCHAR2 ,
   x_errorcode OUT NOCOPY NUMBER,
   x_msg_count OUT NOCOPY NUMBER ,
   x_msg_data OUT NOCOPY VARCHAR2 ,
   x_iface_rec IN OUT NOCOPY MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE)
IS
   l_api_version number := 0.9;
   l_api_name VARCHAR2(30) := 'Enforce_SKU_CountEntry_Match';

   cursor l_mcce_csr(p_cce_id in number) is
     select *
       from mtl_cycle_count_entries
       where cycle_count_entry_id = p_cce_id
       for update of export_flag;

     counter number := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   SAVEPOINT Enforce_SKU_CountEntry_Match;
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
   x_errorcode := 0;
   --
   -- API body
   --

   if (x_iface_rec.cycle_count_entry_id is null) then

      mtl_cceoi_process_pvt.Validate_CHeader
	(
	p_api_version => 0.9,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data,
	x_return_status => x_return_status,
	x_errorcode => x_errorcode,
	p_cycle_count_header_id => x_iface_rec.cycle_count_header_id,
	p_cycle_count_header_name => x_iface_rec.cycle_count_header_name
	);

      if (x_return_status <> fnd_api.g_ret_sts_success) then
	 raise fnd_api.g_exc_error;
      end if;

      mtl_cceoi_process_pvt.Validate_CountListSeq
	(
	p_api_version => 0.9,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data,
	x_return_status => x_return_status,
	x_errorcode => x_errorcode,
	p_cycle_count_header_id => MTL_CCEOI_VAR_PVT.G_CC_HEADER_ID,
	p_cycle_count_entry_id => x_iface_rec.cycle_count_entry_id,
	p_count_list_sequence => x_iface_rec.count_list_sequence,
	p_organization_id =>
	MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_HEADER_REC.organization_id);

      if (x_return_status <> fnd_api.g_ret_sts_success) then
	 raise fnd_api.g_exc_error;
      end if;

      -- if no record found then stop verification, there is no record
      -- that we can lock
      if (x_errorcode in (65, 66)) then
	 x_errorcode := 0;
	 return;
      end if;

      -- if we're here that means we have found a corresponding entry
      -- in the cycle count
      x_iface_rec.cycle_count_entry_id :=
	mtl_cceoi_var_pvt.g_cycle_count_entry_rec.cycle_count_entry_id;
   end if;

   for c_rec in l_mcce_csr(x_iface_rec.cycle_count_entry_id) loop

      -- fatal error since entry was exported by someone else
      if (c_rec.export_flag = 1) then
         IF (l_debug = 1) THEN
            mdebug('fatal error: exported by someone else');
         END IF;
 	 FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_ENTRY_EXPORTED');
	 FND_MSG_PUB.Add;
	 x_errorcode := 201;
	 RAISE FND_API.G_EXC_ERROR;
      end if;


      if (not (c_rec.entry_status_code in (1,3))) then
	 FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_ENTRY_STATUS_NA');
	 FND_MSG_PUB.Add;
	 x_errorcode := 202;
	 RAISE FND_API.G_EXC_ERROR;
      end if;

      -- TODO: print warning about deriving stuff

      derive_CCE_Info(x_iface_rec => x_iface_rec, p_cce_rec => c_rec);

      if (x_iface_rec.action_code <> mtl_cceoi_var_pvt.g_valsim) then
         IF (l_debug = 1) THEN
            mdebug('Exporting: ' || to_char(x_iface_rec.cycle_count_entry_id));
         END IF;
	 mtl_cceoi_process_pvt.Set_CCExport(
	   p_api_version => 0.9,
	   x_msg_data => x_msg_data,
	   x_msg_count => x_msg_count,
	   x_return_status => x_return_status,
	   p_cycle_count_entry_id => x_iface_rec.cycle_count_entry_id,
	   p_export_flag => 1);

	 if (x_return_status <> fnd_api.g_ret_sts_success) then
	    raise fnd_api.g_exc_unexpected_error;
	 end if;

      end if;

      counter := counter + 1;
   end loop;

   -- if user provided cycle_count_entry_id does not correspond
   -- to anything report an error
   if (counter = 0) then
      FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_NO_CCE_WITH_CCEID');
      FND_MSG_PUB.Add;
      x_errorcode := 203;
      raise fnd_api.g_exc_error;
   end if;


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
     ROLLBACK TO Enforce_SKU_CountEntry_Match;

     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     ROLLBACK TO Enforce_SKU_CountEntry_Match;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_errorcode := -1;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
   WHEN OTHERS THEN
     --
     ROLLBACK TO Enforce_SKU_CountEntry_Match;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_errorcode := -1;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
END;



PROCEDURE Initial_Insert
  (p_api_version IN NUMBER,
   p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
   x_return_status OUT NOCOPY VARCHAR2 ,
   x_errorcode OUT NOCOPY NUMBER,
   x_msg_count OUT NOCOPY NUMBER ,
   x_msg_data OUT  NOCOPY VARCHAR2 ,
   x_iface_rec IN OUT NOCOPY MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE)
IS
    -- Start OF comments
    -- API name  : Initial_Insert
    -- TYPE      : Private
    -- Pre-reqs  : None

    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --                API Version of this procedure
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                           DEFAULT = FND_API.G_FALSE,
    --             p_commit           IN  VARCHAR2 (optional)
    --                           DEFAULT = FND_API.G_FALSE,
    --             p_validation_level IN  NUMBER (optional)
    --                           DEFAULT = FND_API.G_VALID_LEVEL_FULL,
    --     OUT   : X_return_status    OUT NUMBER
    --                Result of all the operations
    --             x_msg_count        OUT NUMBER,
    --             x_msg_data         OUT VARCHAR2,
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the Error status

   --     IN OUT:        x_iface_rec    IN  OUT CCEOI_Rec_Type (required)
    --                complete interface RECORD
    --
    -- Version: Current Version 0.9
    --          Initial version 0.9
   -- Notes  : Attempts to insert and lock passed to it p_iface_rec
   -- into the mtl_cc_entries_interface table. If the interface record
   -- corresponds to an existing count request in mtl_cycle_count_entries
   -- then the count entry will be marked as exported unless it was already
   -- exported. If count entry is already exported that would mean that it
   -- is exported by a different interface record in which case interface
   -- record is not inserted. If count entry os not exported then the SKU,
   -- attribures, and account info will be derived from it, and that data
   -- will copied into x_iface_rec and also inserted into a table
    -- END OF comments

   l_api_version number := 0.9;
   l_api_name VARCHAR2(30) := 'Initial_Insert';

   CURSOR l_mcei_csr(ccei_id in number) is
     select *
     from mtl_cc_entries_interface
     where cc_entry_interface_id = ccei_id
     for update of lock_flag;

     counter NUMBER := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   SAVEPOINT Initial_Insert;
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
   x_errorcode := 0;
   --
   -- API body
   --

   if (x_iface_rec.cc_entry_interface_id is not null) then
      IF (l_debug = 1) THEN
         mdebug('cc_entry interface not null');
      END IF;
      -- if record is in the interface already
      for c_rec in l_mcei_csr(x_iface_rec.cc_entry_interface_id) loop

	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID :=
	   x_iface_rec.cc_entry_interface_id;

	 if (c_rec.lock_flag = 1) then

	    FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_IFACE_ROW_LOCKED');
	    FND_MSG_PUB.Add;
	    x_errorcode := 200;
	    RAISE FND_API.G_EXC_ERROR;

	 end if;

	 if (c_rec.delete_flag = 1) then
	    FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_IFACE_MARKED_DELETED');
	    FND_MSG_PUB.Add;
	    x_errorcode := 204;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;

	 if (c_rec.status_flag in (0, 1)) then
	    FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_IFACE_STATUS_DONE');
	    FND_MSG_PUB.Add;
	    x_errorcode := 206;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;

	 if (nvl(c_rec.process_flag,1) = 2) then
	    FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_IFACE_NOT_READY');
	    FND_MSG_PUB.Add;
	    x_errorcode := 207;
	    RAISE FND_API.G_EXC_ERROR;
	 end if;

	 -- if interface record is already linked to mtl_cycle_count_entries
	 if (c_rec.cycle_count_entry_id is not null) then

	    -- we may want to warn about updating only count info
	    x_iface_rec.cycle_count_entry_id := c_rec.cycle_count_entry_id;
	    x_iface_rec.lock_flag := 1;

	    mtl_cceoi_process_pvt.Update_CCIEntry(x_iface_rec,x_return_status);

	    if (x_return_status <> fnd_api.g_ret_sts_success) then
	       raise fnd_api.g_exc_unexpected_error;
	    end if;

	    -- synchronize interface record in memory with interface record
	    -- in the table
	    --	    derive count list sequence from table data in case it
	    -- was null
	    x_iface_rec.count_list_sequence := c_rec.count_list_sequence;
	    x_iface_rec.cycle_count_header_id := c_rec.cycle_count_header_id;
	    x_iface_rec.organization_id := c_rec.organization_id;
	    x_iface_rec.inventory_item_id := c_rec.inventory_item_id;
	    x_iface_rec.subinventory := c_rec.subinventory;
	    x_iface_rec.locator_id := c_rec.locator_id;
	    x_iface_rec.lot_number := c_rec.lot_number;
	    x_iface_rec.revision := c_rec.revision;  -- Bug 7504490
	    x_iface_rec.serial_number := c_rec.serial_number;
	    x_iface_rec.parent_lpn_id := c_rec.parent_lpn_id;
	    x_iface_rec.outermost_lpn_id := c_rec.outermost_lpn_id;
	    x_iface_rec.cost_group_id := c_rec.cost_group_id;

	 else  --
	    -- this procedure will try to export corresponding cycle count
	    -- entry and derive id's from there
	    Enforce_SKU_CountEntry_Match(
	      p_api_version=>0.9,
	      x_msg_data => x_msg_data,
	      x_msg_count => x_msg_count,
	      x_errorcode => x_errorcode,
	      x_return_status => x_return_status,
	      x_iface_rec => x_iface_rec);

	    if (x_return_status <> fnd_api.g_ret_sts_success) then
	       -- only raise exception and rollback if record cannot be
	       -- inserted into the interface (errors > 200)
	       if (x_errorcode < 0) then
 		  raise fnd_api.g_exc_unexpected_error;
	       elsif (x_errorcode >= 200) then
		  raise fnd_api.g_exc_error;
	       else
		  x_errorcode := 0;
		  x_return_status := fnd_api.g_ret_sts_success;
	       end if;
	    end if;


	    x_iface_rec.valid_flag := 2;--c_rec.valid_flag;
	    x_iface_rec.status_flag := c_rec.status_flag;
	    x_iface_rec.error_flag := c_rec.error_flag;
	    x_iface_rec.lock_flag := 1;
	    x_iface_rec.cycle_count_header_id := mtl_cceoi_var_pvt.g_cc_header_id;

	    mtl_cceoi_process_pvt.Update_CCIEntry(x_iface_rec,x_return_status);

	    if (x_return_status <> fnd_api.g_ret_sts_success) then
	       raise fnd_api.g_exc_unexpected_error;
	    end if;
	 end if;


	 counter := counter + 1;
      end loop;
   end if;

   if (counter = 0) then
      if (x_iface_rec.cc_entry_interface_id is null) then

	 SELECT MTL_CC_ENTRIES_INTERFACE_S1.nextval
	   INTO x_iface_rec.cc_entry_interface_id
	   FROM dual;

	 MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID :=
	   x_iface_rec.cc_entry_interface_id;
	 MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM := FALSE;

	 Enforce_SKU_CountEntry_Match(
	   p_api_version=>0.9,
	   x_msg_data => x_msg_data,
	   x_msg_count => x_msg_count,
	   x_errorcode => x_errorcode,
	   x_return_status => x_return_status,
	   x_iface_rec => x_iface_rec);

	 if (x_return_status <> fnd_api.g_ret_sts_success) then
	    -- only raise exception and rollback if record cannot be
	    -- inserted into the interface (errors > 200)
	    -- otherwise just insert record in the interface and let
	    -- errors show up during processing
	    if (x_errorcode < 0) then
	       raise fnd_api.g_exc_unexpected_error;
	    elsif (x_errorcode >= 200) then
	       raise fnd_api.g_exc_error;
	    else
	       x_errorcode := 0;
	       x_return_status := fnd_api.g_ret_sts_success;
	    end if;
	 end if;

	-- mark record to be initially valid, unprocessed, no errors, locked
	 x_iface_rec.valid_flag := 2;
	 -- if header name was supplied then mtl_cceoi_var_pvt.g_cc_header_id
	 -- contains its id, if id was supplied instead of name then
	 --  mtl_cceoi_var_pvt.g_cc_header_id is equal to that
	 -- if no id or header name was supplied then this variable is still
	 -- null
	 IF mtl_cceoi_var_pvt.g_cc_header_id IS NOT NULL THEN
	   x_iface_rec.cycle_count_header_id := mtl_cceoi_var_pvt.g_cc_header_id;
	 END IF;
	 x_iface_rec.status_flag := null;
	 x_iface_rec.error_flag := null;
	 x_iface_rec.lock_flag := 1;

	 mtl_cceoi_process_pvt.Insert_CCIEntry(x_iface_rec, x_return_status);

	 if (x_return_status <> fnd_api.g_ret_sts_success) then
	    -- some exotic error or one of the non-null columns is missing
	    raise fnd_api.g_exc_unexpected_error;
	 end if;

      else
	 FND_MESSAGE.Set_Name('INV', 'INV_CCEOI_INVALID_CEI_ID');
	 FND_MSG_PUB.Add;
	 x_errorcode := 205;
	 raise fnd_api.g_exc_error;
      end if;
   end if;

   --
   MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM := TRUE;  -- XXX do not need this anymore
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
     ROLLBACK TO Initial_Insert;

     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     ROLLBACK TO Initial_Insert;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_errorcode := -1;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
     --
   WHEN OTHERS THEN
     --
     ROLLBACK TO Initial_Insert;
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_errorcode := -1;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
       , p_data => x_msg_data);
END;



  --
  -- Online processing for one record
  PROCEDURE Import_CountRequest(
  p_api_version IN NUMBER ,
  p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  X_return_status OUT NOCOPY VARCHAR2 ,
  x_errorcode OUT NOCOPY NUMBER,
  x_msg_count OUT NOCOPY NUMBER ,
  x_msg_data OUT  NOCOPY VARCHAR2 ,
  p_interface_rec IN MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE,
  x_interface_id OUT NOCOPY NUMBER)
  IS

     l_return_status VARCHAR2(1);
     l_result 	     NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Start OF comments
    -- API name  : Import_CountRequest
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  :
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
    --
    -- Version: Current Version 0.9
    --              Changed
    -- Previous Version Y.X
    --          Initial version 0.9
    -- Notes  : Note text
    -- END OF comments
    DECLARE
       L_api_version CONSTANT NUMBER := 0.9;
       L_api_name CONSTANT VARCHAR2(30) := 'Import_CountRequest';
       L_CCEOIId NUMBER;
       L_interface_rec MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE;
       L_id NUMBER;
    BEGIN
       -- Standard start of API savepoint
       SAVEPOINT Import_CountRequest_PUB;
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
       IF (l_debug = 1) THEN
          mdebug('Process: Import_CountRequest');
       END IF;

      --reset global variables
      MTL_CCEOI_PROCESS_PVT.Reset_Global_Vars;

      --
      L_interface_rec := p_interface_rec;

      --Validate Cost Group
      IF (L_interface_rec.cost_group_id IS NOT NULL) THEN
        l_result := INV_VALIDATE.Cost_Group(L_interface_rec.cost_group_id, L_interface_rec.organization_id);
        IF (l_result = INV_Validate.F) THEN
          IF (l_debug = 1) THEN
             mdebug('invalid cost group id or cost group name');
          END IF;
          FND_MESSAGE.SET_NAME('INV', 'INV_INT_CSTEXT');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      --Set Cost Group ID Global variable
      MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID := p_interface_rec.cost_group_id;

      --Set Cost Group ID Global variable
      MTL_CCEOI_VAR_PVT.G_COST_GROUP_ID := p_interface_rec.cost_group_id;

       -- check for locks, exports / derive necessary data from cc entry
       -- so that we do not store junk

       Initial_Insert(
	 p_api_version => 0.9,
	 x_return_status => x_return_status,
	 x_errorcode => x_errorcode,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data,
	 x_iface_rec => L_interface_rec );

       if (x_errorcode = 201) then
	  l_interface_rec.cc_entry_interface_id := find_iface_id;

	  Initial_Insert(
	    p_api_version => 0.9,
	    x_return_status => x_return_status,
	    x_errorcode => x_errorcode,
	    x_msg_count => x_msg_count,
	    x_msg_data => x_msg_data,
	    x_iface_rec => L_interface_rec );
       end if;

       if (x_return_status <> fnd_api.g_ret_sts_success) then
	  IF (l_debug = 1) THEN
   	  mdebug('initial_insert errocode='||x_errorcode);
	  END IF;
	  if (x_return_status = fnd_api.g_ret_sts_unexp_error) then
	     raise FND_API.g_exc_error;
	  else
	     raise fnd_api.g_exc_unexpected_error;
	  end if;
       end if;


--       IF (p_interface_rec.process_mode = 1) then -- online mode
	  IF
	    P_interface_rec.action_code = MTL_CCEOI_VAR_PVT.G_VALIDATE THEN
	     MTL_CCEOI_ACTION_PVT.Validate_CountRequest(
	       p_api_version => 0.9
	       , p_init_msg_list => FND_API.G_TRUE
	       , x_return_status => x_return_status
	       , x_msg_count => x_msg_count
	       , x_msg_data => x_msg_data
	       , p_interface_rec => L_interface_rec);
	  ELSIF
	    P_interface_rec.action_code = MTL_CCEOI_VAR_PVT.G_CREATE THEN
	     MTL_CCEOI_ACTION_PVT.Create_CountRequest(
	       p_api_version => 0.9
	       , p_init_msg_list => FND_API.G_TRUE
	       , x_return_status => x_return_status
	       , x_msg_count => x_msg_count
	       , x_msg_data => x_msg_data
	       , p_interface_rec => L_interface_rec);
	  ELSIF
	    P_interface_rec.action_code = MTL_CCEOI_VAR_PVT.G_VALSIM THEN
	     MTL_CCEOI_ACTION_PVT.ValSim_CountRequest(
	       p_api_version => 0.9
	       , p_init_msg_list => FND_API.G_TRUE
	       , x_return_status => x_return_status
	       , x_msg_count => x_msg_count
	       , x_msg_data => x_msg_data
	       , p_interface_rec => L_interface_rec);
	  ELSIF
	    P_interface_rec.action_code = MTL_CCEOI_VAR_PVT.G_PROCESS THEN

	     MTL_CCEOI_ACTION_PVT.Process_CountRequest(
	       p_api_version => 0.9
	       , p_init_msg_list => FND_API.G_TRUE
	       , x_return_status => x_return_status
	       , x_msg_count => x_msg_count
	       , x_msg_data => x_msg_data
		 , p_interface_rec => L_interface_rec);

	  ELSE
	     -- invalid action code
	     -- insert record into the interface table if necessary and
	     -- set an error


		FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_UNKNOWN_ACTION_CODE');
		FND_MSG_PUB.Add;

		if (MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM = FALSE) THEN

		   -- this is a really dangerous call since
		   -- some of the mandatory fields may be null in which case
		   -- insert will raise an exception
		   MTL_CCEOI_PROCESS_PVT.Insert_CCIEntry(
		     p_interface_rec => p_interface_rec,
		     x_return_status => x_return_status);
		end if;

		MTL_CCEOI_PROCESS_PVT.Insert_CCEOIError(
		  p_cc_entry_interface_id =>
		  MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
		  p_error_column_name =>  'ACTION_CODE'
		  , p_error_table_name => 'MTL_CC_ENTRIES_INTERFACE_ID'
		  , p_message_name => 'INV_CCEOI_UNKNOWN_ACTION_CODE');

		x_return_status := FND_API.G_RET_STS_ERROR;

	  END IF;



	  IF (l_debug = 1) THEN
   	  mdebug('return_status: ' || x_return_status);
	  END IF;

	  --
	  -- If the record exists in database and the record is processed successful
	  -- mark it for deletion, and unexport the record from MCCE
	  -- if necessary
	  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	     --	     if (mtl_cceoi_var_pvt.g_rec_in_system) then
	     -- it is unnecessary to mark it for deletion since
	     -- it will be deleted by purge if status_flag in (0,1)
/*		MTL_CCEOI_PROCESS_PVT.Set_CCEOIFlags(
		  p_api_version => 0.9
		  , p_init_msg_list => FND_API.G_TRUE
		  , x_return_status => x_return_status
		  , x_msg_count => x_msg_count
		  , x_msg_data => x_msg_data
		  , p_cc_entry_interface_id => MTL_CCEOI_VAR_PVT.G_CC_ENTRY_INTERFACE_ID,
		  --=>L_interface_rec.cc_entry_interface_id,
		  p_flags => '$1$$');

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	--     end if;
	     */

	     -- need to unexport record if it was exported unless it was in
	     -- simulate mode in which case cce record was not exported
	     -- or validate in which case it should stay exported
	     if ((l_interface_rec.action_code not in
	     (mtl_cceoi_var_pvt.g_valsim, mtl_cceoi_var_pvt.g_validate))
	       AND ( MTL_CCEOI_VAR_PVT.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID is not null )) then
		-- record must have been exported in order
		-- to be processed, unless it is just validation
		-- an of unscheduled entry in which case
		-- no cycle count entry id will exist
		mtl_cceoi_process_pvt.Set_CCExport(
		  p_api_version => 0.9,
		  x_return_status => x_return_status,
		  x_msg_data => x_msg_data,
		  x_msg_count => x_msg_count,
		  p_cycle_count_entry_id => mtl_cceoi_var_pvt.G_CYCLE_COUNT_ENTRY_REC.CYCLE_COUNT_ENTRY_ID,
		  p_export_flag => null);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

	     end if;

	  END IF;


--       END IF;
       --Before unlocking record, updating the item id, locator id
       -- into the interface table, which are missing
       IF MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID is not null and
          mtl_cceoi_var_pvt.g_cc_entry_interface_id is not null
       THEN
          begin
             update mtl_cc_entries_interface
             set inventory_item_id = MTL_CCEOI_VAR_PVT.G_INVENTORY_ITEM_ID,
                 locator_id        = MTL_CCEOI_VAR_PVT.G_LOCATOR_ID
             where cc_entry_interface_id = mtl_cceoi_var_pvt.g_cc_entry_interface_id
             and   inventory_item_id is null;
          exception
          when others then null;
          end;
       END IF;
       -- no matter whether we were successful or not
       -- we want to unlock the interface row
       Unlock_CCI_Row(
	 l_interface_rec.cc_entry_interface_id,
	 l_return_status);

       if (l_return_status <> fnd_api.g_ret_sts_success) then
	  raise fnd_api.g_exc_unexpected_error;
       end if;

       -- use a different x_return_status


       x_interface_id := mtl_cceoi_var_pvt.g_cc_entry_interface_id;
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
	 ROLLBACK TO Import_CountRequest_PUB;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 IF (l_debug = 1) THEN
   	 mdebug('Exception: ' || sqlerrm);
	 END IF;
       FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
	 , p_data => x_msg_data);


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 ROLLBACK TO Import_CountRequest_PUB;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 x_errorcode := -1;
	 IF (l_debug = 1) THEN
   	 mdebug('Unexp-Exception: ' || sqlerrm);
	 END IF;
       FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
	 , p_data => x_msg_data);


       WHEN OTHERS THEN
	 ROLLBACK TO Import_CountRequest_PUB;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	 IF (l_debug = 1) THEN
   	 mdebug('Other-Exception: ' || sqlerrm);
	 END IF;

	 IF FND_MSG_PUB.Check_Msg_Level(
	   FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	 END IF;

	 FND_MSG_PUB.Count_And_Get(
	   p_count => x_msg_count
	   , p_data => x_msg_data);
    END;

    --- temporary adhoc which helps concurrent programs to work properly
    --- since the only place where we set this variable is public api
    --- function that is not used by concurrent programs
    MTL_CCEOI_VAR_PVT.G_REC_IN_SYSTEM := TRUE;

END;



PROCEDURE Process_LPN_CountRequest
(
   	p_api_version 		IN 	NUMBER
,  	p_init_msg_list 	IN 	VARCHAR2 DEFAULT FND_API.G_FALSE
,  	p_commit 		IN 	VARCHAR2 DEFAULT FND_API.G_FALSE
,  	p_validation_level 	IN 	NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
,  	x_return_status 	OUT NOCOPY	VARCHAR2
,  	x_errorcode 		OUT NOCOPY	NUMBER
,  	x_msg_count 		OUT NOCOPY	NUMBER
,  	x_msg_data 		   OUT NOCOPY	VARCHAR2
,  	p_interface_rec 	IN 	MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE
,  	x_interface_id_list 	OUT NOCOPY	MTL_CCEOI_VAR_PVT.INV_CCEOI_ID_TABLE_TYPE
)
IS
 l_api_version NUMBER := 0.9;
 L_api_name VARCHAR2(30) := 'Process_LPN_CountRequest';

 l_lpn                  WMS_CONTAINER_PUB.LPN;
 l_expl_tbl		WMS_CONTAINER_PUB.WMS_Container_Tbl_Type;
 l_item_rec    		MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE := p_interface_rec;
 l_temp_int_id		NUMBER;
 l_counter		NUMBER := 0;
 l_unsched_allowed 	NUMBER;
 v_index		NUMBER;
 l_result		NUMBER;
 l_sub			VARCHAR2(30);
 l_loc_id		NUMBER;
 l_lpn_discrepancy	NUMBER := 0;
 l_previous_lpn_id	NUMBER;
 l_in_cc_entries	BOOLEAN;

 L_success_flag		NUMBER;
 L_txn_header_id	NUMBER;
 L_txn_temp_id		NUMBER;
 l_lpn_context          NUMBER;
 flag                   NUMBER; --8712932

 e_Invalid_Inputs	EXCEPTION;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   MTL_CCEOI_VAR_PVT.G_LPN_ID := NULL;
  -- Standard start of API savepoint
  SAVEPOINT Process_LPN_CountRequest;

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
  --
  -- Initialisize API return status to access
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_errorcode := 0;

  IF (l_debug = 1) THEN
     mdebug('Process: Process_LPN_CountRequest ' || to_char(p_interface_rec.cycle_count_header_id));
  END IF;

  -- Check if WMS is installed
  IF NOT WMS_INSTALL.CHECK_INSTALL( x_return_status, x_msg_count, x_msg_data, p_interface_rec.organization_id)   THEN
    IF (l_debug = 1) THEN
       mdebug('wms not installed');
    END IF;
    FND_MESSAGE.SET_NAME('INV', 'INV_WMS_NOT_INSTALLED_ERROR');
    RAISE fnd_api.g_exc_error;
  END IF;

  --No validation for performance reasons
  -- Except for header id and lpn id
  mtl_cceoi_process_pvt.Validate_CHeader
	(
	p_api_version => 0.9,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data,
	x_return_status => x_return_status,
	x_errorcode => x_errorcode,
	p_cycle_count_header_id => p_interface_rec.cycle_count_header_id,
	p_cycle_count_header_name => p_interface_rec.cycle_count_header_name
	);
      IF (x_return_status <> fnd_api.g_ret_sts_success) then
         IF (l_debug = 1) THEN
            mdebug('invalid header id');
         END IF;
         FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_HEADER');
	 raise fnd_api.g_exc_error;
      end IF;

  -- Validate LPN ID and LPN
  IF p_interface_rec.parent_lpn_id IS NOT NULL OR p_interface_rec.parent_lpn IS NOT NULL THEN
     l_lpn.lpn_id := p_interface_rec.parent_lpn_id;
     l_lpn.license_plate_number := p_interface_rec.parent_lpn;
     l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn);
     IF (l_result = INV_Validate.F) THEN
       IF (l_debug = 1) THEN
          mdebug('invalid parent lpn id or parent lpn');
       END IF;
       FND_MESSAGE.SET_NAME('INV', 'INV_WMS_CONT_INVALID_LPN');
       FND_MSG_PUB.ADD;
       RAISE e_Invalid_Inputs;
     END IF;
     -- Assing validated values to l_item_rec.
     l_item_rec.parent_lpn_id := l_lpn.lpn_id;
     l_item_rec.parent_lpn := l_lpn.license_plate_number;

     -- Mark Previous lpn id
     l_previous_lpn_id := l_lpn.lpn_id;

     -- Check for LPN subinventory discrepancy
     SELECT subinventory_code, locator_id
     INTO l_sub, l_loc_id
     FROM WMS_LICENSE_PLATE_NUMBERS
     WHERE lpn_id = l_lpn.lpn_id
     AND   organization_id = p_interface_rec.organization_id;

     IF p_interface_rec.subinventory <> l_sub OR p_interface_rec.locator_id <> l_loc_id THEN
       -- discrepancy exists
       IF (l_debug = 1) THEN
          mdebug('location discrepancy found');
       END IF;
       IF p_interface_rec.parent_lpn_id <> p_interface_rec.outermost_lpn_id THEN
         -- error out, this case not supported
         FND_MESSAGE.SET_NAME('INV', 'INV_WMS_CC_NESTED_LPN_DISCR');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSE
         -- set lpn discrepancy flag to 1 (yes)
         l_lpn_discrepancy := 1;
         -- change subinventory and locator
         l_item_rec.subinventory := l_sub;
         l_item_rec.locator_id := l_loc_id;
       END IF;
     END IF;
  END IF;

  -- Set global variables for container adjustment and discrepancies
  SELECT container_enabled_flag, container_adjustment_option, container_discrepancy_option
  INTO MTL_CCEOI_VAR_PVT.G_CONTAINER_ENABLED_FLAG, MTL_CCEOI_VAR_PVT.G_CONTAINER_ADJUSTMENT_OPTION,
       MTL_CCEOI_VAR_PVT.G_CONTAINER_DISCREPANCY_OPTION
  FROM MTL_CYCLE_COUNT_HEADERS
  WHERE cycle_count_header_id = p_interface_rec.cycle_count_header_id;
  -- If either flag is null if container enabled flag is enabled (1), set to default.
  IF MTL_CCEOI_VAR_PVT.G_CONTAINER_ENABLED_FLAG = 1 THEN
    MTL_CCEOI_VAR_PVT.G_CONTAINER_ADJUSTMENT_OPTION := NVL(MTL_CCEOI_VAR_PVT.G_CONTAINER_ADJUSTMENT_OPTION, 1);
    MTL_CCEOI_VAR_PVT.G_CONTAINER_DISCREPANCY_OPTION := NVL(MTL_CCEOI_VAR_PVT.G_CONTAINER_DISCREPANCY_OPTION, 1);
  END IF;

  --Check id interface record is an item or LPN
  IF (l_item_rec.inventory_item_id IS NOT NULL
  AND l_item_rec.parent_lpn_id IS NULL) THEN -- record is not a container

     Import_CountRequest(
  	p_api_version 		=> 0.9,
  	p_init_msg_list 	=> FND_API.G_TRUE,
  	p_commit 		=> FND_API.G_TRUE,
  	p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
  	X_return_status 	=> x_return_status,
  	x_errorcode 		=> x_errorcode,
  	x_msg_count 		=> x_msg_count,
  	x_msg_data		=> x_msg_data,
  	p_interface_rec 	=> l_item_rec,
  	x_interface_id 		=> l_temp_int_id);
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     	      IF (l_debug = 1) THEN
        	      mdebug('Import count request error');
     	      END IF;
   	      FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

        -- insert interface id into table
	x_interface_id_list(l_counter) := l_temp_int_id;
  ELSE
    IF (l_debug = 1) THEN
       mdebug('record is a container, exploding contents');
    END IF;
    -- Record is a container, thus needs to be exploded
    WMS_CONTAINER_PUB.Explode_LPN(
	p_api_version   	=> 1.0,
   	p_init_msg_list		=> fnd_api.g_true,
   	p_commit		=> fnd_api.g_true,
   	x_return_status		=> x_return_status,
   	x_msg_count		=> x_msg_count,
   	x_msg_data		=> x_msg_data,
   	p_lpn_id        	=> p_interface_rec.parent_lpn_id,
   	x_content_tbl		=> l_expl_tbl);
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              IF (l_debug = 1) THEN
                 mdebug('lpn exlpoder error');
              END IF;
   	      FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
 -- Start 8300310
     BEGIN

 	          SELECT lpn_context
 	          INTO l_lpn_context
 	          FROM wms_license_plate_numbers
 	          WHERE lpn_id = p_interface_rec.parent_lpn_id;

 	          IF l_lpn_context = 5 THEN

 	             l_expl_tbl(1).parent_lpn_id        :=  p_interface_rec.parent_lpn_id;
 	             l_expl_tbl(1).content_lpn_id       :=  NULL;
 	             l_expl_tbl(1).content_item_id      :=  p_interface_rec.inventory_item_id;
 	             l_expl_tbl(1).content_description  :=  NULL;
 	             l_expl_tbl(1).content_type         :=  '1';
 	             l_expl_tbl(1).organization_id      :=  p_interface_rec.organization_id;
 	             l_expl_tbl(1).revision             :=  p_interface_rec.revision;
 	             l_expl_tbl(1).lot_number           :=  p_interface_rec.lot_number;
 	             l_expl_tbl(1).serial_number        :=  p_interface_rec.serial_number;
 	             l_expl_tbl(1).quantity             :=  p_interface_rec.count_quantity;
 	             l_expl_tbl(1).uom                  :=  p_interface_rec.count_uom;
 	             l_expl_tbl(1).cost_group_id        :=  p_interface_rec.cost_group_id;

 	          END IF;

 	       EXCEPTION WHEN OTHERS THEN
 	          NULL;
    END;
    --  8300310 End
                  -- 8712932 Start
		  --Added code to assign the p_interface_rec values  to record type  l_expl_tbl
		  --so that counting can be done for those cases also when called through open interface.
		  flag:=0 ;
                  v_index := l_expl_tbl.FIRST;
                  WHILE v_index IS NOT NULL LOOP
                  IF Nvl(p_interface_rec.inventory_item_id,0) = Nvl(l_expl_tbl(v_index).content_item_id,0)
                  AND Nvl(p_interface_rec.lot_number,0) = Nvl(l_expl_tbl(v_index).lot_number,0)
                  AND Nvl(p_interface_rec.revision,0) = Nvl(l_expl_tbl(v_index).revision,0)
                   AND (p_interface_rec.serial_number IS NULL OR (p_interface_rec.serial_number IS NOT NULL  --Added 8314312
                        AND p_interface_rec.serial_number = Nvl(l_expl_tbl(v_index).serial_number,0))) THEN --Added 8314312
                  -- Nvl(p_interface_rec.serial_number,0) = Nvl(l_expl_tbl(v_index).serial_number,0)  THEN  --commented 8314312
                   flag  := 1 ;
                    mdebug('Records matched');
		    EXIT;
                  ELSE
                     NULL;

               END IF;

                   v_index := l_expl_tbl.NEXT(v_index);
                   END LOOP;

                 v_index := l_expl_tbl.LAST;

	     IF flag = 0 THEN
             l_expl_tbl(v_index+1).parent_lpn_id        :=  p_interface_rec.parent_lpn_id;
 	             l_expl_tbl(v_index+1).content_lpn_id       :=  NULL;
 	             l_expl_tbl(v_index+1).content_item_id      :=  p_interface_rec.inventory_item_id;
 	             l_expl_tbl(v_index+1).content_description  :=  NULL;
 	             l_expl_tbl(v_index+1).content_type         :=  '1';
 	             l_expl_tbl(v_index+1).organization_id      :=  p_interface_rec.organization_id;
 	             l_expl_tbl(v_index+1).revision             :=  p_interface_rec.revision;
 	             l_expl_tbl(v_index+1).lot_number           :=  p_interface_rec.lot_number;
 	             l_expl_tbl(v_index+1).serial_number        :=  p_interface_rec.serial_number;
 	             l_expl_tbl(v_index+1).quantity             :=  p_interface_rec.count_quantity;
 	             l_expl_tbl(v_index+1).uom                  :=  p_interface_rec.count_uom;
 	             l_expl_tbl(v_index+1).cost_group_id        :=  p_interface_rec.cost_group_id;
            END IF;
               -- 8712932 End

    -- Check if Unschedualed Entries are allowed.
    SELECT unscheduled_count_entry
    INTO   l_unsched_allowed
    FROM   mtl_cycle_count_headers
    WHERE  cycle_count_header_id = p_interface_rec.cycle_count_header_id;

    -- Loop through table for each item.
    v_index := l_expl_tbl.FIRST;
    WHILE v_index IS NOT NULL LOOP

     /* Bug 7504490 - Added the check for item and revision to create only for those parameters passed */
         IF p_interface_rec.inventory_item_id IS NULL
	    OR (p_interface_rec.inventory_item_id IS NOT NULL
	    AND (p_interface_rec.inventory_item_id = l_expl_tbl(v_index).content_item_id)) THEN
	    IF p_interface_rec.lot_number IS NULL
	       OR (p_interface_rec.lot_number IS NOT NULL
	       AND (p_interface_rec.lot_number = l_expl_tbl(v_index).lot_number)) THEN
	       IF  p_interface_rec.revision IS NULL
		   OR (p_interface_rec.revision IS NOT NULL
		   AND (p_interface_rec.revision = l_expl_tbl(v_index).revision)) THEN
		  IF  p_interface_rec.serial_number IS NULL  -- 8712932 added for serial number
		      OR (p_interface_rec.serial_number IS NOT NULL
			AND (p_interface_rec.serial_number = l_expl_tbl(v_index).serial_number)) THEN

	    IF (l_debug = 1) THEN
                  mdebug('Inside the condition');
	    END IF;

      --Check if record represents an item
      IF (l_expl_tbl(v_index).content_type = 1) THEN
        -- Check if item exist in cycle count entries table or in the cycle count items
 	-- table if unschedualed entries are allowed.
 	IF (l_debug = 1) THEN
    	mdebug('org id: ' || TO_CHAR(l_expl_tbl(v_index).organization_id));
    	mdebug('lpn id: ' || TO_CHAR(l_expl_tbl(v_index).parent_lpn_id));
    	mdebug('item id: ' || TO_CHAR(l_expl_tbl(v_index).content_item_id));
    	mdebug('cost id: ' || TO_CHAR(l_expl_tbl(v_index).cost_group_id));
    	mdebug('lot : ' || l_expl_tbl(v_index).lot_number);
    	mdebug('rev: ' || l_expl_tbl(v_index).revision);
    	mdebug('serl: ' || l_expl_tbl(v_index).serial_number);
 	END IF;

 	-- *** for testing purposes only.  remove after testing!!!
        /*  SELECT cost_group_id
          INTO  l_expl_tbl(v_index).cost_group_id
          FROM  mtl_cycle_count_entries
          WHERE organization_id  = l_expl_tbl(v_index).organization_id
          AND inventory_item_id = l_expl_tbl(v_index).content_item_id
          AND parent_lpn_id = l_expl_tbl(v_index).parent_lpn_id
          AND cycle_count_header_id = p_interface_rec.cycle_count_header_id;*/
 	  --------------------
        l_in_cc_entries := MTL_INV_UTIL_GRP.Exists_CC_Entries(	l_expl_tbl(v_index).organization_id,
        							l_expl_tbl(v_index).parent_lpn_id,
     			     		     			l_expl_tbl(v_index).content_item_id,
     			     		     			l_expl_tbl(v_index).cost_group_id,
     			     		     			l_expl_tbl(v_index).lot_number,
     			     		     			l_expl_tbl(v_index).revision,
     			     		     			l_expl_tbl(v_index).serial_number);
     	IF l_in_cc_entries OR  ( l_unsched_allowed = 1
           AND MTL_INV_UTIL_GRP.Exists_CC_Items(p_interface_rec.cycle_count_header_id,
                  				   l_expl_tbl(v_index).content_item_id) )
	THEN

	  IF l_in_cc_entries THEN
            -- Count List sequence number required for processing for schedualed entries
	    SELECT count_list_sequence
            INTO  l_item_rec.count_list_sequence
            FROM  mtl_cycle_count_entries
            WHERE organization_id  = l_expl_tbl(v_index).organization_id
            AND inventory_item_id = l_expl_tbl(v_index).content_item_id
            AND parent_lpn_id = l_expl_tbl(v_index).parent_lpn_id
            AND NVL(cost_group_id, -1) = NVL(l_expl_tbl(v_index).cost_group_id, -1)
            AND cycle_count_header_id = p_interface_rec.cycle_count_header_id
	    AND NVL(lot_number, -1) = NVL(l_expl_tbl(v_index).lot_number, -1)
            AND NVL(revision, -1) = NVL(l_expl_tbl(v_index).revision, -1)  -- Bug : 7504490
	    AND Nvl(serial_number,-1) = NVL(l_expl_tbl(v_index).serial_number, -1) -- 8712932 added for serial number
            AND entry_status_code IN (1,3);
          END IF;

	  IF l_previous_lpn_id <> l_expl_tbl(v_index).parent_lpn_id THEN
	    -- validate new lpn_id and get lpn
	    l_lpn.lpn_id := l_expl_tbl(v_index).parent_lpn_id;
	    l_lpn.license_plate_number := NULL;

	    IF (l_debug = 1) THEN
   	    mdebug('validating new parent lpn: ' || TO_CHAR(l_lpn.lpn_id));
	    END IF;
	    l_result := WMS_CONTAINER_PUB.Validate_LPN(l_lpn);
            IF (l_result = INV_Validate.F) THEN
              IF (l_debug = 1) THEN
                 mdebug('invalid parent lpn id or parent lpn');
              END IF;
              FND_MESSAGE.SET_NAME('INV', 'INV_WMS_CONT_INVALID_LPN');
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- put new lpn in record
            l_item_rec.parent_lpn_id := l_lpn.lpn_id;
            l_item_rec.parent_lpn := l_lpn.license_plate_number;
            -- Mark Previous lpn id
            l_previous_lpn_id := l_lpn.lpn_id;
	  END IF;

          IF (l_debug = 1) THEN
             mdebug('populating: ' || to_char(l_item_rec.count_list_sequence));
          END IF;
          -- populate item columns in item record
       	  l_item_rec.inventory_item_id := l_expl_tbl(v_index).content_item_id;
          l_item_rec.lot_number := l_expl_tbl(v_index).lot_number;
          l_item_rec.revision := l_expl_tbl(v_index).revision;
          l_item_rec.serial_number := l_expl_tbl(v_index).serial_number;
  	  l_item_rec.parent_lpn_id := l_expl_tbl(v_index).parent_lpn_id;
         -- l_item_rec.count_quantity := l_expl_tbl(v_index).quantity;
	 l_item_rec.count_quantity := p_interface_rec.count_quantity;  -- 8300310

  	  l_item_rec.count_uom := l_expl_tbl(v_index).uom;
	  -- BEGIN INVCONV
  	  l_item_rec.secondary_count_quantity := l_expl_tbl(v_index).sec_quantity;
  	  l_item_rec.secondary_uom := l_expl_tbl(v_index).sec_uom;
	  -- END INVCONV
  	  l_item_rec.cost_group_id := l_expl_tbl(v_index).cost_group_id;

          -- Assign count quantity to global variable
  	  MTL_CCEOI_VAR_PVT.G_LPN_ITEM_SYSTEM_QTY := l_expl_tbl(v_index).quantity;
          MTL_CCEOI_VAR_PVT.G_LPN_ITEM_SEC_SYSTEM_QTY := l_expl_tbl(v_index).sec_quantity; -- INVCONV

 	  -- Assign parent_lpn_id to global variable
 	  MTL_CCEOI_VAR_PVT.G_LPN_ID := l_expl_tbl(v_index).parent_lpn_id;

          Import_CountRequest(
  		p_api_version 		=> 0.9,
  		p_init_msg_list 	=> FND_API.G_TRUE,
  		p_commit 		=> FND_API.G_TRUE,
  		p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL,
  		X_return_status 	=> x_return_status,
  		x_errorcode 		=> x_errorcode,
  		x_msg_count 		=> x_msg_count,
  		x_msg_data		=> x_msg_data,
  		p_interface_rec 	=> l_item_rec,
  		x_interface_id 		=> l_temp_int_id);
  	  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  	      IF (l_debug = 1) THEN
     	      mdebug('LPN Import count request error');
  	      END IF;
   	      FND_FILE.PUT_LINE(FND_FILE.LOG, x_msg_data);
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

	  -- insert interface id into table
	  x_interface_id_list(l_counter) := l_temp_int_id;
	  l_counter := l_counter + 1;
        END IF;
      END IF;
      END IF; -- for serial
     END IF; -- for rev
    END IF; --for lot
   END IF;  --for item
      v_index := l_expl_tbl.NEXT(v_index);
    END LOOP;

    -- If discrepancy existed in lpn and no approval needed, then do a subinventory trasfer
    IF (l_lpn_discrepancy = 1 AND MTL_CCEOI_VAR_PVT.G_CONTAINER_ENABLED_FLAG = 1
                              AND MTL_CCEOI_VAR_PVT.G_CONTAINER_ADJUSTMENT_OPTION = 1
                              AND MTL_CCEOI_VAR_PVT.G_CONTAINER_DISCREPANCY_OPTION = 1 )THEN
      IF (l_debug = 1) THEN
         mdebug('lpn subinventory move in progress');
      END IF;

      -- Create subinventory transfer information
      SELECT mtl_material_transactions_s.nextval
      INTO   L_txn_header_id
      FROM   dual;

      -- Do a subinventory transfer
      L_success_flag := mtl_cc_transact_pkg.cc_transact(
	      org_id=> p_interface_rec.organization_id
	    , cc_header_id => p_interface_rec.cycle_count_header_id
	    , item_id => -1 --l_item_rec.inventory_item_id
	    , sub => l_sub
	    , PUOMQty=> 1
	    , TxnQty=> 1
	    , TxnUOM=> null
	    , TxnDate => MTL_CCEOI_VAR_PVT.G_count_date
	    , TxnAcctId => MTL_CCEOI_VAR_PVT.G_ADJUST_ACCOUNT_ID
	    , LotNum => NULL
	    , LotExpDate => NULL
	    , rev => NULL
	    , locator_id => l_loc_id
	    , TxnRef=> p_interface_rec.reference
	    , ReasonId=> p_interface_rec.transaction_reason_id
	    , UserId=> MTL_CCEOI_VAR_PVT.G_userid
	    , cc_entry_id=> p_interface_rec.cycle_count_header_id
	    , LoginId => MTL_CCEOI_VAR_PVT.G_LoginId
	    , TxnProcMode => 1
	    , TxnHeaderId=>L_txn_header_id
	    , SerialNum=> NULL
	    , TxnTempId=> NULL
	    , SerialPrefix=> NULL
	    , lpn_id => p_interface_rec.outermost_lpn_id
	    , transfer_sub => p_interface_rec.subinventory
	    , transfer_loc_id => p_interface_rec.locator_id
	    , cost_group_id => p_interface_rec.cost_group_id
	    );
      IF NVL(L_txn_header_id, -1) < 0 OR NVL(L_success_flag, -1) < 0 THEN
        IF (l_debug = 1) THEN
           mdebug('lpn subinventory move failed: ' || to_char(L_success_flag));
        END IF;
        FND_MESSAGE.SET_NAME('INV', 'INV_ADJ_TXN_FAILED');
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END IF;

EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
	 ROLLBACK TO Process_LPN_CountRequest;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 IF (l_debug = 1) THEN
   	 mdebug('Exception: ' || sqlerrm);
	 END IF;
       FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
	 , p_data => x_msg_data);


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 ROLLBACK TO Process_LPN_CountRequest;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 x_errorcode := -1;
	 IF (l_debug = 1) THEN
   	 mdebug('Unexp-Exception: ' || sqlerrm);
	 END IF;
       FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count
	 , p_data => x_msg_data);

       WHEN e_Invalid_Inputs THEN
  	ROLLBACK TO Process_LPN_CountRequest;
  	x_return_status := FND_API.G_RET_STS_ERROR;
  	FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

       WHEN OTHERS THEN
	 ROLLBACK TO Process_LPN_CountRequest;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 IF (l_debug = 1) THEN
   	 mdebug('Other-Exception: ' || sqlerrm);
	 END IF;

	 IF FND_MSG_PUB.Check_Msg_Level(
	   FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	 END IF;

	 FND_MSG_PUB.Count_And_Get(
	   p_count => x_msg_count
	   , p_data => x_msg_data);
END Process_LPN_CountRequest;



END MTL_CCEOI_ACTION_PUB;

/
