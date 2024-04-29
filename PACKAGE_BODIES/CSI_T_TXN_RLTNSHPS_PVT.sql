--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_RLTNSHPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_RLTNSHPS_PVT" as
/* $Header: csivtiib.pls 115.19 2003/09/02 21:56:41 shegde ship $ */

  g_pkg_name    CONSTANT VARCHAR2(30) := 'csi_t_txn_rltnshps_pvt';
  g_file_name   CONSTANT VARCHAR2(12) := 'csivtiib.pls';

  g_user_id              NUMBER := FND_GLOBAL.User_Id;
  g_login_id             NUMBER := FND_GLOBAL.Login_Id;

  PROCEDURE create_txn_ii_rltns_dtls(
    p_api_version        IN  NUMBER,
    p_commit             IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list      IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level   IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_ii_rltns_rec   IN  OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_rec,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)

  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'pvt.create_txn_ii_rltns_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;
    l_txn_relationship_id     NUMBER;
    l_return_status           VARCHAR2(1);
    l_txn_line_dtl_rec1     csi_t_datastructures_grp.txn_line_detail_rec;
    l_txn_line_dtl_rec2     csi_t_datastructures_grp.txn_line_detail_rec;
    l_txn_line_dtl_g_miss   csi_t_datastructures_grp.txn_line_detail_rec;
    l_sub_instance_id       NUMBER ;
    l_sub_tld_id            NUMBER ;
    l_obj_instance_id       NUMBER ;
    l_obj_tld_id            NUMBER ;

  BEGIN

      csi_t_gen_utility_pvt.add('Begin : '||l_api_name);
    -- Standard Start of API savepoint
    SAVEPOINT create_txn_ii_rltns_dtls;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Check the profile option debug_level for debug message reporting

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

-- Added for CZ Integration (Begin)

    IF ( NVL(p_txn_ii_rltns_rec.sub_config_inst_hdr_id , fnd_api.g_miss_num)
          <> fnd_api.g_miss_num
         OR NVL(p_txn_ii_rltns_rec.obj_config_inst_hdr_id , fnd_api.g_miss_num)
          <> fnd_api.g_miss_num )
    AND p_txn_ii_rltns_rec.api_caller_identity <> 'CONFIG'
    THEN
      FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_CALLER');
      FND_MESSAGE.set_token('API_CALLER',p_txn_ii_rltns_rec.api_caller_identity) ;
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF ;

        IF (NVL(p_txn_ii_rltns_rec.sub_config_inst_hdr_id , fnd_api.g_miss_num) <>  fnd_api.g_miss_num
        AND NVL(p_txn_ii_rltns_rec.subject_id , fnd_api.g_miss_num)
         = fnd_api.g_miss_num)
        THEN
          -- Now assuming that user is passing only config keys , get the associated instance/txn_detail_line.

          csi_t_vldn_routines_pvt.get_cz_inst_or_tld_id (
          p_config_inst_hdr_id       => p_txn_ii_rltns_rec.sub_config_inst_hdr_id,
          p_config_inst_rev_num      => p_txn_ii_rltns_rec.sub_config_inst_rev_num,
          p_config_inst_item_id      => p_txn_ii_rltns_rec.sub_config_inst_item_id ,
          x_instance_id              => l_sub_instance_id  ,
          x_txn_line_detail_id       => l_sub_tld_id ,
          x_return_status            => x_return_status );

          IF x_return_status <> fnd_api.g_ret_sts_success
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;
          IF l_sub_instance_id IS NULL
             AND l_sub_tld_id IS NULL
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;

          IF l_sub_instance_id IS NOT NULL
          THEN
             p_txn_ii_rltns_rec.subject_id := l_sub_instance_id;
             p_txn_ii_rltns_rec.subject_type := 'I' ;
          ELSIF l_sub_tld_id IS NOT NULL
          THEN
             p_txn_ii_rltns_rec.subject_id := l_sub_tld_id;
             p_txn_ii_rltns_rec.subject_type := 'T' ;
          END IF ;
		-- get the display order for the subject
	  Begin
	     Select to_number(substr(cz.bom_sort_order,length(bom_sort_order)-3,4))
	     into p_txn_ii_rltns_rec.display_order
	     from cz_config_items_v cz
	     where cz.instance_hdr_id  = p_txn_ii_rltns_rec.sub_config_inst_hdr_id
	     and   cz.instance_rev_nbr = p_txn_ii_rltns_rec.sub_config_inst_rev_num
	     and   cz.config_item_id   = p_txn_ii_rltns_rec.sub_config_inst_item_id;
	     Exception when others then
		Null;
	  End;

         END IF ; --subject_id is null


        IF (NVL(p_txn_ii_rltns_rec.obj_config_inst_hdr_id , fnd_api.g_miss_num) <>  fnd_api.g_miss_num
        AND NVL(p_txn_ii_rltns_rec.object_id , fnd_api.g_miss_num)
         = fnd_api.g_miss_num)
        THEN
          csi_t_vldn_routines_pvt.get_cz_inst_or_tld_id (
          p_config_inst_hdr_id       => p_txn_ii_rltns_rec.obj_config_inst_hdr_id,
          p_config_inst_rev_num      => p_txn_ii_rltns_rec.obj_config_inst_rev_num,
          p_config_inst_item_id      => p_txn_ii_rltns_rec.obj_config_inst_item_id ,
          x_instance_id              => l_obj_instance_id  ,
          x_txn_line_detail_id       => l_obj_tld_id ,
          x_return_status            => x_return_status );

          IF x_return_status <> fnd_api.g_ret_sts_success
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;

          IF l_obj_instance_id IS NOT NULL
          THEN
             p_txn_ii_rltns_rec.object_id := l_obj_instance_id;
             p_txn_ii_rltns_rec.object_type := 'I' ;
          ELSIF l_obj_tld_id IS NOT NULL
          THEN
             p_txn_ii_rltns_rec.object_id := l_obj_tld_id;
             p_txn_ii_rltns_rec.object_type := 'T' ;
          END IF ;

          IF l_obj_instance_id IS NULL
             AND l_obj_tld_id IS NULL
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;
        END IF ; --object_id is null
-- Added for CZ Integration (End)

    IF csi_t_gen_utility_pvt.g_debug_level > 1 THEN

      csi_t_gen_utility_pvt.dump_ii_rltns_rec(
        p_ii_rltns_rec => p_txn_ii_rltns_rec);

    END IF;

    -- Main API code

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value        => p_txn_ii_rltns_rec.object_type,
      p_param_name   => 'p_txn_ii_rltns_rec.object_type',
      p_api_name     => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value        => p_txn_ii_rltns_rec.object_id,
      p_param_name   => 'p_txn_ii_rltns_rec.object_id',
      p_api_name     => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value        => p_txn_ii_rltns_rec.subject_type,
      p_param_name   => 'p_txn_ii_rltns_rec.subject_type',
      p_api_name     => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value        => p_txn_ii_rltns_rec.subject_id,
      p_param_name   => 'p_txn_ii_rltns_rec.subject_id',
      p_api_name     => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value        => p_txn_ii_rltns_rec.relationship_type_code,
      p_param_name   => 'p_txn_ii_rltns_rec.relationship_type_code',
      p_api_name     => l_api_name);

   -- Added for M-M to make sure correctly initialized params are passed for the validate_txn_rltnshp routine call down below    Start

    IF  p_txn_ii_rltns_rec.subject_type not in ('T', 'I') THEN
    	FND_MESSAGE.set_name('CSI','CSI_TXN_II_INVALID_RLTNS_TYPE');
    	FND_MESSAGE.set_token('RLTNS_TYPE',p_txn_ii_rltns_rec.subject_type);
    	FND_MSG_PUB.add;
    	RAISE fnd_api.g_exc_error;
    ELSIF p_txn_ii_rltns_rec.object_type not in ('T', 'I')  THEN
    	FND_MESSAGE.set_name('CSI','CSI_TXN_II_INVALID_RLTNS_TYPE');
    	FND_MESSAGE.set_token('RLTNS_TYPE',p_txn_ii_rltns_rec.object_type);
    	FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
    ELSIF (p_txn_ii_rltns_rec.subject_type = 'I'
	AND p_txn_ii_rltns_rec.object_type = 'I' )  THEN
        FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_SUB_OBJ_TYPES');
        FND_MESSAGE.set_token('TXN_DTL_ID',p_txn_ii_rltns_rec.object_id);
        FND_MSG_PUB.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
    ELSIF  NOT(p_txn_ii_rltns_rec.subject_type = 'T'
	AND p_txn_ii_rltns_rec.object_type = 'T' )  THEN
	IF p_txn_ii_rltns_rec.subject_type = 'T' THEN
         l_txn_line_dtl_rec1  := l_txn_line_dtl_g_miss;-- subject TLD record
	ELSE
         l_txn_line_dtl_rec2  := l_txn_line_dtl_g_miss; --object TLD record
	END IF;
    END IF;


    IF  p_txn_ii_rltns_rec.subject_type = 'T' THEN
  /*    IF nvl(p_txn_ii_rltns_rec.subject_index_flag,fnd_api.g_miss_char)
       = fnd_api.g_miss_char THEN  -- Added the IF for M-M . checking the index flags so that records passed by the txn details grp API are not validated again.
*/
    csi_t_gen_utility_pvt.add('Validate subject_id.');

        csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
          p_txn_line_detail_id => p_txn_ii_rltns_rec.subject_id,
	     x_txn_line_detail_rec =>l_txn_line_dtl_rec2, -- calling the overloaded routine. M-M change
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_SUBJECT_ID_INVALID');
          FND_MESSAGE.set_token('SUBJECT_ID',p_txn_ii_rltns_rec.subject_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

        END IF;
 --     END IF;
    END IF;

    IF  p_txn_ii_rltns_rec.object_type = 'T'  THEN
      /* IF nvl(p_txn_ii_rltns_rec.object_index_flag,fnd_api.g_miss_char)
       = fnd_api.g_miss_char THEN -- Added for M-M . checking the index flags so that records passed by the txn details grp API are not validated again.
*/
    csi_t_gen_utility_pvt.add('Validate object_id.');

        csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
          p_txn_line_detail_id  => p_txn_ii_rltns_rec.object_id,
	     x_txn_line_detail_rec =>l_txn_line_dtl_rec1, -- calling the overloaded routine. M-M change
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

           FND_MESSAGE.set_name('CSI','CSI_TXN_OBJECT_ID_INVALID');
           FND_MESSAGE.set_token('OBJECT_ID',p_txn_ii_rltns_rec.object_id);
           FND_MSG_PUB.add;
           RAISE fnd_api.g_exc_error;

        END IF;
 --     END IF;
    END IF;

    csi_t_gen_utility_pvt.add('Validate relationship_type code.');

    -- validate relationship_type_code  csi_ii_relation_types table
    csi_t_vldn_routines_pvt.validate_ii_rltns_type_code(
      p_rltns_type_code => p_txn_ii_rltns_rec.relationship_type_code,
      x_return_status   => l_return_status);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      FND_MESSAGE.set_name('CSI','CSI_TXN_II_RLTNS_CODE_INVALID');
      FND_MESSAGE.set_token('RLTNS_CODE',
                             p_txn_ii_rltns_rec.relationship_type_code);
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate instance reference

    IF nvl(p_txn_ii_rltns_rec.csi_inst_relationship_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
      csi_t_gen_utility_pvt.add('Validate instance reference.');
      csi_t_vldn_routines_pvt.validate_instance_reference(
        p_level              => 'II_RLTNS',
        p_level_dtl_id       => p_txn_ii_rltns_rec.object_id,
        p_level_inst_ref_id  => p_txn_ii_rltns_rec.csi_inst_relationship_id,
        x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        csi_t_gen_utility_pvt.add('Error in here.');
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate transfer_components
    IF  p_txn_ii_rltns_rec.transfer_components_flag <> fnd_api.g_miss_char THEN
     IF p_txn_ii_rltns_rec.relationship_type_code
         NOT IN ('REPLACED-BY', 'REPLACEMENT-FOR','UPGRADED-FROM') THEN
    	FND_MESSAGE.set_name('CSI','CSI_TXN_PARAM_IGNORED_WARN');
    	FND_MESSAGE.set_token('PARAM','transfer_components_flag');
    	FND_MESSAGE.set_token('VALUE',p_txn_ii_rltns_rec.transfer_components_flag);
    	FND_MESSAGE.set_token('REASON','This attribute is applicable to
          REPLACED-BY, REPLACEMENT-FOR,UPGRADED-FROM relationship types only');
    	FND_MSG_PUB.add;
        p_txn_ii_rltns_rec.transfer_components_flag := fnd_api.g_miss_char;
     END IF;
    END IF;

    -- validate mandatory_flag

    -- validate display_order

    -- validate position_reference

    /* Added M-M changes Validate the relationship record  */
	csi_t_gen_utility_pvt.dump_line_detail_rec
( p_line_detail_rec => l_txn_line_dtl_rec1
);

	csi_t_gen_utility_pvt.dump_line_detail_rec
( p_line_detail_rec => l_txn_line_dtl_rec2
);

    csi_t_vldn_routines_pvt.validate_txn_rltnshp (
                p_txn_line_detail_rec1 =>  l_txn_line_dtl_rec1,
                p_txn_line_detail_rec2 =>  l_txn_line_dtl_rec2,
                p_iir_rec              =>  p_txn_ii_rltns_rec,
                x_return_status        =>  l_return_status);

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
     END IF;

    -- call table handler

    if nvl(p_txn_ii_rltns_rec.txn_relationship_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num then
      l_txn_relationship_id := p_txn_ii_rltns_rec.txn_relationship_id;
    end if;

    begin

      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'insert_row',
        p_pkg_name => 'csi_t_ii_relationships_pkg');

      csi_t_ii_relationships_pkg.insert_row(
        px_txn_relationship_id     => l_txn_relationship_id,
        p_transaction_line_id      => p_txn_ii_rltns_rec.transaction_line_id,
        p_object_type              => p_txn_ii_rltns_rec.object_type,
        p_object_id                => p_txn_ii_rltns_rec.object_id,
        p_relationship_type_code   => p_txn_ii_rltns_rec.relationship_type_code,
        p_display_order            => p_txn_ii_rltns_rec.display_order,
        p_position_reference       => p_txn_ii_rltns_rec.position_reference,
        p_mandatory_flag           => p_txn_ii_rltns_rec.mandatory_flag,
        p_active_start_date        => p_txn_ii_rltns_rec.active_start_date,
        p_active_end_date          => p_txn_ii_rltns_rec.active_end_date,
        p_csi_inst_relationship_id => p_txn_ii_rltns_rec.csi_inst_relationship_id,
        p_subject_type             => p_txn_ii_rltns_rec.subject_type,
        p_subject_id               => p_txn_ii_rltns_rec.subject_id,

        -- Added for CZ Integration (Begin)
        p_sub_config_inst_hdr_id   => p_txn_ii_rltns_rec.sub_config_inst_hdr_id ,
        p_sub_config_inst_rev_num  => p_txn_ii_rltns_rec.sub_config_inst_rev_num  ,
        p_sub_config_inst_item_id  => p_txn_ii_rltns_rec.sub_config_inst_item_id  ,
        p_obj_config_inst_hdr_id   => p_txn_ii_rltns_rec.obj_config_inst_hdr_id    ,
        p_obj_config_inst_rev_num  => p_txn_ii_rltns_rec.obj_config_inst_rev_num  ,
        p_obj_config_inst_item_id  => p_txn_ii_rltns_rec.obj_config_inst_item_id ,
        p_target_commitment_date   => p_txn_ii_rltns_rec.target_commitment_date ,
        -- Added for CZ Integration (End)
        p_attribute1               => p_txn_ii_rltns_rec.attribute1,
        p_attribute2               => p_txn_ii_rltns_rec.attribute2,
        p_attribute3               => p_txn_ii_rltns_rec.attribute3,
        p_attribute4               => p_txn_ii_rltns_rec.attribute4,
        p_attribute5               => p_txn_ii_rltns_rec.attribute5,
        p_attribute6               => p_txn_ii_rltns_rec.attribute6,
        p_attribute7               => p_txn_ii_rltns_rec.attribute7,
        p_attribute8               => p_txn_ii_rltns_rec.attribute8,
        p_attribute9               => p_txn_ii_rltns_rec.attribute9,
        p_attribute10              => p_txn_ii_rltns_rec.attribute10,
        p_attribute11              => p_txn_ii_rltns_rec.attribute11,
        p_attribute12              => p_txn_ii_rltns_rec.attribute12,
        p_attribute13              => p_txn_ii_rltns_rec.attribute13,
        p_attribute14              => p_txn_ii_rltns_rec.attribute14,
        p_attribute15              => p_txn_ii_rltns_rec.attribute15,
        p_created_by               => g_user_id,
        p_creation_date            => sysdate,
        p_last_updated_by          => g_user_id,
        p_last_update_date         => sysdate,
        p_last_update_login        => g_login_id,
        p_object_version_number    => 1.0,
        p_context                  => p_txn_ii_rltns_rec.context,
        p_transfer_components_flag      => p_txn_ii_rltns_rec.transfer_components_flag);

    exception
      when others then
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE',
           'csi_t_ii_relationships_pkg.insert_row Failed. '||substr(sqlerrm,1,200));
        fnd_msg_pub.add;
        raise fnd_api.g_exc_error;
    end;

    p_txn_ii_rltns_rec.txn_relationship_id := l_txn_relationship_id;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    IF csi_t_gen_utility_pvt.g_debug = fnd_api.g_true THEN
      csi_t_gen_utility_pvt.set_debug_off;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO create_txn_ii_rltns_dtls;

      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO create_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO create_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END create_txn_ii_rltns_dtls;

  PROCEDURE update_txn_ii_rltns_dtls (
    p_api_version       IN  NUMBER,
    p_commit            IN  VARCHAR2 := fnd_api.g_false,
    p_init_msg_list     IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level  IN  NUMBER   := fnd_api.g_valid_level_full,
    p_txn_ii_rltns_tbl  IN  csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'update_txn_ii_rltns_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status         VARCHAR2(1);
    l_processing_status     csi_t_transaction_lines.processing_status%TYPE;
    --l_iir_rec               csi_t_ii_relationships%ROWTYPE; M-M change . referencing datastructure record instead
    l_iir_rec               csi_t_datastructures_grp.txn_ii_rltns_rec;
    l_txn_line_dtl_rec1     csi_t_datastructures_grp.txn_line_detail_rec;
    l_txn_line_dtl_rec2     csi_t_datastructures_grp.txn_line_detail_rec;
    l_txn_line_dtl_g_miss   csi_t_datastructures_grp.txn_line_detail_rec;
    l_sub_instance_id       NUMBER ;
    l_sub_tld_id            NUMBER ;
    l_obj_instance_id       NUMBER ;
    l_obj_tld_id            NUMBER ;

    CURSOR iir_cur(p_rltns_id IN NUMBER) IS
      SELECT *
      FROM   csi_t_ii_relationships
      WHERE  txn_relationship_id = p_rltns_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_txn_ii_rltns_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --debug messages
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code
    IF p_txn_ii_rltns_tbl.count > 0 THEN
      FOR l_ind IN p_txn_ii_rltns_tbl.FIRST .. p_txn_ii_rltns_tbl.LAST
      LOOP

        IF l_debug_level > 1 THEN
          csi_t_gen_utility_pvt.dump_ii_rltns_rec(
            p_ii_rltns_rec => p_txn_ii_rltns_tbl(l_ind));
        END IF;

        l_iir_rec.txn_relationship_id  :=
          p_txn_ii_rltns_tbl(l_ind).txn_relationship_id;

        csi_t_vldn_routines_pvt.check_reqd_param(
          p_value      => l_iir_rec.txn_relationship_id,
          p_param_name => 'l_iir_rec.txn_relationship_id',
          p_api_name   => l_api_name);

        csi_t_vldn_routines_pvt.validate_txn_relationship_id(
          p_txn_relationship_id => l_iir_rec.txn_relationship_id,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_RLTNS_ID_INVALID');
          FND_MESSAGE.set_token('RLTNS_ID',l_iir_rec.txn_relationship_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

        END IF;

        FOR l_iir_cur_rec in iir_cur(l_iir_rec.txn_relationship_id)
        LOOP

          l_iir_rec.transaction_line_id  := l_iir_cur_rec.transaction_line_id;
          l_iir_rec.subject_id := p_txn_ii_rltns_tbl(l_ind).subject_id;
          l_iir_rec.object_id := p_txn_ii_rltns_tbl(l_ind).object_id;
          l_iir_rec.subject_type := p_txn_ii_rltns_tbl(l_ind).subject_type;
          l_iir_rec.object_type := p_txn_ii_rltns_tbl(l_ind).object_type;


-- Added for CZ Integration (Begin)

    IF ( NVL(p_txn_ii_rltns_tbl(l_ind).sub_config_inst_hdr_id , fnd_api.g_miss_num)
          <> fnd_api.g_miss_num
         OR NVL(p_txn_ii_rltns_tbl(l_ind).obj_config_inst_hdr_id , fnd_api.g_miss_num)
          <> fnd_api.g_miss_num )
    AND p_txn_ii_rltns_tbl(l_ind).api_caller_identity <> 'CONFIG'
    THEN
      FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_CALLER');
      FND_MESSAGE.set_token('API_CALLER',p_txn_ii_rltns_tbl(l_ind).api_caller_identity) ;
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF ;

        IF (NVL(p_txn_ii_rltns_tbl(l_ind).sub_config_inst_hdr_id , fnd_api.g_miss_num) <>  fnd_api.g_miss_num
        AND NVL(p_txn_ii_rltns_tbl(l_ind).subject_id , fnd_api.g_miss_num)
         = fnd_api.g_miss_num)
        THEN
          -- Now assuming that user is passing only config keys , get the associated instance/txn_detail_line.

          csi_t_vldn_routines_pvt.get_cz_inst_or_tld_id (
          p_config_inst_hdr_id       => p_txn_ii_rltns_tbl(l_ind).sub_config_inst_hdr_id,
          p_config_inst_rev_num      => p_txn_ii_rltns_tbl(l_ind).sub_config_inst_rev_num,
          p_config_inst_item_id      => p_txn_ii_rltns_tbl(l_ind).sub_config_inst_item_id ,
          x_instance_id              => l_sub_instance_id  ,
          x_txn_line_detail_id       => l_sub_tld_id ,
          x_return_status            => x_return_status );

          IF x_return_status <> fnd_api.g_ret_sts_success
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;
          IF l_sub_instance_id IS NULL
             AND l_sub_tld_id IS NULL
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;

          IF l_sub_instance_id IS NOT NULL
          THEN
             l_iir_rec.subject_id := l_sub_instance_id;
             l_iir_rec.subject_type := 'I' ;
          ELSIF l_sub_tld_id IS NOT NULL
          THEN
             l_iir_rec.subject_id := l_sub_tld_id;
             l_iir_rec.subject_type := 'T' ;
          END IF ;
	  -- get the display order for the subject
	  Begin
	     Select to_number(substr(cz.bom_sort_order,length(bom_sort_order)-3,4))
	     into l_iir_rec.display_order
	     from cz_config_items_v cz
	     where cz.instance_hdr_id = p_txn_ii_rltns_tbl(l_ind).sub_config_inst_hdr_id
	     and   cz.instance_rev_nbr= p_txn_ii_rltns_tbl(l_ind).sub_config_inst_rev_num
	     and   cz.config_item_id  = p_txn_ii_rltns_tbl(l_ind).sub_config_inst_item_id;
	     Exception when others then
		Null;
	  End;

         END IF ; --subject_id is null


        IF (NVL(p_txn_ii_rltns_tbl(l_ind).obj_config_inst_hdr_id , fnd_api.g_miss_num) <>  fnd_api.g_miss_num
        AND NVL(p_txn_ii_rltns_tbl(l_ind).object_id , fnd_api.g_miss_num)
         = fnd_api.g_miss_num)
        THEN
          csi_t_vldn_routines_pvt.get_cz_inst_or_tld_id (
          p_config_inst_hdr_id       => p_txn_ii_rltns_tbl(l_ind).obj_config_inst_hdr_id,
          p_config_inst_rev_num      => p_txn_ii_rltns_tbl(l_ind).obj_config_inst_rev_num,
          p_config_inst_item_id      => p_txn_ii_rltns_tbl(l_ind).obj_config_inst_item_id ,
          x_instance_id              => l_obj_instance_id  ,
          x_txn_line_detail_id       => l_obj_tld_id ,
          x_return_status            => x_return_status );

          IF x_return_status <> fnd_api.g_ret_sts_success
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;

          IF l_obj_instance_id IS NOT NULL
          THEN
             l_iir_rec.object_id := l_obj_instance_id;
             l_iir_rec.object_type := 'I' ;
          ELSIF l_obj_tld_id IS NOT NULL
          THEN
             l_iir_rec.object_id := l_obj_tld_id;
             l_iir_rec.object_type := 'T' ;
          END IF ;

          IF l_obj_instance_id IS NULL
             AND l_obj_tld_id IS NULL
          THEN
             RAISE fnd_api.g_exc_error ;
          END IF ;
        END IF ; --object_id is null
-- Added for CZ Integration (End)

   -- Added for M-M to make sure correctly initialized params are passed for the validate_txn_rltnshp routine call down below

    IF  l_iir_rec.subject_type not in ('T', 'I') THEN
    	FND_MESSAGE.set_name('CSI','CSI_TXN_II_INVALID_RLTNS_TYPE');
    	FND_MESSAGE.set_token('RLTNS_TYPE',l_iir_rec.subject_type);
    	FND_MSG_PUB.add;
    	RAISE fnd_api.g_exc_error;
    ELSIF l_iir_rec.object_type not in ('T', 'I')  THEN
    	FND_MESSAGE.set_name('CSI','CSI_TXN_II_INVALID_RLTNS_TYPE');
    	FND_MESSAGE.set_token('RLTNS_TYPE',l_iir_rec.object_type);
    	FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
    ELSIF (l_iir_rec.subject_type = 'I'
	AND l_iir_rec.object_type = 'I' )  THEN
        FND_MESSAGE.set_name('CSI','CSI_TXN_INVALID_SUB_OBJ_TYPES');
        FND_MESSAGE.set_token('TXN_DTL_ID',l_iir_rec.object_id);
        FND_MSG_PUB.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
    ELSIF  NOT(l_iir_rec.subject_type = 'T'
	AND l_iir_rec.object_type = 'T' )  THEN
	IF l_iir_rec.subject_type = 'T' THEN
         l_txn_line_dtl_rec1  := l_txn_line_dtl_g_miss;-- subject TLD record
	ELSE
         l_txn_line_dtl_rec2  := l_txn_line_dtl_g_miss; --object TLD record
	END IF;
    END IF;

    csi_t_gen_utility_pvt.add('Validate subject_id.');

    IF  l_iir_rec.subject_type = 'T'  THEN
        csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
          p_txn_line_detail_id => l_iir_rec.subject_id,
	     x_txn_line_detail_rec =>l_txn_line_dtl_rec2, -- calling the overloaded routine. M-M change
          x_return_status      => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_SUBJECT_ID_INVALID');
          FND_MESSAGE.set_token('SUBJECT_ID',l_iir_rec.subject_id);
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

        END IF;
    END IF;

    csi_t_gen_utility_pvt.add('Validate object_id.');

    IF  l_iir_rec.object_type = 'T'  THEN
    -- validate object_id
        csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
          p_txn_line_detail_id  => l_iir_rec.object_id,
	     x_txn_line_detail_rec =>l_txn_line_dtl_rec1, -- calling the overloaded routine. M-M change
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

           FND_MESSAGE.set_name('CSI','CSI_TXN_OBJECT_ID_INVALID');
           FND_MESSAGE.set_token('OBJECT_ID',l_iir_rec.object_id);
           FND_MSG_PUB.add;
           RAISE fnd_api.g_exc_error;

        END IF;
    END IF;

        BEGIN
	 IF l_iir_rec.subject_type = 'T' THEN
          SELECT tl.processing_status
          INTO   l_processing_status
          FROM   csi_t_transaction_lines tl, csi_t_txn_line_details tld
          WHERE  tld.txn_line_detail_id = l_iir_rec.subject_id
	  AND tl.transaction_line_id = l_iir_rec.transaction_line_id
	  AND tl.transaction_line_id = tld.transaction_line_id;

           IF l_processing_status = 'PROCESSED' THEN

             FND_MESSAGE.set_name('CSI','CSI_TXN_UPD_DEL_NOT_ALLOWED');
             FND_MESSAGE.set_token('LVL_ID', l_iir_rec.transaction_line_id);
             FND_MESSAGE.set_token('STATUS',l_processing_status);
             FND_MSG_PUB.add;
             RAISE FND_API.g_exc_error;

	   ELSIF l_iir_rec.object_type = 'T' THEN
          	SELECT tl.processing_status
          	INTO   l_processing_status
          	FROM   csi_t_transaction_lines tl, csi_t_txn_line_details tld
          	WHERE  tld.txn_line_detail_id = l_iir_rec.object_id
	  	AND tl.transaction_line_id = l_iir_rec.transaction_line_id
	  	AND tl.transaction_line_id = tld.transaction_line_id;

          	IF l_processing_status = 'PROCESSED' THEN

            	   FND_MESSAGE.set_name('CSI','CSI_TXN_UPD_DEL_NOT_ALLOWED');
                   FND_MESSAGE.set_token('LVL_ID', l_iir_rec.transaction_line_id);
                   FND_MESSAGE.set_token('STATUS',l_processing_status);
                   FND_MSG_PUB.add;
                   RAISE FND_API.g_exc_error;
		END IF;
	    END IF;
	  ELSIF l_iir_rec.object_type = 'T' THEN
          	SELECT tl.processing_status
          	INTO   l_processing_status
          	FROM   csi_t_transaction_lines tl, csi_t_txn_line_details tld
          	WHERE  tld.txn_line_detail_id = l_iir_rec.object_id
	  	AND tl.transaction_line_id = l_iir_rec.transaction_line_id
	  	AND tl.transaction_line_id = tld.transaction_line_id;

          	IF l_processing_status = 'PROCESSED' THEN

            	   FND_MESSAGE.set_name('CSI','CSI_TXN_UPD_DEL_NOT_ALLOWED');
                   FND_MESSAGE.set_token('LVL_ID', l_iir_rec.transaction_line_id);
                   FND_MESSAGE.set_token('STATUS',l_processing_status);
                   FND_MSG_PUB.add;
                   RAISE FND_API.g_exc_error;
		END IF;

          END IF;
	Exception when others then
           fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
           fnd_message.set_token('MESSAGE',
             'Unhandled exception in Update Txn reltns'||substr(sqlerrm,1,200));
           fnd_msg_pub.add;
           raise fnd_api.g_exc_error;
        END;

          l_iir_rec.relationship_type_code   :=
            p_txn_ii_rltns_tbl(l_ind).relationship_type_code;

          IF l_iir_rec.relationship_type_code <> fnd_api.g_miss_char THEN

            csi_t_vldn_routines_pvt.validate_ii_rltns_type_code(
              p_rltns_type_code => l_iir_rec.relationship_type_code,
              x_return_status   => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN

              FND_MESSAGE.set_name('CSI','CSI_TXN_II_RLTNS_CODE_INVALID');
              FND_MESSAGE.set_token('RLTNS_CODE',l_iir_rec.relationship_type_code);
              FND_MSG_PUB.add;
              RAISE fnd_api.g_exc_error;

            END IF;

          END IF;

    -- Validate transfer_components

          l_iir_rec.transfer_components_flag   :=
            p_txn_ii_rltns_tbl(l_ind).transfer_components_flag;

    	IF  l_iir_rec.transfer_components_flag <> fnd_api.g_miss_char THEN
     	 IF l_iir_rec.relationship_type_code
            NOT IN ('REPLACED-BY', 'REPLACEMENT-FOR','UPGRADED-FROM') THEN
    		FND_MESSAGE.set_name('CSI','CSI_TXN_PARAM_IGNORED_WARN');
    		FND_MESSAGE.set_token('PARAM','transfer_components_flag');
    		FND_MESSAGE.set_token('VALUE',l_iir_rec.transfer_components_flag);
    		FND_MESSAGE.set_token('REASON','This attribute is applicable to
          	     REPLACED-BY, REPLACEMENT-FOR,UPGRADED-FROM relationship types only');
    		FND_MSG_PUB.add;
                l_iir_rec.transfer_components_flag := fnd_api.g_miss_char;
     	 END IF;
    	END IF;

          l_iir_rec.csi_inst_relationship_id :=
            p_txn_ii_rltns_tbl(l_ind).csi_inst_relationship_id;

          -- ##validate instance relationship_id
          IF l_iir_rec.csi_inst_relationship_id <> fnd_api.g_miss_num
             AND
             l_iir_rec.csi_inst_relationship_id is not null
          THEN
            null;
          END IF;


    /* M-M changes Validate the relationship record  */

        csi_t_vldn_routines_pvt.validate_txn_rltnshp (
                p_txn_line_detail_rec1 =>  l_txn_line_dtl_rec1,
                p_txn_line_detail_rec2 =>  l_txn_line_dtl_rec2,
                p_iir_rec              =>  l_iir_rec,
                x_return_status        =>  l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
             RAISE fnd_api.g_exc_error;
         END IF;


          l_iir_rec.position_reference := p_txn_ii_rltns_tbl(l_ind).position_reference;
          l_iir_rec.mandatory_flag     := p_txn_ii_rltns_tbl(l_ind).mandatory_flag;
          l_iir_rec.active_start_date  := p_txn_ii_rltns_tbl(l_ind).active_start_date;
          l_iir_rec.active_end_date    := p_txn_ii_rltns_tbl(l_ind).active_end_date;
          l_iir_rec.attribute1         := p_txn_ii_rltns_tbl(l_ind).attribute1;
          l_iir_rec.attribute2         := p_txn_ii_rltns_tbl(l_ind).attribute2;
          l_iir_rec.attribute3         := p_txn_ii_rltns_tbl(l_ind).attribute3;
          l_iir_rec.attribute4         := p_txn_ii_rltns_tbl(l_ind).attribute4;
          l_iir_rec.attribute5         := p_txn_ii_rltns_tbl(l_ind).attribute5;
          l_iir_rec.attribute6         := p_txn_ii_rltns_tbl(l_ind).attribute6;
          l_iir_rec.attribute7         := p_txn_ii_rltns_tbl(l_ind).attribute7;
          l_iir_rec.attribute8         := p_txn_ii_rltns_tbl(l_ind).attribute8;
          l_iir_rec.attribute9         := p_txn_ii_rltns_tbl(l_ind).attribute9;
          l_iir_rec.attribute10        := p_txn_ii_rltns_tbl(l_ind).attribute10;
          l_iir_rec.attribute11        := p_txn_ii_rltns_tbl(l_ind).attribute11;
          l_iir_rec.attribute12        := p_txn_ii_rltns_tbl(l_ind).attribute12;
          l_iir_rec.attribute13        := p_txn_ii_rltns_tbl(l_ind).attribute13;
          l_iir_rec.attribute14        := p_txn_ii_rltns_tbl(l_ind).attribute14;
          l_iir_rec.attribute15        := p_txn_ii_rltns_tbl(l_ind).attribute15;
/* -- M-M change . Passing these directly in the table handler below
          l_iir_rec.created_by         := l_iir_cur_rec.created_by;
          l_iir_rec.creation_date      := l_iir_cur_rec.creation_date;
          l_iir_rec.last_updated_by    := g_user_id;
          l_iir_rec.last_update_date   := sysdate;
          l_iir_rec.last_update_login  := g_login_id;
*/
          l_iir_rec.context            := p_txn_ii_rltns_tbl(l_ind).context;
          -- Added for CZ Integration (Begin)
          l_iir_rec.sub_config_inst_hdr_id   := p_txn_ii_rltns_tbl(l_ind).sub_config_inst_hdr_id ;
          l_iir_rec.sub_config_inst_rev_num  := p_txn_ii_rltns_tbl(l_ind).sub_config_inst_rev_num  ;
          l_iir_rec.sub_config_inst_item_id  := p_txn_ii_rltns_tbl(l_ind).sub_config_inst_item_id  ;
          l_iir_rec.obj_config_inst_hdr_id   := p_txn_ii_rltns_tbl(l_ind).obj_config_inst_hdr_id    ;
          l_iir_rec.obj_config_inst_rev_num  := p_txn_ii_rltns_tbl(l_ind).obj_config_inst_rev_num  ;
          l_iir_rec.obj_config_inst_item_id  := p_txn_ii_rltns_tbl(l_ind).obj_config_inst_item_id ;
          l_iir_rec.target_commitment_date   := p_txn_ii_rltns_tbl(l_ind).target_commitment_date ;
          -- Added for CZ Integration (End)
          l_iir_rec.object_version_number    :=
            p_txn_ii_rltns_tbl(l_ind).object_version_number;


          begin

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'update_row',
              p_pkg_name => 'csi_t_ii_relationships_pkg');

            csi_t_ii_relationships_pkg.update_row(
              p_txn_relationship_id      => l_iir_rec.txn_relationship_id,
              p_transaction_line_id      => l_iir_rec.transaction_line_id,
              p_object_type              => l_iir_rec.object_type,
              p_object_id                => l_iir_rec.object_id,
              p_relationship_type_code   => l_iir_rec.relationship_type_code,
              p_display_order            => l_iir_rec.display_order,
              p_position_reference       => l_iir_rec.position_reference,
              p_mandatory_flag           => l_iir_rec.mandatory_flag,
              p_active_start_date        => l_iir_rec.active_start_date,
              p_active_end_date          => l_iir_rec.active_end_date,
              p_csi_inst_relationship_id => l_iir_rec.csi_inst_relationship_id,
              p_subject_type             => l_iir_rec.subject_type,
              p_subject_id               => l_iir_rec.subject_id,
              -- Added for CZ Integration (Begin)
              p_sub_config_inst_hdr_id   => l_iir_rec.sub_config_inst_hdr_id ,
              p_sub_config_inst_rev_num  => l_iir_rec.sub_config_inst_rev_num  ,
              p_sub_config_inst_item_id  => l_iir_rec.sub_config_inst_item_id  ,
              p_obj_config_inst_hdr_id   => l_iir_rec.obj_config_inst_hdr_id    ,
              p_obj_config_inst_rev_num  => l_iir_rec.obj_config_inst_rev_num  ,
              p_obj_config_inst_item_id  => l_iir_rec.obj_config_inst_item_id ,
              p_target_commitment_date   => l_iir_rec.target_commitment_date ,
              -- Added for CZ Integration (End)
              p_attribute1               => l_iir_rec.attribute1,
              p_attribute2               => l_iir_rec.attribute2,
              p_attribute3               => l_iir_rec.attribute3,
              p_attribute4               => l_iir_rec.attribute4,
              p_attribute5               => l_iir_rec.attribute5,
              p_attribute6               => l_iir_rec.attribute6,
              p_attribute7               => l_iir_rec.attribute7,
              p_attribute8               => l_iir_rec.attribute8,
              p_attribute9               => l_iir_rec.attribute9,
              p_attribute10              => l_iir_rec.attribute10,
              p_attribute11              => l_iir_rec.attribute11,
              p_attribute12              => l_iir_rec.attribute12,
              p_attribute13              => l_iir_rec.attribute13,
              p_attribute14              => l_iir_rec.attribute14,
              p_attribute15              => l_iir_rec.attribute15,
              p_created_by               => l_iir_cur_rec.created_by,
              p_creation_date            => l_iir_cur_rec.creation_date,
              p_last_updated_by          => g_user_id,
              p_last_update_date         => sysdate,
              p_last_update_login        => g_login_id,
              p_object_version_number    => l_iir_rec.object_version_number,
              p_context                  => l_iir_rec.context,
              p_transfer_components_flag      => l_iir_rec.transfer_components_flag);

          exception
            when others then
              fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE',
                 'csi_t_ii_relationships_pkg.update_row Failed. '||substr(sqlerrm,1,200));
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          end;

        END LOOP;
      END LOOP;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO update_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO update_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO update_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END update_txn_ii_rltns_dtls;

  PROCEDURE delete_txn_ii_rltns_dtls(
     p_api_version            IN  NUMBER
    ,p_commit                 IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list          IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level       IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ii_rltns_ids_tbl   IN  csi_t_datastructures_grp.txn_ii_rltns_ids_tbl
    ,x_return_status          OUT NOCOPY VARCHAR2
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2)

  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_ii_rltns_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;
    l_return_status           VARCHAR2(1);

    l_rltns_id                NUMBER;

    l_txn_line_id             NUMBER;

    CURSOR ii_cur (p_txn_line_id IN NUMBER) IS
      SELECT txn_relationship_id
      FROM   csi_t_ii_relationships
      WHERE  transaction_line_id = p_txn_line_id;

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_ii_rltns_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       FND_API.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_validation_level||'-'||p_init_msg_list);

    -- Main API code

    IF p_txn_ii_rltns_ids_tbl.COUNT > 0 THEN

      FOR l_ind IN p_txn_ii_rltns_ids_tbl.FIRST.. p_txn_ii_rltns_ids_tbl.LAST
      LOOP

        IF l_debug_level > 1 THEN
          null; --##
        END IF;

        l_rltns_id := p_txn_ii_rltns_ids_tbl(l_ind).txn_relationship_id;

        IF NVL(l_rltns_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          csi_t_vldn_routines_pvt.validate_txn_relationship_id(
            p_txn_relationship_id => l_rltns_id,
            x_return_status       => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_RLTNS_ID_INVALID');
            FND_MESSAGE.set_token('RLTNS_ID',l_rltns_id);
            FND_MSG_PUB.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'delete_row',
            p_pkg_name => 'csi_t_ii_relationships_pkg');

          csi_t_ii_relationships_pkg.delete_row(
            p_txn_relationship_id  => l_rltns_id);

        ELSE

          l_txn_line_id := p_txn_ii_rltns_ids_tbl(l_ind).transaction_line_id;

          csi_t_vldn_routines_pvt.check_reqd_param(
            p_value      => l_txn_line_id,
            p_param_name => 'p_txn_ii_rltns_ids_tbl.transaction_line_id',
            p_api_name   => l_api_name);

          -- #validate transaction_line_id


          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            null;
            -- #populate error message

          END IF;

          FOR ii_rec in ii_cur (l_txn_line_id)
          LOOP

            csi_t_ii_relationships_pkg.delete_row(
              p_txn_relationship_id => ii_rec.txn_relationship_id);

          END LOOP;

        END IF;

      END LOOP;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO delete_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO delete_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_ii_rltns_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF FND_MSG_PUB.Check_Msg_Level(
           p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      FND_MSG_PUB.Count_And_Get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END delete_txn_ii_rltns_dtls;

  PROCEDURE get_ii_rltns_dtls(
    p_txn_line_id_list in  varchar2,
    x_ii_rltns_tbl     OUT NOCOPY csi_t_datastructures_grp.txn_ii_rltns_tbl,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_iir_cur_id       integer;
    l_iir_rec          csi_t_datastructures_grp.txn_ii_rltns_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    l_select_stmt :=
     'select txn_relationship_id, transaction_line_id,csi_inst_relationship_id, '||
     ' subject_id, object_id, relationship_type_code, display_order,'||
     ' position_reference, mandatory_flag, active_start_date, active_end_date, '||
     ' context, attribute1, attribute2, attribute3, attribute4, attribute5, '||
     ' attribute6, attribute7, attribute8, attribute9, attribute10, attribute11, '||
     ' attribute12, attribute13, attribute14, attribute15, object_version_number,transfer_components_flag '||
     'from   csi_t_ii_relationships '||
     'where transaction_line_id in '||p_txn_line_id_list;

    l_iir_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_iir_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.define_column(l_iir_cur_id,1,l_iir_rec.txn_relationship_id);
    dbms_sql.define_column(l_iir_cur_id,2,l_iir_rec.transaction_line_id);
    dbms_sql.define_column(l_iir_cur_id,3,l_iir_rec.csi_inst_relationship_id);
    dbms_sql.define_column(l_iir_cur_id,4,l_iir_rec.subject_id);
    dbms_sql.define_column(l_iir_cur_id,5,l_iir_rec.object_id);
    dbms_sql.define_column(l_iir_cur_id,6,l_iir_rec.relationship_type_code,30);
    dbms_sql.define_column(l_iir_cur_id,7,l_iir_rec.display_order);
    dbms_sql.define_column(l_iir_cur_id,8,l_iir_rec.position_reference,30);
    dbms_sql.define_column(l_iir_cur_id,9,l_iir_rec.mandatory_flag,1);
    dbms_sql.define_column(l_iir_cur_id,10,l_iir_rec.active_start_date);
    dbms_sql.define_column(l_iir_cur_id,11,l_iir_rec.active_end_date);
    dbms_sql.define_column(l_iir_cur_id,12,l_iir_rec.context,30);
    dbms_sql.define_column(l_iir_cur_id,13,l_iir_rec.attribute1,150);
    dbms_sql.define_column(l_iir_cur_id,14,l_iir_rec.attribute2,150);
    dbms_sql.define_column(l_iir_cur_id,15,l_iir_rec.attribute3,150);
    dbms_sql.define_column(l_iir_cur_id,16,l_iir_rec.attribute4,150);
    dbms_sql.define_column(l_iir_cur_id,17,l_iir_rec.attribute5,150);
    dbms_sql.define_column(l_iir_cur_id,18,l_iir_rec.attribute6,150);
    dbms_sql.define_column(l_iir_cur_id,19,l_iir_rec.attribute7,150);
    dbms_sql.define_column(l_iir_cur_id,20,l_iir_rec.attribute8,150);
    dbms_sql.define_column(l_iir_cur_id,21,l_iir_rec.attribute9,150);
    dbms_sql.define_column(l_iir_cur_id,22,l_iir_rec.attribute10,150);
    dbms_sql.define_column(l_iir_cur_id,23,l_iir_rec.attribute11,150);
    dbms_sql.define_column(l_iir_cur_id,24,l_iir_rec.attribute12,150);
    dbms_sql.define_column(l_iir_cur_id,25,l_iir_rec.attribute13,150);
    dbms_sql.define_column(l_iir_cur_id,26,l_iir_rec.attribute14,150);
    dbms_sql.define_column(l_iir_cur_id,27,l_iir_rec.attribute15,150);
    dbms_sql.define_column(l_iir_cur_id,28,l_iir_rec.object_version_number);
    dbms_sql.define_column(l_iir_cur_id,29,l_iir_rec.transfer_components_flag,1);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_iir_cur_id);
    LOOP
      exit when dbms_sql.fetch_rows(l_iir_cur_id) = 0;

      l_ind := l_ind + 1;


      dbms_sql.column_value(l_iir_cur_id,1,x_ii_rltns_tbl(l_ind).txn_relationship_id);
      dbms_sql.column_value(l_iir_cur_id,2,x_ii_rltns_tbl(l_ind).transaction_line_id);
      dbms_sql.column_value(l_iir_cur_id,3,x_ii_rltns_tbl(l_ind).csi_inst_relationship_id);
      dbms_sql.column_value(l_iir_cur_id,4,x_ii_rltns_tbl(l_ind).subject_id);
      dbms_sql.column_value(l_iir_cur_id,5,x_ii_rltns_tbl(l_ind).object_id);
      dbms_sql.column_value(l_iir_cur_id,6,x_ii_rltns_tbl(l_ind).relationship_type_code);
      dbms_sql.column_value(l_iir_cur_id,7,x_ii_rltns_tbl(l_ind).display_order);
      dbms_sql.column_value(l_iir_cur_id,8,x_ii_rltns_tbl(l_ind).position_reference);
      dbms_sql.column_value(l_iir_cur_id,9,x_ii_rltns_tbl(l_ind).mandatory_flag);
      dbms_sql.column_value(l_iir_cur_id,10,x_ii_rltns_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_iir_cur_id,11,x_ii_rltns_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_iir_cur_id,12,x_ii_rltns_tbl(l_ind).context);
      dbms_sql.column_value(l_iir_cur_id,13,x_ii_rltns_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_iir_cur_id,14,x_ii_rltns_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_iir_cur_id,15,x_ii_rltns_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_iir_cur_id,16,x_ii_rltns_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_iir_cur_id,17,x_ii_rltns_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_iir_cur_id,18,x_ii_rltns_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_iir_cur_id,19,x_ii_rltns_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_iir_cur_id,20,x_ii_rltns_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_iir_cur_id,21,x_ii_rltns_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_iir_cur_id,22,x_ii_rltns_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_iir_cur_id,23,x_ii_rltns_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_iir_cur_id,24,x_ii_rltns_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_iir_cur_id,25,x_ii_rltns_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_iir_cur_id,26,x_ii_rltns_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_iir_cur_id,27,x_ii_rltns_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_iir_cur_id,28,x_ii_rltns_tbl(l_ind).object_version_number);
      dbms_sql.column_value(l_iir_cur_id,29,x_ii_rltns_tbl(l_ind).transfer_components_flag);
    END LOOP;

    dbms_sql.close_cursor(l_iir_cur_id);

  EXCEPTION
    WHEN others THEN

     IF dbms_sql.is_open(l_iir_cur_id) THEN
       dbms_sql.close_cursor(l_iir_cur_id);
     END IF;
  END get_ii_rltns_dtls;

END csi_t_txn_rltnshps_pvt;

/
