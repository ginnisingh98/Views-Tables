--------------------------------------------------------
--  DDL for Package Body IEC_RLCTRL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RLCTRL_PUB" AS
/* $Header: IECRCPBB.pls 115.9 2003/08/22 20:42:16 hhuang noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IEC_RLCTRL_PUB';


PROCEDURE MakeListEntriesAvailable
(
	p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2,
	p_commit		IN		VARCHAR2,
	p_resp_appl_id		IN		NUMBER,
	p_resp_id		IN		NUMBER,
	p_user_id		IN		NUMBER,
	p_login_id		IN		NUMBER,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		IN OUT NOCOPY	NUMBER,
	x_msg_data		IN OUT NOCOPY	VARCHAR2,
	p_list_header_id	IN		NUMBER,
	p_dnu_reason_code	IN		NUMBER
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'MakeListEntriesAvailable';
        l_api_version           CONSTANT NUMBER       := 1.0;
        l_api_name_full         CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
        l_return_status         VARCHAR2(1);
        l_return_code           VARCHAR2(1);
        l_data                  VARCHAR2(100);
        l_count                 NUMBER;
        l_list_header_id        NUMBER(15);
        l_dnu_reason_code       NUMBER(15);

BEGIN

   SAVEPOINT make_entries_avail_pub;

   -- Preprocessing Call
   l_list_header_id := p_list_header_id;
   l_dnu_reason_code := p_dnu_reason_code;

   IEC_RLCTRL_PUB_VUHK.MakeListEntriesAvailable_pre( p_list_header_id => l_list_header_id
                                                   , p_dnu_reason_code => l_dnu_reason_code
                                                   , x_data => l_data
                                                   , x_count => l_count
                                                   , x_return_code => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
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

   -- DO ACTUAL WORK HERE BY CALLING PRIVATE METHOD

   IEC_RECORD_FILTER_PVT.Make_ListEntriesAvailable( p_list_header_id => l_list_header_id
                                                  , p_dnu_reason_code => l_dnu_reason_code
                                                  , p_commit => FALSE
                                                  , x_return_status => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

---------------------------------------------------------------------

   -- Post processing Call

   IEC_RLCTRL_PUB_VUHK.MakeListEntriesAvailable_post( p_list_header_id => l_list_header_id
                                                    , p_dnu_reason_code => l_dnu_reason_code
                                                    , x_data => l_data
                                                    , x_count => l_count
                                                    , x_return_code => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
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
      ROLLBACK TO make_entries_avail_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO make_entries_avail_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO make_entries_avail_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );

END MakeListEntriesAvailable;


PROCEDURE MakeListEntriesAvailable
(
	p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2,
	p_commit		IN		VARCHAR2,
	p_resp_appl_id		IN		NUMBER,
	p_resp_id		IN		NUMBER,
	p_user_id		IN		NUMBER,
	p_login_id		IN		NUMBER,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		IN OUT NOCOPY	NUMBER,
	x_msg_data		IN OUT NOCOPY	VARCHAR2,
	p_list_header_id	IN		NUMBER
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'MakeListEntriesAvailable';
        l_api_version           CONSTANT NUMBER       := 1.0;
        l_api_name_full         CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
        l_return_status         VARCHAR2(1);
        l_return_code           VARCHAR2(1);
        l_data                  VARCHAR2(100);
        l_count                 NUMBER;
        l_list_header_id        NUMBER(15);

BEGIN

   SAVEPOINT make_entries_avail_pub;

   -- Preprocessing Call
   l_list_header_id := p_list_header_id;

   IEC_RLCTRL_PUB_VUHK.MakeListEntriesAvailable_pre( p_list_header_id => l_list_header_id
                                                   , x_data => l_data
                                                   , x_count => l_count
                                                   , x_return_code => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
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

   -- DO ACTUAL WORK HERE BY CALLING PRIVATE METHOD

   IEC_RECORD_FILTER_PVT.Make_ListEntriesAvailable( p_list_header_id => l_list_header_id
                                                  , p_dnu_reason_code => NULL
                                                  , p_commit => FALSE
                                                  , x_return_status => l_return_code);

     -- NULL is passed in for dnu_reason_code parameter to indicate that all list entries
     -- should be made available irrespective of DO_NOT_USE_REASON in AMS_LIST_ENTRIES

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

---------------------------------------------------------------------

   -- Post processing Call

   IEC_RLCTRL_PUB_VUHK.MakeListEntriesAvailable_post( p_list_header_id => l_list_header_id
                                                    , x_data => l_data
                                                    , x_count => l_count
                                                    , x_return_code => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
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
      ROLLBACK TO make_entries_avail_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO make_entries_avail_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO make_entries_avail_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );

END MakeListEntriesAvailable;


END IEC_RLCTRL_PUB;

/
