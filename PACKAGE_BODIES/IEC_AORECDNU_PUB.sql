--------------------------------------------------------
--  DDL for Package Body IEC_AORECDNU_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_AORECDNU_PUB" AS
/* $Header: IECRDPBB.pls 115.2 2004/05/18 19:56:39 minwang noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IEC_AORECDNU_PUB';


PROCEDURE SetAORecDNU
(
	p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
	p_commit IN VARCHAR2,
	p_user_id IN NUMBER,
	p_login_id IN NUMBER DEFAULT NULL,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2,
	p_list_entry_id IN NUMBER,
	p_list_header_id IN NUMBER,
	p_dnu_reason_code IN NUMBER DEFAULT NULL
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'SetAORecDNU';
        l_api_version           CONSTANT NUMBER       := 1.0;
        l_api_name_full         CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
        l_return_status         VARCHAR2(1);
        l_data                  VARCHAR2(100);
        l_count                 NUMBER;
     	  l_list_entry_id		  NUMBER(15);
        l_list_header_id        NUMBER(15);
        l_dnu_reason_code       NUMBER(15);
    	  l_returns_id		  NUMBER(15);
	      l_itm_cc_tz_id		  NUMBER;

BEGIN

   SAVEPOINT set_record_donotuse_pub;

   -- Preprocessing Call
   l_list_entry_id := p_list_entry_id;
   l_list_header_id := p_list_header_id;
   IF(p_dnu_reason_code is not null) THEN
   	l_dnu_reason_code := p_dnu_reason_code;
   ELSE
  	l_dnu_reason_code := 10;
   END IF;

   IEC_AORECDNU_PUB_VUHK.SetAORecDNU_pre(p_list_entry_id => l_list_entry_id
				                            			    	   ,p_list_header_id => l_list_header_id
                                                   , p_dnu_reason_code => l_dnu_reason_code
                                                   , x_data => l_data
                                                   , x_count => l_count
                                                   , x_return_code => l_return_status);

   IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call( l_api_version
                                     , p_api_version
                                     , l_api_name
                                     , g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;

   --
   -- Validate user and login session IDs
   --
   IF (p_user_id IS NULL) THEN
      iec_rlctrl_util_pvt.add_null_parameter_msg(l_api_name_full, 'p_user_id');
      RAISE fnd_api.g_exc_error;
   ELSE
      iec_rlctrl_util_pvt.validate_who_info ( p_api_name           => l_api_name_full
                                            , p_parameter_name_usr => 'p_user_id'
                                            , p_parameter_name_log => 'p_login_id'
                                            , p_user_id            => p_user_id
                                            , p_login_id           => p_login_id
                                            , x_return_status      => l_return_status);
      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   END IF;

---------------------------------------------------------------------

   -- DO ACTUAL WORK HERE
   BEGIN
   	select returns_id,itm_cc_tz_id into l_returns_id, l_itm_cc_tz_id from iec_g_return_entries
	where list_entry_id = p_list_entry_id and list_header_id = p_list_header_id;

	update iec_g_return_entries set do_not_use_flag = 'Y',
						  do_not_use_reason = l_dnu_reason_code,
						  last_updated_by = p_user_id,
						  last_update_date = sysdate
	where returns_id = l_returns_id;

	update iec_g_mktg_item_cc_tzs set record_count = nvl(RECORD_COUNT,0)- 1,
						  last_update_date = sysdate
	where itm_cc_tz_id = l_itm_cc_tz_id;

	l_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
		l_return_status:= FND_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
		l_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   END;

   IF (l_return_status= FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_status= FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

---------------------------------------------------------------------

   -- Post processing Call

   IEC_AORECDNU_PUB_VUHK.SetAORecDNU_post(p_list_entry_id => l_list_entry_id
	                                							   ,p_list_header_id => l_list_header_id
                                                   , p_dnu_reason_code => l_dnu_reason_code
                                                   , x_data => l_data
                                                   , x_count => l_count
                                                   , x_return_code => l_return_status);


   IF (l_return_status= FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_status= FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   fnd_msg_pub.count_and_get( p_count  => x_msg_count
                            , p_data   => x_msg_data );

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO set_record_donotuse_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO set_record_donotuse_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO set_record_donotuse_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );

END SetAORecDNU;

END IEC_AORECDNU_PUB;

/
