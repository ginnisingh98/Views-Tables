--------------------------------------------------------
--  DDL for Package Body FND_USER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_USER_PVT" AS
-- $Header: AFSVWUSB.pls 120.4 2005/09/01 03:40:04 tmorrow ship $

c_pkg_name VARCHAR2(30) := 'FND_USER_PVT';
c_log_head VARCHAR2(30) := 'fnd.plsql.FND_USER_PVT.';
chr_newline VARCHAR2(8) := fnd_global.newline;

--  ***********************************************
--     Desupported  procedure Create_User
--  ***********************************************
PROCEDURE Create_User
(  p_api_version_number         IN     NUMBER,
   p_init_msg_list              IN     VARCHAR2 := FND_API.G_FALSE,
   p_simulate                   IN     VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN     VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status              OUT NOCOPY     VARCHAR2,
   p_msg_count                  OUT NOCOPY     NUMBER,
   p_msg_data                   OUT NOCOPY     VARCHAR2,
   p_customer_contact_id        IN     NUMBER   := NULL,
   p_date_format_mask           IN     VARCHAR2 := NULL,
   p_email_address              IN     VARCHAR2 := NULL,
   p_end_date_active            IN     DATE     := NULL,
   p_internal_contact_id        IN     NUMBER   := NULL,
   p_known_as                   IN     VARCHAR2 := NULL,
   p_language                   IN     VARCHAR2 := 'AMERICAN',
   p_last_login_date            IN     DATE     := NULL,
   p_limit_connects             IN     NUMBER   := NULL,
   p_limit_time                 IN     NUMBER   := NULL,
   p_host_port                  IN     VARCHAR2,
   p_password                   IN     VARCHAR2,
   p_supplier_contact_id        IN     NUMBER   := NULL,
   p_username                   IN     VARCHAR2,
   p_created_by                 IN     NUMBER,
   p_creation_date              IN     DATE,
   p_last_updated_by            IN     NUMBER,
   p_last_update_date           IN     DATE,
   p_last_update_login          IN     NUMBER   := NULL,
   p_user_id                    OUT NOCOPY     NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Create_User';
l_api_version_number    CONSTANT NUMBER       := 1.0;

BEGIN
/* This whole package is desupported, just raise error. */

  fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
  fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
  fnd_message.set_token('REASON',
                    'Invalid API call.  API '
                    ||c_pkg_name || '.'|| l_api_name ||
                    ' is desupported and should not be called in R12.'||
                    ' Any product team that calls it '||
                    'must correct their code. ' ||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine');
  if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
    fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_unsupported',
                     FALSE);
  end if;
  fnd_message.raise_error;

end Create_User;


--  ***********************************************
--    Desupported procedure Update_User
--  ***********************************************
PROCEDURE Update_User
(  p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_simulate                   IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_return_status              OUT NOCOPY     VARCHAR2,
   p_msg_count                  OUT NOCOPY     NUMBER,
   p_msg_data                   OUT NOCOPY     VARCHAR2,
   p_user_id                    IN      NUMBER,
   p_customer_contact_id        IN      NUMBER   := FND_API.G_MISS_NUM,
   p_date_format_mask           IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_numeric_characters         IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_territory                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_email_address              IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_end_date_active            IN      DATE     := FND_API.G_MISS_DATE,
   p_internal_contact_id        IN      NUMBER   := FND_API.G_MISS_NUM,
   p_known_as                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_language                   IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_last_login_date            IN      DATE     := FND_API.G_MISS_DATE,
   p_limit_connects             IN      NUMBER   := FND_API.G_MISS_NUM,
   p_limit_time                 IN      NUMBER   := FND_API.G_MISS_NUM,
   p_host_port                  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_old_password               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_new_password               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_supplier_contact_id        IN      NUMBER   := FND_API.G_MISS_NUM,
   p_last_updated_by            IN      NUMBER,
   p_last_update_date           IN      DATE,
   p_last_update_login          IN      NUMBER    := NULL
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_User';
BEGIN

  /* This whole package is desupported, just raise error. */

  fnd_message.set_name('FND', 'GENERIC-INTERNAL ERROR');
  fnd_message.set_token('ROUTINE',
                                       c_pkg_name || '.'|| l_api_name);
  fnd_message.set_token('REASON',
                    'Invalid API call.  API '
                    ||c_pkg_name || '.'|| l_api_name ||
                    ' is desupported and should not be called in R12.'||
                    ' Any product team that calls it '||
                    'must correct their code. ' ||
                    'Oracle employees who encounter this error should log '||
                    'a bug against the product that owns the call to this '||
                    'routine');
  if (fnd_log.LEVEL_EXCEPTION >=
                      fnd_log.g_current_runtime_level) then
    fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     c_log_head || l_api_name || '.end_unsupported',
                     FALSE);
  end if;
  fnd_message.raise_error;

end Update_User;
END FND_USER_PVT;

/
