--------------------------------------------------------
--  DDL for Package Body HXC_INTEGRATION_LAYER_V1_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_INTEGRATION_LAYER_V1_GRP" AS
/* $Header: hxcintegrationv1.pkb 120.1 2005/12/05 14:18:29 arundell noship $ */


--
-- UTILITY PACKAGE
--

-- ----------------------------------------------------------------------------
-- |-------------------------< int_to_otl_timecard_info>----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE int_to_otl_timecard_info(
		 p_building_blocks_otl  IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info
		,p_building_blocks_int 	IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.timecard_info)
		IS

l_index			NUMBER;

BEGIN

l_index := p_building_blocks_int.first;

LOOP
  EXIT WHEN (NOT p_building_blocks_int.exists(l_index));

      p_building_blocks_otl(l_index).time_building_block_id :=
          p_building_blocks_int(l_index).time_building_block_id;
      p_building_blocks_otl(l_index).TYPE :=
      	  p_building_blocks_int(l_index).TYPE;
      p_building_blocks_otl(l_index).measure :=
      	  p_building_blocks_int(l_index).measure;
      p_building_blocks_otl(l_index).unit_of_measure :=
      	  p_building_blocks_int(l_index).unit_of_measure;
      p_building_blocks_otl(l_index).start_time :=
      	  p_building_blocks_int(l_index).start_time;
      p_building_blocks_otl(l_index).stop_time :=
      	  p_building_blocks_int(l_index).stop_time;
      p_building_blocks_otl(l_index).parent_building_block_id :=
      	  p_building_blocks_int(l_index).parent_building_block_id;
      p_building_blocks_otl(l_index).parent_is_new :=
      	  p_building_blocks_int(l_index).parent_is_new;
      p_building_blocks_otl(l_index).SCOPE :=
      	  p_building_blocks_int(l_index).SCOPE;
      p_building_blocks_otl(l_index).object_version_number :=
      	  p_building_blocks_int(l_index).object_version_number;
      p_building_blocks_otl(l_index).approval_status :=
      	  p_building_blocks_int(l_index).approval_status;
      p_building_blocks_otl(l_index).resource_id :=
      	  p_building_blocks_int(l_index).resource_id;
      p_building_blocks_otl(l_index).resource_type :=
      	  p_building_blocks_int(l_index).resource_type;
      p_building_blocks_otl(l_index).approval_style_id :=
      	  p_building_blocks_int(l_index).approval_style_id;
      p_building_blocks_otl(l_index).date_from :=
      	  p_building_blocks_int(l_index).date_from;
      p_building_blocks_otl(l_index).date_to :=
      	  p_building_blocks_int(l_index).date_to;
      p_building_blocks_otl(l_index).comment_text :=
      	  p_building_blocks_int(l_index).comment_text;
      p_building_blocks_otl(l_index).parent_building_block_ovn :=
      	  p_building_blocks_int(l_index).parent_building_block_ovn;
      p_building_blocks_otl(l_index).NEW :=
      	  p_building_blocks_int(l_index).NEW;
      p_building_blocks_otl(l_index).changed :=
      	  p_building_blocks_int(l_index).changed;
      p_building_blocks_otl(l_index).process :=
      	  p_building_blocks_int(l_index).process;
      p_building_blocks_otl(l_index).application_set_id :=
      	  p_building_blocks_int(l_index).application_set_id;

   l_index := p_building_blocks_int.next(l_index);

END LOOP;
-- delete the structure
p_building_blocks_int.delete;

END int_to_otl_timecard_info;

-- ----------------------------------------------------------------------------
-- |-------------------------< otl_to_int_timecard_info>----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_timecard_info(
		 p_building_blocks_otl  IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info
		,p_building_blocks_int 	IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.timecard_info)
		IS
l_index			NUMBER;

BEGIN

l_index := p_building_blocks_otl.first;

LOOP
  EXIT WHEN (NOT p_building_blocks_otl.exists(l_index));

      p_building_blocks_int(l_index).time_building_block_id :=
          p_building_blocks_otl(l_index).time_building_block_id;
      p_building_blocks_int(l_index).TYPE :=
      	  p_building_blocks_otl(l_index).TYPE;
      p_building_blocks_int(l_index).measure :=
      	  p_building_blocks_otl(l_index).measure;
      p_building_blocks_int(l_index).unit_of_measure :=
      	  p_building_blocks_otl(l_index).unit_of_measure;
      p_building_blocks_int(l_index).start_time :=
      	  p_building_blocks_otl(l_index).start_time;
      p_building_blocks_int(l_index).stop_time :=
      	  p_building_blocks_otl(l_index).stop_time;
      p_building_blocks_int(l_index).parent_building_block_id :=
      	  p_building_blocks_otl(l_index).parent_building_block_id;
      p_building_blocks_int(l_index).parent_is_new :=
      	  p_building_blocks_otl(l_index).parent_is_new;
      p_building_blocks_int(l_index).SCOPE :=
      	  p_building_blocks_otl(l_index).SCOPE;
      p_building_blocks_int(l_index).object_version_number :=
      	  p_building_blocks_otl(l_index).object_version_number;
      p_building_blocks_int(l_index).approval_status :=
      	  p_building_blocks_otl(l_index).approval_status;
      p_building_blocks_int(l_index).resource_id :=
      	  p_building_blocks_otl(l_index).resource_id;
      p_building_blocks_int(l_index).resource_type :=
      	  p_building_blocks_otl(l_index).resource_type;
      p_building_blocks_int(l_index).approval_style_id :=
      	  p_building_blocks_otl(l_index).approval_style_id;
      p_building_blocks_int(l_index).date_from :=
      	  p_building_blocks_otl(l_index).date_from;
      p_building_blocks_int(l_index).date_to :=
      	  p_building_blocks_otl(l_index).date_to;
      p_building_blocks_int(l_index).comment_text :=
      	  p_building_blocks_otl(l_index).comment_text;
      p_building_blocks_int(l_index).parent_building_block_ovn :=
      	  p_building_blocks_otl(l_index).parent_building_block_ovn;
      p_building_blocks_int(l_index).NEW :=
      	  p_building_blocks_otl(l_index).NEW;
      p_building_blocks_int(l_index).changed :=
      	  p_building_blocks_otl(l_index).changed;
      p_building_blocks_int(l_index).process :=
      	  p_building_blocks_otl(l_index).process;
      p_building_blocks_int(l_index).application_set_id :=
      	  p_building_blocks_otl(l_index).application_set_id;

   l_index := p_building_blocks_otl.next(l_index);

END LOOP;
-- delete the structure
p_building_blocks_otl.delete;

END otl_to_int_timecard_info;



-- ----------------------------------------------------------------------------
-- |--------------------< int_to_otl_app_attributes_info>----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE int_to_otl_app_attributes_info(
		 p_app_attributes_otl  IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info
		,p_app_attributes_int  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info)
		IS

l_index			NUMBER;

BEGIN

l_index := p_app_attributes_int.first;

LOOP
  EXIT WHEN (NOT p_app_attributes_int.exists(l_index));

      p_app_attributes_otl(l_index).time_attribute_id :=
      		p_app_attributes_int(l_index).time_attribute_id;
      p_app_attributes_otl(l_index).building_block_id :=
      		p_app_attributes_int(l_index).building_block_id;
      p_app_attributes_otl(l_index).attribute_name :=
      		p_app_attributes_int(l_index).attribute_name;
      p_app_attributes_otl(l_index).attribute_value :=
      		p_app_attributes_int(l_index).attribute_value;
      p_app_attributes_otl(l_index).attribute_index :=
      		p_app_attributes_int(l_index).attribute_index;
      p_app_attributes_otl(l_index).segment :=
      		p_app_attributes_int(l_index).segment;
      p_app_attributes_otl(l_index).bld_blk_info_type :=
      		p_app_attributes_int(l_index).bld_blk_info_type;
      p_app_attributes_otl(l_index).CATEGORY :=
      		p_app_attributes_int(l_index).CATEGORY;
      p_app_attributes_otl(l_index).updated :=
      		p_app_attributes_int(l_index).updated;
      p_app_attributes_otl(l_index).changed :=
      		p_app_attributes_int(l_index).changed;
      p_app_attributes_otl(l_index).process :=
      		p_app_attributes_int(l_index).process;

   l_index := p_app_attributes_int.next(l_index);

END LOOP;
-- delete the structure
p_app_attributes_int.delete;

END int_to_otl_app_attributes_info;

-- ----------------------------------------------------------------------------
-- |-------------------< otl_to_int_app_attributes_info>----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_app_attributes_info(
		 p_app_attributes_otl  IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info
		,p_app_attributes_int  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info)
		IS

l_index			NUMBER;

BEGIN

l_index := p_app_attributes_otl.first;

LOOP
  EXIT WHEN (NOT p_app_attributes_otl.exists(l_index));


      p_app_attributes_int(l_index).time_attribute_id :=
      		p_app_attributes_otl(l_index).time_attribute_id;
      p_app_attributes_int(l_index).building_block_id :=
      		p_app_attributes_otl(l_index).building_block_id;
      p_app_attributes_int(l_index).attribute_name :=
      		p_app_attributes_otl(l_index).attribute_name;
      p_app_attributes_int(l_index).attribute_value :=
      		p_app_attributes_otl(l_index).attribute_value;
      p_app_attributes_int(l_index).attribute_index :=
      		p_app_attributes_otl(l_index).attribute_index;
      p_app_attributes_int(l_index).segment :=
      		p_app_attributes_otl(l_index).segment;
      p_app_attributes_int(l_index).bld_blk_info_type :=
      		p_app_attributes_otl(l_index).bld_blk_info_type;
      p_app_attributes_int(l_index).CATEGORY :=
      		p_app_attributes_otl(l_index).CATEGORY;
      p_app_attributes_int(l_index).updated :=
      		p_app_attributes_otl(l_index).updated;
      p_app_attributes_int(l_index).changed :=
      		p_app_attributes_otl(l_index).changed;
      p_app_attributes_int(l_index).process :=
      		p_app_attributes_otl(l_index).process;


   l_index := p_app_attributes_otl.next(l_index);

END LOOP;
-- delete the structure
p_app_attributes_otl.delete;

END otl_to_int_app_attributes_info;



-- ----------------------------------------------------------------------------
-- |-------------------------< int_to_otl_message_table>----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE int_to_otl_message_table(
		 p_messages_otl  IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.message_table
		,p_messages_int  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table)
		IS

l_index			NUMBER;

BEGIN

l_index := p_messages_int.first;

LOOP
  EXIT WHEN (NOT p_messages_int.exists(l_index));

      p_messages_otl(l_index).message_name :=
      		p_messages_int(l_index).message_name;
      p_messages_otl(l_index).message_level :=
      		p_messages_int(l_index).message_level;
      p_messages_otl(l_index).message_field :=
      		p_messages_int(l_index).message_field;
      p_messages_otl(l_index).message_tokens :=
      		p_messages_int(l_index).message_tokens;
      p_messages_otl(l_index).application_short_name :=
      		p_messages_int(l_index).application_short_name;
      p_messages_otl(l_index).time_building_block_id :=
      		p_messages_int(l_index).time_building_block_id;
      p_messages_otl(l_index).time_building_block_ovn :=
      		p_messages_int(l_index).time_building_block_ovn;
      p_messages_otl(l_index).time_attribute_id :=
      		p_messages_int(l_index).time_attribute_id;
      p_messages_otl(l_index).time_attribute_ovn :=
      		p_messages_int(l_index).time_attribute_ovn;
      p_messages_otl(l_index).on_oa_msg_stack :=
      		p_messages_int(l_index).on_oa_msg_stack;
      p_messages_otl(l_index).message_extent :=
      		p_messages_int(l_index).message_extent;

   l_index := p_messages_int.next(l_index);

END LOOP;
-- delete the structure
p_messages_int.delete;

END int_to_otl_message_table;


-- ----------------------------------------------------------------------------
-- |-------------------------< otl_to_int_message_table>----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_message_table(
		 p_messages_otl  IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.message_table
		,p_messages_int  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table)
		IS

l_index			NUMBER;

BEGIN

l_index := p_messages_otl.first;

LOOP
  EXIT WHEN (NOT p_messages_otl.exists(l_index));

      p_messages_int(l_index).message_name :=
      		p_messages_otl(l_index).message_name;
      p_messages_int(l_index).message_level :=
      		p_messages_otl(l_index).message_level;
      p_messages_int(l_index).message_field :=
      		p_messages_otl(l_index).message_field;
      p_messages_int(l_index).message_tokens :=
      		p_messages_otl(l_index).message_tokens;
      p_messages_int(l_index).application_short_name :=
      		p_messages_otl(l_index).application_short_name;
      p_messages_int(l_index).time_building_block_id :=
      		p_messages_otl(l_index).time_building_block_id;
      p_messages_int(l_index).time_building_block_ovn :=
      		p_messages_otl(l_index).time_building_block_ovn;
      p_messages_int(l_index).time_attribute_id :=
      		p_messages_otl(l_index).time_attribute_id;
      p_messages_int(l_index).time_attribute_ovn :=
      		p_messages_otl(l_index).time_attribute_ovn;
      p_messages_int(l_index).on_oa_msg_stack :=
      		p_messages_otl(l_index).on_oa_msg_stack;
      p_messages_int(l_index).message_extent :=
      		p_messages_otl(l_index).message_extent;

   l_index := p_messages_otl.next(l_index);

END LOOP;
-- delete the structure
p_messages_otl.delete;

END otl_to_int_message_table;


--
-- HXC_SELF_SERVICE_TIME_DEPOSIT
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_app_hook_params    >----------------------|
-- ----------------------------------------------------------------------------
procedure get_app_hook_params(
		 p_building_blocks IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.timecard_info
		,p_app_attributes  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info
		,p_messages        IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table)
		IS

l_building_blocks_otl	HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;
l_app_attributes_otl	HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info;
l_messages_otl          HXC_SELF_SERVICE_TIME_DEPOSIT.message_table;


BEGIN

--
-- call of the OTL API
--
HXC_SELF_SERVICE_TIME_DEPOSIT.get_app_hook_params (
      p_building_blocks   =>  l_building_blocks_otl
     ,p_app_attributes    =>  l_app_attributes_otl
     ,p_messages          =>  l_messages_otl
     );

-- transfer the data from otl pl/sql table
-- to the integration pl/sql table
otl_to_int_timecard_info
		(p_building_blocks_otl  => l_building_blocks_otl
		,p_building_blocks_int 	=> p_building_blocks);

otl_to_int_app_attributes_info
		(p_app_attributes_otl  => l_app_attributes_otl
		,p_app_attributes_int  => p_app_attributes);

otl_to_int_message_table
		(p_messages_otl  => l_messages_otl
		,p_messages_int  => p_messages);


END get_app_hook_params;


-- ----------------------------------------------------------------------------
-- |---------------------------< set_app_hook_params    >----------------------|
-- ----------------------------------------------------------------------------
procedure set_app_hook_params(
                        p_building_blocks IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.timecard_info
                       ,p_app_attributes  IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info
                       ,p_messages        IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table)
                       IS


l_building_blocks_otl	HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;
l_app_attributes_otl	HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info;
l_messages_otl          HXC_SELF_SERVICE_TIME_DEPOSIT.message_table;


BEGIN

-- transfer the data from the integration pl/sql table
-- to the otl pl/sql table
int_to_otl_timecard_info
		(p_building_blocks_otl  => l_building_blocks_otl
		,p_building_blocks_int 	=> p_building_blocks);

int_to_otl_app_attributes_info
		(p_app_attributes_otl  => l_app_attributes_otl
		,p_app_attributes_int  => p_app_attributes);

int_to_otl_message_table
		(p_messages_otl  => l_messages_otl
		,p_messages_int  => p_messages);
--
-- call of the OTL API
--
HXC_SELF_SERVICE_TIME_DEPOSIT.set_app_hook_params (
      p_building_blocks   =>  l_building_blocks_otl
     ,p_app_attributes    =>  l_app_attributes_otl
     ,p_messages          =>  l_messages_otl
     );


-- transfer the data from the otl pl/sql table
-- to the integration pl/sql table
otl_to_int_timecard_info
		(p_building_blocks_otl  => l_building_blocks_otl
		,p_building_blocks_int 	=> p_building_blocks);

otl_to_int_app_attributes_info
		(p_app_attributes_otl  => l_app_attributes_otl
		,p_app_attributes_int  => p_app_attributes);

otl_to_int_message_table
		(p_messages_otl  => l_messages_otl
		,p_messages_int  => p_messages);



END set_app_hook_params;


--
-- HXC_GENERIC_RETRIEVAL_PKG TRANSFER UTILITY PROCEDURE
--
-- ----------------------------------------------------------------------------
-- |---------------------< otl_to_int_gb_tx_detail_status >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_gb_tx_detail_status IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_status.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_status.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_index) :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_status(l_index);


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_status.next(l_index);

END LOOP;

END otl_to_int_gb_tx_detail_status;
-- ----------------------------------------------------------------------------
-- |-------------------< otl_to_int_gb_tx_detail_exception >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_gb_tx_detail_except IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_exception.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_exception.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_index) :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_exception(l_index);


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_exception.next(l_index);

END LOOP;

END otl_to_int_gb_tx_detail_except;
-- ----------------------------------------------------------------------------
-- |----------------------< otl_to_int_gb_detail_bld_blks >-------------------|
-- ----------------------------------------------------------------------------

PROCEDURE otl_to_int_gb_detail_bld_blks	IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).type :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).type;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).measure :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).measure;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).start_time :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).start_time;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).stop_time :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).stop_time;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).parent_bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).parent_bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).scope :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).scope;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).resource_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).resource_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).resource_type :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).resource_type;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).comment_text :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).comment_text;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).uom :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).uom;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).ovn :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).ovn;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).changed :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).changed;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).deleted :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).deleted;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).timecard_bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).timecard_bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_bld_blks(l_index).timecard_ovn :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks(l_index).timecard_ovn;


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_detail_bld_blks.next(l_index);

END LOOP;

END otl_to_int_gb_detail_bld_blks;
-- ----------------------------------------------------------------------------
-- |-------------------< otl_to_int_gb_old_detail_bld_blks >-------------------|
-- ----------------------------------------------------------------------------

PROCEDURE otl_to_int_gb_old_det_bld_blks IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).type :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).type;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).measure :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).measure;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).start_time :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).start_time;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).stop_time :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).stop_time;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).parent_bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).parent_bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).scope :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).scope;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).resource_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).resource_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).resource_type :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).resource_type;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).comment_text :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).comment_text;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).uom :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).uom;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).ovn :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).ovn;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).changed :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).changed;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).deleted :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).deleted;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).timecard_bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).timecard_bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_bld_blks(l_index).timecard_ovn :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks(l_index).timecard_ovn;


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_bld_blks.next(l_index);

END LOOP;

END otl_to_int_gb_old_det_bld_blks;
-- ----------------------------------------------------------------------------
-- |---------------------< otl_to_int_gb_detail_attributes >-------------------|
-- ----------------------------------------------------------------------------

PROCEDURE otl_to_int_gb_detail_att IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes(l_index).bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes(l_index).bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes(l_index).field_name :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes(l_index).field_name;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes(l_index).value :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes(l_index).value;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes(l_index).context :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes(l_index).context;
	HXC_USER_TYPE_DEFINITION_GRP.t_detail_attributes(l_index).category :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes(l_index).category;


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_detail_attributes.next(l_index);

END LOOP;

END otl_to_int_gb_detail_att;
-- ----------------------------------------------------------------------------
-- |-----------------< otl_to_int_gb_old_detail_attributes >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_gb_old_detail_att IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes(l_index).bb_id :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes(l_index).bb_id;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes(l_index).field_name :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes(l_index).field_name;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes(l_index).value :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes(l_index).value;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes(l_index).context :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes(l_index).context;
	HXC_USER_TYPE_DEFINITION_GRP.t_old_detail_attributes(l_index).category :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes(l_index).category;


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_old_detail_attributes.next(l_index);

END LOOP;

END otl_to_int_gb_old_detail_att;
-- ----------------------------------------------------------------------------
-- |----------------------< otl_to_int_gb_tx_detail_bb_id >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_gb_tx_detail_bb_id	IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_bb_id.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_bb_id.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_bb_id.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_bb_id(l_index) :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_bb_id(l_index);


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_bb_id.next(l_index);

END LOOP;

END otl_to_int_gb_tx_detail_bb_id;
-- ----------------------------------------------------------------------------
-- |---------------------< int_to_otl_gb_tx_detail_status >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE int_to_otl_gb_tx_detail_status IS
l_index			NUMBER;

BEGIN

l_index := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status.first;

LOOP
  EXIT WHEN (NOT HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status.exists(l_index));

	HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_status(l_index) :=
	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status(l_index);


   l_index := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_status.next(l_index);

END LOOP;

END int_to_otl_gb_tx_detail_status;

-- ----------------------------------------------------------------------------
-- |------------------< int_to_otl_gb_tx_detail_exception >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE int_to_otl_gb_tx_detail_except IS

l_index			NUMBER;

BEGIN

l_index := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception.first;

LOOP
  EXIT WHEN (NOT HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception.exists(l_index));

	HXC_GENERIC_RETRIEVAL_PKG.t_tx_detail_exception(l_index) :=
	    HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception(l_index);


   l_index := HXC_USER_TYPE_DEFINITION_GRP.t_tx_detail_exception.next(l_index);

END LOOP;

END int_to_otl_gb_tx_detail_except;


-- ----------------------------------------------------------------------------
-- |-------------------< otl_to_int_gb_time_bld_blks >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE otl_to_int_gb_time_bld_blks IS

l_index			NUMBER;

BEGIN

-- delete the integration global pl/sql first
HXC_USER_TYPE_DEFINITION_GRP.t_time_bld_blks.delete;

l_index := HXC_GENERIC_RETRIEVAL_PKG.t_time_bld_blks.first;

LOOP
  EXIT WHEN (NOT HXC_GENERIC_RETRIEVAL_PKG.t_time_bld_blks.exists(l_index));

	HXC_USER_TYPE_DEFINITION_GRP.t_time_bld_blks(l_index).start_time :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_time_bld_blks(l_index).start_time;
	HXC_USER_TYPE_DEFINITION_GRP.t_time_bld_blks(l_index).stop_time :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_time_bld_blks(l_index).stop_time;
	HXC_USER_TYPE_DEFINITION_GRP.t_time_bld_blks(l_index).comment_text :=
	    HXC_GENERIC_RETRIEVAL_PKG.t_time_bld_blks(l_index).comment_text;


   l_index := HXC_GENERIC_RETRIEVAL_PKG.t_time_bld_blks.next(l_index);

END LOOP;

END otl_to_int_gb_time_bld_blks;


--
-- HXC_GENERIC_RETRIEVAL_PKG
--
-- ----------------------------------------------------------------------------
-- |---------------------------< execute_retrieval_process >-------------------|
-- ----------------------------------------------------------------------------
PROCEDURE execute_retrieval_process (
	 p_process		in	hxc_retrieval_processes.name%TYPE
	,p_transaction_code 	in	VARCHAR2
	,p_start_date		in	DATE default null
	,p_end_date		in	DATE default null
	,p_incremental		in	VARCHAR2 default 'Y'
	,p_rerun_flag		in	VARCHAR2 default 'N'
	,p_where_clause		in	VARCHAR2
	,p_scope		in	VARCHAR2 default 'DAY'
	,p_clusive		in	VARCHAR2 default 'EX'
	,p_unique_params 	in      VARCHAR2 default null)
	IS


BEGIN

--
-- call of the OTL API
--
HXC_GENERIC_RETRIEVAL_PKG.execute_retrieval_process
        (p_process		=> p_process
	,p_transaction_code 	=> p_transaction_code
	,p_start_date		=> p_start_date
	,p_end_date		=> p_end_date
	,p_incremental		=> p_incremental
	,p_rerun_flag		=> p_rerun_flag
	,p_where_clause		=> p_where_clause
	,p_scope		=> p_scope
	,p_clusive		=> p_clusive
	,p_unique_params	=> p_unique_params);

-- transfer the data from the otl pl/sql table
-- to the integration pl/sql table

otl_to_int_gb_tx_detail_status;

otl_to_int_gb_tx_detail_except;

otl_to_int_gb_detail_bld_blks;

otl_to_int_gb_old_det_bld_blks;

otl_to_int_gb_detail_att;

otl_to_int_gb_old_detail_att;

otl_to_int_gb_tx_detail_bb_id;

otl_to_int_gb_time_bld_blks;

END execute_retrieval_process;

-- ----------------------------------------------------------------------------
-- |---------------------------< Update_Transaction_Status >-------------------|
-- ----------------------------------------------------------------------------
Procedure Update_Transaction_Status(
		 p_process			hxc_retrieval_processes.name%TYPE
		,p_status			hxc_transactions.status%TYPE
		,p_exception_description   	hxc_transactions.exception_description%TYPE
		,p_rollback 			BOOLEAN DEFAULT FALSE)
		IS
BEGIN

-- transfer the data from the integration pl/sql table
-- to the otl pl/sql table
int_to_otl_gb_tx_detail_status;

int_to_otl_gb_tx_detail_except;

--
-- call of the OTL API
--
HXC_GENERIC_RETRIEVAL_PKG.Update_Transaction_Status(
		 p_process			=> p_process
		,p_status			=> p_status
		,p_exception_description   	=> p_exception_description
		,p_rollback 			=> p_rollback);


END Update_Transaction_Status;

--
-- HXC_GENERIC_RETRIEVAL_UTILS
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_parent_statuses >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_parent_statuses IS

BEGIN

--
-- Populate the detail status table
-- from the integration table
--
int_to_otl_gb_tx_detail_status;
--
-- call of the OTL API
--
HXC_GENERIC_RETRIEVAL_UTILS.set_parent_statuses;

END set_parent_statuses;


-- ----------------------------------------------------------------------------
-- |---------------------------< time_bld_blk_changed >------------------------|
-- ----------------------------------------------------------------------------

FUNCTION time_bld_blk_changed (
		p_bb_id	 NUMBER
	       ,p_bb_ovn NUMBER)
	       RETURN BOOLEAN
	       IS

l_return	BOOLEAN;

BEGIN

--
-- call of the OTL API
--
l_return :=
    HXC_GENERIC_RETRIEVAL_UTILS.time_bld_blk_changed (
		p_bb_id	 => p_bb_id
	       ,p_bb_ovn => p_bb_ovn);

return l_return;

END time_bld_blk_changed;

--
-- HXC_TIME_ENTRY_RULES_UTILS_PKG
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_error_to_table >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_error_to_table (
	 p_message_table		in out nocopy   HXC_USER_TYPE_DEFINITION_GRP.MESSAGE_TABLE
	,p_message_name  		in     FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
	,p_message_token 		in     VARCHAR2
	,p_message_level 		in     VARCHAR2
        ,p_message_field 		in     VARCHAR2
	,p_application_short_name 	IN     VARCHAR2 default 'HXC'
	,p_timecard_bb_id     		in     NUMBER
	,p_time_attribute_id  		in     NUMBER
        ,p_timecard_bb_ovn    		in     NUMBER   default null
        ,p_time_attribute_ovn 		in     NUMBER   default null
        ,p_message_extent     		in     VARCHAR2 default null)
        IS

l_messages_otl          HXC_SELF_SERVICE_TIME_DEPOSIT.message_table;

BEGIN

-- transfer the data from the integration pl/sql table
-- to the otl pl/sql table
int_to_otl_message_table
		(p_messages_otl  => l_messages_otl
		,p_messages_int  => p_message_table);

--
-- call of the OTL API
--
HXC_TIME_ENTRY_RULES_UTILS_PKG.add_error_to_table (
	 p_message_table		=> l_messages_otl
	,p_message_name  		=> p_message_name
	,p_message_token 		=> p_message_token
	,p_message_level 		=> p_message_level
        ,p_message_field 		=> p_message_field
	,p_application_short_name 	=> p_application_short_name
	,p_timecard_bb_id     		=> p_timecard_bb_id
	,p_time_attribute_id  		=> p_time_attribute_id
        ,p_timecard_bb_ovn    		=> p_timecard_bb_ovn
        ,p_time_attribute_ovn 		=> p_time_attribute_ovn
        ,p_message_extent     		=> p_message_extent);


-- transfer the data from otl pl/sql table
-- to the integration pl/sql table
otl_to_int_message_table
		(p_messages_otl  => l_messages_otl
		,p_messages_int  => p_message_table);


END add_error_to_table;

--
-- HXC_MAPPING_UTILITIES
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_mappingvalue_sum >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_mappingvalue_sum (
 		 p_bld_blk_info_type VARCHAR2
		,p_field_name1       VARCHAR2
		,p_field_name2       VARCHAR2
		,p_field_value2      VARCHAR2
		,p_status            VARCHAR2
                ,p_resource_id       VARCHAR2
		) RETURN NUMBER
		IS

l_return	NUMBER;

BEGIN

--
-- call of the OTL API
--
l_return :=
	HXC_MAPPING_UTILITIES.get_mappingvalue_sum (
	         p_bld_blk_info_type => p_bld_blk_info_type
		,p_field_name1       => p_field_name1
		,p_field_name2       => p_field_name2
		,p_field_value2      => p_field_value2
		,p_status            => p_status
                ,p_resource_id       => p_resource_id);

return l_return;

END get_mappingvalue_sum;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mapping_exists >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION chk_mapping_exists (
		 p_bld_blk_info_type 		VARCHAR2
		,p_field_name  			VARCHAR2
		,p_field_value 			VARCHAR2
		,p_scope       			VARCHAR2
                ,p_retrieval_process_name 	VARCHAR2 DEFAULT 'None'
                ,p_status   			VARCHAR2 DEFAULT 'None'
                ,p_end_date 			DATE DEFAULT null)
                RETURN BOOLEAN
                IS

l_return	BOOLEAN;

BEGIN
--
-- call of the OTL API
--
l_return :=
	HXC_MAPPING_UTILITIES.chk_mapping_exists (
		 p_bld_blk_info_type 		=> p_bld_blk_info_type
		,p_field_name  			=> p_field_name
		,p_field_value 			=> p_field_value
		,p_scope       			=> p_scope
                ,p_retrieval_process_name 	=> p_retrieval_process_name
                ,p_status   			=> p_status
                ,p_end_date 			=> p_end_date);

return l_return;


END chk_mapping_exists;

--
-- HXC_DEPOSIT_WRAPPER_UTILITIES
--
-- ----------------------------------------------------------------------------
-- |---------------------------< messages_to_string >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION messages_to_string
           (p_messages IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.message_table)
           RETURN VARCHAR2
           IS

l_return	VARCHAR2(32767);
l_messages_otl  HXC_SELF_SERVICE_TIME_DEPOSIT.message_table;

BEGIN

-- transfer the data from the integration pl/sql table
-- to the otl pl/sql table
int_to_otl_message_table
		(p_messages_otl  => l_messages_otl
		,p_messages_int  => p_messages);

--
-- call of the OTL API
--
l_return :=
	HXC_DEPOSIT_WRAPPER_UTILITIES.messages_to_string
           (p_messages => l_messages_otl);


-- transfer the data from the olt pl/sql table
-- to the integration pl/sql table
otl_to_int_message_table
		(p_messages_otl  => l_messages_otl
		,p_messages_int  => p_messages);


return l_return;

END messages_to_string;
-- ----------------------------------------------------------------------------
-- |---------------------------< attributes_to_string >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION attributes_to_string(
  	p_attributes IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info)
  	RETURN VARCHAR2
  	IS

l_return		VARCHAR2(32767);
l_app_attributes_otl	HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info;


BEGIN

-- transfer the data from the integration pl/sql table
-- to the otl pl/sql table
int_to_otl_app_attributes_info
		(p_app_attributes_otl  => l_app_attributes_otl
		,p_app_attributes_int  => p_attributes);

--
-- call of the OTL API
--
l_return :=
	HXC_DEPOSIT_WRAPPER_UTILITIES.attributes_to_string
           (p_attributes => l_app_attributes_otl);


-- transfer the data from the olt pl/sql table
-- to the integration pl/sql table
otl_to_int_app_attributes_info
		(p_app_attributes_otl  => l_app_attributes_otl
		,p_app_attributes_int  => p_attributes);

return l_return;

END attributes_to_string;
-- ----------------------------------------------------------------------------
-- |---------------------------< blocks_to_string >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION blocks_to_string
           (p_blocks IN OUT NOCOPY HXC_USER_TYPE_DEFINITION_GRP.timecard_info)
           RETURN VARCHAR2
           IS

l_return		VARCHAR2(32767);
l_building_blocks_otl	HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;

BEGIN
-- transfer the data from integration pl/sql table
-- to otl pl/sql table
int_to_otl_timecard_info
		(p_building_blocks_otl  => l_building_blocks_otl
		,p_building_blocks_int 	=> p_blocks);

--
-- call of the OTL API
--

l_return :=
	HXC_DEPOSIT_WRAPPER_UTILITIES.blocks_to_string
           (p_blocks => l_building_blocks_otl);


-- transfer the data from the olt pl/sql table
-- to the integration pl/sql table
otl_to_int_timecard_info
		(p_building_blocks_otl  => l_building_blocks_otl
		,p_building_blocks_int 	=> p_blocks);


return l_return;

END blocks_to_string;
--
-- HXC_PERIOD_EVALUATION
--
-- ----------------------------------------------------------------------------
-- |---------------------------< period_start_stop >------------------------|
-- ----------------------------------------------------------------------------
procedure period_start_stop(p_current_date 		date,
                            p_rec_period_start_date 	date,
                            l_period_start 		in out nocopy date,
                            l_period_end 		in out nocopy date,
                            l_base_period_type 		varchar2)
                            IS
BEGIN
--
-- call of the OTL API
--
HXC_PERIOD_EVALUATION.period_start_stop(
			 p_current_date 	 => p_current_date
                        ,p_rec_period_start_date => p_rec_period_start_date
                        ,l_period_start 	 => l_period_start
                        ,l_period_end 		 => l_period_end
                        ,l_base_period_type 	 => l_base_period_type);


END period_start_stop;



--
-- HXC_APPROVAL_WF_PKG
--
-- ----------------------------------------------------------------------------
-- |-----------------< get_wf_G_Time_Building_Blocks >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_wf_g_time_building_blocks
           RETURN HXC_USER_TYPE_DEFINITION_GRP.timecard_info
           IS


l_building_blocks_otl	HXC_SELF_SERVICE_TIME_DEPOSIT.timecard_info;
l_building_blocks_int	HXC_USER_TYPE_DEFINITION_GRP.timecard_info;

BEGIN

l_building_blocks_int.delete;
l_building_blocks_otl.delete;

--
-- call of the OTL API
--
l_building_blocks_otl := HXC_APPROVAL_WF_PKG.g_time_building_blocks;

-- transfer the data from the integration pl/sql table
-- to the otl pl/sql table
otl_to_int_timecard_info
		(p_building_blocks_otl  => l_building_blocks_otl
		,p_building_blocks_int 	=> l_building_blocks_int);

return l_building_blocks_int;

END get_wf_g_time_building_blocks;

-- ----------------------------------------------------------------------------
-- |-----------------< get_wf_G_Time_App_Attributes >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_wf_g_time_app_attributes
           RETURN HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info
           IS

l_app_attributes_otl  HXC_SELF_SERVICE_TIME_DEPOSIT.app_attributes_info;
l_app_attributes_int  HXC_USER_TYPE_DEFINITION_GRP.app_attributes_info;

BEGIN

l_app_attributes_int.delete;
l_app_attributes_otl.delete;

--
-- call of the OTL API
--
l_app_attributes_otl := HXC_APPROVAL_WF_PKG.g_time_app_attributes;


otl_to_int_app_attributes_info(
		 p_app_attributes_otl  => l_app_attributes_otl
		,p_app_attributes_int  => l_app_attributes_int);

return l_app_attributes_int;

END get_wf_g_time_app_attributes;


--
--  HXC_TIMECARD_INFO
--
-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_status >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_approval_status
	(p_timecard_id in hxc_timecard_summary.timecard_id%type)
	    RETURN hxc_timecard_summary.approval_status%type
	    IS

l_return  hxc_timecard_summary.approval_status%type;

BEGIN

l_return :=
	HXC_TIME_APPROVAL_INFO.get_timecard_approval_status
		(p_timecard_id => p_timecard_id);

return l_return;

END get_timecard_approval_status;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_status 2>------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_approval_status
	(p_resource_id in hxc_timecard_summary.resource_id%type
 	,p_start_time in hxc_timecard_summary.start_time%type
 	,p_stop_time in hxc_timecard_summary.stop_time%type)
	    RETURN hxc_timecard_summary.approval_status%type
	    IS

l_return  hxc_timecard_summary.approval_status%type;

BEGIN

l_return :=
	HXC_TIME_APPROVAL_INFO.get_timecard_approval_status
		(p_resource_id => p_resource_id
	 	,p_start_time  => p_start_time
	 	,p_stop_time   => p_stop_time);

return l_return;

END get_timecard_approval_status;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_submission_date >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_submission_date
	(p_timecard_id in hxc_timecard_summary.timecard_id%type)
	   RETURN hxc_timecard_summary.submission_date%type
	   IS

l_return  hxc_timecard_summary.submission_date%type;

BEGIN

l_return :=
 	HXC_TIME_APPROVAL_INFO.get_timecard_submission_date
		(p_timecard_id => p_timecard_id);

return l_return;

END get_timecard_submission_date;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_submission_date 2>------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_submission_date
	(p_resource_id in hxc_timecard_summary.resource_id%type
 	,p_start_time in hxc_timecard_summary.start_time%type
 	,p_stop_time in hxc_timecard_summary.stop_time%type)
	  RETURN hxc_timecard_summary.submission_date%type
	  IS

l_return  hxc_timecard_summary.submission_date%type;

BEGIN

l_return :=
 	HXC_TIME_APPROVAL_INFO.get_timecard_submission_date
		(p_resource_id => p_resource_id
	 	,p_start_time  => p_start_time
	 	,p_stop_time   => p_stop_time);

return l_return;

END get_timecard_submission_date;


-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_date    >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_timecard_approval_date
	(p_timecard_id in hxc_timecard_summary.timecard_id%type)
	  RETURN hxc_timecard_summary.submission_date%type
	  IS

l_return  hxc_timecard_summary.submission_date%type;

BEGIN

l_return :=
	HXC_TIME_APPROVAL_INFO.get_timecard_approval_date
		(p_timecard_id => p_timecard_id);

return l_return;

END get_timecard_approval_date;

-- ----------------------------------------------------------------------------
-- |-----------------< get_timecard_approval_date 2  >------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_timecard_approval_date
	(p_resource_id in hxc_timecard_summary.resource_id%type
 	,p_start_time in hxc_timecard_summary.start_time%type
 	,p_stop_time in hxc_timecard_summary.stop_time%type)
	  RETURN hxc_timecard_summary.submission_date%type
	  IS

l_return  hxc_timecard_summary.submission_date%type;

BEGIN

l_return :=
	HXC_TIME_APPROVAL_INFO.get_timecard_approval_date
		(p_resource_id => p_resource_id
	 	,p_start_time  => p_start_time
	 	,p_stop_time   => p_stop_time);

return l_return;

END get_timecard_approval_date;



--
--  Straight Interface
--
-- ----------------------------------------------------------------------------
-- |-----------------------------------< build_block >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION build_block
          (p_time_building_block_id  IN HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn IN HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
          ) RETURN HXC_USER_TYPE_DEFINITION_GRP.building_block_info IS

cursor c_block
        (p_time_building_block_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
        ,p_time_building_block_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
        ) is
select *
  from hxc_time_building_blocks
 where time_building_block_id = p_time_building_block_id
   and object_version_number  = p_time_building_block_ovn;


l_block     		c_block%ROWTYPE;
l_new_block 		HXC_USER_TYPE_DEFINITION_GRP.building_block_info;
e_no_existing_block 	exception;

BEGIN

open c_block(p_time_building_block_id,p_time_building_block_ovn);
fetch c_block into l_block;

if(c_block%FOUND) then

  close c_block;

      l_new_block.time_building_block_id := l_block.time_building_block_id;
      l_new_block.TYPE 			 := l_block.TYPE;
      l_new_block.measure 		 := l_block.measure;
      l_new_block.unit_of_measure 	 := l_block.unit_of_measure;
      l_new_block.start_time 		 := l_block.start_time;
      l_new_block.stop_time 		 := l_block.stop_time;
      l_new_block.parent_building_block_id := l_block.parent_building_block_id;
      l_new_block.parent_is_new  	 := 'N';
      l_new_block.SCOPE 		 := l_block.SCOPE;
      l_new_block.object_version_number  := l_block.object_version_number;
      l_new_block.approval_status 	 := l_block.approval_status;
      l_new_block.resource_id  	 	 := l_block.resource_id;
      l_new_block.resource_type 	 := l_block.resource_type;
      l_new_block.approval_style_id 	 := l_block.approval_style_id;
      l_new_block.date_from 		 := l_block.date_from;
      l_new_block.date_to 		 := l_block.date_to;
      l_new_block.comment_text 		 := l_block.comment_text;
      l_new_block.parent_building_block_ovn := l_block.parent_building_block_ovn;
      l_new_block.NEW			 := 'N';
      l_new_block.changed 		 := 'N';
      l_new_block.application_set_id 	 := l_block.application_set_id;

else
  --
  -- No block with this id and ovn
  --
  close c_block;
  raise e_no_existing_block;

end if;

return l_new_block;

END build_block;


-- ----------------------------------------------------------------------------
-- |-------------------------------< build_attribute >------------------------|
-- ----------------------------------------------------------------------------
FUNCTION build_attribute
          (p_time_building_block_id  in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
          ,p_time_building_block_ovn in hxc_time_building_blocks.object_version_number%type
          ,p_attribute_category	     in hxc_time_attributes.attribute_category%type
          ) return HXC_USER_TYPE_DEFINITION_GRP.building_block_attribute_info is

cursor c_attribute is
  select a.*
    from hxc_time_attributes a,
         hxc_time_attribute_usages b
   where a.time_attribute_id 	   = b.time_attribute_id
     and b.time_building_block_id  = p_time_building_block_id
     and b.time_building_block_ovn = P_time_building_block_ovn
     and a.attribute_category      = nvl(p_attribute_category,a.attribute_category);


l_new_attribute 	HXC_USER_TYPE_DEFINITION_GRP.building_block_attribute_info;
l_attribute_row 	c_attribute%ROWTYPE;
l_index_att		NUMBER := 1;

Begin

FOR l_attribute_row in c_attribute LOOP

  l_new_attribute(l_index_att).TIME_ATTRIBUTE_ID  	:= l_attribute_row.TIME_ATTRIBUTE_ID;
  l_new_attribute(l_index_att).building_block_id  	:= p_time_building_block_id;
  l_new_attribute(l_index_att).ATTRIBUTE_CATEGORY 	:= l_attribute_row.ATTRIBUTE_CATEGORY;
  l_new_attribute(l_index_att).ATTRIBUTE1   	:= l_attribute_row.ATTRIBUTE1;
  l_new_attribute(l_index_att).ATTRIBUTE2   	:= l_attribute_row.ATTRIBUTE2;
  l_new_attribute(l_index_att).ATTRIBUTE3   	:= l_attribute_row.ATTRIBUTE3;
  l_new_attribute(l_index_att).ATTRIBUTE4   	:= l_attribute_row.ATTRIBUTE4;
  l_new_attribute(l_index_att).ATTRIBUTE5   	:= l_attribute_row.ATTRIBUTE5;
  l_new_attribute(l_index_att).ATTRIBUTE6   	:= l_attribute_row.ATTRIBUTE6;
  l_new_attribute(l_index_att).ATTRIBUTE7   	:= l_attribute_row.ATTRIBUTE7;
  l_new_attribute(l_index_att).ATTRIBUTE8   	:= l_attribute_row.ATTRIBUTE8;
  l_new_attribute(l_index_att).ATTRIBUTE9   	:= l_attribute_row.ATTRIBUTE9;
  l_new_attribute(l_index_att).ATTRIBUTE10   	:= l_attribute_row.ATTRIBUTE10;
  l_new_attribute(l_index_att).ATTRIBUTE11   	:= l_attribute_row.ATTRIBUTE11;
  l_new_attribute(l_index_att).ATTRIBUTE12   	:= l_attribute_row.ATTRIBUTE12;
  l_new_attribute(l_index_att).ATTRIBUTE13   	:= l_attribute_row.ATTRIBUTE13;
  l_new_attribute(l_index_att).ATTRIBUTE14   	:= l_attribute_row.ATTRIBUTE14;
  l_new_attribute(l_index_att).ATTRIBUTE15   	:= l_attribute_row.ATTRIBUTE15;
  l_new_attribute(l_index_att).ATTRIBUTE16   	:= l_attribute_row.ATTRIBUTE16;
  l_new_attribute(l_index_att).ATTRIBUTE17   	:= l_attribute_row.ATTRIBUTE17;
  l_new_attribute(l_index_att).ATTRIBUTE18   	:= l_attribute_row.ATTRIBUTE18;
  l_new_attribute(l_index_att).ATTRIBUTE19   	:= l_attribute_row.ATTRIBUTE19;
  l_new_attribute(l_index_att).ATTRIBUTE20   	:= l_attribute_row.ATTRIBUTE20;
  l_new_attribute(l_index_att).ATTRIBUTE21   	:= l_attribute_row.ATTRIBUTE21;
  l_new_attribute(l_index_att).ATTRIBUTE22   	:= l_attribute_row.ATTRIBUTE22;
  l_new_attribute(l_index_att).ATTRIBUTE23   	:= l_attribute_row.ATTRIBUTE23;
  l_new_attribute(l_index_att).ATTRIBUTE24   	:= l_attribute_row.ATTRIBUTE24;
  l_new_attribute(l_index_att).ATTRIBUTE25   	:= l_attribute_row.ATTRIBUTE25;
  l_new_attribute(l_index_att).ATTRIBUTE26   	:= l_attribute_row.ATTRIBUTE26;
  l_new_attribute(l_index_att).ATTRIBUTE27   	:= l_attribute_row.ATTRIBUTE27;
  l_new_attribute(l_index_att).ATTRIBUTE28   	:= l_attribute_row.ATTRIBUTE28;
  l_new_attribute(l_index_att).ATTRIBUTE29   	:= l_attribute_row.ATTRIBUTE29;
  l_new_attribute(l_index_att).ATTRIBUTE30   	:= l_attribute_row.ATTRIBUTE30;
  l_new_attribute(l_index_att).BLD_BLK_INFO_TYPE_ID  := l_attribute_row.BLD_BLK_INFO_TYPE_ID;
  l_new_attribute(l_index_att).OBJECT_VERSION_NUMBER := l_attribute_row.OBJECT_VERSION_NUMBER;
  l_new_attribute(l_index_att).NEW   		:= 'N';
  l_new_attribute(l_index_att).CHANGED   	:= 'N';

  l_index_att := l_index_att + 1;

  -- not set
  --l_new_attribute.BLD_BLK_INFO_TYPE   ,get_bld_blk_info_type(l_attribute_row.BLD_BLK_INFO_TYPE_ID)

END LOOP;


return l_new_attribute;

End Build_Attribute;


END HXC_INTEGRATION_LAYER_V1_GRP;

/
