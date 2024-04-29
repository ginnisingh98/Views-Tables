--------------------------------------------------------
--  DDL for Package Body IEC_SCHEDULE_MGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_SCHEDULE_MGMT_PUB" AS
/* $Header: IECSCHMB.pls 120.1 2006/03/28 09:28:27 hhuang noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IEC_SCHEDULE_MGMT_PUB';

PROCEDURE CopyScheduleEntries
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_src_schedule_id  IN NUMBER,
     p_dest_schedule_id IN NUMBER
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'CopyScheduleEntries';
        l_api_version           CONSTANT NUMBER       := 1.0;
        l_api_name_full         CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
        l_return_status         VARCHAR2(1);
        l_return_code           VARCHAR2(1);
        l_data                  VARCHAR2(100);
        l_count                 NUMBER;
        l_src_schedule_id       NUMBER(15);
        l_dest_schedule_id      NUMBER(15);
BEGIN

   SAVEPOINT copy_schedule_entries_pub;

   -- Preprocessing Call
   l_src_schedule_id := p_src_schedule_id;
   l_dest_schedule_id := p_dest_schedule_id;

   IEC_SCHEDULE_MGMT_VUHK.CopyScheduleEntries_pre
      ( p_src_schedule_id => l_src_schedule_id
      , p_dest_schedule_id => l_dest_schedule_id
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
      IEC_SCHEDULE_MGMT_UTIL_PVT.add_null_parameter_msg(l_api_name_full, 'p_user_id');
      RAISE fnd_api.g_exc_error;
   ELSE
      IEC_SCHEDULE_MGMT_UTIL_PVT.validate_who_info
        ( p_api_name           => l_api_name_full
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

   IEC_VALIDATE_PVT.Copy_ScheduleEntries_Pub
      ( p_src_schedule_id => l_src_schedule_id
      , p_dest_schedule_id => l_dest_schedule_id
      , p_commit => FALSE
      , x_return_status => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

---------------------------------------------------------------------

   -- Post processing Call
   IEC_SCHEDULE_MGMT_VUHK.CopyScheduleEntries_post
      ( p_src_schedule_id => l_src_schedule_id
      , p_dest_schedule_id => l_dest_schedule_id
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
      ROLLBACK TO copy_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO copy_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO copy_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );

END CopyScheduleEntries;

PROCEDURE MoveScheduleEntries
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_src_schedule_id  IN NUMBER,
     p_dest_schedule_id IN NUMBER
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'MoveScheduleEntries';
        l_api_version           CONSTANT NUMBER       := 1.0;
        l_api_name_full         CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
        l_return_status         VARCHAR2(1);
        l_return_code           VARCHAR2(1);
        l_data                  VARCHAR2(100);
        l_count                 NUMBER;
        l_src_schedule_id       NUMBER(15);
        l_dest_schedule_id      NUMBER(15);
BEGIN

   SAVEPOINT copy_schedule_entries_pub;

   -- Preprocessing Call
   l_src_schedule_id := p_src_schedule_id;
   l_dest_schedule_id := p_dest_schedule_id;

   IEC_SCHEDULE_MGMT_VUHK.MoveScheduleEntries_pre
      ( p_src_schedule_id => l_src_schedule_id
      , p_dest_schedule_id => l_dest_schedule_id
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
      IEC_SCHEDULE_MGMT_UTIL_PVT.add_null_parameter_msg(l_api_name_full, 'p_user_id');
      RAISE fnd_api.g_exc_error;
   ELSE
      IEC_SCHEDULE_MGMT_UTIL_PVT.validate_who_info
        ( p_api_name           => l_api_name_full
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

   IEC_VALIDATE_PVT.Move_ScheduleEntries_Pub
      ( p_src_schedule_id => l_src_schedule_id
      , p_dest_schedule_id => l_dest_schedule_id
      , p_commit => FALSE
      , x_return_status => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

---------------------------------------------------------------------

   -- Post processing Call
   IEC_SCHEDULE_MGMT_VUHK.MoveScheduleEntries_post
      ( p_src_schedule_id => l_src_schedule_id
      , p_dest_schedule_id => l_dest_schedule_id
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
      ROLLBACK TO move_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO move_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO move_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );

END MoveScheduleEntries;

PROCEDURE PurgeScheduleEntries
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_schedule_id  IN NUMBER
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'PurgeScheduleEntries';
        l_api_version           CONSTANT NUMBER       := 1.0;
        l_api_name_full         CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
        l_return_status         VARCHAR2(1);
        l_return_code           VARCHAR2(1);
        l_data                  VARCHAR2(100);
        l_count                 NUMBER;
        l_schedule_id           NUMBER(15);

BEGIN

   SAVEPOINT purge_schedule_entries_pub;

   -- Preprocessing Call
   l_schedule_id := p_schedule_id;

   IEC_SCHEDULE_MGMT_VUHK.PurgeScheduleEntries_pre
      ( p_schedule_id => l_schedule_id
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
      IEC_SCHEDULE_MGMT_UTIL_PVT.add_null_parameter_msg(l_api_name_full, 'p_user_id');
      RAISE fnd_api.g_exc_error;
   ELSE
      IEC_SCHEDULE_MGMT_UTIL_PVT.validate_who_info
        ( p_api_name           => l_api_name_full
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

   IEC_VALIDATE_PVT.Purge_ScheduleEntries_Pub
      ( p_schedule_id => l_schedule_id
      , p_commit => FALSE
      , x_return_status => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

---------------------------------------------------------------------

   -- Post processing Call
   IEC_SCHEDULE_MGMT_VUHK.PurgeScheduleEntries_post
      ( p_schedule_id => l_schedule_id
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
      ROLLBACK TO purge_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO purge_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO purge_schedule_entries_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );

END PurgeScheduleEntries;

PROCEDURE StopScheduleExecution
   ( p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2,
     p_commit IN VARCHAR2,
     p_resp_appl_id IN NUMBER,
     p_resp_id IN NUMBER,
     p_user_id IN NUMBER,
     p_login_id IN NUMBER,
     x_return_status IN OUT NOCOPY VARCHAR2,
     x_msg_count IN OUT NOCOPY NUMBER,
     x_msg_data IN OUT NOCOPY VARCHAR2,
     p_schedule_id  IN NUMBER
) AS
        l_api_name              CONSTANT VARCHAR2(30) := 'StopScheduleExecution';
        l_api_version           CONSTANT NUMBER       := 1.0;
        l_api_name_full         CONSTANT VARCHAR2(61) := g_pkg_name||'.'||l_api_name;
        l_return_status         VARCHAR2(1);
        l_return_code           VARCHAR2(1);
        l_data                  VARCHAR2(100);
        l_count                 NUMBER;
        l_schedule_id           NUMBER(15);

BEGIN

   SAVEPOINT stop_schedule_pub;

   -- Preprocessing Call
   l_schedule_id := p_schedule_id;

   IEC_SCHEDULE_MGMT_VUHK.StopScheduleExecution_pre
      ( p_schedule_id => l_schedule_id
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
      IEC_SCHEDULE_MGMT_UTIL_PVT.add_null_parameter_msg(l_api_name_full, 'p_user_id');
      RAISE fnd_api.g_exc_error;
   ELSE
      IEC_SCHEDULE_MGMT_UTIL_PVT.validate_who_info
        ( p_api_name           => l_api_name_full
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

   IEC_STATUS_PVT.Stop_ScheduleExecution_Pub
      ( p_schedule_id => l_schedule_id
      , p_commit => FALSE
      , x_return_status => l_return_code);

   IF (l_return_code = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_return_code = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

---------------------------------------------------------------------

   -- Post processing Call
   IEC_SCHEDULE_MGMT_VUHK.StopScheduleExecution_post
      ( p_schedule_id => l_schedule_id
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
      ROLLBACK TO stop_schedule_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO stop_schedule_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );
   WHEN OTHERS THEN
      ROLLBACK TO stop_schedule_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count => x_msg_count
                               , p_data  => x_msg_data );

END StopScheduleExecution;

END IEC_SCHEDULE_MGMT_PUB;

/
