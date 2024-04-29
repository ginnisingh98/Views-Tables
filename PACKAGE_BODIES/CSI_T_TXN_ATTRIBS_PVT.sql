--------------------------------------------------------
--  DDL for Package Body CSI_T_TXN_ATTRIBS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_T_TXN_ATTRIBS_PVT" as
/* $Header: csivteab.pls 120.1 2005/09/26 15:14:46 shegde noship $ */

  g_pkg_name         CONSTANT VARCHAR2(30) := 'csi_t_txn_attribs_pvt';
  g_file_name        CONSTANT VARCHAR2(12) := 'csivteab.pls';

  g_user_id                   NUMBER       := fnd_global.user_id;
  g_login_id                  NUMBER       := fnd_global.login_id;


  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.add(p_message);
  END debug;

  PROCEDURE api_log(
    p_api_name IN varchar2)
  IS
  BEGIN
    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => 'csi_t_txn_attribs_pvt',
      p_api_name => p_api_name);
  END api_log;

  PROCEDURE create_txn_ext_attrib_dtls(
    p_api_version             IN     number,
    p_commit                  IN     varchar2 := fnd_api.g_false,
    p_init_msg_list           IN     varchar2 := fnd_api.g_false,
    p_validation_level        IN     number   := fnd_api.g_valid_level_full,
    p_txn_ext_attrib_vals_rec IN OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_rec,
    x_return_status              OUT NOCOPY varchar2,
    x_msg_count                  OUT NOCOPY number,
    x_msg_data                   OUT NOCOPY varchar2)

  IS
    l_api_name       CONSTANT VARCHAR2(30)  := 'create_txn_ext_attrib_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;
    l_return_status           VARCHAR2(1);
    l_preserve_detail_flag    VARCHAR2(1);
    l_process_flag            VARCHAR2(1);
    l_txn_attrib_detail_id    NUMBER;
    x_attribute_id            NUMBER ;
    x_error_msg               VARCHAR2(2000);

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT create_txn_ext_attrib_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -- Check the profile option debug_level for debug message reporting

    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    IF l_debug_level > 1 THEN

      csi_t_gen_utility_pvt.add(
        p_api_version||'-'||p_commit||'-'||p_init_msg_list||'-'||p_validation_level);

      csi_t_gen_utility_pvt.dump_txn_eav_rec(
        p_txn_eav_rec => p_txn_ext_attrib_vals_rec);

    END IF;

    -- Added for CZ Integration (Begin)
    IF NVL(p_txn_ext_attrib_vals_rec.attribute_source_id,fnd_api.g_miss_num)
          = fnd_api.g_miss_num
    THEN
       IF p_txn_ext_attrib_vals_rec.api_caller_identity <> 'CONFIG'
       THEN
         FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_CALLER');
         FND_MESSAGE.set_token('API_CALLER',p_txn_ext_attrib_vals_rec.api_caller_identity) ;
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;
       END IF ;
       -- get the attrib_source_id
       IF NVL(p_txn_ext_attrib_vals_rec.attribute_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
       AND  NVL(p_txn_ext_attrib_vals_rec.attribute_level, fnd_api.g_miss_char) <> fnd_api.g_miss_char
       THEN
          ---Both the attribs are given
          get_ext_attrib_id ( p_txn_ext_attrib_vals_rec.attribute_code
                       ,p_txn_ext_attrib_vals_rec.attribute_level
                       ,p_txn_ext_attrib_vals_rec.txn_line_detail_id
                       ,x_attribute_id
                       ,p_txn_ext_attrib_vals_rec.attrib_source_table
                       ,x_return_status
                       ,x_error_msg );

          debug ('After calling get_ext_attrib_id : attrib id - attrib_source_table :'|| x_attribute_id || ' - '||p_txn_ext_attrib_vals_rec.attrib_source_table);
          IF NOT (x_return_status = fnd_api.g_ret_sts_success)
          THEN
             debug ('Call to get_ext_attrib_id failed ..');
    		   FND_MESSAGE.set_token('ATTRIB_LEVEL',p_txn_ext_attrib_vals_rec.attribute_level);
	        fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;
          END IF ;
       ELSIF NVL(p_txn_ext_attrib_vals_rec.attribute_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
           AND NVL(p_txn_ext_attrib_vals_rec.attribute_level, fnd_api.g_miss_char) = fnd_api.g_miss_char
       THEN
          ---Attrib level is NOT passed
          ---First trywith different attrib levels
           debug ('Attribute level is not passed ');
          FOR i IN 1..4
          LOOP
             IF i=1
             THEN
                p_txn_ext_attrib_vals_rec.attribute_level := 'GLOBAL' ;
             ELSIF i=2
             THEN
                p_txn_ext_attrib_vals_rec.attribute_level := 'CATEGORY' ;
             ELSIF i=3
             THEN
                p_txn_ext_attrib_vals_rec.attribute_level := 'ITEM' ;
             ELSIF i=4
             THEN
                p_txn_ext_attrib_vals_rec.attribute_level := 'INSTANCE' ;
             END IF ;
              get_ext_attrib_id ( p_txn_ext_attrib_vals_rec.attribute_code
                       ,p_txn_ext_attrib_vals_rec.attribute_level
                       ,p_txn_ext_attrib_vals_rec.txn_line_detail_id
                       ,x_attribute_id
                       ,p_txn_ext_attrib_vals_rec.attrib_source_table
                       ,x_return_status
                       ,x_error_msg );

             IF NOT (x_return_status = fnd_api.g_ret_sts_success)
             THEN
              IF i=4 THEN
                 debug ('Call to get_ext_attrib_id failed ..');
    			  FND_MESSAGE.set_token('ATTRIB_LEVEL','');
		 	  fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
	      	END IF;
             END IF ;

             IF NVL(x_attribute_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
             THEN
                ---Attribute ID is derived
                ---Exit from this loop we don't need to go further
                EXIT ;
             END IF ;
          END LOOP ;

               debug ('After calling get_ext_attrib_id : attrib id - attrib_source_table :'|| x_attribute_id || ' - '||p_txn_ext_attrib_vals_rec.attrib_source_table);
       ELSE
          ---Attrib code is NOT passed.
           fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
           fnd_message.set_token('MESSAGE',
           'No Attribute code is passed ');
           fnd_msg_pub.add;
           debug ( 'Attribute Code is null so raise the error :');
          RAISE fnd_api.g_exc_error;
       END IF ;
        debug ( 'checking x_attribute_id :'|| x_attribute_id) ;
        IF NVL(x_attribute_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
        THEN
           p_txn_ext_attrib_vals_rec.attribute_source_id :=  x_attribute_id ;
        ELSE
           fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
           fnd_message.set_token('MESSAGE',
           'Either no Attribute code is passed OR csi_t_extend_attribs_pkg.get_attrib_id failed');
           fnd_msg_pub.add;
           debug ( 'Attribute id is null so raise the error :');
           RAISE fnd_api.g_exc_error;
        END IF ;
    END IF ; --(p_txn_ext_attrib_vals_rec.attrib_source_id is not passed
    -- Added for CZ Integration (End)


    -- Main API code
    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_txn_ext_attrib_vals_rec.txn_line_detail_id,
      p_param_name => 'p_txn_ext_attrib_vals_rec.txn_line_detail_id',
      p_api_name   => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_txn_ext_attrib_vals_rec.attrib_source_table,
      p_param_name => 'p_txn_ext_attrib_vals_rec.attrib_source_table',
      p_api_name   => l_api_name);

    csi_t_vldn_routines_pvt.check_reqd_param(
      p_value      => p_txn_ext_attrib_vals_rec.attribute_source_id,
      p_param_name => 'p_txn_ext_attrib_vals_rec.attribute_source_id',
      p_api_name   => l_api_name);

    -- validate attrib_source_id
    csi_t_vldn_routines_pvt.validate_attrib_source_id(
      p_attrib_source_table => p_txn_ext_attrib_vals_rec.attrib_source_table,
      p_attrib_source_id    => p_txn_ext_attrib_vals_rec.attribute_source_id,
      x_return_status       => l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- defaulting the preserve detail flag

    SELECT decode( nvl(p_txn_ext_attrib_vals_rec.preserve_detail_flag,fnd_api.g_miss_char),
             fnd_api.g_miss_char, 'Y', p_txn_ext_attrib_vals_rec.preserve_detail_flag)
    INTO   l_preserve_detail_flag
    FROM   sys.dual;

    -- defaulting the process_flag
    IF nvl(p_txn_ext_attrib_vals_rec.attribute_value, fnd_api.g_miss_char) = fnd_api.g_miss_char
    THEN
      l_process_flag := 'N';
    ELSE
      l_process_flag := p_txn_ext_attrib_vals_rec.process_flag;
    END IF;

    IF nvl(p_txn_ext_attrib_vals_rec.txn_attrib_detail_id,fnd_api.g_miss_num) <>
       fnd_api.g_miss_num THEN
      l_txn_attrib_detail_id := p_txn_ext_attrib_vals_rec.txn_attrib_detail_id;
    END IF;

    --debug info
    BEGIN

      csi_t_gen_utility_pvt.dump_api_info(
        p_api_name => 'insert_row',
        p_pkg_name => 'csi_t_extend_attribs_pkg');

      csi_t_extend_attribs_pkg.insert_row(
        px_txn_attrib_detail_id => l_txn_attrib_detail_id,
        p_txn_line_detail_id    => p_txn_ext_attrib_vals_rec.txn_line_detail_id,
        p_attrib_source_id      => p_txn_ext_attrib_vals_rec.attribute_source_id,
        p_attrib_source_table   => p_txn_ext_attrib_vals_rec.attrib_source_table,
        p_attribute_value       => p_txn_ext_attrib_vals_rec.attribute_value,
        p_process_flag          => l_process_flag,
        p_active_start_date     => p_txn_ext_attrib_vals_rec.active_start_date,
        p_active_end_date       => p_txn_ext_attrib_vals_rec.active_end_date,
        p_preserve_detail_flag  => l_preserve_detail_flag,
        p_attribute1            => p_txn_ext_attrib_vals_rec.attribute1,
        p_attribute2            => p_txn_ext_attrib_vals_rec.attribute2,
        p_attribute3            => p_txn_ext_attrib_vals_rec.attribute3,
        p_attribute4            => p_txn_ext_attrib_vals_rec.attribute4,
        p_attribute5            => p_txn_ext_attrib_vals_rec.attribute5,
        p_attribute6            => p_txn_ext_attrib_vals_rec.attribute6,
        p_attribute7            => p_txn_ext_attrib_vals_rec.attribute7,
        p_attribute8            => p_txn_ext_attrib_vals_rec.attribute8,
        p_attribute9            => p_txn_ext_attrib_vals_rec.attribute9,
        p_attribute10           => p_txn_ext_attrib_vals_rec.attribute10,
        p_attribute11           => p_txn_ext_attrib_vals_rec.attribute11,
        p_attribute12           => p_txn_ext_attrib_vals_rec.attribute12,
        p_attribute13           => p_txn_ext_attrib_vals_rec.attribute13,
        p_attribute14           => p_txn_ext_attrib_vals_rec.attribute14,
        p_attribute15           => p_txn_ext_attrib_vals_rec.attribute15,
        p_created_by            => g_user_id,
        p_creation_date         => sysdate,
        p_last_updated_by       => g_user_id,
        p_last_update_date      => sysdate,
        p_last_update_login     => g_login_id,
        p_object_version_number => 1.0,
        p_context               => p_txn_ext_attrib_vals_rec.context);

    EXCEPTION
      WHEN others THEN
        fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
        fnd_message.set_token('MESSAGE',
           'csi_t_extend_attribs_pkg.insert_row Failed. '||substr(sqlerrm,1,200));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
    END;

    p_txn_ext_attrib_vals_rec.txn_attrib_detail_id := l_txn_attrib_detail_id;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    IF csi_t_gen_utility_pvt.g_debug = fnd_api.g_true THEN
      csi_t_gen_utility_pvt.set_debug_off;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.count_and_get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO create_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_error ;
      fnd_msg_pub.count_and_get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO create_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO create_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.Check_Msg_Level(
           p_message_level => fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN

        fnd_msg_pub.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END create_txn_ext_attrib_dtls;

  PROCEDURE update_txn_ext_attrib_dtls(
    p_api_version             IN  number,
    p_commit                  IN  varchar2 := fnd_api.g_false,
    p_init_msg_list           IN  varchar2 := fnd_api.g_false,
    p_validation_level        IN  number   := fnd_api.g_valid_level_full,
    p_txn_ext_attrib_vals_tbl IN  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status           OUT NOCOPY varchar2,
    x_msg_count               OUT NOCOPY number,
    x_msg_data                OUT NOCOPY varchar2)
  IS

    l_ea_rec                  csi_t_datastructures_grp.txn_ext_attrib_vals_rec;
    l_ext_att_id              number;
    l_processing_status       csi_t_transaction_lines.processing_status%TYPE;

    l_api_name       CONSTANT varchar2(30)  := 'update_txn_ext_attrib_dtls';
    l_api_version    CONSTANT number        := 1.0;
    l_debug_level             number;
    l_return_status           varchar2(1);
    l_txn_ext_attrib_vals_tbl csi_t_datastructures_grp.txn_ext_attrib_vals_tbl ;
    l_update_ext_attribs      BOOLEAN ;
    l_attribute_id            NUMBER ;
    l_error_msg               VARCHAR2(2000);

    CURSOR l_ea_cur(p_attrib_dtl_id in number) IS
      SELECT *
      FROM   csi_t_extend_attribs
      where  txn_attrib_detail_id = p_attrib_dtl_id;

    CURSOR ext_attribs_cur (c_txn_line_detail_id IN NUMBER,
                            c_attrib_source_id IN NUMBER,
                            c_attrib_source_table IN VARCHAR2)
    IS
    SELECT txn_attrib_detail_id
    FROM   csi_t_extend_attribs
    WHERE  txn_line_detail_id  = c_txn_line_detail_id
    AND    attrib_source_id    = c_attrib_source_id
    AND    attrib_source_table = c_attrib_source_table ;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT update_txn_ext_attrib_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => g_pkg_name) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -- Check the profile option debug_level for debug message reporting
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_init_msg_list||'-'||p_validation_level);
      ---FOR CZ
      l_txn_ext_attrib_vals_tbl := p_txn_ext_attrib_vals_tbl ;
      ---FOR CZ end

    -- Main API code

    IF l_txn_ext_attrib_vals_tbl.COUNT > 0 THEN
      FOR l_ind in l_txn_ext_attrib_vals_tbl.FIRST..l_txn_ext_attrib_vals_tbl.LAST
      LOOP
        IF l_debug_level > 1 THEN
          csi_t_gen_utility_pvt.dump_txn_eav_rec(
            p_txn_eav_rec => l_txn_ext_attrib_vals_tbl(l_ind));
        END IF;

        -- Added for CZ Integration (Begin)
           IF NVL(l_txn_ext_attrib_vals_tbl(l_ind).attribute_source_id,
                 fnd_api.g_miss_num) = fnd_api.g_miss_num
           THEN
              IF l_txn_ext_attrib_vals_tbl(l_ind).api_caller_identity <> 'CONFIG'
              THEN
                FND_MESSAGE.set_name('CSI','CSI_TXN_NOT_CZ_CALLER');
                FND_MESSAGE.set_token('API_CALLER',l_txn_ext_attrib_vals_tbl(l_ind).api_caller_identity) ;
                FND_MSG_PUB.add;
                RAISE FND_API.g_exc_error;
              END IF ;
              -- get the attrib_source_id
              IF NVL(l_txn_ext_attrib_vals_tbl(l_ind).attribute_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
              AND  NVL(l_txn_ext_attrib_vals_tbl(l_ind).attribute_level, fnd_api.g_miss_char) <> fnd_api.g_miss_char
              THEN
                 ---Both the attribs are given
                 get_ext_attrib_id ( l_txn_ext_attrib_vals_tbl(l_ind).attribute_code
                              ,l_txn_ext_attrib_vals_tbl(l_ind).attribute_level
                              ,l_txn_ext_attrib_vals_tbl(l_ind).txn_line_detail_id
                              ,l_attribute_id
                              ,l_txn_ext_attrib_vals_tbl(l_ind).attrib_source_table
                              ,x_return_status
                              ,l_error_msg );

                 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                 THEN
                    debug ('Call to get_ext_attrib_id failed ..');
    		   		FND_MESSAGE.set_token('ATTRIB_LEVEL',l_txn_ext_attrib_vals_tbl(l_ind).attribute_level);
		    		fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_error;
                 END IF ;
              ELSIF NVL(l_txn_ext_attrib_vals_tbl(l_ind).attribute_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char
                  AND NVL(l_txn_ext_attrib_vals_tbl(l_ind).attribute_level, fnd_api.g_miss_char) = fnd_api.g_miss_char
              THEN
                 ---Attrib level is NOT passed
                 ---First trywith different attrib levels
                  debug ('Attribute level is not passed ');
                 FOR i IN 1..4
                 LOOP
                    IF i=1
                    THEN
                       l_txn_ext_attrib_vals_tbl(l_ind).attribute_level := 'GLOBAL' ;
                    ELSIF i=2
                    THEN
                       l_txn_ext_attrib_vals_tbl(l_ind).attribute_level := 'CATEGORY' ;
                    ELSIF i=3
                    THEN
                       l_txn_ext_attrib_vals_tbl(l_ind).attribute_level := 'ITEM' ;
                    ELSIF i=4
                    THEN
                       l_txn_ext_attrib_vals_tbl(l_ind).attribute_level := 'INSTANCE' ;
                    END IF ;

                     get_ext_attrib_id ( l_txn_ext_attrib_vals_tbl(l_ind).attribute_code
                              ,l_txn_ext_attrib_vals_tbl(l_ind).attribute_level
                              ,l_txn_ext_attrib_vals_tbl(l_ind).txn_line_detail_id
                              ,l_attribute_id
                              ,l_txn_ext_attrib_vals_tbl(l_ind).attrib_source_table
                              ,x_return_status
                              ,l_error_msg );

                    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                    THEN
              			IF i=4 THEN
                 	   		debug ('Call to get_ext_attrib_id failed ..');
    			  		     FND_MESSAGE.set_token('ATTRIB_LEVEL','');
		 	        		fnd_msg_pub.add;
                 	   		RAISE fnd_api.g_exc_error;
	      			END IF;
                    END IF ;

                      debug ( 'l_attribute_id :'|| l_attribute_id) ;
                    IF NVL(l_attribute_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
                    THEN
                       ---Attribute ID is derived
                       ---Exit from this loop we dont need to go further
                       EXIT ;
                    END IF ;
                 END LOOP ; --i IN 1..4
                ELSE
                 ---Attrib code is NOT passed.
                  fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
                  fnd_message.set_token('MESSAGE',
                  'No attribute code is passed ');
                  fnd_msg_pub.add;
                  debug ( 'Attribute id is null so raise the error :');
                  RAISE fnd_api.g_exc_error;
              END IF ;
               IF NVL(l_attribute_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
               THEN
                 l_txn_ext_attrib_vals_tbl(l_ind).attribute_source_id :=  l_attribute_id ;
               ELSE
                  fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
                  fnd_message.set_token('MESSAGE',
                  'csi_t_extend_attribs_pkg.get_attrib_id failed');
                  fnd_msg_pub.add;
                  debug ( 'Attribute id is null so raise the error :');
                  RAISE fnd_api.g_exc_error;
               END IF ;
           END IF ; --l_txn_ext_attrib_vals_tbl(l_ind).source_id
       -- Added for CZ Integration (End)

        l_ext_att_id := l_txn_ext_attrib_vals_tbl(l_ind).txn_attrib_detail_id;

        csi_t_vldn_routines_pvt.check_reqd_param(
          p_value      => l_ext_att_id,
          p_param_name => 'l_txn_ext_attrib_vals_tbl.txn_attrib_detail_id',
          p_api_name   => l_api_name);

        -- validate txn_attrib_detail_id
        csi_t_vldn_routines_pvt.validate_txn_attrib_detail_id(
          p_txn_attrib_detail_id => l_ext_att_id,
          x_return_status        => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN

          FND_MESSAGE.set_name('CSI','CSI_TXN_EXT_ATTRIB_ID_INVALID');
          FND_MESSAGE.set_token('EXT_ATT_ID',l_ext_att_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;

        END IF;

        l_ea_rec.txn_attrib_detail_id := l_ext_att_id;

        FOR l_ea_cur_rec IN l_ea_cur(l_ext_att_id)
        LOOP

          l_ea_rec.txn_line_detail_id   := l_ea_cur_rec.txn_line_detail_id;

          csi_t_vldn_routines_pvt.get_processing_status(
            p_level             => 'EXT_ATTRIB',
            p_level_dtl_id      => l_ea_rec.txn_line_detail_id,
            x_processing_status => l_processing_status,
            x_return_status     => l_return_status);

          IF l_processing_status = 'PROCESSED' THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_UPD_DEL_NOT_ALLOWED');
            FND_MESSAGE.set_token('LVL_ID', l_ext_att_id);
            FND_MESSAGE.set_token('STATUS',l_processing_status);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          IF nvl(l_txn_ext_attrib_vals_tbl(l_ind).attribute_source_id, fnd_api.g_miss_num) <>
             fnd_api.g_miss_num
          THEN

            csi_t_vldn_routines_pvt.validate_attrib_source_id(
              p_attrib_source_table => l_txn_ext_attrib_vals_tbl(l_ind).attrib_source_table,
              p_attrib_source_id    => l_txn_ext_attrib_vals_tbl(l_ind).attribute_source_id,
              x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
              raise fnd_api.g_exc_error;
            END IF;

          END IF;

          l_ea_rec.attribute_source_id  :=
              nvl(l_txn_ext_attrib_vals_tbl(l_ind).attribute_source_id, fnd_api.g_miss_num);

          l_ea_rec.attrib_source_table  :=
              nvl(l_txn_ext_attrib_vals_tbl(l_ind).attrib_source_table, fnd_api.g_miss_char);

          l_ea_rec.attribute_value      :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute_value;

          IF nvl(l_ea_rec.attribute_value, fnd_api.g_miss_char) = fnd_api.g_miss_char
             AND
             l_ea_cur_rec.attribute_value = NULL
          THEN
            l_ea_rec.process_flag  := 'N';
          ELSE
            l_ea_rec.process_flag  := l_txn_ext_attrib_vals_tbl(l_ind).process_flag;
          END IF;

          l_ea_rec.active_start_date    :=
              l_txn_ext_attrib_vals_tbl(l_ind).active_start_date;

          l_ea_rec.active_end_date      :=
              l_txn_ext_attrib_vals_tbl(l_ind).active_end_date ;

          l_ea_rec.preserve_detail_flag :=
              l_txn_ext_attrib_vals_tbl(l_ind).preserve_detail_flag;

          l_ea_rec.attribute1           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute1 ;

          l_ea_rec.attribute2           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute2 ;

          l_ea_rec.attribute3           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute3 ;

          l_ea_rec.attribute4           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute4 ;

          l_ea_rec.attribute5           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute5 ;

          l_ea_rec.attribute6           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute6 ;

          l_ea_rec.attribute7           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute7 ;

          l_ea_rec.attribute8           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute8 ;

          l_ea_rec.attribute9           :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute9 ;

          l_ea_rec.attribute10          :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute10 ;

          l_ea_rec.attribute11          :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute11 ;

          l_ea_rec.attribute12          :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute12 ;

          l_ea_rec.attribute13          :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute13 ;

          l_ea_rec.attribute14          :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute14 ;

          l_ea_rec.attribute15          :=
              l_txn_ext_attrib_vals_tbl(l_ind).attribute15 ;

          l_ea_rec.object_version_number:=
              l_txn_ext_attrib_vals_tbl(l_ind).object_version_number ;

          l_ea_rec.context              :=
              l_txn_ext_attrib_vals_tbl(l_ind).context ;

          begin

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'update_row',
              p_pkg_name => 'csi_t_extend_attribs_pkg');

            csi_t_extend_attribs_pkg.update_row(
              p_txn_attrib_detail_id      => l_ea_rec.txn_attrib_detail_id,
              p_txn_line_detail_id        => l_ea_rec.txn_line_detail_id,
              p_attrib_source_id          => l_ea_rec.attribute_source_id,
              p_attrib_source_table       => l_ea_rec.attrib_source_table,
              p_attribute_value           => l_ea_rec.attribute_value,
              p_process_flag              => l_ea_rec.process_flag,
              p_active_start_date         => l_ea_rec.active_start_date,
              p_active_end_date           => l_ea_rec.active_end_date,
              p_preserve_detail_flag      => l_ea_rec.preserve_detail_flag,
              p_attribute1                => l_ea_rec.attribute1 ,
              p_attribute2                => l_ea_rec.attribute2 ,
              p_attribute3                => l_ea_rec.attribute3 ,
              p_attribute4                => l_ea_rec.attribute4 ,
              p_attribute5                => l_ea_rec.attribute5 ,
              p_attribute6                => l_ea_rec.attribute6 ,
              p_attribute7                => l_ea_rec.attribute7 ,
              p_attribute8                => l_ea_rec.attribute8 ,
              p_attribute9                => l_ea_rec.attribute9 ,
              p_attribute10               => l_ea_rec.attribute10 ,
              p_attribute11               => l_ea_rec.attribute11 ,
              p_attribute12               => l_ea_rec.attribute12 ,
              p_attribute13               => l_ea_rec.attribute13 ,
              p_attribute14               => l_ea_rec.attribute14 ,
              p_attribute15               => l_ea_rec.attribute15 ,
              p_created_by                => fnd_api.g_miss_num,
              p_creation_date             => fnd_api.g_miss_date,
              p_last_updated_by           => g_user_id,
              p_last_update_date          => sysdate,
              p_last_update_login         => g_login_id,
              p_object_version_number     => l_ea_rec.object_version_number,
              p_context                   => l_ea_rec.context);

          exception
            when others then
              fnd_message.set_name('FND', 'FND_GENERIC_MESSAGE');
              fnd_message.set_token('MESSAGE',
                 'csi_t_extend_attribs_pkg.update_row Failed. '||substr(sqlerrm,1,200));
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
          end;

        END LOOP;
      END LOOP;

    END IF;
    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.count_and_get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO update_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_error ;
      fnd_msg_pub.count_and_get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO update_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO update_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.Check_Msg_Level(
           p_message_level => fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN

        fnd_msg_pub.Add_Exc_Msg(
          p_pkg_name       => G_PKG_NAME,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END update_txn_ext_attrib_dtls;

  PROCEDURE delete_txn_ext_attrib_dtls
  (
     p_api_version             IN  NUMBER
    ,p_commit                  IN  VARCHAR2 := fnd_api.g_false
    ,p_init_msg_list           IN  VARCHAR2 := fnd_api.g_false
    ,p_validation_level        IN  NUMBER   := fnd_api.g_valid_level_full
    ,p_txn_ext_attrib_ids_tbl  IN  csi_t_datastructures_grp.txn_ext_attrib_ids_tbl
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
  )
  IS

    l_api_name       CONSTANT VARCHAR2(30)  := 'delete_txn_ext_attrib_dtls';
    l_api_version    CONSTANT NUMBER        := 1.0;
    l_debug_level             NUMBER;

    l_return_status           VARCHAR2(1);
    l_ext_att_id              NUMBER;

    l_line_dtl_id             NUMBER;

    CURSOR ea_cur (p_line_dtl_id IN NUMBER) IS
      SELECT txn_attrib_detail_id
      FROM   csi_t_extend_attribs
      WHERE  txn_line_detail_id = p_line_dtl_id;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT delete_txn_ext_attrib_dtls;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT

       fnd_api.Compatible_API_Call (
         p_current_version_number => l_api_version,
         p_caller_version_number  => p_api_version,
         p_api_name               => l_api_name,
         p_pkg_name               => G_PKG_NAME) THEN

      RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    -- Check the profile option debug_level for debug message reporting
    l_debug_level := csi_t_gen_utility_pvt.g_debug_level;

    csi_t_gen_utility_pvt.dump_api_info(
      p_pkg_name => g_pkg_name,
      p_api_name => l_api_name);

    csi_t_gen_utility_pvt.add(
      p_api_version||'-'||p_commit||'-'||p_init_msg_list||'-'||p_validation_level);

    -- Main API code
    IF p_txn_ext_attrib_ids_tbl.count > 0 THEN
      FOR l_ind in p_txn_ext_attrib_ids_tbl.FIRST..p_txn_ext_attrib_ids_tbl.LAST
      LOOP

        IF l_debug_level > 1 THEN
          null; --##
        END IF;

        l_ext_att_id := p_txn_ext_attrib_ids_tbl(l_ind).txn_attrib_detail_id;

        IF nvl(l_ext_att_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN

          -- validate txn_attrib_detail_id
          csi_t_vldn_routines_pvt.validate_txn_attrib_detail_id(
            p_txn_attrib_detail_id => l_ext_att_id,
            x_return_status        => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            FND_MESSAGE.set_name('CSI','CSI_TXN_EXT_ATTRIB_ID_INVALID');
            FND_MESSAGE.set_token('EXT_ATT_ID',l_ext_att_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;

          END IF;

          csi_t_gen_utility_pvt.dump_api_info(
            p_api_name => 'delete_row',
            p_pkg_name => 'csi_t_extend_attribs_pkg');

          csi_t_extend_attribs_pkg.delete_row(
            p_txn_attrib_detail_id => l_ext_att_id);

        ELSE

          l_line_dtl_id := p_txn_ext_attrib_ids_tbl(l_ind).txn_line_detail_id;

          csi_t_vldn_routines_pvt.check_reqd_param(
            p_value      => l_line_dtl_id,
            p_param_name => 'p_txn_ext_attrib_ids_tbl.txn_line_detail_id',
            p_api_name   => l_api_name);

          -- validate txn_line_detail_id
          csi_t_vldn_routines_pvt.validate_txn_line_detail_id(
            p_txn_line_detail_id => l_line_dtl_id,
            x_return_status      => l_return_status);

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

             FND_MESSAGE.set_name('CSI','CSI_TXN_LINE_DTL_ID_INVALID');
             FND_MESSAGE.set_token('LINE_DTL_ID',l_line_dtl_id);
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;

          END IF;

          FOR ea_rec in ea_cur (l_line_dtl_id)
          LOOP

            csi_t_gen_utility_pvt.dump_api_info(
              p_api_name => 'delete_row',
              p_pkg_name => 'csi_t_extend_attribs_pkg');

            csi_t_extend_attribs_pkg.delete_row(
              p_txn_attrib_detail_id => ea_rec.txn_attrib_detail_id);

          END LOOP;

        END IF;

      END LOOP;

    END IF;

    -- Standard check of p_commit.
    IF fnd_api.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is  get message info.
    fnd_msg_pub.count_and_get(
      p_count  =>  x_msg_count,
      p_data   =>  x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO delete_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_error ;
      fnd_msg_pub.count_and_get (
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO delete_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO delete_txn_ext_attrib_dtls;
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(
           p_message_level => fnd_msg_pub.g_msg_lvl_unexp_error) THEN

        fnd_msg_pub.add_exc_msg(
          p_pkg_name       => g_pkg_name,
          p_procedure_name => l_api_name);

      END IF;

      fnd_msg_pub.count_and_get(
        p_count  => x_msg_count,
        p_data   => x_msg_data);

  END delete_txn_ext_attrib_dtls;

  PROCEDURE get_csi_ext_attrib_vals(
    p_instance_id      in  number,
    x_csi_ea_vals_tbl  OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_iea_cur_id       integer;
    l_iea_rec          csi_t_datastructures_grp.csi_ext_attrib_vals_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    l_select_stmt :=
     'select attribute_value_id, instance_id,attribute_id, attribute_value,'||
     ' active_start_date, active_end_date, context, attribute1, attribute2,'||
     ' attribute3, attribute4, attribute5, attribute6, attribute7,'||
     ' attribute8, attribute9, attribute10, attribute11, attribute12,'||
     ' attribute13, attribute14, attribute15, object_version_number '||
     'from csi_iea_values '||
     'where instance_id = :instance_id';

    l_iea_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_iea_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.bind_variable(l_iea_cur_id, 'instance_id', p_instance_id);

    dbms_sql.define_column(l_iea_cur_id,1,l_iea_rec.attribute_value_id);
    dbms_sql.define_column(l_iea_cur_id,2,l_iea_rec.instance_id);
    dbms_sql.define_column(l_iea_cur_id,3,l_iea_rec.attribute_id);
    dbms_sql.define_column(l_iea_cur_id,4,l_iea_rec.attribute_value,240);
    dbms_sql.define_column(l_iea_cur_id,5,l_iea_rec.active_start_date);
    dbms_sql.define_column(l_iea_cur_id,6,l_iea_rec.active_end_date);
    dbms_sql.define_column(l_iea_cur_id,7,l_iea_rec.context,30);
    dbms_sql.define_column(l_iea_cur_id,8,l_iea_rec.attribute1,150);
    dbms_sql.define_column(l_iea_cur_id,9,l_iea_rec.attribute2,150);
    dbms_sql.define_column(l_iea_cur_id,10,l_iea_rec.attribute3,150);
    dbms_sql.define_column(l_iea_cur_id,11,l_iea_rec.attribute4,150);
    dbms_sql.define_column(l_iea_cur_id,12,l_iea_rec.attribute5,150);
    dbms_sql.define_column(l_iea_cur_id,13,l_iea_rec.attribute6,150);
    dbms_sql.define_column(l_iea_cur_id,14,l_iea_rec.attribute7,150);
    dbms_sql.define_column(l_iea_cur_id,15,l_iea_rec.attribute8,150);
    dbms_sql.define_column(l_iea_cur_id,16,l_iea_rec.attribute9,150);
    dbms_sql.define_column(l_iea_cur_id,17,l_iea_rec.attribute10,150);
    dbms_sql.define_column(l_iea_cur_id,18,l_iea_rec.attribute11,150);
    dbms_sql.define_column(l_iea_cur_id,19,l_iea_rec.attribute12,150);
    dbms_sql.define_column(l_iea_cur_id,20,l_iea_rec.attribute13,150);
    dbms_sql.define_column(l_iea_cur_id,21,l_iea_rec.attribute14,150);
    dbms_sql.define_column(l_iea_cur_id,22,l_iea_rec.attribute15,150);
    dbms_sql.define_column(l_iea_cur_id,23,l_iea_rec.object_version_number);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_iea_cur_id);
    LOOP

      exit when dbms_sql.fetch_rows(l_iea_cur_id) = 0;

      l_ind := l_ind + 1;
      dbms_sql.column_value(l_iea_cur_id,1,x_csi_ea_vals_tbl(l_ind).attribute_value_id);
      dbms_sql.column_value(l_iea_cur_id,2,x_csi_ea_vals_tbl(l_ind).instance_id);
      dbms_sql.column_value(l_iea_cur_id,3,x_csi_ea_vals_tbl(l_ind).attribute_id);
      dbms_sql.column_value(l_iea_cur_id,4,x_csi_ea_vals_tbl(l_ind).attribute_value);
      dbms_sql.column_value(l_iea_cur_id,5,x_csi_ea_vals_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_iea_cur_id,6,x_csi_ea_vals_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_iea_cur_id,7,x_csi_ea_vals_tbl(l_ind).context);
      dbms_sql.column_value(l_iea_cur_id,8,x_csi_ea_vals_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_iea_cur_id,9,x_csi_ea_vals_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_iea_cur_id,10,x_csi_ea_vals_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_iea_cur_id,11,x_csi_ea_vals_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_iea_cur_id,12,x_csi_ea_vals_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_iea_cur_id,13,x_csi_ea_vals_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_iea_cur_id,14,x_csi_ea_vals_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_iea_cur_id,15,x_csi_ea_vals_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_iea_cur_id,16,x_csi_ea_vals_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_iea_cur_id,17,x_csi_ea_vals_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_iea_cur_id,18,x_csi_ea_vals_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_iea_cur_id,19,x_csi_ea_vals_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_iea_cur_id,20,x_csi_ea_vals_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_iea_cur_id,21,x_csi_ea_vals_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_iea_cur_id,22,x_csi_ea_vals_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_iea_cur_id,23,x_csi_ea_vals_tbl(l_ind).object_version_number);

    END LOOP;

    dbms_sql.close_cursor(l_iea_cur_id);

  EXCEPTION
    WHEN others THEN

     IF dbms_sql.is_open(l_iea_cur_id) THEN
       dbms_sql.close_cursor(l_iea_cur_id);
     END IF;
  END get_csi_ext_attrib_vals;

  PROCEDURE get_csi_ext_attribs(
    p_line_dtl_id         in  number,
    p_instance_id         in  number,
    x_csi_ext_attribs_tbl OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_inst_based_stmt  varchar2(1000);
    l_ea_cur_id        integer;
    l_ea_rec           csi_t_datastructures_grp.csi_ext_attribs_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    l_select_stmt :=
     'select attribute_id, attribute_level, master_organization_id,'||
     ' inventory_item_id, item_category_id, instance_id, attribute_code,'||
     ' attribute_name, attribute_category, description, active_start_date,'||
     ' active_end_date, context, attribute1, attribute2, attribute3,'||
     ' attribute4, attribute5, attribute6, attribute7, attribute8,'||
     ' attribute9, attribute10, attribute11, attribute12, attribute13,'||
     ' attribute14, attribute15, object_version_number '||
     'from csi_i_extended_attribs '||
     'where attribute_level = ''GLOBAL'' '||
     'union '||
     'select attribute_id, attribute_level, master_organization_id,'||
     ' inventory_item_id, item_category_id, instance_id, attribute_code,'||
     ' attribute_name, attribute_category, description, active_start_date,'||
     ' active_end_date, context, attribute1, attribute2, attribute3,'||
     ' attribute4, attribute5, attribute6, attribute7, attribute8,'||
     ' attribute9, attribute10, attribute11, attribute12, attribute13,'||
     ' attribute14, attribute15, object_version_number '||
     'from csi_i_extended_attribs '||
     'where (inventory_item_id, master_organization_id) in '||
     '      (select inventory_item_id,inv_organization_id '||
     '       from   csi_t_txn_line_details'||
     '       where  txn_line_detail_id = :line_dtl_id '||
     '       and    instance_exists_flag = ''N'') ';

    l_inst_based_stmt :=
     'union '||
     'select attribute_id, attribute_level, master_organization_id,'||
     ' inventory_item_id, item_category_id, instance_id, attribute_code,'||
     ' attribute_name, attribute_category, description, active_start_date,'||
     ' active_end_date, context, attribute1, attribute2, attribute3,'||
     ' attribute4, attribute5, attribute6, attribute7, attribute8,'||
     ' attribute9, attribute10, attribute11, attribute12, attribute13,'||
     ' attribute14, attribute15, object_version_number '||
     'from csi_i_extended_attribs '||
     'where instance_id = :instance_id';

    IF p_instance_id is not null THEN
      l_select_stmt := l_select_stmt||l_inst_based_stmt;
    END IF;
    l_ea_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_ea_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.bind_variable(l_ea_cur_id,'line_dtl_id',p_line_dtl_id);

    IF p_instance_id is not null THEN
      dbms_sql.bind_variable(l_ea_cur_id,'instance_id',p_instance_id);
    END IF;


    dbms_sql.define_column(l_ea_cur_id,1,l_ea_rec.attribute_id);
    dbms_sql.define_column(l_ea_cur_id,2,l_ea_rec.attribute_level,15);
    dbms_sql.define_column(l_ea_cur_id,3,l_ea_rec.master_organization_id);
    dbms_sql.define_column(l_ea_cur_id,4,l_ea_rec.inventory_item_id);
    dbms_sql.define_column(l_ea_cur_id,5,l_ea_rec.item_category_id);
    dbms_sql.define_column(l_ea_cur_id,6,l_ea_rec.instance_id);
    dbms_sql.define_column(l_ea_cur_id,7,l_ea_rec.attribute_code,30);
    dbms_sql.define_column(l_ea_cur_id,8,l_ea_rec.attribute_name,50);
    dbms_sql.define_column(l_ea_cur_id,9,l_ea_rec.attribute_category,30);
    dbms_sql.define_column(l_ea_cur_id,10,l_ea_rec.description,240);
    dbms_sql.define_column(l_ea_cur_id,11,l_ea_rec.active_start_date);
    dbms_sql.define_column(l_ea_cur_id,12,l_ea_rec.active_end_date);
    dbms_sql.define_column(l_ea_cur_id,13,l_ea_rec.context,30);
    dbms_sql.define_column(l_ea_cur_id,14,l_ea_rec.attribute1,150);
    dbms_sql.define_column(l_ea_cur_id,15,l_ea_rec.attribute2,150);
    dbms_sql.define_column(l_ea_cur_id,16,l_ea_rec.attribute3,150);
    dbms_sql.define_column(l_ea_cur_id,17,l_ea_rec.attribute4,150);
    dbms_sql.define_column(l_ea_cur_id,18,l_ea_rec.attribute5,150);
    dbms_sql.define_column(l_ea_cur_id,19,l_ea_rec.attribute6,150);
    dbms_sql.define_column(l_ea_cur_id,20,l_ea_rec.attribute7,150);
    dbms_sql.define_column(l_ea_cur_id,21,l_ea_rec.attribute8,150);
    dbms_sql.define_column(l_ea_cur_id,22,l_ea_rec.attribute9,150);
    dbms_sql.define_column(l_ea_cur_id,23,l_ea_rec.attribute10,150);
    dbms_sql.define_column(l_ea_cur_id,24,l_ea_rec.attribute11,150);
    dbms_sql.define_column(l_ea_cur_id,25,l_ea_rec.attribute12,150);
    dbms_sql.define_column(l_ea_cur_id,26,l_ea_rec.attribute13,150);
    dbms_sql.define_column(l_ea_cur_id,27,l_ea_rec.attribute14,150);
    dbms_sql.define_column(l_ea_cur_id,28,l_ea_rec.attribute15,150);
    dbms_sql.define_column(l_ea_cur_id,29,l_ea_rec.object_version_number);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_ea_cur_id);
    LOOP

      exit when dbms_sql.fetch_rows(l_ea_cur_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_ea_cur_id,1,x_csi_ext_attribs_tbl(l_ind).attribute_id);
      dbms_sql.column_value(l_ea_cur_id,2,x_csi_ext_attribs_tbl(l_ind).attribute_level);
      dbms_sql.column_value(l_ea_cur_id,3,x_csi_ext_attribs_tbl(l_ind).master_organization_id);
      dbms_sql.column_value(l_ea_cur_id,4,x_csi_ext_attribs_tbl(l_ind).inventory_item_id);
      dbms_sql.column_value(l_ea_cur_id,5,x_csi_ext_attribs_tbl(l_ind).item_category_id);
      dbms_sql.column_value(l_ea_cur_id,6,x_csi_ext_attribs_tbl(l_ind).instance_id);
      dbms_sql.column_value(l_ea_cur_id,7,x_csi_ext_attribs_tbl(l_ind).attribute_code);
      dbms_sql.column_value(l_ea_cur_id,8,x_csi_ext_attribs_tbl(l_ind).attribute_name);
      dbms_sql.column_value(l_ea_cur_id,9,x_csi_ext_attribs_tbl(l_ind).attribute_category);
      dbms_sql.column_value(l_ea_cur_id,10,x_csi_ext_attribs_tbl(l_ind).description);
      dbms_sql.column_value(l_ea_cur_id,11,x_csi_ext_attribs_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_ea_cur_id,12,x_csi_ext_attribs_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_ea_cur_id,13,x_csi_ext_attribs_tbl(l_ind).context);
      dbms_sql.column_value(l_ea_cur_id,14,x_csi_ext_attribs_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_ea_cur_id,15,x_csi_ext_attribs_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_ea_cur_id,16,x_csi_ext_attribs_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_ea_cur_id,17,x_csi_ext_attribs_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_ea_cur_id,18,x_csi_ext_attribs_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_ea_cur_id,19,x_csi_ext_attribs_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_ea_cur_id,20,x_csi_ext_attribs_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_ea_cur_id,21,x_csi_ext_attribs_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_ea_cur_id,22,x_csi_ext_attribs_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_ea_cur_id,23,x_csi_ext_attribs_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_ea_cur_id,24,x_csi_ext_attribs_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_ea_cur_id,25,x_csi_ext_attribs_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_ea_cur_id,26,x_csi_ext_attribs_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_ea_cur_id,27,x_csi_ext_attribs_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_ea_cur_id,28,x_csi_ext_attribs_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_ea_cur_id,29,x_csi_ext_attribs_tbl(l_ind).object_version_number);

    END LOOP;

    dbms_sql.close_cursor(l_ea_cur_id);

  EXCEPTION
    WHEN others THEN

     IF dbms_sql.is_open(l_ea_cur_id) THEN
       dbms_sql.close_cursor(l_ea_cur_id);
     END IF;
  END get_csi_ext_attribs;

  PROCEDURE get_ext_attrib_dtls(
    p_line_dtl_id      in  number,
    x_ext_attrib_tbl   OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status    OUT NOCOPY varchar2)
  IS

    l_select_stmt      varchar2(2000);
    l_ea_cur_id        integer;
    l_ea_rec           csi_t_datastructures_grp.txn_ext_attrib_vals_rec;
    l_processed_rows   number := 0;
    l_ind              binary_integer;

  BEGIN

    l_select_stmt :=
     'select txn_attrib_detail_id, txn_line_detail_id, attrib_source_table,
             attrib_source_id, attribute_value, process_flag,
             active_start_date, active_end_date, preserve_detail_flag,
             context, attribute1, attribute2, attribute3, attribute4,
             attribute5, attribute6, attribute7, attribute8, attribute9,
             attribute10, attribute11, attribute12, attribute13, attribute14,
             attribute15, object_version_number
      from   csi_t_extend_attribs
      where txn_line_detail_id = :line_dtl_id';

    l_ea_cur_id := dbms_sql.open_cursor;

    dbms_sql.parse(l_ea_cur_id, l_select_stmt , dbms_sql.native);

    dbms_sql.bind_variable(l_ea_cur_id,'line_dtl_id', p_line_dtl_id);

    dbms_sql.define_column(l_ea_cur_id,1,l_ea_rec.txn_attrib_detail_id);
    dbms_sql.define_column(l_ea_cur_id,2,l_ea_rec.txn_line_detail_id);
    dbms_sql.define_column(l_ea_cur_id,3,l_ea_rec.attrib_source_table,30);
    dbms_sql.define_column(l_ea_cur_id,4,l_ea_rec.attribute_source_id);
    dbms_sql.define_column(l_ea_cur_id,5,l_ea_rec.attribute_value,240);
    dbms_sql.define_column(l_ea_cur_id,6,l_ea_rec.process_flag,1);
    dbms_sql.define_column(l_ea_cur_id,7,l_ea_rec.active_start_date);
    dbms_sql.define_column(l_ea_cur_id,8,l_ea_rec.active_end_date);
    dbms_sql.define_column(l_ea_cur_id,9,l_ea_rec.preserve_detail_flag,1);
    dbms_sql.define_column(l_ea_cur_id,10,l_ea_rec.context,30);
    dbms_sql.define_column(l_ea_cur_id,11,l_ea_rec.attribute1,150);
    dbms_sql.define_column(l_ea_cur_id,12,l_ea_rec.attribute2,150);
    dbms_sql.define_column(l_ea_cur_id,13,l_ea_rec.attribute3,150);
    dbms_sql.define_column(l_ea_cur_id,14,l_ea_rec.attribute4,150);
    dbms_sql.define_column(l_ea_cur_id,15,l_ea_rec.attribute5,150);
    dbms_sql.define_column(l_ea_cur_id,16,l_ea_rec.attribute6,150);
    dbms_sql.define_column(l_ea_cur_id,17,l_ea_rec.attribute7,150);
    dbms_sql.define_column(l_ea_cur_id,18,l_ea_rec.attribute8,150);
    dbms_sql.define_column(l_ea_cur_id,19,l_ea_rec.attribute9,150);
    dbms_sql.define_column(l_ea_cur_id,20,l_ea_rec.attribute10,150);
    dbms_sql.define_column(l_ea_cur_id,21,l_ea_rec.attribute11,150);
    dbms_sql.define_column(l_ea_cur_id,22,l_ea_rec.attribute12,150);
    dbms_sql.define_column(l_ea_cur_id,23,l_ea_rec.attribute13,150);
    dbms_sql.define_column(l_ea_cur_id,24,l_ea_rec.attribute14,150);
    dbms_sql.define_column(l_ea_cur_id,25,l_ea_rec.attribute15,150);
    dbms_sql.define_column(l_ea_cur_id,26,l_ea_rec.object_version_number);

    l_ind := 0;

    l_processed_rows := dbms_sql.execute(l_ea_cur_id);
    LOOP

      exit when dbms_sql.fetch_rows(l_ea_cur_id) = 0;

      l_ind := l_ind + 1;

      dbms_sql.column_value(l_ea_cur_id,1,x_ext_attrib_tbl(l_ind).txn_attrib_detail_id);
      dbms_sql.column_value(l_ea_cur_id,2,x_ext_attrib_tbl(l_ind).txn_line_detail_id);
      dbms_sql.column_value(l_ea_cur_id,3,x_ext_attrib_tbl(l_ind).attrib_source_table);
      dbms_sql.column_value(l_ea_cur_id,4,x_ext_attrib_tbl(l_ind).attribute_source_id);
      dbms_sql.column_value(l_ea_cur_id,5,x_ext_attrib_tbl(l_ind).attribute_value);
      dbms_sql.column_value(l_ea_cur_id,6,x_ext_attrib_tbl(l_ind).process_flag);
      dbms_sql.column_value(l_ea_cur_id,7,x_ext_attrib_tbl(l_ind).active_start_date);
      dbms_sql.column_value(l_ea_cur_id,8,x_ext_attrib_tbl(l_ind).active_end_date);
      dbms_sql.column_value(l_ea_cur_id,9,x_ext_attrib_tbl(l_ind).preserve_detail_flag);
      dbms_sql.column_value(l_ea_cur_id,10,x_ext_attrib_tbl(l_ind).context);
      dbms_sql.column_value(l_ea_cur_id,11,x_ext_attrib_tbl(l_ind).attribute1);
      dbms_sql.column_value(l_ea_cur_id,12,x_ext_attrib_tbl(l_ind).attribute2);
      dbms_sql.column_value(l_ea_cur_id,13,x_ext_attrib_tbl(l_ind).attribute3);
      dbms_sql.column_value(l_ea_cur_id,14,x_ext_attrib_tbl(l_ind).attribute4);
      dbms_sql.column_value(l_ea_cur_id,15,x_ext_attrib_tbl(l_ind).attribute5);
      dbms_sql.column_value(l_ea_cur_id,16,x_ext_attrib_tbl(l_ind).attribute6);
      dbms_sql.column_value(l_ea_cur_id,17,x_ext_attrib_tbl(l_ind).attribute7);
      dbms_sql.column_value(l_ea_cur_id,18,x_ext_attrib_tbl(l_ind).attribute8);
      dbms_sql.column_value(l_ea_cur_id,19,x_ext_attrib_tbl(l_ind).attribute9);
      dbms_sql.column_value(l_ea_cur_id,20,x_ext_attrib_tbl(l_ind).attribute10);
      dbms_sql.column_value(l_ea_cur_id,21,x_ext_attrib_tbl(l_ind).attribute11);
      dbms_sql.column_value(l_ea_cur_id,22,x_ext_attrib_tbl(l_ind).attribute12);
      dbms_sql.column_value(l_ea_cur_id,23,x_ext_attrib_tbl(l_ind).attribute13);
      dbms_sql.column_value(l_ea_cur_id,24,x_ext_attrib_tbl(l_ind).attribute14);
      dbms_sql.column_value(l_ea_cur_id,25,x_ext_attrib_tbl(l_ind).attribute15);
      dbms_sql.column_value(l_ea_cur_id,26,x_ext_attrib_tbl(l_ind).object_version_number);

    END LOOP;

    dbms_sql.close_cursor(l_ea_cur_id);

  EXCEPTION
    WHEN others THEN

     IF dbms_sql.is_open(l_ea_cur_id) THEN
       dbms_sql.close_cursor(l_ea_cur_id);
     END IF;
  END get_ext_attrib_dtls;

  PROCEDURE get_all_csi_ext_attrib_vals(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_csi_ea_vals_tbl     OUT NOCOPY csi_t_datastructures_grp.csi_ext_attrib_vals_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
    l_ceav_tbl       csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_tmp_ceav_tbl   csi_t_datastructures_grp.csi_ext_attrib_vals_tbl;
    l_c_ind          binary_integer := 0;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_all_csi_ext_attrib_vals');

    IF p_txn_line_detail_tbl.COUNT > 0 THEN
      FOR l_ind IN p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST
      LOOP

        IF nvl(p_txn_line_detail_tbl(l_ind).instance_id, fnd_api.g_miss_num) <>
           fnd_api.g_miss_num
        THEN

           l_tmp_ceav_tbl.delete;

           get_csi_ext_attrib_vals(
             p_instance_id     => p_txn_line_detail_tbl(l_ind).instance_id,
             x_csi_ea_vals_tbl => l_tmp_ceav_tbl,
             x_return_status   => l_return_status);

           IF l_return_status <> fnd_api.g_ret_sts_success THEN
             raise fnd_api.g_exc_error;
           END IF;

           IF l_tmp_ceav_tbl.count > 0 THEN
             FOR l_t_ind IN l_tmp_ceav_tbl.FIRST .. l_tmp_ceav_tbl.LAST
             LOOP
               l_c_ind := l_ceav_tbl.COUNT;
               l_ceav_tbl(l_c_ind) := l_tmp_ceav_tbl(l_t_ind);
             END LOOP;
           END IF;

        END IF;

      END LOOP;
    END IF;
    x_csi_ea_vals_tbl := l_ceav_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_all_csi_ext_attrib_vals;

  PROCEDURE get_all_csi_ext_attribs(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_csi_ext_attribs_tbl OUT NOCOPY csi_t_datastructures_grp.csi_ext_attribs_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS

    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
    l_cea_tbl        csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_tmp_cea_tbl    csi_t_datastructures_grp.csi_ext_attribs_tbl;
    l_c_ind          binary_integer := 0;
    l_instance_id    number := null;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_all_csi_ext_attribs');

    IF p_txn_line_detail_tbl.count > 0 THEN
      FOR l_ind IN p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST
      LOOP

        IF nvl(p_txn_line_detail_tbl(l_ind).instance_id, fnd_api.g_miss_num) =
           fnd_api.g_miss_num
        THEN
          l_instance_id := null;
        ELSE
          l_instance_id := p_txn_line_detail_tbl(l_ind).instance_id;
        END IF;

        l_tmp_cea_tbl.DELETE;

        get_csi_ext_attribs(
          p_line_dtl_id         => p_txn_line_detail_tbl(l_ind).txn_line_detail_id,
          p_instance_id         => l_instance_id,
          x_csi_ext_attribs_tbl => l_tmp_cea_tbl,
          x_return_status       => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_tmp_cea_tbl.COUNT > 0 THEN
          FOR l_t_ind IN l_tmp_cea_tbl.FIRST .. l_tmp_cea_tbl.LAST
          LOOP
            l_c_ind := l_cea_tbl.count + 1;
            l_cea_tbl(l_c_ind) := l_tmp_cea_tbl(l_t_ind);
          END LOOP;
        END IF;

      END LOOP;
    END IF;
    x_csi_ext_attribs_tbl := l_cea_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_all_csi_ext_attribs;

  PROCEDURE get_all_ext_attrib_dtls(
    p_txn_line_detail_tbl in  csi_t_datastructures_grp.txn_line_detail_tbl,
    x_ext_attrib_tbl      OUT NOCOPY csi_t_datastructures_grp.txn_ext_attrib_vals_tbl,
    x_return_status       OUT NOCOPY varchar2)
  IS
    l_return_status  varchar2(1) := fnd_api.g_ret_sts_success;
    l_c_ind          binary_integer := 0;
    l_teav_tbl       csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_tmp_teav_tbl   csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;

  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    api_log('get_all_ext_attrib_dtls');

    IF p_txn_line_detail_tbl.count > 0 THEN
      FOR l_ind IN p_txn_line_detail_tbl.FIRST .. p_txn_line_detail_tbl.LAST
      LOOP

        l_tmp_teav_tbl.delete;

        get_ext_attrib_dtls(
          p_line_dtl_id      => p_txn_line_detail_tbl(l_ind).txn_line_detail_id,
          x_ext_attrib_tbl   => l_tmp_teav_tbl,
          x_return_status    => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          raise fnd_api.g_exc_error;
        END IF;
        IF l_tmp_teav_tbl.count > 0 THEN
          FOR l_t_ind IN l_tmp_teav_tbl.FIRST .. l_tmp_teav_tbl.LAST
          LOOP
            l_c_ind := l_teav_tbl.count + 1;
            l_teav_tbl(l_c_ind) := l_tmp_teav_tbl(l_t_ind);
          END LOOP;
        END IF;

      END LOOP;
    END IF;

    x_ext_attrib_tbl := l_teav_tbl;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
  END get_all_ext_attrib_dtls;

 -- Added for CZ Integration (Begin)
PROCEDURE get_ext_attrib_id(
    p_attrib_code           IN   VARCHAR2 ,
    p_attrib_level          IN   VARCHAR2 ,
    p_txn_line_detail_id    IN   NUMBER ,
    x_attribute_id          OUT NOCOPY  NUMBER ,
    x_source_table          OUT NOCOPY  VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_error_msg             OUT NOCOPY  VARCHAR2)
IS
l_sysdate         DATE ;
l_inv_item_id     Number ;
l_inv_orgn_id     Number ;
l_item_category   Number ;
l_attrib_param    Varchar2(150);

CURSOR get_global_attrib_cur  (c_attribute_code IN VARCHAR2)
IS
SELECT attribute_id
FROM csi_i_extended_attribs a
WHERE attribute_level = 'GLOBAL'
AND   attribute_code = c_attribute_code
AND  (a.active_end_date is NULL  OR
      trunc(a.active_end_date) > l_sysdate) ;

CURSOR get_item_attrib_cur (c_attribute_code IN VARCHAR2)
IS
SELECT a.attribute_id, b.inventory_item_id, b.inv_organization_id
FROM csi_i_extended_attribs a ,
     csi_t_txn_line_details b,
     mtl_parameters mtp       -- Added for bug 4118180
WHERE a.attribute_level = 'ITEM'
AND  a.attribute_code = c_attribute_code
AND  a.inventory_item_id = b.inventory_item_id
AND  b.inv_organization_id = mtp.organization_id           -- Modified for bug 4118180
AND  a.master_organization_id = mtp.master_organization_id -- Modified for bug 4118180
AND  b.txn_line_detail_id = p_txn_line_detail_id
AND  (a.active_end_date is NULL  OR
      trunc(a.active_end_date) > l_sysdate) ;

CURSOR get_instance_attrib_cur  (c_attribute_code IN VARCHAR2 )
IS
--FOR non-CZ
SELECT  a.attribute_id, b.inventory_item_id, b.inv_organization_id
	, a.instance_id
FROM csi_i_extended_attribs a,
     csi_t_txn_line_details b
WHERE a.attribute_level = 'INSTANCE'
AND  a.attribute_code = c_attribute_code
AND  b.config_inst_hdr_id IS NULL
AND  b.txn_line_detail_id = p_txn_line_detail_id
AND  a.instance_id = b.instance_id
AND  (a.active_end_date is NULL  OR
      trunc(a.active_end_date) > l_sysdate)
UNION
---FOR CZ
SELECT a.attribute_id, b.inventory_item_id, b.inv_organization_id
       , c.instance_id
FROM csi_i_extended_attribs a,
     csi_t_txn_line_details b,
     csi_item_instances c
WHERE a.attribute_level = 'INSTANCE'
AND  a.attribute_code = c_attribute_code
AND  b.config_inst_hdr_id IS NOT NULL
AND  b.config_inst_hdr_id = c.config_inst_hdr_id
AND  b.config_inst_rev_num = c.config_inst_rev_num
AND  b.config_inst_item_id = c.config_inst_item_id
AND b.txn_line_detail_id = p_txn_line_detail_id
AND  (a.active_end_date is NULL  OR
      trunc(a.active_end_date) > l_sysdate) ;

CURSOR get_category_attrib_cur (c_attribute_code IN VARCHAR2, c_category_set_id IN VARCHAR2 ) -- changes for 4028827
IS
SELECT csie.attribute_id, csie.item_category_id,
       ctld.inventory_item_id, ctld.inv_organization_id
FROM mtl_item_categories mti,
     mtl_categories_b mtc ,
     --csi_install_parameters csii,
     csi_i_extended_attribs csie ,
     csi_t_txn_line_details ctld
WHERE mti.organization_id = ctld.inv_organization_id -- Bug 4306650. Typo:inv_orgn and item_id swap
AND   mti.inventory_item_id = ctld.inventory_item_id -- Bug 4306650. Typo:inv_orgn and item_id swap
AND   mti.category_set_id = c_category_set_id -- csii.category_set_id
AND   mti.category_id = mtc.category_id
AND   (mtc.disable_date is NULL OR TRUNC(mtc.disable_date) > TRUNC(SYSDATE))
AND   csie.item_category_id = mti.category_id
AND   csie.attribute_level = 'CATEGORY'
AND   attribute_code = c_attribute_code
AND   ctld.txn_line_detail_id = p_txn_line_detail_id
AND  (csie.active_end_date is NULL  OR
      trunc(csie.active_end_date) > l_sysdate) ;

CURSOR instance_id_cur
IS
SELECT instance_id
FROM   csi_t_txn_line_details
WHERE  txn_line_detail_id = p_txn_line_detail_id
AND    config_inst_hdr_id IS NULL
UNION
SELECT b.instance_id
FROM   csi_t_txn_line_details a,
       csi_item_instances b
WHERE  a.txn_line_detail_id = p_txn_line_detail_id
AND    a.config_inst_hdr_id IS NOT NULL
AND    a.config_inst_hdr_id  = b.config_inst_hdr_id
AND    a.config_inst_rev_num = b.config_inst_rev_num
AND    a.config_inst_item_id = b.config_inst_item_id
AND    a.txn_line_detail_id = p_txn_line_detail_id
AND  (b.active_end_date is NULL  OR
      trunc(b.active_end_date) > l_sysdate) ;

CURSOR iea_values_cur (c_instance_id IN NUMBER,
                       c_attrib_source_id IN NUMBER)
IS
SELECT attribute_value_id
FROM   csi_iea_values
WHERE  instance_id = c_instance_id
AND    attribute_id = c_attrib_source_id
AND  (active_end_date is NULL  OR
      trunc(active_end_date) > l_sysdate) ;

l_instance_id         NUMBER ;
l_attribute_value_id  NUMBER ;
l_loop_count          NUMBER ;
l_category_set_id     csi_install_parameters.category_set_id%type;

BEGIN
   debug ('Begin : get_source_attribute_id -' ||p_attrib_code||' - '||
          p_attrib_level || ' - '|| p_txn_line_detail_id);

   x_return_status :=  fnd_api.g_ret_sts_success ;
   x_attribute_id := NULL ;
   l_instance_id := NULL ;
   x_source_table := NULL ;
   l_attribute_value_id  := NULL ;
   l_loop_count := 0;

   SELECT TRUNC(SYSDATE) INTO l_sysdate FROM dual ;

  IF p_attrib_level = 'GLOBAL'
  THEN
     FOR  get_global_attrib_rec IN get_global_attrib_cur(p_attrib_code)
     LOOP
       x_attribute_id := get_global_attrib_rec.attribute_id ;
       l_loop_count := l_loop_count+1 ;
     END LOOP ;
     IF l_loop_count > 1
     THEN
        x_error_msg := 'Unable to derive attribute id .....';
        FND_MESSAGE.set_name('CSI','CSI_TXN_TOO_MANY_EXT_ATT');
        FND_MESSAGE.set_token('ATTRIB_CODE',p_attrib_code);
        FND_MESSAGE.set_token('ATTRIB_LEVEL',p_attrib_level);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error ;
     END IF ;
   ELSIF p_attrib_level = 'CATEGORY'
   THEN
     -- bug 4028827 , cursor optimization changes
     l_category_set_id := csi_datastructures_pub.g_install_param_rec.category_set_id;
     FOR  get_category_attrib_rec IN get_category_attrib_cur(p_attrib_code, l_category_set_id)
     LOOP
       x_attribute_id := get_category_attrib_rec.attribute_id ;
       l_inv_item_id  := get_category_attrib_rec.inventory_item_id ;
       l_inv_orgn_id  := get_category_attrib_rec.inv_organization_id ;
       l_item_category  := get_category_attrib_rec.item_category_id ;
       l_loop_count := l_loop_count+1 ;
     END LOOP ;
     IF l_loop_count > 1
     THEN
        x_error_msg := 'Unable to derive attribute id .....';
        FND_MESSAGE.set_name('CSI','CSI_TXN_TOO_MANY_EXT_ATT');
        FND_MESSAGE.set_token('ATTRIB_CODE',p_attrib_code);
        FND_MESSAGE.set_token('ATTRIB_LEVEL',p_attrib_level);
        RAISE fnd_api.g_exc_error ;
     END IF ;
   ELSIF p_attrib_level = 'ITEM'
   THEN
     FOR  get_item_attrib_rec IN get_item_attrib_cur(p_attrib_code)
     LOOP
       x_attribute_id := get_item_attrib_rec.attribute_id ;
       l_inv_item_id  := get_item_attrib_rec.inventory_item_id ;
       l_inv_orgn_id  := get_item_attrib_rec.inv_organization_id ;
       l_loop_count := l_loop_count+1 ;
     END LOOP ;
     IF l_loop_count > 1
     THEN
        x_error_msg := 'Unable to derive attribute id .....';
        FND_MESSAGE.set_name('CSI','CSI_TXN_TOO_MANY_EXT_ATT');
        FND_MESSAGE.set_token('ATTRIB_CODE',p_attrib_code);
        FND_MESSAGE.set_token('ATTRIB_LEVEL',p_attrib_level);
        RAISE fnd_api.g_exc_error ;
     END IF ;
   ELSIF p_attrib_level = 'INSTANCE'
   THEN
     FOR  get_instance_attrib_rec IN get_instance_attrib_cur(p_attrib_code)
     LOOP
       x_attribute_id := get_instance_attrib_rec.attribute_id ;
       l_instance_id  := get_instance_attrib_rec.instance_id ;
       l_inv_item_id  := get_instance_attrib_rec.inventory_item_id ;
       l_inv_orgn_id  := get_instance_attrib_rec.inv_organization_id ;
       l_loop_count := l_loop_count+1 ;
     END LOOP ;
     IF l_loop_count > 1
     THEN
        x_error_msg := 'Unable to derive attribute id .....';
        FND_MESSAGE.set_name('CSI','CSI_TXN_TOO_MANY_EXT_ATT');
        FND_MESSAGE.set_token('ATTRIB_CODE',p_attrib_code);
        FND_MESSAGE.set_token('ATTRIB_LEVEL',p_attrib_level);
        RAISE fnd_api.g_exc_error ;
     END IF ;
   END IF ; --p_attrib_level

   debug ('x_attribute_id :'|| x_attribute_id);
 IF x_attribute_id IS NOT NULL THEN
   OPEN instance_id_cur ;
   FETCH instance_id_cur INTO l_instance_id ;
   CLOSE instance_id_cur ;

   debug ('l_instance_id :'|| l_instance_id);

   l_loop_count := 0 ;
   IF l_instance_id IS NULL
   THEN
     x_source_table := 'CSI_I_EXTENDED_ATTRIBS' ;
   ELSE
     FOR  iea_values_rec IN iea_values_cur(l_instance_id , x_attribute_id)
     LOOP
       l_attribute_value_id := iea_values_rec.attribute_value_id ;
       l_loop_count := l_loop_count+1 ;
     END LOOP ;
     IF l_loop_count > 1
     THEN
        FND_MESSAGE.set_name('CSI','CSI_TXN_TOO_MANY_EXT_ATT_VALS');
        FND_MESSAGE.set_token('ATTRIB_ID',x_attribute_id);
        FND_MESSAGE.set_token('INSTANCE_ID',l_instance_id);
        RAISE fnd_api.g_exc_error ;
     END IF ;
     IF l_attribute_value_id IS NOT NULL
     THEN
       x_source_table := 'CSI_IEA_VALUES' ;
       x_attribute_id := l_attribute_value_id ;
     ELSE
       x_source_table := 'CSI_I_EXTENDED_ATTRIBS' ;
     END IF ; --l_attribute_value_id
   END IF ; --l_instance_id
 ELSE
    l_attrib_param := 'Item ID:'||l_inv_item_id||' Orgn ID:'||l_inv_orgn_id||'Category ID: '||l_item_category||'Instance ID: '||l_instance_id;
    FND_MESSAGE.set_name('CSI','CSI_TXN_EXT_ATT_NOT_FOUND');
    FND_MESSAGE.set_token('ATTRIB_CODE',p_attrib_code);
    FND_MESSAGE.set_token('ATTRIB_PARAM',l_attrib_param);
    RAISE fnd_api.g_exc_error ;
 END IF ;
EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_attribute_id := NULL ;
      x_return_status := fnd_api.g_ret_sts_error;
END get_ext_attrib_id ;

-- Added for CZ Integration (End)

END csi_t_txn_attribs_pvt;

/
