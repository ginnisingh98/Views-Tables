--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_NUMBER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_NUMBER_PVT" as
/* $Header: EAMVASNB.pls 120.25.12010000.2 2008/12/11 11:39:46 dsingire ship $ */
 -- Start of comments
 -- API name : EAM_ASSET_NUMBER_PVT
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_API_VERSION                 IN NUMBER       REQUIRED
 --          P_INIT_MSG_LIST               IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_COMMIT                      IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_VALIDATION_LEVEL            IN NUMBER       OPTIONAL
 --             DEFAULT = FND_API.G_VALID_LEVEL_FULL
 --          P_ROWID                       IN OUT VARCHAR2 REQUIRED
 --          P_INVENTORY_ITEM_ID           IN  NUMBER
 --          P_SERIAL_NUMBER               IN  VARCHAR2
 --          P_START_DATE_ACTIVE           IN  DATE
 --          P_DESCRIPTIVE_TEXT            IN  VARCHAR2
 --          P_ORGANIZATION_ID             IN  NUMBER
 --          P_CATEGORY_ID                 IN  NUMBER
 --          P_PN_LOCATION_ID              IN  NUMBER
 --          P_EAM_LOCATION_ID             IN  NUMBER
 --          P_FA_ASSET_ID                 IN  NUMBER
 --          P_ASSET_STATUS_CODE           IN  VARCHAR2
 --          P_ASSET_CRITICALITY_CODE      IN  VARCHAR2
 --          P_WIP_ACCOUNTING_CLASS_CODE   IN  VARCHAR2
 --          P_MAINTAINABLE_FLAG           IN  VARCHAR2
 --          P_NETWORK_ASSET_FLAG          IN  VARCHAR2
 --          P_OWNING_DEPARTMENT_ID        IN  NUMBER
 --          P_ATTRIBUTE_CATEGORY          IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE1                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE2                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE3                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE4                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE5                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE6                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE7                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE8                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE9                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE10                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE11                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE12                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE13                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE14                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE15                 IN  VARCHAR2    OPTIONAL
 --          P_LAST_UPDATE_DATE            IN  DATE        REQUIRED
 --          P_LAST_UPDATED_BY             IN  NUMBER      REQUIRED
 --          P_CREATION_DATE               IN  DATE        REQUIRED
 --          P_CREATED_BY                  IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_LOGIN           IN  NUMBER      REQUIRED
 --          P_REQUEST_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_APPLICATION_ID      IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_UPDATE_DATE         IN  DATE DEFAULT NULL
 -- OUT      X_OBJECT_ID                   OUT NUMBER
 --          X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 1.0
 --
 -- Notes    : Note text
 --
 -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_asset_number_pvt';


FUNCTION actual_value_char(p_from_public_api VARCHAR2,  p_new_value VARCHAR2, p_old_value VARCHAR2) RETURN VARCHAR2 is
result VARCHAR2(240);
BEGIN
  result := null;
  IF (p_from_public_api = 'N') THEN
    result := p_new_value;
  ELSE
    IF (p_new_value is null) THEN
      result := p_old_value;
    ELSIF (p_new_value = fnd_api.g_miss_char) THEN
      result := null;
    ELSE
      result := p_new_value;
    END IF;
  END IF;
  RETURN(result);
END;

FUNCTION actual_value_date(p_from_public_api VARCHAR2,  p_new_value date, p_old_value date) RETURN date is
result date;
BEGIN
  result := null;
  IF (p_from_public_api = 'N') THEN
    result := p_new_value;
  ELSE
    IF (p_new_value is null) THEN
      result := p_old_value;
    ELSIF (p_new_value = fnd_api.g_miss_date) THEN
      result := null;
    ELSE
      result := p_new_value;
    END IF;
  END IF;
  RETURN(result);
END;


PROCEDURE INSERT_ROW(
  P_API_VERSION                IN NUMBER,
  P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_INVENTORY_ITEM_ID             NUMBER,
  P_SERIAL_NUMBER                 VARCHAR2,
  P_INSTANCE_NUMBER		  VARCHAR2,
  P_INSTANCE_DESCRIPTION          VARCHAR2,
  P_ORGANIZATION_ID               NUMBER,
  P_CATEGORY_ID                   NUMBER,
  P_PN_LOCATION_ID                NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_FA_SYNC_FLAG		  VARCHAR2,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_NETWORK_ASSET_FLAG            VARCHAR2,
  P_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
  P_REQUEST_ID                    NUMBER   DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER   DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER   DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE     DEFAULT NULL,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_CREATION_DATE                 DATE,
  P_CREATED_BY                    NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  p_active_start_date		  DATE DEFAULT NULL,
  p_active_end_date		  DATE DEFAULT NULL,
  p_location			  NUMBER DEFAULT NULL,
  p_linear_location_id	  	  NUMBER DEFAULT NULL,
  p_operational_log_flag	  VARCHAR2 DEFAULT NULL,
  p_checkin_status		  NUMBER DEFAULT NULL,
  p_supplier_warranty_exp_date    DATE DEFAULT NULL,
  p_equipment_gen_object_id   	  NUMBER DEFAULT NULL,
  p_mfg_serial_number_flag	  VARCHAR2,
  X_OBJECT_ID OUT NOCOPY NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2
  )

  is
  	l_instance_rec          	CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
  	l_ext_attrib_values_tbl 	CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
  	l_party_tbl             	CSI_DATASTRUCTURES_PUB.PARTY_TBL;
  	l_account_tbl           	CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
  	l_pricing_attrib_tbl    	CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
  	l_org_assignments_tbl   	CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
  	l_asset_assignment_tbl  	CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
  	l_txn_rec               	CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
  	l_instance_asset_rec 		csi_datastructures_pub.instance_asset_rec;
  	l_x_return_status         	VARCHAR2(2000);
  	l_x_msg_count             	NUMBER;
  	l_x_msg_data              	VARCHAR2(2000);
  	l_x_msg_index_out       	NUMBER;
  	t_output                	VARCHAR2(2000);
  	t_msg_dummy             	NUMBER;
	l_master_organization_id	NUMBER;
	l_primary_uom_code		MTL_SYSTEM_ITEMS.primary_uom_code%type;
	l_internal_party_id		NUMBER;
	l_fa_x_return_status         	VARCHAR2(2000);
	l_fa_x_msg_count             	NUMBER;
  	l_fa_x_msg_data              	VARCHAR2(2000);

  	l_msg_index			NUMBER;
  	l_msg_count  			NUMBER;

  	  l_api_name       CONSTANT VARCHAR2(30) := 'insert_row';
  l_api_version    CONSTANT NUMBER       := 1.0;
  begin
  	  -- Standard Start of API savepoint
		SAVEPOINT insert_row;

	     -- Standard call to check for call compatibility.
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
		   RAISE fnd_api.g_exc_unexpected_error;
		END IF;

	     -- Initialize message list if p_init_msg_list is set to TRUE.
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		   fnd_msg_pub.initialize;
		END IF;

	     -- Initialize API return status to success
		x_return_status := fnd_api.g_ret_sts_success;

	     -- API body

	  l_instance_rec.instance_number := p_instance_number;
	  l_instance_rec.inventory_item_id := p_inventory_item_id;  -- replace
	  l_instance_rec.vld_organization_id := p_organization_id; -- replace

	  select master_organization_id
	  into l_master_organization_id
	  from mtl_parameters
	  where organization_id = p_organization_id;

	  l_instance_rec.inv_master_organization_id := l_master_organization_id; -- replace
	  l_instance_rec.serial_number := p_serial_number; -- replace
	  l_instance_rec.mfg_serial_number_flag := p_mfg_serial_number_flag;
	  l_instance_rec.quantity := 1;

	  select primary_uom_code into l_primary_uom_code
	  from mtl_system_items
	  where organization_id = p_organization_id
	  and inventory_item_id = p_inventory_item_id;

	  l_instance_rec.unit_of_measure := l_primary_uom_code;
	  l_instance_rec.instance_condition_id := 1;

	  l_instance_rec.active_start_date := p_active_start_date;
	  l_instance_rec.active_end_date := p_active_end_date;

	  if (p_location is null) then
	  	l_instance_rec.location_type_code := 'INTERNAL_SITE';

	  else
	  	l_instance_rec.location_type_code := 'HZ_LOCATIONS';

	  end if;
	  l_instance_rec.location_id := p_location;

	  l_instance_rec.instance_description := p_instance_description;

	  l_instance_rec.context := P_ATTRIBUTE_CATEGORY;
	  l_instance_rec.attribute1 := P_ATTRIBUTE1;
	  l_instance_rec.attribute2 := P_ATTRIBUTE2;
	  l_instance_rec.attribute3 := P_ATTRIBUTE3;
	  l_instance_rec.attribute4 := P_ATTRIBUTE4;
	  l_instance_rec.attribute5 := P_ATTRIBUTE5;
	  l_instance_rec.attribute6 := P_ATTRIBUTE6;
	  l_instance_rec.attribute7 := P_ATTRIBUTE7;
	  l_instance_rec.attribute8 := P_ATTRIBUTE8;
	  l_instance_rec.attribute9 := P_ATTRIBUTE9;
	  l_instance_rec.attribute10 := P_ATTRIBUTE10;
	  l_instance_rec.attribute11 := P_ATTRIBUTE11;
	  l_instance_rec.attribute12 := P_ATTRIBUTE12;
	  l_instance_rec.attribute13 := P_ATTRIBUTE13;
	  l_instance_rec.attribute14 := P_ATTRIBUTE14;
	  l_instance_rec.attribute15 := P_ATTRIBUTE15;
	  l_instance_rec.attribute16 := P_ATTRIBUTE16;
	  l_instance_rec.attribute17 := P_ATTRIBUTE17;
	  l_instance_rec.attribute18 := P_ATTRIBUTE18;
	  l_instance_rec.attribute19 := P_ATTRIBUTE19;
	  l_instance_rec.attribute20 := P_ATTRIBUTE20;
	  l_instance_rec.attribute21 := P_ATTRIBUTE21;
	  l_instance_rec.attribute22 := P_ATTRIBUTE22;
	  l_instance_rec.attribute23 := P_ATTRIBUTE23;
	  l_instance_rec.attribute24 := P_ATTRIBUTE24;
	  l_instance_rec.attribute25 := P_ATTRIBUTE25;
	  l_instance_rec.attribute26 := P_ATTRIBUTE26;
	  l_instance_rec.attribute27 := P_ATTRIBUTE27;
	  l_instance_rec.attribute28 := P_ATTRIBUTE28;
	  l_instance_rec.attribute29 := P_ATTRIBUTE29;
	  l_instance_rec.attribute30 := P_ATTRIBUTE30;

	  l_instance_rec.instance_usage_code := 'IN_SERVICE';

	  l_instance_rec.network_asset_flag := p_network_asset_flag;
	  l_instance_rec.maintainable_flag := p_maintainable_flag;
	  l_instance_rec.pn_location_id := p_pn_location_id;
	  l_instance_rec.asset_criticality_code := p_asset_criticality_code;
	  l_instance_rec.category_id := p_category_id;
	  l_instance_rec.equipment_gen_object_id  := p_equipment_gen_object_id;
	  l_instance_rec.linear_location_id := p_linear_location_id;
	  l_instance_rec.active_start_date := p_active_start_date;
	  l_instance_rec.active_end_date := p_active_end_date;
	  l_instance_rec.operational_log_flag := p_operational_log_flag;
	  l_instance_rec.checkin_status := p_checkin_status;
  	  l_instance_rec.supplier_warranty_exp_date := p_supplier_warranty_exp_date;

	  select internal_party_id
	  into l_internal_party_id
	  from csi_install_parameters;

	  l_party_tbl(1).party_source_table := 'HZ_PARTIES';
	  l_party_tbl(1).party_id := l_internal_party_id;
	  l_party_tbl(1).relationship_type_code := 'OWNER';
	  l_party_tbl(1).contact_flag := 'N';

	  l_txn_rec.transaction_date := sysdate;
	  l_txn_rec.source_transaction_date := sysdate;
	  l_txn_rec.transaction_type_id := 91;
	  l_txn_rec.transaction_status_code := 'COMPLETE';

	  if P_FA_ASSET_ID is not null then

	  	l_asset_assignment_tbl(1).instance_id := null;
		l_asset_assignment_tbl(1).fa_asset_id := P_FA_ASSET_ID;


		if P_FA_SYNC_FLAG = 'Y' then
			l_asset_assignment_tbl(1).fa_sync_flag := 'Y';
			l_asset_assignment_tbl(1).fa_sync_validation_reqd := FND_API.G_TRUE;
		else
			l_asset_assignment_tbl(1).fa_sync_flag := 'N';
			l_asset_assignment_tbl(1).fa_sync_validation_reqd := FND_API.G_FALSE;
		end if;

		select fb.book_type_code
  		into l_asset_assignment_tbl(1).fa_book_type_code
  		from   fa_books fb,
         		fa_book_controls fbc
  		where  fb.asset_id = P_FA_ASSET_ID
  		and    fb.book_type_code = fbc.book_type_code
  		and    fbc.book_class = 'CORPORATE'
  		and rownum = 1;

  		select fdh.location_id
		into l_asset_assignment_tbl(1).fa_location_id
		from   fa_distribution_history fdh
		where  asset_id = P_FA_ASSET_ID
		and    book_type_code = l_asset_assignment_tbl(1).fa_book_type_code
		and    date_ineffective is null
		and rownum = 1;

		l_asset_assignment_tbl(1).asset_quantity := 1;
		l_asset_assignment_tbl(1).update_status := 'IN_SERVICE';

		l_asset_assignment_tbl(1).parent_tbl_index := 1;
	  end if;


	-- Now call the stored program

	 csi_item_instance_pub.create_item_instance
	 (
	     p_api_version           =>   1.0
	    ,p_commit                =>   fnd_api.g_false
	    ,p_init_msg_list         =>   fnd_api.g_false
	    ,p_validation_level      =>   fnd_api.g_valid_level_full
	    ,p_instance_rec          =>   l_instance_rec
	    ,p_ext_attrib_values_tbl =>   l_ext_attrib_values_tbl
	    ,p_party_tbl             =>   l_party_tbl
	    ,p_account_tbl           =>   l_account_tbl
	    ,p_pricing_attrib_tbl    =>   l_pricing_attrib_tbl
	    ,p_org_assignments_tbl   =>   l_org_assignments_tbl
	    ,p_asset_assignment_tbl  =>   l_asset_assignment_tbl
	    ,p_txn_rec               =>   l_txn_rec
	    ,x_return_status         =>   x_return_status
	    ,x_msg_count             =>   x_msg_count
	    ,x_msg_data              =>   x_msg_data
	 );

 	 IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        	l_msg_index := 1;
         	l_msg_count := x_msg_count;
         	WHILE l_msg_count > 0 LOOP
         	         x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
         		    -- csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post API ');
             		-- csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              		l_msg_index := l_msg_index + 1;
              		l_msg_count := l_msg_count - 1;
          	END LOOP;

         	RAISE FND_API.G_EXC_ERROR;
       	END IF;

       x_object_id := l_instance_rec.instance_id;

       /* Bug # 5339642 : Call Text index procedure for inserting the row in EAT */
       eam_text_util.process_asset_update_event
       (
         p_event         => 'INSERT'
        ,p_instance_id   => l_instance_rec.instance_id
       );

       -- Standard check of p_commit.
       	       IF fnd_api.to_boolean(p_commit) THEN
       	          COMMIT WORK;
       	       END IF;

       	    -- Standard call to get message count and if count is 1, get message info.
       	       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
       	    EXCEPTION
       	       WHEN fnd_api.g_exc_error THEN
       	          ROLLBACK TO insert_row;
       	          x_return_status := fnd_api.g_ret_sts_error;
       	          /*fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);*/
       	       WHEN fnd_api.g_exc_unexpected_error THEN
       	          ROLLBACK TO insert_row;
       	          x_return_status := fnd_api.g_ret_sts_unexp_error;
       	          /*fnd_msg_pub.count_and_get(
       	             p_count => x_msg_count
       	            ,p_data => x_msg_data);*/
       	       WHEN OTHERS THEN
       	          ROLLBACK TO insert_row;
       	          x_return_status := fnd_api.g_ret_sts_unexp_error;

       	          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
       	             fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
       	          END IF;

	          /*fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data); */


  end insert_row;



PROCEDURE UPDATE_ROW(
  P_API_VERSION                IN NUMBER,
  P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_instance_id     IN NUMBER,
  P_INSTANCE_DESCRIPTION              VARCHAR2,
  P_CATEGORY_ID                   NUMBER,
  P_PN_LOCATION_ID                NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_FA_SYNC_FLAG		  VARCHAR2 DEFAULT NULL,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_NETWORK_ASSET_FLAG            VARCHAR2,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_FROM_PUBLIC_API		  VARCHAR2 DEFAULT 'Y',
  P_INSTANCE_NUMBER		  VARCHAR2 DEFAULT NULL,
    P_LOCATION_TYPE_CODE		  VARCHAR2 DEFAULT NULL,
    P_LOCATION_ID			  NUMBER DEFAULT NULL,
    p_active_end_date		  DATE DEFAULT NULL,
    p_linear_location_id	  	  NUMBER DEFAULT NULL,
    p_operational_log_flag	  VARCHAR2 DEFAULT NULL,
    p_checkin_status		  NUMBER DEFAULT NULL,
    p_supplier_warranty_exp_date        DATE DEFAULT NULL,
  p_equipment_gen_object_id   	  NUMBER DEFAULT NULL,
  p_reactivate_asset		VARCHAR2 DEFAULT 'N',
  p_disassociate_fa_flag	VARCHAR2 DEFAULT 'N',   --5474749
  X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT NOCOPY NUMBER,
  X_MSG_DATA                  OUT NOCOPY VARCHAR2
  )
is

  l_instance_rec          CSI_DATASTRUCTURES_PUB.INSTANCE_REC;
  l_ext_attrib_values_tbl CSI_DATASTRUCTURES_PUB.EXTEND_ATTRIB_VALUES_TBL;
  l_party_tbl             CSI_DATASTRUCTURES_PUB.PARTY_TBL;
  l_party_account_tbl     CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
  l_pricing_attrib_tbl    CSI_DATASTRUCTURES_PUB.PRICING_ATTRIBS_TBL;
  l_org_assignments_tbl   CSI_DATASTRUCTURES_PUB.ORGANIZATION_UNITS_TBL;
  l_asset_assignment_tbl  CSI_DATASTRUCTURES_PUB.INSTANCE_ASSET_TBL;
  l_txn_rec               CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
  l_x_instance_id_lst       CSI_DATASTRUCTURES_PUB.ID_TBL;

  t_output                varchar2(2000);
  t_msg_dummy             number;
  l_object_version_number number;

  l_api_name       CONSTANT VARCHAR2(30) := 'update_row';
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_x_return_status	varchar2(100);
  l_x_msg_count		number;
  l_x_msg_data		varchar2(20000);
  l_msg_index 		NUMBER;
  l_msg_count		NUMBER;
  l_old_location_type_code varchar2(80);
  begin
  	  -- Standard Start of API savepoint
	        SAVEPOINT update_row;

	     -- Standard call to check for call compatibility.
	        IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
	           RAISE fnd_api.g_exc_unexpected_error;
	        END IF;

	     -- Initialize message list if p_init_msg_list is set to TRUE.
	        IF fnd_api.to_boolean(p_init_msg_list) THEN
	           fnd_msg_pub.initialize;
	        END IF;

	     -- Initialize API return status to success
	        x_return_status := fnd_api.g_ret_sts_success;

	     -- API body

	     --csi_gen_utility_pvt.put_line('EAM: Start of update_row, Active End date is : '||to_char(p_active_end_date,'dd-mon-yy hh24:mi:ss'));


	  l_instance_rec.instance_id := P_INSTANCE_ID; --replace

	  select object_version_number
	  into l_object_version_number
	  from csi_item_instances
	  where instance_id = p_instance_id;

	  l_instance_rec.object_version_number := l_object_version_number; --replace


	  l_instance_rec.location_type_code := 	actual_value_char(p_from_public_api, p_location_type_code, FND_API.G_MISS_CHAR);
	  l_instance_rec.location_id := actual_value_char(p_from_public_api, p_location_id,FND_API.G_MISS_NUM);
          l_instance_rec.instance_description := actual_value_char(p_from_public_api, p_instance_description,FND_API.G_MISS_CHAR);

	  l_instance_rec.instance_number := actual_value_char(p_from_public_api, p_instance_number,FND_API.G_MISS_CHAR);
	  l_instance_rec.context := actual_value_char(p_from_public_api, P_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute1 := actual_value_char(p_from_public_api, P_ATTRIBUTE1,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute2 := actual_value_char(p_from_public_api, P_ATTRIBUTE2,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute3 := actual_value_char(p_from_public_api, P_ATTRIBUTE3,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute4 := actual_value_char(p_from_public_api, P_ATTRIBUTE4,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute5 := actual_value_char(p_from_public_api, P_ATTRIBUTE5,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute6 := actual_value_char(p_from_public_api, P_ATTRIBUTE6,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute7 := actual_value_char(p_from_public_api, P_ATTRIBUTE7,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute8 := actual_value_char(p_from_public_api, P_ATTRIBUTE8,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute9 := actual_value_char(p_from_public_api, P_ATTRIBUTE9,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute10 := actual_value_char(p_from_public_api, P_ATTRIBUTE10,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute11 := actual_value_char(p_from_public_api, P_ATTRIBUTE11,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute12 := actual_value_char(p_from_public_api, P_ATTRIBUTE12,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute13 := actual_value_char(p_from_public_api, P_ATTRIBUTE13,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute14 := actual_value_char(p_from_public_api, P_ATTRIBUTE14,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute15 := actual_value_char(p_from_public_api, P_ATTRIBUTE15,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute16 := actual_value_char(p_from_public_api, P_ATTRIBUTE16,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute17 := actual_value_char(p_from_public_api, P_ATTRIBUTE17,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute18 := actual_value_char(p_from_public_api, P_ATTRIBUTE18,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute19 := actual_value_char(p_from_public_api, P_ATTRIBUTE19,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute20 := actual_value_char(p_from_public_api, P_ATTRIBUTE20,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute21 := actual_value_char(p_from_public_api, P_ATTRIBUTE21,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute22 := actual_value_char(p_from_public_api, P_ATTRIBUTE22,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute23 := actual_value_char(p_from_public_api, P_ATTRIBUTE23,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute24 := actual_value_char(p_from_public_api, P_ATTRIBUTE24,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute25 := actual_value_char(p_from_public_api, P_ATTRIBUTE25,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute26 := actual_value_char(p_from_public_api, P_ATTRIBUTE26,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute27 := actual_value_char(p_from_public_api, P_ATTRIBUTE27,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute28 := actual_value_char(p_from_public_api, P_ATTRIBUTE28,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute29 := actual_value_char(p_from_public_api, P_ATTRIBUTE29,FND_API.G_MISS_CHAR);
	  l_instance_rec.attribute30 := actual_value_char(p_from_public_api, P_ATTRIBUTE30,FND_API.G_MISS_CHAR);

 	  l_instance_rec.maintainable_flag := actual_value_char(p_from_public_api, p_maintainable_flag,FND_API.G_MISS_CHAR);
 	  l_instance_rec.network_asset_flag := actual_value_char(p_from_public_api, p_network_asset_flag,FND_API.G_MISS_CHAR);
 	  l_instance_rec.pn_location_id := actual_value_char(p_from_public_api, p_pn_location_id,FND_API.G_MISS_NUM);
 	  l_instance_rec.asset_criticality_code := actual_value_char(p_from_public_api, p_asset_criticality_code,FND_API.G_MISS_CHAR);
 	  l_instance_rec.category_id := actual_value_char(p_from_public_api, p_category_id,FND_API.G_MISS_NUM);

 	  l_instance_rec.equipment_gen_object_id  := actual_value_char(p_from_public_api, p_equipment_gen_object_id,FND_API.G_MISS_NUM);
 	  l_instance_rec.linear_location_id := actual_value_char(p_from_public_api, p_linear_location_id,FND_API.G_MISS_NUM);
 	  --p_instance_rec.start_date_active := actual_value_date(p_from_public_api, p_start_date_active,FND_API.G_MISS_DATE);

 	  if p_reactivate_asset = 'Y' then
 	  	l_instance_rec.active_end_date := null;
 	  else
 	  	 l_instance_rec.active_end_date := actual_value_date(p_from_public_api, p_active_end_date,FND_API.G_MISS_DATE);
 	  end if;

 	  --csi_gen_utility_pvt.put_line('EAM: After conversion, end date : '||to_char(l_instance_rec.active_end_date,'dd-mon-yy hh24:mi:ss'));

 	  --l_instance_rec.linear_location_id := actual_value_char(p_from_public_api, p_linear_location_id,FND_API.G_MISS_NUM);
 	  l_instance_rec.operational_log_flag := actual_value_char(p_from_public_api, p_operational_log_flag,FND_API.G_MISS_CHAR);
 	  l_instance_rec.checkin_status := actual_value_char(p_from_public_api, p_checkin_status,FND_API.G_MISS_NUM);
   	  l_instance_rec.supplier_warranty_exp_date := actual_value_date(p_from_public_api, p_supplier_warranty_exp_date,FND_API.G_MISS_DATE);

   	  l_txn_rec.transaction_id := NULL;
	  l_txn_rec.transaction_date := sysdate;
	  l_txn_rec.source_transaction_date := sysdate;
	  l_txn_rec.transaction_type_id := 91;
	  l_txn_rec.transaction_status_code := 'COMPLETE';

	  if P_FA_ASSET_ID is not null then

	    		l_asset_assignment_tbl(1).instance_id := p_instance_id;
	  		l_asset_assignment_tbl(1).fa_asset_id := P_FA_ASSET_ID;

	  		begin
	  			select instance_asset_id, object_version_number
	  			into l_asset_assignment_tbl(1).instance_asset_id,l_asset_assignment_tbl(1).object_version_number
	  			from csi_i_assets
	  			where instance_id = p_instance_id
	  			and fa_asset_id = fa_asset_id;
	  		exception
	  			when no_data_found then
	  				null;
	  		end;

 	  		if P_FA_SYNC_FLAG = 'Y' then
				l_asset_assignment_tbl(1).fa_sync_flag := 'Y';
				l_asset_assignment_tbl(1).fa_sync_validation_reqd := FND_API.G_TRUE;
			else
				l_asset_assignment_tbl(1).fa_sync_flag := 'N';
				l_asset_assignment_tbl(1).fa_sync_validation_reqd := FND_API.G_FALSE;
			end if;

	  		select fb.book_type_code
	    		into l_asset_assignment_tbl(1).fa_book_type_code
	    		from   fa_books fb,
	           		fa_book_controls fbc
	    		where  fb.asset_id = P_FA_ASSET_ID
	    		and    fb.book_type_code = fbc.book_type_code
	    		and    fbc.book_class = 'CORPORATE'
	    		and rownum = 1;

	    		select fdh.location_id
	  		into l_asset_assignment_tbl(1).fa_location_id
	  		from   fa_distribution_history fdh
	  		where  asset_id = P_FA_ASSET_ID
	  		and    book_type_code = l_asset_assignment_tbl(1).fa_book_type_code
	  		and    date_ineffective is null
	  		and rownum = 1;

	  		l_asset_assignment_tbl(1).asset_quantity := 1;
	  		l_asset_assignment_tbl(1).update_status := 'IN_SERVICE';
	  		l_asset_assignment_tbl(1).active_end_date := null;
	  		l_asset_assignment_tbl(1).parent_tbl_index := 1;
             END IF;

--5474749 condition added
	     if nvl(p_disassociate_fa_flag,'N') = 'Y' then

			select fa_asset_id into l_asset_assignment_tbl(1).fa_asset_id
			from csi_i_assets where instance_id = p_instance_id;

			begin
	  			select instance_asset_id, object_version_number
	  			into l_asset_assignment_tbl(1).instance_asset_id,l_asset_assignment_tbl(1).object_version_number
	  			from csi_i_assets
	  			where instance_id = p_instance_id
	  			and fa_asset_id = l_asset_assignment_tbl(1).fa_asset_id;
	  		exception
	  			when no_data_found then
	  				null;
	  		end;

			if P_FA_SYNC_FLAG = 'Y' then
				l_asset_assignment_tbl(1).fa_sync_flag := 'Y';
				l_asset_assignment_tbl(1).fa_sync_validation_reqd := FND_API.G_TRUE;
			else
				l_asset_assignment_tbl(1).fa_sync_flag := 'N';
				l_asset_assignment_tbl(1).fa_sync_validation_reqd := FND_API.G_FALSE;
			end if;

			select fb.book_type_code
	    		into l_asset_assignment_tbl(1).fa_book_type_code
	    		from   fa_books fb,
	           		fa_book_controls fbc
	    		where  fb.asset_id = l_asset_assignment_tbl(1).fa_asset_id
	    		and    fb.book_type_code = fbc.book_type_code
	    		and    fbc.book_class = 'CORPORATE'
	    		and rownum = 1;

			select fdh.location_id
	  		into l_asset_assignment_tbl(1).fa_location_id
	  		from   fa_distribution_history fdh
	  		where  asset_id = l_asset_assignment_tbl(1).fa_asset_id
	  		and    book_type_code = l_asset_assignment_tbl(1).fa_book_type_code
	  		and    date_ineffective is null
	  		and rownum = 1;

			l_asset_assignment_tbl(1).asset_quantity := 1;
	  		l_asset_assignment_tbl(1).update_status := 'IN_SERVICE';

	  		l_asset_assignment_tbl(1).parent_tbl_index := 1;

	  		l_asset_assignment_tbl(1).instance_id := p_instance_id;
			l_asset_assignment_tbl(1).active_end_date := sysdate;

	  end if; --end if for disassociate fa flag

	    if 	(P_LOCATION_TYPE_CODE is not NULL AND P_LOCATION_TYPE_CODE <> FND_API.G_MISS_CHAR) then


	    	if (p_location_type_code <> 'INVENTORY') then

	    		select location_type_code
	    		into l_old_location_type_code
	    		from csi_item_instances
	    		where instance_id = p_instance_id;

	    		if (l_old_location_type_code = 'INVENTORY') then
	    			FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_LOCATION_UPDATE');
				FND_MSG_PUB.Add;
				RAISE FND_API.G_EXC_ERROR;
	    		end if;
	    	end if;
	    end if;

	    --csi_gen_utility_pvt.put_line('End date passed to IB API : '||to_char(l_instance_rec.active_end_date,'dd-mon-yy hh24:mi:ss'));
	    -- Now call the stored program
	    csi_item_instance_pub.update_item_instance(
			p_api_version => 1.0,
			p_commit => p_commit,
			p_init_msg_list => p_init_msg_list,
			p_validation_level => 100,
			p_instance_rec => l_instance_rec,
			p_ext_attrib_values_tbl => l_ext_attrib_values_tbl,
			p_party_tbl => l_party_tbl,
			p_account_tbl => l_party_account_tbl,
			p_pricing_attrib_tbl => l_pricing_attrib_tbl,
			p_org_assignments_tbl => l_org_assignments_tbl,
			p_asset_assignment_tbl => l_asset_assignment_tbl,
			p_txn_rec => l_txn_rec,
			x_instance_id_lst => l_x_instance_id_lst,
			x_return_status => l_x_return_status,
			x_msg_count => l_x_msg_count,
			x_msg_data => l_x_msg_data
		);
		x_return_status := l_x_return_status;
		x_msg_count := l_x_msg_count;
		x_msg_data := l_x_msg_data;
          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        	l_msg_index := 1;
         	l_msg_count := x_msg_count;
         	WHILE l_msg_count > 0 LOOP
         	         x_msg_data := FND_MSG_PUB.GET
                              (  l_msg_index,
                                 FND_API.G_FALSE );
         		    -- csi_gen_utility_pvt.put_line('ERROR FROM CSI_ITEM_INSTANCE_CUHK.Create_Item_Instance_Post API ');
             		-- csi_gen_utility_pvt.put_line('MESSAGE DATA = '||x_msg_data);
              		l_msg_index := l_msg_index + 1;
              		l_msg_count := l_msg_count - 1;
          	END LOOP;
         	RAISE FND_API.G_EXC_ERROR;
       	   END IF;

           /* Bug # 5339642 : Call Text index procedure for inserting the row in EAT */
	   eam_text_util.process_asset_update_event
	   (
	      p_event         => 'UPDATE'
	     ,p_instance_id   => l_instance_rec.instance_id
	   );

	 -- End of API body.
	    -- Standard check of p_commit.
	       IF fnd_api.to_boolean(p_commit) THEN
	          COMMIT WORK;
	       END IF;

	    -- Standard call to get message count and if count is 1, get message info.
	       fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
	    EXCEPTION
	       WHEN fnd_api.g_exc_error THEN
	          ROLLBACK TO update_row;
	          x_return_status := fnd_api.g_ret_sts_error;
	          /*fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);*/
	       WHEN fnd_api.g_exc_unexpected_error THEN
	          ROLLBACK TO update_row;
	          x_return_status := fnd_api.g_ret_sts_unexp_error;
	          /*fnd_msg_pub.count_and_get(
	             p_count => x_msg_count
	            ,p_data => x_msg_data);*/
	       WHEN OTHERS THEN
	          ROLLBACK TO update_row;
	          x_return_status := fnd_api.g_ret_sts_unexp_error;

	          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	             fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	          END IF;

	          /*fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data); */

  end update_row;

  PROCEDURE LOCK_ROW(

          P_API_VERSION                IN NUMBER,
          P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE,
          P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE,
          P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          P_ROWID                         VARCHAR2,
          P_INSTANCE_ID		IN NUMBER,
          P_INSTANCE_NUMBER		    VARCHAR2 DEFAULT NULL,
          P_INSTANCE_DESCRIPTION         VARCHAR2,
          P_CATEGORY_ID                   NUMBER,
          P_PN_LOCATION_ID                NUMBER,
          P_FA_ASSET_ID                   NUMBER,
          P_ASSET_CRITICALITY_CODE        VARCHAR2,
          P_MAINTAINABLE_FLAG             VARCHAR2,
          P_NETWORK_ASSET_FLAG            VARCHAR2,
          P_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL,
          P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL,
          P_REQUEST_ID                    NUMBER   DEFAULT NULL,
          P_PROGRAM_APPLICATION_ID        NUMBER   DEFAULT NULL,
          P_PROGRAM_ID                    NUMBER   DEFAULT NULL,
          P_PROGRAM_UPDATE_DATE           DATE     DEFAULT NULL,
          P_LAST_UPDATE_DATE              DATE,
          P_LAST_UPDATED_BY               NUMBER,
          P_LAST_UPDATE_LOGIN             NUMBER,
          P_LOCATION_TYPE_CODE		  VARCHAR2 DEFAULT NULL,
    	  P_LOCATION_ID			  NUMBER DEFAULT NULL,
          p_linear_location_id	    NUMBER 	DEFAULT NULL,
          p_operational_log_flag	    VARCHAR2 	DEFAULT NULL,
          P_checkin_status	           NUMBER 	DEFAULT NULL,
          p_supplier_warranty_exp_date        DATE 	DEFAULT NULL,
          p_equipment_gen_object_id           NUMBER 	DEFAULT NULL,
          X_RETURN_STATUS                 OUT NOCOPY VARCHAR2,
          X_MSG_COUNT                     OUT NOCOPY NUMBER,
          X_MSG_DATA                      OUT NOCOPY VARCHAR2
      )
      IS
         	CURSOR C IS
              	SELECT *
              	FROM CSI_ITEM_INSTANCES
              	WHERE INSTANCE_ID =  p_INSTANCE_ID
              	FOR UPDATE of INSTANCE_ID NOWAIT;
         	Recinfo C%ROWTYPE;
       	BEGIN
          		OPEN C;
          		FETCH C INTO Recinfo;
          		IF (C%NOTFOUND) THEN
              			CLOSE C;
              			FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
              			APP_EXCEPTION.RAISE_EXCEPTION;
          		END IF;
          		CLOSE C;

          		IF (
			           (      Recinfo.INSTANCE_ID = p_INSTANCE_ID)
			       AND (    ( Recinfo.INSTANCE_NUMBER = p_INSTANCE_NUMBER)
			            OR (    ( Recinfo.INSTANCE_NUMBER IS NULL )
			                AND (  p_INSTANCE_NUMBER IS NULL )))
			       /*
			       AND (    ( Recinfo.LOCATION_TYPE_CODE = p_LOCATION_TYPE_CODE)
			            OR (    ( Recinfo.LOCATION_TYPE_CODE IS NULL )
			                AND (  p_LOCATION_TYPE_CODE IS NULL )))
			       AND (    ( Recinfo.LOCATION_ID = p_LOCATION_ID)
			            OR (    ( Recinfo.LOCATION_ID IS NULL )
			                AND (  p_LOCATION_ID IS NULL )))
			       AND (    ( Recinfo.CONTEXT = p_ATTRIBUTE_CATEGORY)
			            OR (    ( Recinfo.CONTEXT IS NULL )
			                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
			            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
			                AND (  p_ATTRIBUTE1 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
			            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
			                AND (  p_ATTRIBUTE2 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
			            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
			                AND (  p_ATTRIBUTE3 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
			            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
			                AND (  p_ATTRIBUTE4 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
			            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
			                AND (  p_ATTRIBUTE5 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
			            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
			                AND (  p_ATTRIBUTE6 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
			            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
			                AND (  p_ATTRIBUTE7 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
			            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
			                AND (  p_ATTRIBUTE8 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
			            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
			                AND (  p_ATTRIBUTE9 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
			            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
			                AND (  p_ATTRIBUTE10 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
			            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
			                AND (  p_ATTRIBUTE11 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
			            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
			                AND (  p_ATTRIBUTE12 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
			            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
			                AND (  p_ATTRIBUTE13 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
			            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
			                AND (  p_ATTRIBUTE14 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
			            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
			                AND (  p_ATTRIBUTE15 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE16 = p_ATTRIBUTE16)
			            OR (    ( Recinfo.ATTRIBUTE16 IS NULL )
			                AND (  p_ATTRIBUTE16 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE17 = p_ATTRIBUTE17)
			            OR (    ( Recinfo.ATTRIBUTE17 IS NULL )
			                AND (  p_ATTRIBUTE17 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE18 = p_ATTRIBUTE18)
			            OR (    ( Recinfo.ATTRIBUTE18 IS NULL )
			                AND (  p_ATTRIBUTE18 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE19 = p_ATTRIBUTE19)
			            OR (    ( Recinfo.ATTRIBUTE19 IS NULL )
			                AND (  p_ATTRIBUTE19 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE20 = p_ATTRIBUTE20)
			            OR (    ( Recinfo.ATTRIBUTE20 IS NULL )
			                AND (  p_ATTRIBUTE20 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE21 = p_ATTRIBUTE21)
			            OR (    ( Recinfo.ATTRIBUTE21 IS NULL )
			                AND (  p_ATTRIBUTE21 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE22 = p_ATTRIBUTE22)
			            OR (    ( Recinfo.ATTRIBUTE22 IS NULL )
			                AND (  p_ATTRIBUTE22 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE23 = p_ATTRIBUTE23)
			            OR (    ( Recinfo.ATTRIBUTE23 IS NULL )
			                AND (  p_ATTRIBUTE23 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE24 = p_ATTRIBUTE24)
			            OR (    ( Recinfo.ATTRIBUTE24 IS NULL )
			                AND (  p_ATTRIBUTE24 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE25 = p_ATTRIBUTE25)
			            OR (    ( Recinfo.ATTRIBUTE25 IS NULL )
			                AND (  p_ATTRIBUTE25 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE26 = p_ATTRIBUTE26)
			            OR (    ( Recinfo.ATTRIBUTE26 IS NULL )
			                AND (  p_ATTRIBUTE26 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE27 = p_ATTRIBUTE27)
			            OR (    ( Recinfo.ATTRIBUTE27 IS NULL )
			                AND (  p_ATTRIBUTE27 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE28 = p_ATTRIBUTE28)
			            OR (    ( Recinfo.ATTRIBUTE28 IS NULL )
			                AND (  p_ATTRIBUTE28 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE29 = p_ATTRIBUTE29)
			            OR (    ( Recinfo.ATTRIBUTE29 IS NULL )
			                AND (  p_ATTRIBUTE29 IS NULL )))
			       AND (    ( Recinfo.ATTRIBUTE30 = p_ATTRIBUTE30)
			            OR (    ( Recinfo.ATTRIBUTE30 IS NULL )
			                AND (  p_ATTRIBUTE30 IS NULL )))
			       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
			            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
			                AND (  p_LAST_UPDATED_BY IS NULL )))
			       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
			            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
			                AND (  p_LAST_UPDATE_DATE IS NULL )))
			       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
			            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
			                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
			       AND (    ( Recinfo.INSTANCE_DESCRIPTION = p_INSTANCE_DESCRIPTION)
			            OR (    ( Recinfo.INSTANCE_DESCRIPTION IS NULL )
			                AND (  p_INSTANCE_DESCRIPTION IS NULL )))
			       AND (    ( Recinfo.CATEGORY_ID = p_CATEGORY_ID)
			            OR (    ( Recinfo.CATEGORY_ID IS NULL )
			                AND (  p_CATEGORY_ID IS NULL )))
			       AND (    ( Recinfo.PN_LOCATION_ID = p_PN_LOCATION_ID)
			            OR (    ( Recinfo.PN_LOCATION_ID IS NULL )
			                AND (  p_PN_LOCATION_ID IS NULL )))
			       AND (    ( Recinfo.ASSET_CRITICALITY_CODE = p_ASSET_CRITICALITY_CODE)
			            OR (    ( Recinfo.ASSET_CRITICALITY_CODE IS NULL )
			                AND (  p_ASSET_CRITICALITY_CODE IS NULL )))
			       AND (    ( Recinfo.MAINTAINABLE_FLAG = p_MAINTAINABLE_FLAG)
			            OR (    ( Recinfo.MAINTAINABLE_FLAG IS NULL )
			                AND (  p_MAINTAINABLE_FLAG IS NULL )))
			       AND (    ( Recinfo.NETWORK_ASSET_FLAG = p_NETWORK_ASSET_FLAG)
			            OR (    ( Recinfo.NETWORK_ASSET_FLAG IS NULL )
			                AND (  p_NETWORK_ASSET_FLAG IS NULL )))
			       AND (    ( Recinfo.LINEAR_LOCATION_ID = p_LINEAR_LOCATION_ID)
			            OR (    ( Recinfo.LINEAR_LOCATION_ID IS NULL )
			                AND (  p_LINEAR_LOCATION_ID IS NULL )))
			       AND (    ( Recinfo.OPERATIONAL_LOG_FLAG = p_OPERATIONAL_LOG_FLAG)
			            OR (    ( Recinfo.OPERATIONAL_LOG_FLAG IS NULL )
			                AND (  p_OPERATIONAL_LOG_FLAG IS NULL )))
			       AND (    ( Recinfo.CHECKIN_STATUS = p_CHECKIN_STATUS)
			            OR (    ( Recinfo.CHECKIN_STATUS IS NULL )
			                AND (  p_CHECKIN_STATUS IS NULL )))
			       AND (    ( Recinfo.SUPPLIER_WARRANTY_EXP_DATE = p_SUPPLIER_WARRANTY_EXP_DATE)
			            OR (    ( Recinfo.SUPPLIER_WARRANTY_EXP_DATE IS NULL )
			                AND (  p_SUPPLIER_WARRANTY_EXP_DATE IS NULL )))
			       AND (    ( Recinfo.EQUIPMENT_GEN_OBJECT_ID = p_EQUIPMENT_GEN_OBJECT_ID)
			            OR (    ( Recinfo.EQUIPMENT_GEN_OBJECT_ID IS NULL )
			                AND (  p_EQUIPMENT_GEN_OBJECT_ID IS NULL )))
			       */
			       ) THEN
			       RETURN;
			   ELSE
			       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
			       APP_EXCEPTION.RAISE_EXCEPTION;
   			   END IF;
      end lock_row;

      PROCEDURE CREATE_ASSET(
      	 P_API_VERSION                IN NUMBER
      	 ,P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE
      	 ,P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE
         ,P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
         ,P_INVENTORY_ITEM_ID             NUMBER
      	 ,P_SERIAL_NUMBER                 VARCHAR2
      	 ,P_INSTANCE_NUMBER		  VARCHAR2
      	 ,P_INSTANCE_DESCRIPTION          VARCHAR2
         ,P_ORGANIZATION_ID               NUMBER
         ,P_CATEGORY_ID                   NUMBER DEFAULT NULL
      	 ,P_PN_LOCATION_ID              NUMBER DEFAULT NULL
      	 ,P_FA_ASSET_ID                 NUMBER DEFAULT NULL
      	 ,P_FA_SYNC_FLAG		VARCHAR2 DEFAULT NULL
      	 ,P_ASSET_CRITICALITY_CODE      VARCHAR2 DEFAULT NULL
      	 ,P_MAINTAINABLE_FLAG           VARCHAR2 DEFAULT NULL
      	 ,P_NETWORK_ASSET_FLAG          VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE_CATEGORY            VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL
      	 ,P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL
	 ,P_REQUEST_ID                    NUMBER   DEFAULT NULL
	 ,P_PROGRAM_APPLICATION_ID        NUMBER   DEFAULT NULL
	 ,P_PROGRAM_ID                    NUMBER   DEFAULT NULL
	 ,P_PROGRAM_UPDATE_DATE           DATE     DEFAULT NULL
	 ,P_LAST_UPDATE_DATE              DATE
	 ,P_LAST_UPDATED_BY               NUMBER
	 ,P_CREATION_DATE                 DATE
	 ,P_CREATED_BY                    NUMBER
	 ,P_LAST_UPDATE_LOGIN             NUMBER
	 ,p_active_start_date		  DATE DEFAULT NULL
	 ,p_active_end_date		  DATE DEFAULT NULL
	 ,p_location			  NUMBER DEFAULT NULL
	 ,p_linear_location_id	  	  NUMBER DEFAULT NULL
	 ,p_operational_log_flag	  VARCHAR2 DEFAULT NULL
	 ,p_checkin_status		  NUMBER DEFAULT NULL
	 ,p_supplier_warranty_exp_date        DATE DEFAULT NULL
	 ,p_equipment_gen_object_id   	  NUMBER DEFAULT NULL
	 ,p_owning_department_id	  NUMBER DEFAULT NULL
	 ,p_accounting_class_code	  VARCHAR2 DEFAULT NULL
	 ,p_area_id			  NUMBER DEFAULT NULL
	 ,X_OBJECT_ID OUT NOCOPY NUMBER
	 ,X_RETURN_STATUS OUT NOCOPY VARCHAR2
	 ,X_MSG_COUNT OUT NOCOPY NUMBER
	 ,X_MSG_DATA OUT NOCOPY VARCHAR2
	)
	is
		l_api_name       CONSTANT VARCHAR2(30) := 'create_asset';
	    	l_api_version    CONSTANT NUMBER       := 1.0;
    		l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
    		l_count number := 0;
    		l_x_asset_return_status varchar2(3);
    		l_x_asset_msg_count number;
    		l_x_asset_msg_data varchar2(20000);
    		l_x_maint_return_status varchar2(3);
    		l_x_maint_msg_count number;
    		l_x_maint_msg_data varchar2(20000);
    		l_mfg_serial_number_flag varchar2(1);
    		l_instance_id number;
	begin
		-- Standard Start of API savepoint
		SAVEPOINT create_asset;

		-- Standard call to check for call compatibility.
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
		         RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		         fnd_msg_pub.initialize;
		END IF;

		-- Initialize API return status to success
		x_return_status := fnd_api.g_ret_sts_success;

		-- API body
		begin
			select 1
			into l_count
			from mtl_serial_numbers
			where inventory_item_id = p_inventory_item_id
			and serial_number = p_serial_number
			and rownum <= 1;

		exception
			when no_data_found then
				l_count := 0;
		end;

		if l_count = 0 then
			l_mfg_serial_number_flag := 'N';
		else
			l_mfg_serial_number_flag := 'Y';
		end if;

		insert_row(
			  P_API_VERSION           	=> P_API_VERSION,
			  P_INVENTORY_ITEM_ID           => P_INVENTORY_ITEM_ID,
			  P_SERIAL_NUMBER               =>  P_SERIAL_NUMBER,
			  P_INSTANCE_NUMBER		=>  P_INSTANCE_NUMBER,
			  P_INSTANCE_DESCRIPTION        =>  P_INSTANCE_DESCRIPTION,
			  P_ORGANIZATION_ID             =>  P_ORGANIZATION_ID,
			  P_CATEGORY_ID                 =>  P_CATEGORY_ID,
			  P_PN_LOCATION_ID              =>  P_PN_LOCATION_ID,
			  P_FA_ASSET_ID                 =>  P_FA_ASSET_ID,
			  P_FA_SYNC_FLAG		=>  P_FA_SYNC_FLAG,
			  P_ASSET_CRITICALITY_CODE      =>  P_ASSET_CRITICALITY_CODE,
			  P_MAINTAINABLE_FLAG           =>  P_MAINTAINABLE_FLAG,
			  P_NETWORK_ASSET_FLAG          =>  P_NETWORK_ASSET_FLAG,
			  P_ATTRIBUTE_CATEGORY          =>  P_ATTRIBUTE_CATEGORY,
			  P_ATTRIBUTE1                  =>  P_ATTRIBUTE1,
			  P_ATTRIBUTE2                  =>  P_ATTRIBUTE2,
			  P_ATTRIBUTE3                  =>  P_ATTRIBUTE3,
			  P_ATTRIBUTE4                  =>  P_ATTRIBUTE4,
			  P_ATTRIBUTE5                  =>  P_ATTRIBUTE5,
			  P_ATTRIBUTE6                  =>  P_ATTRIBUTE6,
			  P_ATTRIBUTE7                  =>  P_ATTRIBUTE7,
			  P_ATTRIBUTE8                  =>  P_ATTRIBUTE8,
			  P_ATTRIBUTE9                  =>  P_ATTRIBUTE9,
			  P_ATTRIBUTE10                 =>  P_ATTRIBUTE10,
			  P_ATTRIBUTE11                 =>  P_ATTRIBUTE11,
			  P_ATTRIBUTE12                 =>  P_ATTRIBUTE12,
			  P_ATTRIBUTE13                 =>  P_ATTRIBUTE13,
			  P_ATTRIBUTE14                 =>  P_ATTRIBUTE14,
			  P_ATTRIBUTE15                 =>  P_ATTRIBUTE15,
			  P_ATTRIBUTE16                 =>  P_ATTRIBUTE16,
			  P_ATTRIBUTE17                 =>  P_ATTRIBUTE17,
			  P_ATTRIBUTE18                 =>  P_ATTRIBUTE18,
			  P_ATTRIBUTE19                 =>  P_ATTRIBUTE19,
			  P_ATTRIBUTE20                 =>  P_ATTRIBUTE20,
			  P_ATTRIBUTE21                 =>  P_ATTRIBUTE21,
			  P_ATTRIBUTE22                 =>  P_ATTRIBUTE22,
			  P_ATTRIBUTE23                 =>  P_ATTRIBUTE23,
			  P_ATTRIBUTE24                 =>  P_ATTRIBUTE24,
			  P_ATTRIBUTE25                 =>  P_ATTRIBUTE25,
			  P_ATTRIBUTE26                 =>  P_ATTRIBUTE26,
			  P_ATTRIBUTE27                 =>  P_ATTRIBUTE27,
			  P_ATTRIBUTE28                 =>  P_ATTRIBUTE28,
			  P_ATTRIBUTE29                 =>  P_ATTRIBUTE29,
			  P_ATTRIBUTE30                 =>  P_ATTRIBUTE30,
			  P_REQUEST_ID                  =>  P_REQUEST_ID,
			  P_PROGRAM_APPLICATION_ID      =>  P_PROGRAM_APPLICATION_ID,
			  P_PROGRAM_ID                  =>  P_PROGRAM_ID,
			  P_PROGRAM_UPDATE_DATE         =>  P_PROGRAM_UPDATE_DATE,
			  P_LAST_UPDATE_DATE            =>  P_LAST_UPDATE_DATE,
			  P_LAST_UPDATED_BY             =>  P_LAST_UPDATED_BY,
			  P_CREATION_DATE               =>  P_CREATION_DATE,
			  P_CREATED_BY                  =>  P_CREATED_BY,
			  P_LAST_UPDATE_LOGIN           =>  P_LAST_UPDATE_LOGIN,
			  p_active_start_date		=>  p_active_start_date,
			  p_active_end_date		=>  p_active_end_date,
			  p_location			=>  p_location,
			  p_linear_location_id	  	=>  p_linear_location_id,
			  p_operational_log_flag	=>  p_operational_log_flag,
			  p_checkin_status		=>  p_checkin_status,
			  p_supplier_warranty_exp_date  =>  p_supplier_warranty_exp_date,
			  p_equipment_gen_object_id   	=>  p_equipment_gen_object_id,
			  p_mfg_serial_number_flag	=>  l_mfg_serial_number_flag,
			  X_OBJECT_ID 			=>  l_instance_id
			  ,X_RETURN_STATUS 		=>  l_x_asset_return_status
			  ,X_MSG_COUNT 			=>  l_x_asset_msg_count
  		          ,X_MSG_DATA 			=>  l_x_asset_msg_data
		);
		x_return_status := l_x_asset_return_status;
		x_msg_count := l_x_asset_msg_count;
		x_msg_data := l_x_asset_msg_data;
		if (l_x_asset_return_status <> FND_API.G_RET_STS_SUCCESS) then
			       RAISE FND_API.G_EXC_ERROR ;
    		else
    			if (p_owning_department_id is not null OR p_accounting_class_code is not null OR p_area_id is not null) then
    				EAM_MAINT_ATTRIBUTES_PUB.create_maint_attributes(
    					p_api_version 		=> p_api_version
					,p_instance_id          => l_instance_id
					,p_owning_department_id  => p_owning_department_id
					,p_accounting_class_code => p_accounting_class_code
					,p_area_id               => p_area_id
					,p_parent_instance_id    => null
					,x_return_status         => l_x_maint_return_status
					,x_msg_count             => l_x_maint_msg_count
     					,x_msg_data              => l_x_maint_msg_data
    				);
    				x_return_status := l_x_maint_return_status;
				x_msg_count := l_x_maint_msg_count;
				x_msg_data := l_x_maint_msg_data;
    			end if;

		end if;

		x_object_id := l_instance_id;

		-- End of API body.
		-- Standard check of p_commit.
		IF fnd_api.to_boolean(p_commit) THEN
		        COMMIT WORK;
		END IF;

		-- Standard call to get message count and if count is 1, get message info.
		fnd_msg_pub.count_and_get(
		         p_count => x_msg_count
		        ,p_data => x_msg_data);


	EXCEPTION
		      WHEN fnd_api.g_exc_error THEN
		         ROLLBACK TO create_asset;
		         x_return_status := fnd_api.g_ret_sts_error;
		         /*fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);*/
		      WHEN fnd_api.g_exc_unexpected_error THEN
		         ROLLBACK TO create_asset;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;
		         /*fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);*/
		      WHEN OTHERS THEN
		         ROLLBACK TO create_asset;
		         x_return_status := fnd_api.g_ret_sts_unexp_error;

		         IF fnd_msg_pub.check_msg_level(
		               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
		            fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
		         END IF;

		         /*fnd_msg_pub.count_and_get(
		            p_count => x_msg_count
		           ,p_data => x_msg_data);*/

	end create_asset;

	procedure update_asset(
	  	P_API_VERSION                IN NUMBER
	  	,P_INIT_MSG_LIST              IN VARCHAR2 := FND_API.G_FALSE
	  	,P_COMMIT                     IN VARCHAR2 := FND_API.G_FALSE
	  	,P_VALIDATION_LEVEL           IN NUMBER   := FND_API.G_VALID_LEVEL_FULL
	  	,p_instance_id     IN NUMBER
	  	,P_INSTANCE_DESCRIPTION              VARCHAR2
	  	,P_INVENTORY_ITEM_ID		 NUMBER
	  	,P_SERIAL_NUMBER		 VARCHAR2
	  	,P_ORGANIZATION_ID		 NUMBER
	  	,P_CATEGORY_ID                   NUMBER
	  	,P_PN_LOCATION_ID                NUMBER
	  	,P_FA_ASSET_ID                   NUMBER
	  	,P_FA_SYNC_FLAG		  VARCHAR2 DEFAULT NULL
	  	,P_ASSET_CRITICALITY_CODE        VARCHAR2
	  	,P_MAINTAINABLE_FLAG             VARCHAR2
	  	,P_NETWORK_ASSET_FLAG            VARCHAR2
	  	,P_ATTRIBUTE_CATEGORY            VARCHAR2
	  	,P_ATTRIBUTE1                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE2                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE3                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE4                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE5                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE6                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE7                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE8                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE9                    VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE10                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE11                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE12                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE13                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE14                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE15                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE16                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE17                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE18                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE19                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE20                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE21                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE22                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE23                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE24                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE25                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE26                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE27                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE28                   VARCHAR2 DEFAULT NULL
	    	,P_ATTRIBUTE29                   VARCHAR2 DEFAULT NULL
	  	,P_ATTRIBUTE30                   VARCHAR2 DEFAULT NULL
	 	,P_REQUEST_ID                    NUMBER DEFAULT NULL
	  	,P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL
	  	,P_PROGRAM_ID                    NUMBER DEFAULT NULL
	  	,P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL
	  	,P_LAST_UPDATE_DATE              DATE
	  	,P_LAST_UPDATED_BY               NUMBER
	  	,P_LAST_UPDATE_LOGIN             NUMBER
	  	,P_FROM_PUBLIC_API		  VARCHAR2 DEFAULT 'Y'
	  	,P_INSTANCE_NUMBER		  VARCHAR2 DEFAULT NULL
	        ,P_LOCATION_TYPE_CODE		  VARCHAR2 DEFAULT NULL
	        ,P_LOCATION_ID			  NUMBER DEFAULT NULL
	        ,p_active_end_date		  DATE DEFAULT NULL
	    	,p_linear_location_id	  	  NUMBER DEFAULT NULL
	    	,p_operational_log_flag	  VARCHAR2 DEFAULT NULL
	    	,p_checkin_status		  NUMBER DEFAULT NULL
	    	,p_supplier_warranty_exp_date        DATE DEFAULT NULL
	  	,p_equipment_gen_object_id   	  NUMBER DEFAULT NULL
	        ,p_owning_department_id	  NUMBER DEFAULT NULL
	        ,p_accounting_class_code	  VARCHAR2 DEFAULT NULL
	 	,p_area_id			  NUMBER DEFAULT NULL
	 	,p_reactivate_asset		VARCHAR2 DEFAULT 'N'
		,p_disassociate_fa_flag         VARCHAR2 DEFAULT 'N'
	  	,X_RETURN_STATUS             OUT NOCOPY VARCHAR2
	  	,X_MSG_COUNT                 OUT NOCOPY NUMBER
	  	,X_MSG_DATA                  OUT NOCOPY VARCHAR2
  	)
  	IS
  		l_api_name       CONSTANT VARCHAR2(30) := 'create_asset';
		l_api_version    CONSTANT NUMBER       := 1.0;
	    	l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
	    	l_count number := 0;
	    	l_x_asset_return_status varchar2(3);
	    	l_x_asset_msg_count number;
	    	l_x_asset_msg_data varchar2(20000);
	    	l_x_maint_return_status varchar2(3);
	    	l_x_maint_msg_count number;
	    	l_x_maint_msg_data varchar2(20000);
	    	l_mfg_serial_number_flag varchar2(1);
    		l_instance_id number;
    		l_current_status number;
    		l_owning_department_id number;
		l_accounting_class_code varchar2(10);
		l_area_id number;
BEGIN
  		-- Standard Start of API savepoint
		SAVEPOINT update_asset;

		-- Standard call to check for call compatibility.
		IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
		         RAISE fnd_api.g_exc_unexpected_error;
		END IF;

		-- Initialize message list if p_init_msg_list is set to TRUE.
		IF fnd_api.to_boolean(p_init_msg_list) THEN
		         fnd_msg_pub.initialize;
		END IF;

		-- Initialize API return status to success
		x_return_status := fnd_api.g_ret_sts_success;

		-- API body
		begin
			select 1,current_status
			into l_count,l_current_status
			from mtl_serial_numbers
			where inventory_item_id = p_inventory_item_id
			and serial_number = p_serial_number
			and rownum <= 1;

		exception
			when no_data_found then
				l_count := 0;
			end;

		if (l_count = 0 OR (l_count = 1 AND nvl(l_current_status,1) = 1))then
			l_mfg_serial_number_flag := 'N';

			insert_row(
				  P_API_VERSION           	=> P_API_VERSION,
				  P_INVENTORY_ITEM_ID           => P_INVENTORY_ITEM_ID,
				  P_SERIAL_NUMBER               =>  P_SERIAL_NUMBER,
				  P_INSTANCE_NUMBER		=>  P_INSTANCE_NUMBER,
				  P_INSTANCE_DESCRIPTION        =>  P_INSTANCE_DESCRIPTION,
				  P_ORGANIZATION_ID             =>  P_ORGANIZATION_ID,
				  P_CATEGORY_ID                 =>  P_CATEGORY_ID,
				  P_PN_LOCATION_ID              =>  P_PN_LOCATION_ID,
				  P_FA_ASSET_ID                 =>  P_FA_ASSET_ID,
				  P_FA_SYNC_FLAG		=>  P_FA_SYNC_FLAG,
				  P_ASSET_CRITICALITY_CODE      =>  P_ASSET_CRITICALITY_CODE,
				  P_MAINTAINABLE_FLAG           =>  P_MAINTAINABLE_FLAG,
				  P_NETWORK_ASSET_FLAG          =>  P_NETWORK_ASSET_FLAG,
				  P_ATTRIBUTE_CATEGORY          =>  P_ATTRIBUTE_CATEGORY,
				  P_ATTRIBUTE1                  =>  P_ATTRIBUTE1,
				  P_ATTRIBUTE2                  =>  P_ATTRIBUTE2,
				  P_ATTRIBUTE3                  =>  P_ATTRIBUTE3,
				  P_ATTRIBUTE4                  =>  P_ATTRIBUTE4,
				  P_ATTRIBUTE5                  =>  P_ATTRIBUTE5,
				  P_ATTRIBUTE6                  =>  P_ATTRIBUTE6,
				  P_ATTRIBUTE7                  =>  P_ATTRIBUTE7,
				  P_ATTRIBUTE8                  =>  P_ATTRIBUTE8,
				  P_ATTRIBUTE9                  =>  P_ATTRIBUTE9,
				  P_ATTRIBUTE10                 =>  P_ATTRIBUTE10,
				  P_ATTRIBUTE11                 =>  P_ATTRIBUTE11,
				  P_ATTRIBUTE12                 =>  P_ATTRIBUTE12,
				  P_ATTRIBUTE13                 =>  P_ATTRIBUTE13,
				  P_ATTRIBUTE14                 =>  P_ATTRIBUTE14,
				  P_ATTRIBUTE15                 =>  P_ATTRIBUTE15,
				  P_ATTRIBUTE16                 =>  P_ATTRIBUTE16,
				  P_ATTRIBUTE17                 =>  P_ATTRIBUTE17,
				  P_ATTRIBUTE18                 =>  P_ATTRIBUTE18,
				  P_ATTRIBUTE19                 =>  P_ATTRIBUTE19,
				  P_ATTRIBUTE20                 =>  P_ATTRIBUTE20,
				  P_ATTRIBUTE21                 =>  P_ATTRIBUTE21,
				  P_ATTRIBUTE22                 =>  P_ATTRIBUTE22,
				  P_ATTRIBUTE23                 =>  P_ATTRIBUTE23,
				  P_ATTRIBUTE24                 =>  P_ATTRIBUTE24,
				  P_ATTRIBUTE25                 =>  P_ATTRIBUTE25,
				  P_ATTRIBUTE26                 =>  P_ATTRIBUTE26,
				  P_ATTRIBUTE27                 =>  P_ATTRIBUTE27,
				  P_ATTRIBUTE28                 =>  P_ATTRIBUTE28,
				  P_ATTRIBUTE29                 =>  P_ATTRIBUTE29,
				  P_ATTRIBUTE30                 =>  P_ATTRIBUTE30,
				  P_REQUEST_ID                  =>  P_REQUEST_ID,
				  P_PROGRAM_APPLICATION_ID      =>  P_PROGRAM_APPLICATION_ID,
				  P_PROGRAM_ID                  =>  P_PROGRAM_ID,
				  P_PROGRAM_UPDATE_DATE         =>  P_PROGRAM_UPDATE_DATE,
				  P_LAST_UPDATE_DATE            =>  P_LAST_UPDATE_DATE,
				  P_LAST_UPDATED_BY             =>  P_LAST_UPDATED_BY,
				  P_CREATION_DATE               =>  P_LAST_UPDATE_DATE,
				  P_CREATED_BY                  =>  P_LAST_UPDATED_BY,
				  P_LAST_UPDATE_LOGIN           =>  P_LAST_UPDATE_LOGIN,
				  p_active_start_date		=>  sysdate,
				  p_active_end_date		=>  p_active_end_date,
				  p_location			=>  p_location_id,
				  p_linear_location_id	  	=>  p_linear_location_id,
				  p_operational_log_flag	=>  p_operational_log_flag,
				  p_checkin_status		=>  p_checkin_status,
				  p_supplier_warranty_exp_date  =>  p_supplier_warranty_exp_date,
				  p_equipment_gen_object_id   	=>  p_equipment_gen_object_id,
				  p_mfg_serial_number_flag	=>  l_mfg_serial_number_flag,
				  X_OBJECT_ID 			=>  l_instance_id
				  ,X_RETURN_STATUS 		=>  l_x_asset_return_status
				  ,X_MSG_COUNT 			=>  l_x_asset_msg_count
				  ,X_MSG_DATA 			=>  l_x_asset_msg_data
			);
		else
			l_mfg_serial_number_flag := 'Y';
			l_instance_id := p_instance_id;
			update_row
			(
			  P_API_VERSION           	=> P_API_VERSION,
			  p_instance_id     		=> P_INSTANCE_ID,
			  P_INSTANCE_DESCRIPTION        =>  P_INSTANCE_DESCRIPTION,
			  P_CATEGORY_ID                 =>  P_CATEGORY_ID,
			  P_PN_LOCATION_ID              =>  P_PN_LOCATION_ID,
			  P_FA_ASSET_ID                 =>  P_FA_ASSET_ID,
			  P_FA_SYNC_FLAG		=>  P_FA_SYNC_FLAG,
			  P_ASSET_CRITICALITY_CODE      =>  P_ASSET_CRITICALITY_CODE,
			  P_MAINTAINABLE_FLAG           =>  P_MAINTAINABLE_FLAG,
			  P_NETWORK_ASSET_FLAG          =>  P_NETWORK_ASSET_FLAG,
			  P_ATTRIBUTE_CATEGORY          =>  P_ATTRIBUTE_CATEGORY,
			  P_ATTRIBUTE1                  =>  P_ATTRIBUTE1,
			  P_ATTRIBUTE2                  =>  P_ATTRIBUTE2,
			  P_ATTRIBUTE3                  =>  P_ATTRIBUTE3,
			  P_ATTRIBUTE4                  =>  P_ATTRIBUTE4,
			  P_ATTRIBUTE5                  =>  P_ATTRIBUTE5,
			  P_ATTRIBUTE6                  =>  P_ATTRIBUTE6,
			  P_ATTRIBUTE7                  =>  P_ATTRIBUTE7,
			  P_ATTRIBUTE8                  =>  P_ATTRIBUTE8,
			  P_ATTRIBUTE9                  =>  P_ATTRIBUTE9,
			  P_ATTRIBUTE10                 =>  P_ATTRIBUTE10,
			  P_ATTRIBUTE11                 =>  P_ATTRIBUTE11,
			  P_ATTRIBUTE12                 =>  P_ATTRIBUTE12,
			  P_ATTRIBUTE13                 =>  P_ATTRIBUTE13,
			  P_ATTRIBUTE14                 =>  P_ATTRIBUTE14,
			  P_ATTRIBUTE15                 =>  P_ATTRIBUTE15,
			  P_ATTRIBUTE16                 =>  P_ATTRIBUTE16,
			  P_ATTRIBUTE17                 =>  P_ATTRIBUTE17,
			  P_ATTRIBUTE18                 =>  P_ATTRIBUTE18,
			  P_ATTRIBUTE19                 =>  P_ATTRIBUTE19,
			  P_ATTRIBUTE20                 =>  P_ATTRIBUTE20,
			  P_ATTRIBUTE21                 =>  P_ATTRIBUTE21,
			  P_ATTRIBUTE22                 =>  P_ATTRIBUTE22,
			  P_ATTRIBUTE23                 =>  P_ATTRIBUTE23,
			  P_ATTRIBUTE24                 =>  P_ATTRIBUTE24,
			  P_ATTRIBUTE25                 =>  P_ATTRIBUTE25,
			  P_ATTRIBUTE26                 =>  P_ATTRIBUTE26,
			  P_ATTRIBUTE27                 =>  P_ATTRIBUTE27,
			  P_ATTRIBUTE28                 =>  P_ATTRIBUTE28,
			  P_ATTRIBUTE29                 =>  P_ATTRIBUTE29,
			  P_ATTRIBUTE30                 =>  P_ATTRIBUTE30,
			  P_REQUEST_ID                  =>  P_REQUEST_ID,
			  P_PROGRAM_APPLICATION_ID      =>  P_PROGRAM_APPLICATION_ID,
			  P_PROGRAM_ID                  =>  P_PROGRAM_ID,
			  P_PROGRAM_UPDATE_DATE         =>  P_PROGRAM_UPDATE_DATE,
			  P_LAST_UPDATE_DATE            =>  P_LAST_UPDATE_DATE,
			  P_LAST_UPDATED_BY             =>  P_LAST_UPDATED_BY,
			  P_LAST_UPDATE_LOGIN           =>  P_LAST_UPDATE_LOGIN,
			  P_FROM_PUBLIC_API		=>  P_FROM_PUBLIC_API ,
			  P_INSTANCE_NUMBER		=>  P_INSTANCE_NUMBER,
			  P_LOCATION_TYPE_CODE		=> P_LOCATION_TYPE_CODE,
			  P_LOCATION_ID			=> P_LOCATION_ID,
			  p_active_end_date		=> p_active_end_date,
			  p_linear_location_id		=> p_linear_location_id,
			  p_operational_log_flag	=> p_operational_log_flag,
			  p_checkin_status		=> p_checkin_status,
			  p_supplier_warranty_exp_date 	=> p_supplier_warranty_exp_date,
			  p_equipment_gen_object_id   	=> p_equipment_gen_object_id
			  ,p_reactivate_asset		=> p_reactivate_asset
			  ,p_disassociate_fa_flag       => p_disassociate_fa_flag
			  ,X_RETURN_STATUS 		=>  l_x_asset_return_status
			  ,X_MSG_COUNT 			=>  l_x_asset_msg_count
			  ,X_MSG_DATA 			=>  l_x_asset_msg_data
  			);
		end if;

		x_return_status := l_x_asset_return_status;
		x_msg_count := l_x_asset_msg_count;
		x_msg_data := l_x_asset_msg_data;

		if (l_x_asset_return_status <> FND_API.G_RET_STS_SUCCESS) then
			       RAISE FND_API.G_EXC_ERROR ;
		else
			--if (p_owning_department_id is not null OR p_accounting_class_code is not null OR p_area_id is not null) then

			    /* bug 5177526 : Need to pass maint org id */
			    SELECT maint_organization_id INTO l_count
			      FROM mtl_parameters
			     WHERE organization_id = p_organization_id;

			     if (p_from_public_api = 'N') then
			     	l_owning_department_id := nvl(p_owning_department_id,FND_API.G_MISS_NUM);
			     	l_accounting_class_code := nvl(p_accounting_class_code,FND_API.G_MISS_CHAR);
			     	l_area_id := nvl(p_area_id,FND_API.G_MISS_NUM);
			     else
			     	l_owning_department_id := p_owning_department_id;
			     	l_accounting_class_code := p_accounting_class_code;
			     	l_area_id := p_area_id;
			     end if;

				EAM_ORG_MAINT_DEFAULTS_PVT.update_insert_row(
					p_api_version 		=> p_api_version
					,p_object_type 		=> 50
					,p_object_id            => l_instance_id
					,p_organization_id	=> l_count
					,p_owning_department_id  => l_owning_department_id
					,p_accounting_class_code => l_accounting_class_code
					,p_area_id               => l_area_id
					,x_return_status         => l_x_maint_return_status
					,x_msg_count             => l_x_maint_msg_count
					,x_msg_data              => l_x_maint_msg_data
				);
				x_return_status := l_x_maint_return_status;
				x_msg_count := l_x_maint_msg_count;
				x_msg_data := l_x_maint_msg_data;
			--end if;

		end if;

		-- End of API body.
		-- Standard check of p_commit.
		IF fnd_api.to_boolean(p_commit) THEN
			COMMIT WORK;
		END IF;


		-- Standard call to get message count and if count is 1, get message info.
		fnd_msg_pub.count_and_get(
			 p_count => x_msg_count
			,p_data => x_msg_data);


	EXCEPTION
		      WHEN fnd_api.g_exc_error THEN
			 ROLLBACK TO update_asset;
			 x_return_status := fnd_api.g_ret_sts_error;
			 /*fnd_msg_pub.count_and_get(
			    p_count => x_msg_count
			   ,p_data => x_msg_data);*/
		      WHEN fnd_api.g_exc_unexpected_error THEN
			 ROLLBACK TO update_asset;
			 x_return_status := fnd_api.g_ret_sts_unexp_error;
			 /*fnd_msg_pub.count_and_get(
			    p_count => x_msg_count
			   ,p_data => x_msg_data);*/
		      WHEN OTHERS THEN
			 ROLLBACK TO update_asset;
			 x_return_status := fnd_api.g_ret_sts_unexp_error;

			 IF fnd_msg_pub.check_msg_level(
			       fnd_msg_pub.g_msg_lvl_unexp_error) THEN
			    fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
			 END IF;

			 /*fnd_msg_pub.count_and_get(
			    p_count => x_msg_count
	   			,p_data => x_msg_data);*/


  	end update_asset;

  	PROCEDURE SERIAL_CHECK
	( p_api_version                IN    NUMBER,
	  p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
	  p_commit                     IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
	  p_validation_level           IN    NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
	  x_return_status              OUT NOCOPY   VARCHAR2,
	  x_msg_count                  OUT NOCOPY   NUMBER,
	  x_msg_data                   OUT NOCOPY   VARCHAR2,
	  x_errorcode                  OUT NOCOPY   NUMBER,
	  x_ser_num_in_item_id		OUT NOCOPY boolean,
	  p_INVENTORY_ITEM_ID		IN NUMBER,
	  p_SERIAL_NUMBER              IN    VARCHAR2,
	  p_ORGANIZATION_ID            IN    NUMBER
	) IS
	    l_api_name       CONSTANT VARCHAR2(30) := 'serial_check';
	    l_api_version    CONSTANT NUMBER       := 1.0;
	    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
	    l_serial_number_type number;
	    l_count number;
	BEGIN

	      -- Standard Start of API savepoint
	      SAVEPOINT serial_check;

	      -- Standard call to check for call compatibility.
	      IF NOT fnd_api.compatible_api_call(
	            l_api_version
	           ,p_api_version
	           ,l_api_name
	           ,g_pkg_name) THEN
	         RAISE fnd_api.g_exc_unexpected_error;
	      END IF;

	      -- Initialize message list if p_init_msg_list is set to TRUE.
	      IF fnd_api.to_boolean(p_init_msg_list) THEN
	         fnd_msg_pub.initialize;
	      END IF;

	      --  Initialize API return status to success
	      x_return_status := fnd_api.g_ret_sts_success;

	      -- API body

	   -- added to fix bug 2446341
	   -- get serial_number_type and pass it to mtl_serial_check.SNUniqueCheck

	   x_ser_num_in_item_id := FALSE;
	   select serial_number_type
	   into l_serial_number_type
	   from mtl_parameters
	   where organization_id = p_organization_id;

	    mtl_serial_check.SNUniqueCheck(
	      p_api_version         =>  0.9,
	      x_return_status       =>  x_return_status,
	      x_errorcode           =>  x_errorcode,
	      x_msg_count           =>  x_msg_count,
	      x_msg_data            =>  x_msg_data,
	      p_org_id              =>  p_organization_id,
	      p_serial_number_type  =>  l_serial_number_type,
	      p_serial_number       =>  p_Serial_number);


	    /*IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	       RAISE FND_API.G_EXC_ERROR ;
	    END IF;
	    */

	    -- check if serial number exists within asset group
	    select count(1) into l_count
	    from mtl_serial_numbers
	    where inventory_item_id = p_inventory_item_id
	    and serial_number = p_serial_number;

	    if l_count > 0 then
	    	x_return_status := FND_API.G_RET_STS_ERROR;
	    	x_ser_num_in_item_id := TRUE;
	    else
	        x_ser_num_in_item_id := FALSE;
	    end if;



	      -- End of API body.
	      -- Standard check of p_commit.
	      IF fnd_api.to_boolean(p_commit) THEN
	         COMMIT WORK;
	      END IF;

	      -- Standard call to get message count and if count is 1, get message info.
	      fnd_msg_pub.count_and_get(
	         p_count => x_msg_count
	        ,p_data => x_msg_data);


	   EXCEPTION
	      WHEN fnd_api.g_exc_error THEN
	         ROLLBACK TO serial_check;
	         x_return_status := fnd_api.g_ret_sts_error;
	         fnd_msg_pub.count_and_get(
	            p_count => x_msg_count
	           ,p_data => x_msg_data);
	      WHEN fnd_api.g_exc_unexpected_error THEN
	         ROLLBACK TO serial_check;
	         x_return_status := fnd_api.g_ret_sts_unexp_error;
	         fnd_msg_pub.count_and_get(
	            p_count => x_msg_count
	           ,p_data => x_msg_data);
	      WHEN OTHERS THEN
	         ROLLBACK TO serial_check;
	         x_return_status := fnd_api.g_ret_sts_unexp_error;

	         IF fnd_msg_pub.check_msg_level(
	               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
	            fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
	         END IF;

	         fnd_msg_pub.count_and_get(
	            p_count => x_msg_count
	           ,p_data => x_msg_data);

	END SERIAL_CHECK;

procedure find_assets(
  p_organization_id number
  ,p_inventory_item_id number
  ,p_instance_id number
  ,p_category_id number
  ,P_PN_LOCATION_ID                NUMBER,
  P_EAM_LOCATION_ID               NUMBER,
  P_FA_ASSET_ID                   NUMBER,
  P_ASSET_CRITICALITY_CODE        VARCHAR2,
  P_WIP_ACCOUNTING_CLASS_CODE     VARCHAR2,
  P_MAINTAINABLE_FLAG             VARCHAR2,
  P_OWNING_DEPARTMENT_ID          NUMBER,
   P_PROD_ORGANIZATION_ID          NUMBER,
  P_EQUIPMENT_ITEM_ID             NUMBER,
  P_EQP_SERIAL_NUMBER             VARCHAR2
  ,p_eam_item_type                NUMBER
  ,p_asset_category_id            NUMBER
) is
cursor asset_cur is
select cii.serial_number,
cii.instance_number,
cii.inventory_item_id,
msn.gen_object_id
from csi_item_instances cii,
mtl_serial_numbers msn,
fa_additions fa,
csi_i_assets cia,
mtl_system_items msi,
mtl_parameters mp,
eam_org_maint_defaults eomd,
mtl_system_items msi_prod,
mtl_serial_numbers msn_prod,
mtl_parameters mp_prod
where cii.last_vld_organization_id = msn.current_organization_id
and cii.inventory_item_id=msn.inventory_item_id
and cii.serial_number=msn.serial_number
and cii.last_vld_organization_id = p_organization_id
and nvl(cii.network_asset_flag,'N') = 'N'
and msi.eam_item_type=p_eam_item_type
and msi.inventory_item_id = cii.inventory_item_id
and msi.organization_id = cii.last_vld_organization_id
and cii.instance_id = cia.instance_id(+)
and cia.fa_asset_id = fa.asset_id(+)
and mp.organization_id = cii.last_vld_organization_id
and cii.instance_id = eomd.object_id (+)
and eomd.object_type(+) = 50
and eomd.organization_id(+) = cii.last_vld_organization_id --mp.maint_organization_id
and cii.equipment_gen_object_id      = msn_prod.gen_object_id(+)
and msn_prod.current_organization_id = msi_prod.organization_id(+)
and msn_prod.inventory_item_id       = msi_prod.inventory_item_id(+)
and msi_prod.organization_id         = mp_prod.organization_id(+)
and msi_prod.equipment_type(+)       = 1
and (p_inventory_item_id is null or p_inventory_item_id = cii.inventory_item_id)
and (p_instance_id is null or p_instance_id = cii.instance_id)
and (p_category_id is null or p_category_id = cii.category_id)
and (P_PN_LOCATION_ID is null or P_PN_LOCATION_ID = cii.pn_location_id)
and (P_EAM_LOCATION_ID is null or P_EAM_LOCATION_ID= eomd.area_id)
and (P_FA_ASSET_ID is null or P_FA_ASSET_ID =  fa.asset_id)
and (P_ASSET_CRITICALITY_CODE is null or P_ASSET_CRITICALITY_CODE = cii.asset_criticality_code)
and (P_WIP_ACCOUNTING_CLASS_CODE is null or P_WIP_ACCOUNTING_CLASS_CODE = eomd.accounting_class_code)
and (P_MAINTAINABLE_FLAG is null or P_MAINTAINABLE_FLAG = cii.maintainable_flag)
and (P_OWNING_DEPARTMENT_ID is null or P_OWNING_DEPARTMENT_ID = eomd.OWNING_DEPARTMENT_ID)
and (P_PROD_ORGANIZATION_ID is null or P_PROD_ORGANIZATION_ID = msn_prod.CURRENT_ORGANIZATION_ID)
and (P_EQUIPMENT_ITEM_ID is null or P_EQUIPMENT_ITEM_ID = msi_prod.INVENTORY_ITEM_ID)
and (P_EQP_SERIAL_NUMBER is null or P_EQP_SERIAL_NUMBER = decode(msi_prod.equipment_type,null,null,1,msn_prod.serial_number,null))
and (P_ASSET_CATEGORY_ID is null or p_ASSET_CATEGORY_ID = fa.asset_category_id)
  ;
begin
commit;
  for asset in asset_cur
  loop
      begin
              INSERT INTO  EAM_ASSET_RESULTS_GTT(gen_object_id)
              VALUES (asset.gen_object_id);
        exception

              when DUP_VAL_ON_INDEX then
                    null;
              when others then
                    RAISE;
        end;

  	begin
  		insert  into EAM_ASSET_RESULTS_GTT (gen_object_id)
  		(select object_id from mtl_object_genealogy
		 where  genealogy_type = 5
                and (sysdate between NVL(start_date_active,sysdate-1) and NVL(end_date_active,sysdate+1))
  		start with parent_object_id = asset.gen_object_id
		connect by parent_object_id = prior object_id
		and prior genealogy_type = 5
		and sysdate between NVL(prior start_date_active,sysdate-1) and NVL(prior end_date_active,sysdate+1)
		);
	exception
         when DUP_VAL_ON_INDEX then
                    null;
          when others then
            RAISE;
        end;

    end loop;
end find_assets;
END EAM_ASSET_NUMBER_PVT;

/
