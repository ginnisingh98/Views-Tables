--------------------------------------------------------
--  DDL for Package Body OKC_K_ENTITY_LOCKS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ENTITY_LOCKS_GRP" 
/* $Header: OKCGELKB.pls 120.0.12010000.6 2012/06/11 07:50:53 nbingi noship $ */
AS
   l_debug                          VARCHAR2 (1)
                            := NVL (fnd_profile.VALUE ('AFLOG_ENABLED'), 'N');
---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
   g_fnd_app               CONSTANT VARCHAR2 (200) := okc_api.g_fnd_app;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
   g_pkg_name              CONSTANT VARCHAR2 (200)
                                                  := 'OKC_K_ENTITY_LOCKS_GRP';
   g_app_name              CONSTANT VARCHAR2 (3)   := okc_api.g_app_name;
------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
   g_false                 CONSTANT VARCHAR2 (1)   := fnd_api.g_false;
   g_true                  CONSTANT VARCHAR2 (1)   := fnd_api.g_true;
   g_ret_sts_success       CONSTANT VARCHAR2 (1) := fnd_api.g_ret_sts_success;
   g_ret_sts_error         CONSTANT VARCHAR2 (1)   := fnd_api.g_ret_sts_error;
   g_ret_sts_unexp_error   CONSTANT VARCHAR2 (1)
                                             := fnd_api.g_ret_sts_unexp_error;
   g_unexpected_error      CONSTANT VARCHAR2 (200) := 'OKC_UNEXPECTED_ERROR';
   g_sqlerrm_token         CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
   g_sqlcode_token         CONSTANT VARCHAR2 (200) := 'ERROR_CODE';
   g_amend_code_deleted    CONSTANT VARCHAR2 (30)  := 'DELETED';
   g_amend_code_added      CONSTANT VARCHAR2 (30)  := 'ADDED';
   g_amend_code_updated    CONSTANT VARCHAR2 (30)  := 'UPDATED';


----------------------------------------------------
-- Declare the private Procedures
   PROCEDURE refresh_clause (
      p_source_doc_clause_id   IN              NUMBER,
      p_target_doc_clause_id   IN              NUMBER,
      p_target_document_type   IN              VARCHAR2,
      p_target_document_id     IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   );

   PROCEDURE refresh_xprt (
      p_target_document_type   IN              VARCHAR2,
      p_target_document_id     IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   );

   PROCEDURE copy_art_variables (
      p_source_doc_clause_id   IN              NUMBER,
      p_target_doc_clause_id   IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   );

-----------------------------------------------------
   PROCEDURE checkbaserecexists (
      x_rec_exists      OUT NOCOPY      VARCHAR2,
      p_entity_name     IN              VARCHAR2,
      p_entity_pk1      IN              VARCHAR2,
      p_entity_pk2      IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk3      IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk4      IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk5      IN              VARCHAR2 DEFAULT NULL,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      l_sql                 VARCHAR2 (2000);
      l_exists              VARCHAR2 (1)    := 'N';
      l_from_table          VARCHAR2 (256);
      l_entity_pk1_column   VARCHAR2 (240);
      l_entity_pk2_column   VARCHAR2 (240)  := NULL;
      l_entity_pk3_column   VARCHAR2 (240)  := NULL;
      l_entity_pk4_column   VARCHAR2 (240);
      l_entity_pk5_column   VARCHAR2 (240);
      l_entity_pk1_n        NUMBER;
      l_entity_pk2_c        VARCHAR2 (240);
   BEGIN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1000: Entered CheckBaseRecExists Function'
                        );
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                            '1005: Parameters : P_ENTITY_NAME => '
                         || p_entity_name
                         || ' P_ENTITY_PK1 => '
                         || p_entity_pk1
                         || ' P_ENTITY_PK2 => '
                         || p_entity_pk2
                        );
      END IF;

      IF p_entity_name = 'CLAUSE'
      THEN
         l_from_table := 'OKC_K_ARTICLES_B';
         l_entity_pk1_column := 'ID';
         l_entity_pk1_n := TO_NUMBER (p_entity_pk1);
      ELSIF p_entity_name = 'SECTION'
      THEN
         l_from_table := 'OKC_SECTIONS_B';
         l_entity_pk1_column := 'ID';
         l_entity_pk1_n := TO_NUMBER (p_entity_pk1);
      ELSIF p_entity_name = 'XPRT'
      THEN
         l_from_table := 'OKC_TEMPLATE_USAGES';
         l_entity_pk1_column := 'DOCUMENT_ID';
         l_entity_pk1_n := TO_NUMBER (p_entity_pk1);
         l_entity_pk2_column := 'DOCUMENT_TYPE';
         l_entity_pk2_c := p_entity_pk2;
      END IF;

      l_sql :=
            'SELECT ''Y'' FROM '
         || l_from_table
         || ' WHERE 1 =1 AND '
         || l_entity_pk1_column
         || ' = '
         || l_entity_pk1_n;

      IF p_entity_pk2 IS NOT NULL
      THEN
         l_sql :=
               l_sql
            || ' AND '
            || l_entity_pk2_column
            || ' = '
            || ''''
            || l_entity_pk2_c
            || '''';
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name, '1010: l_sql ' || l_sql);
      END IF;

      EXECUTE IMMEDIATE l_sql
                   INTO l_exists;

      x_rec_exists := l_exists;
      x_return_status := g_ret_sts_success;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- If it does not exists that means that the some other document has merged it's changes.
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                            g_pkg_name,
                            '9990: exception  - record does not exist'
                           );
         END IF;

         okc_api.set_message
            (p_app_name      => g_app_name,
             p_msg_name      => 'OKC_BASE_ENT_NOT_FOUND'
            );
         x_rec_exists := 'N';
         x_return_status := g_ret_sts_error;
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                            g_pkg_name,
                            '9992: exception  - ' || SQLERRM
                           );
         END IF;

         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         x_rec_exists := 'N';
         x_return_status := g_ret_sts_unexp_error;
   END checkbaserecexists;

   PROCEDURE checklockexists (
      x_lock_sts        OUT NOCOPY      NUMBER,
      p_entity_name     IN              VARCHAR2,
      p_entity_pk1      IN              VARCHAR2,
      p_entity_pk2      IN              VARCHAR2,
      p_entity_pk3      IN              VARCHAR2,
      p_entity_pk4      IN              VARCHAR2,
      p_entity_pk5      IN              VARCHAR2,
      p_document_type   IN              VARCHAR2,
      p_document_id     IN              NUMBER,
      x_document_type   OUT NOCOPY      VARCHAR2,
      x_document_id     OUT NOCOPY      NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
      /*   0 --> No locks            => Can proceed with lock
          1 --> Lock already exists => Return. No need to lock
         -1 --> Lock already exists => But locked by some other document
          2 --> Two records => Record already locked so throw error.
      */
      l_chk_sql         VARCHAR2 (2000);
      l_lock_count      NUMBER;
      l_document_type   VARCHAR2 (240);
      l_document_id     NUMBER;
   BEGIN
      l_chk_sql :=
            'SELECT LOCK_by_document_type, LOCK_by_document_id FROM okc_k_entity_locks WHERE entity_name =  '
         || ''''
         || p_entity_name
         || ''''
         || ' and entity_pk1 = '
         || ''''
         || p_entity_pk1
         || '''';

      IF p_entity_pk2 IS NOT NULL
      THEN
         l_chk_sql :=
            l_chk_sql || ' AND entity_pk2  = ' || '''' || p_entity_pk2
            || '''';
      END IF;

      IF p_entity_pk3 IS NOT NULL
      THEN
         l_chk_sql :=
            l_chk_sql || ' AND entity_pk3  = ' || '''' || p_entity_pk3
            || '''';
      END IF;

      IF p_entity_pk4 IS NOT NULL
      THEN
         l_chk_sql :=
            l_chk_sql || ' AND entity_pk4  = ' || '''' || p_entity_pk4
            || '''';
      END IF;

      IF p_entity_pk5 IS NOT NULL
      THEN
         l_chk_sql :=
            l_chk_sql || ' AND entity_pk5  = ' || '''' || p_entity_pk5
            || '''';
      END IF;

      EXECUTE IMMEDIATE l_chk_sql
                   INTO l_document_type, l_document_id;

      IF l_document_type = p_document_type AND l_document_id = p_document_id
      THEN
         x_lock_sts := 1;
         x_return_status := g_ret_sts_success;
      ELSE
         okc_api.set_message
                       (p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_BASE_ENT_LOCKED'
                       );
         x_lock_sts := -1;
         x_return_status := g_ret_sts_error;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         x_return_status := g_ret_sts_success;
         x_lock_sts := 0;
      WHEN TOO_MANY_ROWS
      THEN
         x_return_status := g_ret_sts_error;
         x_lock_sts := 2;
         okc_api.set_message
                       (p_app_name      => g_app_name,
                        p_msg_name      => 'OKC_BASE_ENT_LOCKED'
                       );
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_unexp_error;
         x_lock_sts := NULL;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END checklockexists;

   PROCEDURE lock_entity (
      p_api_version             IN              NUMBER,
      p_init_msg_list           IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                  IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_entity_name             IN              VARCHAR2,
      p_entity_pk1              IN              VARCHAR2,
      p_entity_pk2              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk3              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk4              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk5              IN              VARCHAR2 DEFAULT NULL,
      p_lock_by_entity_id       IN              NUMBER DEFAULT NULL,
      p_lock_by_document_type   IN              VARCHAR2,
      p_lock_by_document_id     IN              NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version    CONSTANT NUMBER         := 1;
      l_api_name       CONSTANT VARCHAR2 (30)  := 'g_lock_entity';

      CURSOR cur_lock_exists
      IS
         SELECT lock_by_entity_id, lock_by_document_type,
                lock_by_document_id
           FROM okc_k_entity_locks
          WHERE entity_name = p_entity_name
          AND entity_pk1 = p_entity_pk1
         ;

      l_lock_by_entity_id       NUMBER;
      l_lock_by_document_type   VARCHAR2 (240);
      l_lock_by_document_id     NUMBER;
      x_k_entity_lock_id        NUMBER;
      l_baserecexists           VARCHAR2 (1);
      l_lock_sts                NUMBER;
      x_document_type           VARCHAR2 (240);
      x_document_id             NUMBER;
   BEGIN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1000: Entered lock_entity'
                        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT g_lock_entity_grp;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

         IF  p_entity_name = 'DUMMYSEC' THEN
        x_return_status := g_ret_sts_success;
        INSERT INTO okc_k_entity_locks
            (k_entity_lock_id, entity_name, entity_pk1, entity_pk2,
             entity_pk3, entity_pk4, entity_pk5, lock_by_entity_id,
             lock_by_document_type, lock_by_document_id,
             object_version_number, created_by, creation_date,
             last_updated_by, last_update_date, last_update_login)
   SELECT okc_k_entity_locks_s.NEXTVAL, p_entity_name, p_entity_pk1,
          p_entity_pk2, p_entity_pk3, p_entity_pk4, p_entity_pk5,
          p_lock_by_entity_id, p_lock_by_document_type, p_lock_by_document_id,
          1, fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE,
          fnd_global.login_id
     FROM DUAL
    WHERE NOT EXISTS (
             SELECT 'Y'
               FROM okc_k_entity_locks
              WHERE entity_name = p_entity_name
                AND lock_by_document_type = p_lock_by_document_type
                AND lock_by_document_id = p_lock_by_document_id
                AND lock_by_entity_id = p_lock_by_entity_id);
        RETURN;
      END IF;

      --  Initialize API return status to success
      x_return_status := g_ret_sts_success;
      -- Check whether the record to be locked exists or not.
      checkbaserecexists (x_rec_exists         => l_baserecexists,
                          p_entity_name        => p_entity_name,
                          p_entity_pk1         => p_entity_pk1,
                          p_entity_pk2         => p_entity_pk2,
                          p_entity_pk3         => p_entity_pk3,
                          p_entity_pk4         => p_entity_pk4,
                          p_entity_pk5         => p_entity_pk5,
                          x_return_status      => x_return_status
                         );

---------------------------------------------
      IF (x_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

--------------------------------------------

      -- Check whether the base record has been locked by other document.
      checklockexists (x_lock_sts           => l_lock_sts,
                       p_entity_name        => p_entity_name,
                       p_entity_pk1         => p_entity_pk1,
                       p_entity_pk2         => p_entity_pk2,
                       p_entity_pk3         => p_entity_pk3,
                       p_entity_pk4         => p_entity_pk4,
                       p_entity_pk5         => p_entity_pk5,
                       p_document_type      => p_lock_by_document_type,
                       p_document_id        => p_lock_by_document_id,
                       x_return_status      => x_return_status,
                       x_document_type      => x_document_type,
                       x_document_id        => x_document_id
                      );

---------------------------------------------
      IF (x_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

--------------------------------------------
      IF NVL (l_lock_sts, -99) = 1 AND x_return_status = g_ret_sts_success
      THEN
         -- Entity already locked by the same document
         x_return_status := g_ret_sts_success;
         RETURN;
      END IF;

      -- Call the Package Handler to insert the Row
      okc_k_entity_locks_pkg.insert_row
                          (p_entity_name                => p_entity_name,
                           p_entity_pk1                 => p_entity_pk1,
                           p_entity_pk2                 => p_entity_pk2,
                           p_entity_pk3                 => p_entity_pk3,
                           p_entity_pk4                 => p_entity_pk4,
                           p_entity_pk5                 => p_entity_pk5,
                           p_lock_by_entity_id          => p_lock_by_entity_id,
                           p_lock_by_document_type      => p_lock_by_document_type,
                           p_lock_by_document_id        => p_lock_by_document_id,
                           p_object_version_number      => 1,
                           p_created_by                 => fnd_global.user_id,
                           p_creation_date              => SYSDATE,
                           p_last_updated_by            => fnd_global.user_id,
                           p_last_update_date           => SYSDATE,
                           p_last_update_login          => fnd_global.login_id,
                           x_return_status              => x_return_status,
                           x_msg_count                  => x_msg_count,
                           x_msg_data                   => x_msg_data,
                           x_k_entity_lock_id           => x_k_entity_lock_id
                          );

--------------------------------------------
      IF (x_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

--------------------------------------------

      -- Check whether two records exists
      checklockexists (x_lock_sts           => l_lock_sts,
                       p_entity_name        => p_entity_name,
                       p_entity_pk1         => p_entity_pk1,
                       p_entity_pk2         => p_entity_pk2,
                       p_entity_pk3         => p_entity_pk3,
                       p_entity_pk4         => p_entity_pk4,
                       p_entity_pk5         => p_entity_pk5,
                       p_document_type      => p_lock_by_document_type,
                       p_document_id        => p_lock_by_document_id,
                       x_return_status      => x_return_status,
                       x_document_type      => x_document_type,
                       x_document_id        => x_document_id
                      );

---------------------------------------------
      IF (x_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

--------------------------------------------
      IF x_return_status = g_ret_sts_success
      THEN
         IF NVL (l_lock_sts, -99) = 1
         THEN
            x_return_status := g_ret_sts_success;
         ELSE
            x_return_status := g_ret_sts_error;
         END IF;
      END IF;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
               (FND_LOG.LEVEL_STATEMENT,
                g_pkg_name,
                '9999: Leaving lock_entity: OKC_API.G_EXCEPTION_ERROR Exception'
               );
         END IF;

         ROLLBACK TO g_lock_entity_grp;
         x_return_status := g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
               (FND_LOG.LEVEL_STATEMENT,
                g_pkg_name,
                '9999: Leaving lock_entity: OKC_API.G_RET_STS_UNEXP_ERROR Exception'
               );
         END IF;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );


         ROLLBACK TO g_lock_entity_grp;
         x_return_status := g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END lock_entity;

   PROCEDURE rebuild_locks (
      p_api_version            IN              NUMBER,
      p_init_msg_list          IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                 IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_update_from_doc_type   IN              VARCHAR2,
      p_update_from_doc_id     IN              NUMBER,
      p_update_to_doc_type     IN              VARCHAR2,
      p_update_to_doc_id       IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER        := 1;

      TYPE l_k_entity_id IS TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

      l_old_clause_id_tbl      l_k_entity_id;
      l_new_clause_id_tbl      l_k_entity_id;
      l_old_scn_id_tbl         l_k_entity_id;
      l_new_scn_id_tbl         l_k_entity_id;
      l_upd_clause_id_tbl      l_k_entity_id;
      l_upd_sec_id_tbl         l_k_entity_id;


-- Get the list of source clauses from the Modification document
      CURSOR c_clauses
      IS
         SELECT SOURCE.orig_system_reference_id1 old_id, target.ID new_id , klock.LOCK_by_entity_id
           FROM okc_k_articles_b SOURCE                    -- Modification Doc
                                       ,
                okc_k_articles_b target                            -- Base Doc
                                       ,
                okc_k_entity_locks klock                        -- Locks Table
          WHERE SOURCE.document_type = p_update_from_doc_type
            AND SOURCE.document_id = p_update_from_doc_id
            AND target.document_type = p_update_to_doc_type
            AND target.document_id = p_update_to_doc_id
            AND target.orig_system_reference_id1 = SOURCE.ID
            AND klock.entity_name = 'CLAUSE'
            AND klock.entity_pk1 = TO_CHAR (SOURCE.orig_system_reference_id1);

      CURSOR c_sections
      IS
         SELECT SOURCE.orig_system_reference_id1 old_id, target.ID new_id, klock.lock_by_entity_id
           FROM okc_sections_b SOURCE                      -- Modification Doc
                                     ,
                okc_sections_b target                              -- Base Doc
                                     ,
                okc_k_entity_locks klock                        -- Locks Table
          WHERE SOURCE.document_type = p_update_from_doc_type
            AND SOURCE.document_id = p_update_from_doc_id
            AND target.document_type = p_update_to_doc_type
            AND target.document_id = p_update_to_doc_id
            AND target.orig_system_reference_id1 = SOURCE.ID
            AND klock.entity_name = 'SECTION'
            AND klock.entity_pk1 = TO_CHAR (SOURCE.orig_system_reference_id1);

      CURSOR c_Dummysections   -- This is to Achieve Sync Functionality
      IS
         SELECT SOURCE.orig_system_reference_id1 old_id, target.ID new_id
           FROM okc_sections_b SOURCE                      -- Modification Doc
                                     ,
                okc_sections_b target                              -- Base Doc
                                     ,
                okc_k_entity_locks klock                        -- Locks Table
          WHERE SOURCE.document_type = p_update_from_doc_type
            AND SOURCE.document_id = p_update_from_doc_id
            AND target.document_type = p_update_to_doc_type
            AND target.document_id = p_update_to_doc_id
            AND target.orig_system_reference_id1 = SOURCE.ID
            AND klock.entity_name = 'DUMMYSEC'
            AND klock.entity_pk1 = TO_CHAR (SOURCE.orig_system_reference_id1);

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT g_rebuild_locks_grp;
      -- Release the locks from Source Document Type and Doc ID
      -- Delete the locks from Build_from_doc_type and build_to_doc_id
      release_locks (p_api_version        => 1,
                     p_init_msg_list      => fnd_api.g_false,
                     p_commit             => fnd_api.g_false,
                     p_doc_type           => p_update_from_doc_type,
                     p_doc_id             => p_update_from_doc_id,
                     x_return_status      => x_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data
                    );

      -- Rebuild locks
         -- a) Rebuild locks for clauses
      OPEN c_clauses;

      FETCH c_clauses
      BULK COLLECT INTO l_old_clause_id_tbl, l_new_clause_id_tbl,l_upd_clause_id_tbl;

      CLOSE c_clauses;

      FORALL i IN l_old_clause_id_tbl.FIRST .. l_old_clause_id_tbl.LAST
         UPDATE okc_k_entity_locks
            SET entity_pk1 = TO_CHAR (l_new_clause_id_tbl (i)),
                last_updated_by = fnd_global.user_id,
                last_update_date = SYSDATE,
                last_update_login = fnd_global.login_id
          WHERE entity_pk1 = TO_CHAR (l_old_clause_id_tbl (i))
            AND entity_name = 'CLAUSE';

        -- Update the Lock By articles with the correct orig_sys_ref.
       FORALL i IN l_new_clause_id_tbl.first..l_new_clause_id_tbl.LAST
            UPDATE OKC_K_ARTICLES_B
            SET    orig_system_reference_id1 = l_new_clause_id_tbl(i)
            WHERE  id =  l_upd_clause_id_tbl(i);

      -- b) Rebuild locks for sections
      OPEN c_sections;

      FETCH c_sections
      BULK COLLECT INTO l_old_scn_id_tbl, l_new_scn_id_tbl,l_upd_sec_id_tbl;

      CLOSE c_sections;

      FORALL i IN l_old_scn_id_tbl.FIRST .. l_old_scn_id_tbl.LAST
         UPDATE okc_k_entity_locks
            SET entity_pk1 = l_new_scn_id_tbl (i)
          WHERE entity_pk1 = l_old_scn_id_tbl (i) AND entity_name = 'SECTION';

      FORALL i IN l_new_scn_id_tbl.first..l_new_scn_id_tbl.LAST
           UPDATE okc_sections_b
            SET    orig_system_reference_id1 = l_new_scn_id_tbl(i)
           WHERE  id =  l_upd_sec_id_tbl(i);

      --c) No need to re-build  locks for xprt as the document type and document id will not be changed.

      OPEN c_Dummysections;
      FETCH c_Dummysections
      BULK COLLECT INTO l_old_scn_id_tbl, l_new_scn_id_tbl;
      CLOSE c_Dummysections;


      FORALL i IN l_old_scn_id_tbl.FIRST .. l_old_scn_id_tbl.LAST
         UPDATE okc_k_entity_locks
            SET entity_pk1 = l_new_scn_id_tbl (i)
          WHERE entity_pk1 = l_old_scn_id_tbl (i)
          AND entity_name = 'DUMMYSEC';

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO g_rebuild_locks_grp;
   END rebuild_locks;

   PROCEDURE release_locks (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN              VARCHAR2 DEFAULT fnd_api.g_false,
      p_doc_type        IN              VARCHAR2,
      p_doc_id          IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER := 1;
   BEGIN
      DELETE FROM okc_k_entity_locks
            WHERE lock_by_document_type = p_doc_type
              AND lock_by_document_id = p_doc_id;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END release_locks;

   FUNCTION islockexists (
      p_entity_name             IN   VARCHAR2,
      p_lock_by_document_type   IN   VARCHAR2,
      p_lock_by_document_id     IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR c_lock_exists
      IS
         SELECT 'Y'
           FROM okc_k_entity_locks
          WHERE entity_name = p_entity_name
            AND lock_by_document_type = p_lock_by_document_type
            AND lock_by_document_id = p_lock_by_document_id;

      l_lock_exists   VARCHAR2 (1) := NULL;
   BEGIN
      OPEN c_lock_exists;

      FETCH c_lock_exists
       INTO l_lock_exists;

      CLOSE c_lock_exists;

      RETURN NVL (l_lock_exists, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END islockexists;

   PROCEDURE unlock_entity (
      p_api_version             IN              NUMBER,
      p_init_msg_list           IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                  IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_entity_name             IN              VARCHAR2,
      p_entity_pk1              IN              VARCHAR2,
      p_entity_pk2              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk3              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk4              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk5              IN              VARCHAR2 DEFAULT NULL,
      p_lock_by_entity_id       IN              NUMBER DEFAULT NULL,
      p_lock_by_document_type   IN              VARCHAR2,
      p_lock_by_document_id     IN              NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER        := 1;
      l_api_name      CONSTANT VARCHAR2 (30) := 'unlock_entity';
   BEGIN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1000: Entered unlock_entity'
                        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT g_unlock_entity_grp;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- Calling simple API to delete the row
      okc_k_entity_locks_pkg.delete_row
                          (p_entity_name                => p_entity_name,
                           p_entity_pk1                 => p_entity_pk1,
                           p_entity_pk2                 => p_entity_pk2,
                           p_entity_pk3                 => p_entity_pk3,
                           p_entity_pk4                 => p_entity_pk4,
                           p_entity_pk5                 => p_entity_pk5,
                           p_lock_by_entity_id          => p_lock_by_entity_id,
                           p_lock_by_document_type      => p_lock_by_document_type,
                           p_lock_by_document_id        => p_lock_by_document_id,
                           x_return_status              => x_return_status,
                           x_msg_count                  => x_msg_count,
                           x_msg_data                   => x_msg_data
                          );

--------------------------------------------
      IF (x_return_status = g_ret_sts_unexp_error)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

--------------------------------------------
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '9999: completed unlock_entity'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
               (FND_LOG.LEVEL_STATEMENT,
                g_pkg_name,
                '0000: Leaving unlock_entity: OKC_API.G_EXCEPTION_ERROR Exception'
               );
         END IF;

         ROLLBACK TO g_unlock_entity_grp;
         x_return_status := g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
               (FND_LOG.LEVEL_STATEMENT,
                g_pkg_name,
                '0000: Leaving unlock_entity: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception'
               );
         END IF;

         ROLLBACK TO g_unlock_entity_grp;
         x_return_status := g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
                     (FND_LOG.LEVEL_STATEMENT,
                      g_pkg_name,
                         '0000: Leaving unlock_entity because of EXCEPTION: '
                      || SQLERRM
                     );
         END IF;

         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         ROLLBACK TO g_unlock_entity_grp;
         x_return_status := g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END unlock_entity;

   PROCEDURE delete_clause (
      p_doc_clause_id   IN              NUMBER,
      x_return_status   OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      x_return_status := g_ret_sts_success;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1000: Entered delete_clause : ' || p_doc_clause_id
                        );
      END IF;

--------------------------------------------------
-- Call the API to take care of MRV values etc..
------------------------------------------------------
      okc_k_art_variables_pvt.delete_set (x_return_status      => x_return_status,
                                          p_cat_id             => p_doc_clause_id
                                         );

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING
             (FND_LOG.LEVEL_STATEMENT,
              g_pkg_name,
                 '1010: After Call to  okc_k_art_variables_pvt.delete_set : '
              || x_return_status
             );
      END IF;

      IF x_return_status <> g_ret_sts_success
      THEN
         RETURN;
      END IF;

--------------------------------------------
-- Calling Simple API for Deleting A Row
--------------------------------------------
      okc_k_articles_pvt.delete_row (x_return_status              => x_return_status,
                                     p_id                         => p_doc_clause_id,
                                     p_object_version_number      => NULL
                                    );

--------------------------------------------
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                            '1000: Completed delete_clause with status '
                         || x_return_status
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                            g_pkg_name,
                            '0000: Exception in delete_clause ' || SQLERRM
                           );
         END IF;

         x_return_status := g_ret_sts_unexp_error;
   END delete_clause;

   PROCEDURE copy_clause (
      p_source_doc_clause_id   IN              NUMBER,
      p_target_document_type   IN              VARCHAR2,
      p_target_document_id     IN              NUMBER,
      p_target_doc_clause_id   IN              NUMBER DEFAULT NULL,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_get_art_csr
      IS
         SELECT sav_sae_id, (SELECT standard_yn
                               FROM okc_articles_all
                              WHERE article_id = sav_sae_id) standard_yn,
                kart.attribute_category, kart.attribute1, kart.attribute2,
                kart.attribute3, kart.attribute4, kart.attribute5,
                kart.attribute6, kart.attribute7, kart.attribute8,
                kart.attribute9, kart.attribute10, kart.attribute11,
                kart.attribute12, kart.attribute13, kart.attribute14,
                kart.attribute15, kart.source_flag, kart.article_version_id,
                kart.change_nonstd_yn, scn_id,
                'COPY' orig_system_reference_code,
                kart.ID orig_system_reference_id1, kart.mandatory_yn,
                kart.mandatory_rwa, kart.label, kart.display_sequence,
                kart.ref_article_id, kart.ref_article_version_id,
                kart.orig_article_id, NULL amend_operation_code,
                kart.orig_system_reference_id1 src_orig_system_reference_id1
           FROM okc_k_articles_b kart
          WHERE kart.ID = p_source_doc_clause_id;

      l_doc_clause_rec                l_get_art_csr%ROWTYPE;
      x_article_version_id            NUMBER;
      x_article_id                    NUMBER;
      x_article_number                okc_articles_all.article_number%TYPE;
      x_new_doc_clause_id             NUMBER;

      CURSOR cur_get_clause_scn (cp_clause_id NUMBER)
      IS
         SELECT scn_id, orig_system_reference_id1
           FROM okc_k_articles_b
          WHERE ID = cp_clause_id;

      l_target_scn_id                 NUMBER;
      l_target_art_orig_ref_id1       NUMBER;
      l_src_scn_id                    NUMBER;
      l_src_art_orig_ref_id1          NUMBER;

      CURSOR cur_target_doc_scn (p_scn_id NUMBER)
      IS
         SELECT orig_system_reference_code, orig_system_reference_id1,
                amendment_operation_code
           FROM okc_sections_b
          WHERE ID = p_scn_id
            AND document_type = p_target_document_type
            AND document_id = p_target_document_id;


            CURSOR cur_target_doc_scn1(cp_orig_sys_ref_id1 NUMBER )
            IS
            SELECT id,amendment_operation_code
            FROM okc_sections_b
            WHERE 1=1
            AND orig_system_reference_id1 =  cp_orig_sys_ref_id1
            AND document_type = p_target_document_type
            AND document_id = p_target_document_id;
            l_target_doc_scn1_rec  cur_target_doc_scn1%ROWTYPE;


      l_scn_tgt_orig_ref_code         VARCHAR2 (240);
      l_scn_tgt_orig_ref_id1          NUMBER;
      l_scn_tgt_amen_operation_code   VARCHAR2 (240);
      l_scn_id                        NUMBER                           := NULL;
   BEGIN
      x_return_status := g_ret_sts_success;

--------------------------------------------
-- Insert the clause
--------------------------------------------
      OPEN l_get_art_csr;

      FETCH l_get_art_csr
       INTO l_doc_clause_rec;

      IF l_get_art_csr%NOTFOUND
      THEN
         CLOSE l_get_art_csr;

         okc_api.set_message
            (p_app_name      => g_app_name,
             p_msg_name      => 'OKC_SRC_ART_NOT_FOUND_RVRT'
            );
         x_return_status := g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE l_get_art_csr;

      -- Find the section in the target document corresponding to the section in the source document.
      OPEN  cur_target_doc_scn1(l_doc_clause_rec.scn_id);
      FETCH cur_target_doc_scn1 INTO l_target_doc_scn1_rec;
      CLOSE cur_target_doc_scn1;

      IF NVL (l_target_doc_scn1_rec.amendment_operation_code, '?') = 'DELETED'
      THEN
               okc_api.set_message
                  (p_app_name      => g_app_name,
                   p_msg_name      => 'OKC_RVRT_SEC_BEFORE_ART'
                  );
               x_return_status := g_ret_sts_error;
               RAISE fnd_api.g_exc_error;
      END IF;

      l_doc_clause_rec.scn_id := l_target_doc_scn1_rec.id;

      IF l_doc_clause_rec.standard_yn = 'N'
      THEN
         -- Copying Non-Standard Article and get the new article_id and article_Version_id
         okc_articles_grp.copy_article
                (p_api_version             => 1,
                 p_init_msg_list           => fnd_api.g_false,
                 p_validation_level        => fnd_api.g_valid_level_full,
                 p_commit                  => fnd_api.g_false,
                 p_article_version_id      => l_doc_clause_rec.article_version_id,
                 p_new_article_title       => NULL,
                 p_create_standard_yn      => 'N',
                 x_article_version_id      => x_article_version_id,
                 x_article_id              => x_article_id,
                 x_article_number          => x_article_number,
                 x_return_status           => x_return_status,
                 x_msg_count               => x_msg_count,
                 x_msg_data                => x_msg_data
                );

         IF (x_return_status = g_ret_sts_unexp_error)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF (x_return_status = g_ret_sts_error)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         l_doc_clause_rec.article_version_id := x_article_version_id;
         l_doc_clause_rec.sav_sae_id := x_article_id;
      END IF;

      -- Insert the record into okc_k_articles_b
      INSERT INTO okc_k_articles_b
                  (ID, sav_sae_id,
                   document_type, document_id,
                   chr_id,
                   dnz_chr_id,
                   source_flag,
                   mandatory_yn,
                   mandatory_rwa, scn_id,
                   label, amendment_description, amendment_operation_code,
                   article_version_id,
                   change_nonstd_yn,
                   orig_system_reference_code,
                   orig_system_reference_id1, orig_system_reference_id2,
                   display_sequence,
                   attribute_category,
                   attribute1, attribute2,
                   attribute3, attribute4,
                   attribute5, attribute6,
                   attribute7, attribute8,
                   attribute9, attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15, print_text_yn,
                   ref_article_id,
                   ref_article_version_id, object_version_number,
                   created_by, creation_date, last_updated_by,
                   last_update_login, last_update_date,
                   orig_article_id
                  )
           VALUES (okc_k_articles_b_s.NEXTVAL, l_doc_clause_rec.sav_sae_id,
                   p_target_document_type, p_target_document_id,
                   DECODE (p_target_document_type,
                           'OKC_BUY', p_target_document_id,
                           'OKC_SELL', p_target_document_id,
                           'OKO', p_target_document_id,
                           'OKS', p_target_document_id,
                           'OKE_BUY', p_target_document_id,
                           'OKE_SELL', p_target_document_id,
                           'OKL', p_target_document_id,
                           NULL
                          ),
                   DECODE (p_target_document_type,
                           'OKC_BUY', p_target_document_id,
                           'OKC_SELL', p_target_document_id,
                           'OKO', p_target_document_id,
                           'OKS', p_target_document_id,
                           'OKE_BUY', p_target_document_id,
                           'OKE_SELL', p_target_document_id,
                           'OKL', p_target_document_id,
                           NULL
                          ),
                   l_doc_clause_rec.source_flag,
                   l_doc_clause_rec.mandatory_yn,
                   l_doc_clause_rec.mandatory_rwa, l_doc_clause_rec.scn_id,
                   l_doc_clause_rec.label, NULL, NULL,
                   DECODE (p_target_document_type,
                           okc_terms_util_grp.g_tmpl_doc_type, NULL,
                           l_doc_clause_rec.article_version_id
                          ),
                   l_doc_clause_rec.change_nonstd_yn,
                   l_doc_clause_rec.orig_system_reference_code,
                   l_doc_clause_rec.orig_system_reference_id1, NULL,
                   l_doc_clause_rec.display_sequence,
                   l_doc_clause_rec.attribute_category,
                   l_doc_clause_rec.attribute1, l_doc_clause_rec.attribute2,
                   l_doc_clause_rec.attribute3, l_doc_clause_rec.attribute4,
                   l_doc_clause_rec.attribute5, l_doc_clause_rec.attribute6,
                   l_doc_clause_rec.attribute7, l_doc_clause_rec.attribute8,
                   l_doc_clause_rec.attribute9, l_doc_clause_rec.attribute10,
                   l_doc_clause_rec.attribute11,
                   l_doc_clause_rec.attribute12,
                   l_doc_clause_rec.attribute13,
                   l_doc_clause_rec.attribute14,
                   l_doc_clause_rec.attribute15, NULL,
                   l_doc_clause_rec.ref_article_id,
                   l_doc_clause_rec.ref_article_version_id, 1,
                   fnd_global.user_id, SYSDATE, fnd_global.user_id,
                   fnd_global.login_id, SYSDATE,
                   l_doc_clause_rec.orig_article_id
                  )
        RETURNING ID
             INTO x_new_doc_clause_id;

      -- Copy the variables.
      copy_art_variables (p_source_doc_clause_id      => p_source_doc_clause_id,
                          p_target_doc_clause_id      => x_new_doc_clause_id,
                          x_return_status             => x_return_status,
                          x_msg_data                  => x_msg_data,
                          x_msg_count                 => x_msg_count
                         );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
                   (fnd_log.LEVEL_STATEMENT,
                    g_pkg_name,
                    '0000: Leaving copy_clause:FND_API.G_EXC_ERROR Exception'
                   );
         END IF;

         x_return_status := g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
               (fnd_log.LEVEL_STATEMENT,
                g_pkg_name,
                '0000: Leaving copy_clause:FND_API.G_EXC_UNEXPECTED_ERROR  Exception'
               );
         END IF;

         x_return_status := g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                            g_pkg_name,
                            '0000: exception in copy_clause ' || SQLERRM
                           );
         END IF;

         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END copy_clause;

   PROCEDURE refresh_clause (
      p_source_doc_clause_id   IN              NUMBER,
      p_target_doc_clause_id   IN              NUMBER,
      p_target_document_type   IN              VARCHAR2,
      p_target_document_id     IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR cur_val_scn (cp_scn_id NUMBER)
      IS
         SELECT 'Y'
           FROM okc_sections_b
          WHERE ID = cp_scn_id
            AND NVL (amendment_operation_code, '?') <> 'DELETED';

      l_found   VARCHAR2 (1);
   BEGIN
      x_return_status := g_ret_sts_success;

     -- Release locks if any
      copy_clause (p_source_doc_clause_id      => p_source_doc_clause_id,
                   p_target_doc_clause_id      => p_target_doc_clause_id,
                   p_target_document_type      => p_target_document_type,
                   p_target_document_id        => p_target_document_id,
                   x_return_status             => x_return_status,
                   x_msg_data                  => x_msg_data,
                   x_msg_count                 => x_msg_count
                  );

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '9999: Completed  refresh_clause '
                        );
      END IF;

--------------------------------------
-- Delete the clause
--------------------------------------
      delete_clause (p_doc_clause_id      => p_target_doc_clause_id,
                     x_return_status      => x_return_status
                    );

      IF x_return_status <> g_ret_sts_success
      THEN
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                            g_pkg_name,
                            '0000: exception in refresh_clause ' || SQLERRM
                           );
         END IF;

         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END refresh_clause;


   /* Tune the logic */
   PROCEDURE refresh_xprt (
      p_target_document_type   IN              VARCHAR2,
      p_target_document_id     IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR cur_config_data (
         cp_document_type   IN   VARCHAR2,
         cp_document_id     IN   NUMBER
      )
      IS
         SELECT config_header_id, config_revision_number, valid_config_yn,
                orig_system_reference_code, orig_system_reference_id1
           FROM okc_template_usages
          WHERE document_type = cp_document_type
            AND document_id = cp_document_id;

      TYPE l_clause_id_list IS TABLE OF NUMBER
         INDEX BY PLS_INTEGER;

      l_clause_id_tbl                l_clause_id_list;
      l_old_config_header_id         okc_template_usages.config_header_id%TYPE;
      l_old_config_revision_number   okc_template_usages.config_revision_number%TYPE;
      l_old_valid_config_yn          okc_template_usages.valid_config_yn%TYPE;
      l_src_document_type            VARCHAR2 (30);
      l_src_document_id              NUMBER;
      l_src_config_header_id         okc_template_usages.config_header_id%TYPE;
      l_src_config_revision_number   okc_template_usages.config_revision_number%TYPE;
      l_src_valid_config_yn          okc_template_usages.valid_config_yn%TYPE;
      l_src_src_document_type        VARCHAR2 (30);
      l_src_src_document_id          NUMBER;
      l_new_config_header_id         okc_template_usages.config_header_id%TYPE;
      l_new_config_rev_nbr           okc_template_usages.config_revision_number%TYPE;

      CURSOR cur_src_xprt_clauses (
         cp_document_type   IN   VARCHAR2,
         cp_document_id     IN   NUMBER
      )
      IS
         SELECT ID
           FROM okc_k_articles_b
          WHERE document_type = cp_document_type
            AND document_id = cp_document_id
            AND source_flag = 'R';

      l_config_exists                VARCHAR2 (1)                       := 'N';

      CURSOR check_config_exists (
         c_config_header_id   NUMBER,
         c_config_rev_nbr     NUMBER
      )
      IS
         SELECT 'Y'
           FROM cz_config_hdrs
          WHERE config_hdr_id = c_config_header_id
            AND config_rev_nbr = c_config_rev_nbr;

      CURSOR cur_lock_on_clauses (
         cp_document_type   IN   VARCHAR2,
         cp_document_id     IN   NUMBER
      )
      IS
         SELECT TO_CHAR (orig_system_reference_id1)
           FROM okc_k_articles_b
          WHERE document_type = cp_document_type
            AND document_id = cp_document_id
            AND source_flag = 'R'
            AND orig_system_reference_id1 IS NOT NULL;

      TYPE l_clause_tbl_type IS TABLE OF VARCHAR2 (240)
         INDEX BY PLS_INTEGER;

      l_clause_tbl                   l_clause_tbl_type;
   BEGIN
      x_return_status := g_ret_sts_success;

      OPEN cur_config_data (p_target_document_type, p_target_document_id);

      FETCH cur_config_data
       INTO l_old_config_header_id, l_old_config_revision_number,
            l_old_valid_config_yn, l_src_document_type, l_src_document_id;

      CLOSE cur_config_data;

--------------------------------------------
-- Delete xprt suggested clause locks
--------------------------------------------
      OPEN cur_lock_on_clauses (p_target_document_type, p_target_document_id);

      FETCH cur_lock_on_clauses
      BULK COLLECT INTO l_clause_tbl;

      CLOSE cur_lock_on_clauses;

      if      l_clause_tbl.count > 0 then
      FORALL i IN l_clause_tbl.FIRST .. l_clause_tbl.LAST
         DELETE FROM okc_k_entity_locks
               WHERE lock_by_document_type = p_target_document_type
                 AND lock_by_document_id = p_target_document_id
                 AND entity_name = okc_k_entity_locks_grp.g_clause_entity
                 AND entity_pk1 = l_clause_tbl (i);
       end if;
--------------------------------------------
-- Delete contract expert suggested clauses
--------------------------------------------
      DELETE FROM okc_k_articles_b
            WHERE document_type = p_target_document_type
              AND document_id = p_target_document_id
              AND source_flag = 'R'
              ;

--------------------------------------------
-- Delete contract expert suggested clauses
--------------------------------------------
        -- Delete sections that are newly added by contract xprt.



--------------------------------------------
-- Delete configuration data
--------------------------------------------
	IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN --okc rules engine

		--deleting the responses
		DELETE FROM okc_xprt_doc_ques_response
		WHERE doc_id =  p_target_document_id
		AND doc_type = p_target_document_type;

	ELSE --configurator rule engine
      IF (    l_old_config_header_id IS NOT NULL
          AND l_old_config_revision_number IS NOT NULL
         )
      THEN
         okc_xprt_cz_int_pvt.delete_configuration
                           (p_api_version           => 1.0,
                            p_init_msg_list         => fnd_api.g_false,
                            p_config_header_id      => l_old_config_header_id,
                            p_config_rev_nbr        => l_old_config_revision_number,
                            x_return_status         => x_return_status,
                            x_msg_data              => x_msg_data,
                            x_msg_count             => x_msg_count
                           );
      END IF;                                  -- delete the old configuration

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
	END IF;--configurator

--------------------------------------------
-- Add Expert clauses to the target document
--------------------------------------------

      -- Get the source clauses
      OPEN cur_src_xprt_clauses (l_src_document_type, l_src_document_id);

      FETCH cur_src_xprt_clauses
      BULK COLLECT INTO l_clause_id_tbl;

      CLOSE cur_src_xprt_clauses;

      -- Call Copy clause article
      if l_clause_id_tbl.count > 0 then
      FOR i IN l_clause_id_tbl.FIRST .. l_clause_id_tbl.LAST
      LOOP
         copy_clause (p_source_doc_clause_id      => l_clause_id_tbl (i),
                      p_target_document_type      => p_target_document_type,
                      p_target_document_id        => p_target_document_id,
                      p_target_doc_clause_id      => NULL,
                      x_return_status             => x_return_status,
                      x_msg_data                  => x_msg_data,
                      x_msg_count                 => x_msg_count
                     );
      END LOOP;
      end if;
-----------------------------------------------------
-- Copy the configuration data from the Src to target
-----------------------------------------------------
	IF nvl(fnd_profile.value('OKC_USE_CONTRACTS_RULES_ENGINE'), 'N') = 'Y' THEN
		--okc rules engine
		--copying responses from the base document
		INSERT INTO okc_xprt_doc_ques_response(doc_question_response_id, doc_id, doc_type, question_id, response)
		(SELECT okc_xprt_doc_ques_response_s.NEXTVAL, p_target_document_id, p_target_document_type, question_id, response
		 FROM okc_xprt_doc_ques_response WHERE doc_id = l_src_document_id AND doc_type = l_src_document_type );

		--updating the finish flag to the previous state of the base document
		UPDATE okc_template_usages
		SET contract_expert_finish_flag = (SELECT contract_expert_finish_flag FROM okc_template_usages WHERE document_type = l_src_document_type AND document_id = l_src_document_id)
		WHERE document_type = p_target_document_type
	     AND document_id = p_target_document_id;

	ELSE ---configurator
      OPEN cur_config_data (l_src_document_type, l_src_document_id);

      FETCH cur_config_data
       INTO l_src_config_header_id, l_src_config_revision_number,
            l_src_valid_config_yn, l_src_src_document_type,
            l_src_src_document_id;

      CLOSE cur_config_data;

      IF l_src_config_header_id IS NOT NULL
      THEN
         OPEN check_config_exists (l_src_config_header_id,
                                   l_src_config_revision_number
                                  );

         FETCH check_config_exists
          INTO l_config_exists;

         CLOSE check_config_exists;

         IF l_config_exists = 'Y'
         THEN
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
               NULL;
            END IF;

            /* Call Copy Config API provided by Contract Expert Team */
            okc_xprt_cz_int_pvt.copy_configuration
                            (p_api_version               => 1,
                             p_init_msg_list             => okc_api.g_false,
                             p_config_header_id          => l_src_config_header_id,
                             p_config_rev_nbr            => l_src_config_revision_number,
                             p_new_config_flag           => fnd_api.g_true,
                             x_new_config_header_id      => l_new_config_header_id,
                             x_new_config_rev_nbr        => l_new_config_rev_nbr,
                             x_return_status             => x_return_status,
                             x_msg_data                  => x_msg_data,
                             x_msg_count                 => x_msg_count
                            );

            IF (x_return_status = g_ret_sts_unexp_error)
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF (x_return_status = g_ret_sts_error)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            UPDATE okc_template_usages
               SET config_header_id = l_new_config_header_id,
                   config_revision_number = l_new_config_rev_nbr,
                   valid_config_yn = l_src_valid_config_yn
             WHERE document_type = p_target_document_type
               AND document_id = p_target_document_id;
         END IF;
      END IF;
	END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END refresh_xprt;

   PROCEDURE copy_art_variables (
      p_source_doc_clause_id   IN              NUMBER,
      p_target_doc_clause_id   IN              NUMBER,
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR l_get_variables_csr
      IS
         SELECT p_target_doc_clause_id cat_id, var.variable_code,
                busvar.variable_type, busvar.external_yn,
                busvar.value_set_id, var.variable_value,
                var.variable_value_id, var.override_global_yn,
                var.mr_variable_html, var.mr_variable_xml, busvar.mrv_flag
           FROM okc_k_art_variables var,
                okc_k_articles_b kart,
                okc_k_articles_b kart_tar,
                okc_bus_variables_b busvar
          WHERE kart.ID = p_source_doc_clause_id
            AND var.cat_id = kart.ID
            AND busvar.variable_code = var.variable_code;

      TYPE catlist IS TABLE OF okc_k_art_variables.cat_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE varlist IS TABLE OF okc_k_art_variables.variable_code%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE vartypelist IS TABLE OF okc_k_art_variables.variable_type%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE externallist IS TABLE OF okc_k_art_variables.external_yn%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE valsetlist IS TABLE OF okc_k_art_variables.attribute_value_set_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE varvallist IS TABLE OF okc_k_art_variables.variable_value%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE varidlist IS TABLE OF okc_k_art_variables.variable_value_id%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE overrideglobalynlist IS TABLE OF okc_k_art_variables.override_global_yn%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE mrvariablehtmllist IS TABLE OF okc_k_art_variables.mr_variable_html%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE mrvariablexmllist IS TABLE OF okc_k_art_variables.mr_variable_xml%TYPE
         INDEX BY BINARY_INTEGER;

      TYPE mrvflaglist IS TABLE OF okc_bus_variables_b.mrv_flag%TYPE
         INDEX BY BINARY_INTEGER;

      cat_tbl                  catlist;
      var_tbl                  varlist;
      var_type_tbl             vartypelist;
      external_yn_tbl          externallist;
      value_set_id_tbl         valsetlist;
      var_value_tbl            varvallist;
      var_value_id_tbl         varidlist;
      override_global_yn_tbl   overrideglobalynlist;
      mrvariablehtml_tbl       mrvariablehtmllist;
      mrvariablexml_tbl        mrvariablexmllist;
      mrvflag_tbl              mrvflaglist;
      dochasmrv                VARCHAR2 (1);
   BEGIN
      x_return_status := g_ret_sts_success;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1000: Entered copy_art_variables'
                        );
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                            '1000: Entered p_source_doc_clause_id '
                         || p_source_doc_clause_id
                        );
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                            '1000: Entered p_target_doc_clause_id '
                         || p_target_doc_clause_id
                        );
      END IF;

      OPEN l_get_variables_csr;

      FETCH l_get_variables_csr
      BULK COLLECT INTO cat_tbl, var_tbl, var_type_tbl, external_yn_tbl,
             value_set_id_tbl, var_value_tbl, var_value_id_tbl,
             override_global_yn_tbl, mrvariablehtml_tbl, mrvariablexml_tbl,
             mrvflag_tbl;

      CLOSE l_get_variables_csr;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1010: Got variable information'
                        );
      END IF;

      IF cat_tbl.COUNT > 0
      THEN
         FORALL i IN cat_tbl.FIRST .. cat_tbl.LAST
            INSERT INTO okc_k_art_variables
                        (cat_id, variable_code, variable_type,
                         external_yn, attribute_value_set_id,
                         variable_value, variable_value_id,
                         override_global_yn, mr_variable_html,
                         mr_variable_xml, object_version_number,
                         creation_date, created_by, last_update_date,
                         last_updated_by, last_update_login
                        )
                 VALUES (cat_tbl (i), var_tbl (i), var_type_tbl (i),
                         external_yn_tbl (i), value_set_id_tbl (i),
                         var_value_tbl (i), var_value_id_tbl (i),
                         override_global_yn_tbl (i), mrvariablehtml_tbl (i),
                         mrvariablexml_tbl (i), 1,
                         SYSDATE, fnd_global.user_id, SYSDATE,
                         fnd_global.user_id, fnd_global.login_id
                        );
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1020: Inserted records into okc_k_art_variables ||'
                        );
      END IF;

      FOR i IN mrvflag_tbl.FIRST .. mrvflag_tbl.LAST
      LOOP
         IF NVL (mrvflag_tbl (i), 'N') = 'Y'
         THEN
            -- Call to UDA API.
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
               fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                               g_pkg_name,
                               '1040: Calling Copy UDA API'
                              );
               fnd_log.STRING (FND_LOG.LEVEL_STATEMENT, g_pkg_name, '1050: var_tbl (i)');
            END IF;

            okc_mrv_util.copy_variable_uda_data
                                     (p_from_cat_id             => p_source_doc_clause_id,
                                      p_from_variable_code      => var_tbl (i),
                                      p_to_cat_id               => p_target_doc_clause_id,
                                      p_to_variable_code        => var_tbl (i),
                                      x_return_status           => x_return_status,
                                      x_msg_count               => x_msg_count,
                                      x_msg_data                => x_msg_data
                                     );
         END IF;
      END LOOP;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '9999: Completed copy_art_variables'
                        );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                            g_pkg_name,
                            '0000: exception in copy_art_variables '
                            || SQLERRM
                           );
         END IF;

         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END copy_art_variables;

   PROCEDURE copy_section (
      p_source_section_id       IN              NUMBER,
      p_target_document_type    IN              VARCHAR2,
      p_target_document_id      IN              NUMBER,
      p_target_doc_section_id   IN              NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR cur_scn_details (cp_scn_id NUMBER)
      IS
         SELECT ID, scn_id parent_scn_id, scn_code, amendment_operation_code,
                orig_system_reference_id1, heading, label, section_sequence
           FROM okc_sections_b
          WHERE ID = cp_scn_id;


      CURSOR cur_scn_details1 (cp_scn_id number)
      IS  SELECT ID, scn_id parent_scn_id, scn_code, amendment_operation_code,
                orig_system_reference_id1, heading, label, section_sequence
           FROM okc_sections_b
          WHERE orig_system_reference_id1 = cp_scn_id
          AND document_type = p_target_document_type
          AND document_id=p_target_document_id;

      l_tgt_scn_details_rec      cur_scn_details%ROWTYPE;
      l_src_scn_details_rec      cur_scn_details%ROWTYPE;
      l_parent_scn_details_rec   cur_scn_details1%ROWTYPE;
      l_parent_scn_id            NUMBER                    := NULL;
      x_new_section_id           NUMBER;
      l_src_parent_section_id    NUMBER;
   BEGIN

     x_return_status := g_ret_sts_success;

      -- Get the current section details
      OPEN cur_scn_details (p_target_doc_section_id);
      FETCH cur_scn_details
      INTO l_tgt_scn_details_rec;
      CLOSE cur_scn_details;

      -- Find the source record.
      OPEN  cur_scn_details(l_tgt_scn_details_rec.orig_system_reference_id1);
      FETCH cur_scn_details INTO l_src_scn_details_rec;
      IF  cur_scn_details%NOTFOUND THEN
          CLOSE cur_scn_details;
           okc_Api.Set_Message(p_app_name    => G_APP_NAME,
                               p_msg_name    => 'OKC_SRC_SEC_NOT_FOUND_RVRT'
                               );
           x_return_status :=  G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE cur_scn_details;

      IF l_src_scn_details_rec.parent_scn_id IS NOT NULL THEN
          -- The section is a sub-section in the base document, so find the corresponding parent record in the target document.
          OPEN   cur_scn_details1(l_src_scn_details_rec.parent_scn_id);
          FETCH  cur_scn_details1 INTO l_parent_scn_details_rec;
          CLOSE  cur_scn_details1;

          IF l_parent_scn_details_rec.amendment_operation_code = 'DELETED'
          THEN
                  okc_api.set_message
                              (p_app_name      =>   g_app_name,
                               p_msg_name      =>   'OKC_RVRT_P_SEC_BEFORE_SEC',
                               p_token1        =>  'SEC_NAME',
                               p_token1_value  => l_parent_scn_details_rec.heading
                              );
                  x_return_status := g_ret_sts_error;
                  RAISE fnd_api.g_exc_error;
           ELSE
                  l_parent_scn_id := l_parent_scn_details_rec.ID;
           END IF;
      ELSE
         l_parent_scn_id := NULL;
      END IF;

      IF l_tgt_scn_details_rec.scn_code IS NOT NULL
      THEN
         -- section is coming from library no need to copy from base document.
         UPDATE okc_sections_b
            SET amendment_description = NULL,
                amendment_operation_code = NULL,
                summary_amend_operation_code = NULL,
                scn_id = l_parent_scn_id,
                last_amended_by = NULL,
                last_amendment_date = NULL
          WHERE ID = p_target_doc_section_id;
      ELSE
         SELECT okc_sections_b_s.NEXTVAL
           INTO x_new_section_id
           FROM DUAL;

         INSERT INTO okc_sections_b tar_sec
                     (ID, chr_id, heading, description, document_type,
                      document_id, scn_id, orig_system_reference_code,
                      orig_system_reference_id1, orig_system_reference_id2,
                      section_sequence, label, print_yn, attribute_category,
                      attribute1, attribute2, attribute3, attribute4,
                      attribute5, attribute6, attribute7, attribute8,
                      attribute9, attribute10, attribute11, attribute12,
                      attribute13, attribute14, attribute15,
                      object_version_number,created_by, creation_date, last_updated_by, last_update_date, last_update_login)
            SELECT x_new_section_id,
                   DECODE (p_target_document_type,
                           'OKC_BUY', p_target_document_id,
                           'OKC_SELL', p_target_document_id,
                           'OKO', p_target_document_id,
                           'OKS', p_target_document_id,
                           'OKE_BUY', p_target_document_id,
                           'OKE_SELL', p_target_document_id,
                           'OKL', p_target_document_id,
                           NULL
                          ),
                   heading, description, p_target_document_type,
                   p_target_document_id, l_parent_scn_id, 'COPY', ID, NULL,
                   section_sequence, label, print_yn, attribute_category,
                   attribute1, attribute2, attribute3, attribute4, attribute5,
                   attribute6, attribute7, attribute8, attribute9,
                   attribute10, attribute11, attribute12, attribute13,
                   attribute14, attribute15,
                   1,fnd_global.user_id,SYSDATE,fnd_global.user_id,SYSDATE,fnd_global.login_id
              FROM okc_sections_b
             WHERE ID = p_source_section_id;

             IF SQL%ROWCOUNT = 0 THEN
                okc_Api.Set_Message(p_app_name    => G_APP_NAME,
                                    p_msg_name    => 'OKC_SRC_ART_NOT_FOUND_RVRT'
                                    );
                x_return_status :=  G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
             END IF;

         -- Update the existsing sub-sections /clauses with the new section id.
         UPDATE okc_sections_b
            SET scn_id = x_new_section_id
          WHERE document_type = p_target_document_type
            AND document_id = p_target_document_id
            AND scn_id = p_target_doc_section_id;

         UPDATE okc_k_articles_b
            SET scn_id = p_target_doc_section_id
          WHERE document_type = p_target_document_type
            AND document_id = p_target_document_id
            AND scn_id = p_target_doc_section_id;
      END IF;
   END copy_section;

   PROCEDURE refresh_section (
      p_source_section_id       IN              NUMBER,
      p_target_document_type    IN              VARCHAR2,
      p_target_document_id      IN              NUMBER,
      p_target_doc_section_id   IN              NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR cur_tgt_sec_details
      IS
         SELECT scn_code, ROWID
           FROM okc_sections_b
          WHERE ID = p_target_doc_section_id;

      l_cur_tgt_rec   cur_tgt_sec_details%ROWTYPE;


      l_api_name VARCHAR2(240) := g_pkg_name||'.' ||'refresh_section';

   BEGIN
      x_return_status := g_ret_sts_success;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,l_api_name,'1000: Entered refresh Section');
      END IF;


--------------------------------------
-- Copy the Section
--------------------------------------
      copy_section (p_source_section_id          => p_source_section_id,
                    p_target_document_type       => p_target_document_type,
                    p_target_document_id         => p_target_document_id,
                    p_target_doc_section_id      => p_target_doc_section_id,
                    x_return_status              => x_return_status,
                    x_msg_data                   => x_msg_data,
                    x_msg_count                  => x_msg_count
                   );

--------------------------------------
-- Delete the Section
--------------------------------------
      OPEN cur_tgt_sec_details;

      FETCH cur_tgt_sec_details
       INTO l_cur_tgt_rec;

      CLOSE cur_tgt_sec_details;

      IF l_cur_tgt_rec.scn_code IS NULL
      THEN
         DELETE FROM okc_sections_tl
               WHERE ID = p_target_doc_section_id;

         DELETE FROM okc_sections_b
               WHERE ROWID = l_cur_tgt_rec.ROWID;
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '9999: Completed  refresh_section '
                        );
      END IF;
END refresh_section;

   PROCEDURE revert_changes (
      p_api_version             IN              NUMBER,
      p_init_msg_list           IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                  IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_K_ENTITY_LOCK_ID IN NUMBER,
      p_entity_name             IN              VARCHAR2,
      p_entity_pk1              IN              VARCHAR2,
      p_entity_pk2              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk3              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk4              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk5              IN              VARCHAR2 DEFAULT NULL,
      p_lock_by_entity_id       IN              NUMBER DEFAULT NULL,
      p_lock_by_document_type   IN              VARCHAR2,
      p_lock_by_document_id     IN              NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_version   CONSTANT NUMBER         := 1;
      l_api_name      CONSTANT VARCHAR2 (240) := 'revert_changes';
   BEGIN
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '1000: Entered revert_changes'
                        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT g_revert_changes_grp;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF p_entity_name = okc_k_entity_locks_grp.g_clause_entity
      THEN
         refresh_clause (p_source_doc_clause_id      => TO_NUMBER
                                                                 (p_entity_pk1),
                         p_target_document_type      => p_lock_by_document_type,
                         p_target_document_id        => p_lock_by_document_id,
                         p_target_doc_clause_id      => p_lock_by_entity_id,
                         x_return_status             => x_return_status,
                         x_msg_count                 => x_msg_count,
                         x_msg_data                  => x_msg_data
                        );
      ELSIF p_entity_name = okc_k_entity_locks_grp.g_section_entity
      THEN
         refresh_section (p_source_section_id          => TO_NUMBER
                                                                 (p_entity_pk1),
                          p_target_document_type       => p_lock_by_document_type,
                          p_target_document_id         => p_lock_by_document_id,
                          p_target_doc_section_id      => p_lock_by_entity_id,
                          x_return_status              => x_return_status,
                          x_msg_count                  => x_msg_count,
                          x_msg_data                   => x_msg_data
                         );
      ELSIF p_entity_name = okc_k_entity_locks_grp.g_xprt_entity
      THEN
         refresh_xprt (p_target_document_type      => p_lock_by_document_type,
                       p_target_document_id        => p_lock_by_document_id,
                       x_return_status             => x_return_status,
                       x_msg_count                 => x_msg_count,
                       x_msg_data                  => x_msg_data
                      );
      END IF;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
         fnd_log.STRING (FND_LOG.LEVEL_STATEMENT,
                         g_pkg_name,
                         '9999: completed revert_changes'
                        );
      END IF;

      -- Delete the lock from the table
      DELETE FROM okc_k_entity_locks
      WHERE k_entity_lock_id = p_K_ENTITY_LOCK_ID;

  -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
               (FND_LOG.LEVEL_STATEMENT,
                g_pkg_name,
                '0000: Leaving revert_changes: OKC_API.G_EXCEPTION_ERROR Exception'
               );
         END IF;

         ROLLBACK TO g_revert_changes_grp;
         x_return_status := g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
               (FND_LOG.LEVEL_STATEMENT,
                g_pkg_name,
                '0000: Leaving revert_changes: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception'
               );
         END IF;

         ROLLBACK TO g_revert_changes_grp;
         x_return_status := g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
            fnd_log.STRING
                    (FND_LOG.LEVEL_STATEMENT,
                     g_pkg_name,
                        '0000: Leaving revert_changes because of EXCEPTION: '
                     || SQLERRM
                    );
         END IF;

         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         ROLLBACK TO g_revert_changes_grp;
         x_return_status := g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END revert_changes;


  FUNCTION get_document_number(p_document_type IN VARCHAR2, p_document_id IN number)
  RETURN VARCHAR2
  IS

  l_sql VARCHAR2(2000);

  l_from_table VARCHAR2(240);
  l_where_clause VARCHAR2(1000);
  l_pk1_col_name VARCHAR2(240);
  l_pk1_id       NUMBER;

  l_doc_num_col_name VARCHAR2(240);
  l_document_number VARCHAR2(240);

  BEGIN

  IF p_document_type IN ( 'PO_STANDARD_MOD' , 'PA_BLANKET_MOD' , 'PA_CONTRACT_MOD' ) THEN
     l_from_table := 'PO_DRAFTS' ;
     l_pk1_col_name   := 'DRAFT_ID';
     l_doc_num_col_name := 'MODIFICATION_NUMBER';
  END IF;

  l_sql := 'SELECT ' ||l_doc_num_col_name || ' FROM ' || l_from_table || ' WHERE 1=1 ';
  l_where_clause := ' AND '|| l_pk1_col_name ||' = '|| p_document_id;

  l_sql := l_sql || l_where_clause;

  EXECUTE IMMEDIATE l_sql INTO l_document_number;

  RETURN  l_document_number;
  EXCEPTION
   WHEN OTHERS THEN
    RETURN NULL;
  END get_document_number;


FUNCTION get_entity_title (p_entity_name IN VARCHAR2, p_entity_pk1 IN VARCHAR2 , p_entity_pk2 IN VARCHAR2)
 RETURN VARCHAR2
IS
l_title VARCHAR2(2000) := null;
BEGIN
    IF  p_entity_name = 'CLAUSE' THEN
        SELECT okc_terms_util_pvt.get_article_name(kart.sav_sae_id, kart.article_version_id)
        INTO l_title
        FROM okc_k_articles_b kart
        WHERE id=To_Number(p_entity_pk1);
    ELSIF  p_entity_name = 'SECTION' THEN
     SELECT heading
     INTO  l_title
     FROM okc_sections_b
     WHERE id=To_Number(p_entity_pk1);
    ELSE
     RETURN l_title;
    END IF;

    RETURN l_title;
EXCEPTION
 WHEN OTHERS THEN
  RETURN l_title;
END  get_entity_title;


PROCEDURE get_src_doc_details ( p_doc_type IN VARCHAR2,
                                p_doc_id   IN NUMBER,
                                x_src_doc_type  OUT NOCOPY VARCHAR2,
                                x_src_doc_id OUT NOCOPY VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data  OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER
                              )
IS

CURSOR cur_get_details_from_usage
IS
SELECT orig_system_reference_code, To_Char(orig_system_reference_id1)
FROM okc_template_usages
WHERE document_type  =  p_doc_type
AND document_id=  p_doc_id;

CURSOR cur_get_details_from_sections
IS
SELECT src.document_type, To_Char(src.document_id)
FROM   okc_sections_b tgt,
       okc_sections_b src
WHERE  tgt.document_type= p_doc_type
AND    tgt.document_id= p_doc_id
AND    tgt.orig_system_reference_code = 'COPY'
AND    src.id=tgt.orig_system_reference_id1;

BEGIN

x_return_status := G_RET_STS_SUCCESS;
x_msg_count     := 0;
x_msg_data      := NULL;


OPEN   cur_get_details_from_usage;
FETCH  cur_get_details_from_usage INTO x_src_doc_type,x_src_doc_id;
IF  cur_get_details_from_usage%NOTFOUND THEN
    OPEN cur_get_details_from_sections;
    FETCH  cur_get_details_from_sections INTO x_src_doc_type,x_src_doc_id;
    IF  cur_get_details_from_sections%NOTFOUND THEN
        x_return_status := G_RET_STS_ERROR;
        OKC_API.SET_MESSAGE(  p_app_name      => g_app_name
                            , p_msg_name      => 'OKC_SRC_DOC_NOT_FOUND');
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_log.STRING
                    (FND_LOG.LEVEL_STATEMENT,
                     g_pkg_name,
                        '0100: Can not find the source document'
                    );
         end IF;
    ELSE
     CLOSE cur_get_details_from_sections;
     RETURN ;
    END IF;
ELSE
    CLOSE cur_get_details_from_usage;
    RETURN;
END IF;

EXCEPTION
 WHEN OTHERS THEN
     IF cur_get_details_from_usage%ISOPEN THEN
       CLOSE  cur_get_details_from_usage;
     END IF;

     IF cur_get_details_from_sections%ISOPEN THEN
       CLOSE  cur_get_details_from_sections;
     END IF;
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
     THEN
            fnd_log.STRING
                    (FND_LOG.LEVEL_STATEMENT,
                     g_pkg_name,
                        '0000: Leaving get_src_doc_details because of EXCEPTION: '
                     || SQLERRM
                    );
         END IF;
     --RAISE;
END  get_src_doc_details;


PROCEDURE revert_entity ( p_api_version     IN NUMBER,
                          p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_commit         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_k_entity_lock_id IN NUMBER,
                          X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          X_MSG_COUNT OUT NOCOPY NUMBER,
                          X_MSG_DATA OUT NOCOPY VARCHAR2
                         )
IS

CURSOR cur_lock_details
IS
SELECT  entity_name, entity_pk1, entity_pk2, entity_pk3, entity_pk4, entity_pk5, lock_by_entity_id, lock_by_document_type, lock_by_document_id
FROM OKC_K_ENTITY_LOCKS
WHERE  k_entity_lock_id = p_k_entity_lock_id;

lock_details_rec cur_lock_details%rowtype;
BEGIN

OPEN    cur_lock_details;
FETCH  cur_lock_details INTO lock_details_rec;
CLOSE cur_lock_details;

revert_changes(    p_api_version => p_api_version
                 , p_init_msg_list =>  p_init_msg_list
                 , p_commit => p_commit
                 , p_k_entity_lock_id => p_k_entity_lock_id
                 , P_ENTITY_NAME  => lock_details_rec.entity_name
                 , P_ENTITY_PK1   => lock_details_rec.entity_pk1
                 , P_ENTITY_PK2   => lock_details_rec.entity_pk2
                 , P_ENTITY_PK3   => lock_details_rec.entity_pk3
                 , P_ENTITY_PK4   => lock_details_rec.entity_pk4
                 , P_ENTITY_PK5   => lock_details_rec.entity_pk5
                 , p_lock_by_entity_id   => lock_details_rec.lock_by_entity_id
                 , p_LOCK_BY_DOCUMENT_TYPE => lock_details_rec.lock_by_document_type
                 , p_LOCK_BY_DOCUMENT_ID => lock_details_rec.lock_by_document_id
                 , X_RETURN_STATUS => X_RETURN_STATUS
                 , X_MSG_COUNT => X_MSG_COUNT
                 , X_MSG_DATA => X_MSG_DATA
              );


END revert_entity;


FUNCTION isclauseLockedbyOtherDoc (p_src_kart_id IN NUMBER,p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
RETURN VARCHAR2
IS
l_lock_exists VARCHAR2(1);
BEGIN
  SELECT 'Y'
   INTO l_lock_exists
  FROM  okc_k_entity_locks
  WHERE entity_name='CLAUSE'
  AND   entity_pk1=To_Char(p_src_kart_id)
  AND   lock_by_document_id <> p_tgt_document_id;

   RETURN Nvl(l_lock_exists,'N');
EXCEPTION
WHEN No_Data_Found THEN
 RETURN 'N';
WHEN OTHERS THEN
  RAISE;
END isclauseLockedbyOtherDoc;


FUNCTION isEntityLockedbyOtherDoc (p_entity_name IN VARCHAR2,p_src_entity_id IN NUMBER,p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
RETURN VARCHAR2
IS
l_lock_exists VARCHAR2(1);

CURSOR cur_src_art_details(cp_article_id NUMBER)
IS
SELECT document_type,document_id
FROM   okc_k_Articles_b
WHERE  id=  cp_article_id;


CURSOR cur_src_sec_details(cp_sec_id NUMBER)
IS
SELECT document_type,document_id
FROM   okc_sections_b
WHERE  id=  cp_sec_id;

l_src_doc_type  VARCHAR2(30);
l_src_doc_id NUMBER;

CURSOR  cur_src_doc_details
IS
SELECT orig_system_reference_code, orig_system_reference_id1
FROM   okc_template_usages
WHERE document_type =   p_tgt_document_type
AND   document_id   =  p_tgt_document_id;


l_document_type VARCHAR2(30);
l_document_id NUMBER;

l_lock_by_doc_type VARCHAR2(30);
l_lock_by_document_id NUMBER;

BEGIN

  IF p_entity_name = 'CLAUSE' THEN
     OPEN  cur_src_art_details(p_src_entity_id);
     FETCH cur_src_art_details INTO l_document_type,l_document_id;
     CLOSE cur_src_art_details;
  ELSIF  p_entity_name = 'SECTION' THEN
    OPEN  cur_src_sec_details(p_src_entity_id);
    FETCH cur_src_sec_details INTO  l_document_type,l_document_id;
    CLOSE cur_src_sec_details;
  END IF;

  IF   l_document_type =  p_tgt_document_type THEN
       RETURN 'N';
  END IF;

  SELECT lock_by_document_type,lock_by_document_id
   INTO  l_lock_by_doc_type,l_lock_by_document_id
  FROM  okc_k_entity_locks
  WHERE entity_name=p_entity_name
  AND   entity_pk1=To_Char(p_src_entity_id);

   IF  l_lock_by_doc_type = p_tgt_document_type AND   l_lock_by_document_id  = p_tgt_document_id THEN
       RETURN 'N';
   ELSE
      RETURN 'Y';
   END IF;

EXCEPTION
WHEN No_Data_Found THEN
 RETURN 'N';
WHEN OTHERS THEN
  RAISE;
END isEntityLockedbyOtherDoc;



FUNCTION isSectionLockedbyOtherDoc (p_src_ksec_id IN NUMBER,p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
RETURN VARCHAR2
IS
l_lock_exists VARCHAR2(1);
BEGIN
  SELECT 'Y'
   INTO l_lock_exists
  FROM  okc_k_entity_locks
  WHERE entity_name='SECTION'
  AND   entity_pk1=To_Char(p_src_ksec_id)
  AND   lock_by_document_id <> p_tgt_document_id;

   RETURN Nvl(l_lock_exists,'N');
EXCEPTION
WHEN No_Data_Found THEN
 RETURN 'N';
WHEN OTHERS THEN
  RAISE;
END isSectionLockedbyOtherDoc;




FUNCTION isXprtLockedbyOtherDoc (p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
RETURN VARCHAR2
IS
l_lock_exists VARCHAR2(1);

l_src_doc_type  VARCHAR2(30);
l_src_doc_id NUMBER;

CURSOR  cur_src_doc_details
IS
SELECT orig_system_reference_code, orig_system_reference_id1
FROM   okc_template_usages
WHERE document_type =   p_tgt_document_type
AND   document_id   =  p_tgt_document_id;

BEGIN

  OPEN  cur_src_doc_details;
  FETCH cur_src_doc_details INTO  l_src_doc_type,l_src_doc_id;
  CLOSE cur_src_doc_details;

  IF l_src_doc_type IS NULL OR  l_src_doc_id IS NULL THEN
     RETURN 'N';
  END IF;

  SELECT 'Y'
   INTO l_lock_exists
  FROM  okc_k_entity_locks
  WHERE entity_name='XPRT'
  AND   entity_pk1=  To_Char(l_src_doc_id)
  AND   entity_pk2 = l_src_doc_type
  AND   lock_by_document_id <> p_tgt_document_id;

   RETURN Nvl(l_lock_exists,'N');
EXCEPTION
WHEN No_Data_Found THEN
 RETURN 'N';
WHEN OTHERS THEN
  RETURN 'N';
END isXprtLockedbyOtherDoc;

FUNCTION isAnyClauseLockedByOtherDoc(p_variable_code IN VARCHAR2, p_tgt_document_type IN VARCHAR2, p_tgt_document_id IN NUMBER)
RETURN VARCHAR2
IS

CURSOR cur_lock_exists
IS
SELECT  'Y'
FROM okc_k_art_variables v,
     okc_k_articles_b k
WHERE k.id = v.cat_id
  AND v.variable_code = p_variable_code
  AND k.document_type = p_tgt_document_type
  AND k.document_id = p_tgt_document_id
  AND k.orig_system_reference_code = 'COPY'
  AND EXISTS  (SELECT 'Lock Exists'
                FROM okc_k_entity_locks lck
               WHERE lck.entity_name='CLAUSE'
               AND lck.entity_pk1 = To_Char(k.orig_system_reference_id1)
               AND   lock_by_document_id <> p_tgt_document_id)
              ;

l_exists varchar2(1);

BEGIN
   OPEN  cur_lock_exists;
   FETCH cur_lock_exists INTO  l_exists;
   IF cur_lock_exists%FOUND THEN
     CLOSE cur_lock_exists;
     RETURN 'Y';
   END IF;
   CLOSE cur_lock_exists;
   RETURN 'N';
END isAnyClauseLockedByOtherDoc;


PROCEDURE isAnyEntityLockedbyOtherDoc( p_doc_type IN VARCHAR2,
                             p_doc_id   IN NUMBER,
                             x_entity_locked OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER
                           )
IS
l_src_doc_type  VARCHAR2 (30);
l_src_doc_id NUMBER;

l_lock_exists VARCHAR2(1);


BEGIN

x_return_status := G_RET_STS_SUCCESS;

-- Get the Source document details:
get_src_doc_details (   p_doc_type      =>  p_doc_type,
                        p_doc_id        =>  p_doc_id,
                        x_src_doc_type  =>  l_src_doc_type ,
                        x_src_doc_id    =>  l_src_doc_id,
                        x_return_status =>  x_return_status,
                        x_msg_data      =>  x_msg_data,
                        x_msg_count     =>  x_msg_count
                    );

-- Check for xprt locked.
BEGIN

SELECT    'Y'
INTO l_lock_exists
FROM  okc_k_entity_locks
WHERE entity_name='XPRT'
AND entity_pk1=To_Char(l_src_doc_id)
AND entity_pk2=l_src_doc_type
AND lock_by_document_id <> p_doc_id;

IF Nvl(l_lock_exists,'N')='Y' THEN
 x_entity_locked := 'Y';
 RETURN;
END IF;
EXCEPTION
WHEN No_Data_Found  THEN
  NULL;
WHEN too_many_rows THEN
 x_entity_locked := 'Y';
 RETURN;
END;

BEGIN
x_return_status := G_RET_STS_SUCCESS;
-- Check for sections
SELECT  'Y'
INTO   l_lock_exists
FROM okc_k_entity_locks lck, okc_sections_b sec
WHERE lck.entity_name='SECTION'
AND   lck.entity_pk1=   To_Char(sec.id)
AND   sec.document_type= l_src_doc_type
AND   sec.document_id=   l_src_doc_id
AND  lck.lock_by_document_id <> p_doc_id;

IF Nvl(l_lock_exists,'N')='Y' THEN
 x_entity_locked := 'Y'         ;
 RETURN;
END IF;
EXCEPTION
WHEN No_Data_Found  THEN
  NULL;
WHEN too_many_rows THEN
 x_entity_locked := 'Y';
 RETURN;
END;


BEGIN
-- check for clauses
SELECT  'Y'
INTO l_lock_exists
FROM okc_k_entity_locks lck, okc_k_articles_b kart
WHERE lck.entity_name='CLAUSE'
AND   lck.entity_pk1=   To_Char(kart.id)
AND   kart.document_type= l_src_doc_type
AND   kart.document_id=   l_src_doc_id
AND   lck.lock_by_document_id <> p_doc_id;

IF Nvl(l_lock_exists,'N')='Y' THEN
 x_entity_locked := 'Y'          ;
 RETURN;
END IF;
EXCEPTION
WHEN No_Data_Found  THEN
   x_entity_locked := 'N';
   RETURN;
WHEN too_many_rows THEN
 x_entity_locked := 'Y';
 RETURN;
END;


EXCEPTION
 WHEN OTHERS THEN
        fnd_msg_pub.initialize;
        x_return_status := G_RET_STS_ERROR;
        okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
        fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                   p_count        => x_msg_count,
                                   p_data         => x_msg_data
                                   );

END  isAnyEntityLockedbyOtherDoc;


PROCEDURE start_notify_workflow (
   p_document_type        IN              VARCHAR2,
   p_document_id          IN              NUMBER,
   p_requestor_id         IN              NUMBER,
   p_actioner_id          IN              NUMBER,
   p_action_requested     IN              VARCHAR2,
   p_action_req_details   IN              VARCHAR2,
   x_return_status        OUT NOCOPY      VARCHAR2,
   x_msg_data             OUT NOCOPY      VARCHAR2,
   x_msg_count            OUT NOCOPY      NUMBER,
   p_init_msg_list        IN              VARCHAR2 DEFAULT fnd_api.g_true

)
IS
   l_wf_item_key       VARCHAR2 (240);
   l_wf_user_key       VARCHAR2 (240);
   l_wf_item_type      VARCHAR2 (100);
   l_reqestor_name     VARCHAR2 (240);
   l_actioner_name     VARCHAR2 (240);
   l_document_number   VARCHAR2 (240);
   l_doc_type          VARCHAR2 (240);

   CURSOR cur_user (cp_user_id NUMBER)
   IS
      SELECT user_name
        FROM fnd_user
       WHERE user_id = cp_user_id;

   CURSOR cur_doc_type (cp_doc_type VARCHAR2)
   IS
      SELECT NAME
        FROM okc_bus_doc_types_tl
       WHERE document_type = cp_doc_type AND LANGUAGE = USERENV ('Lang');
BEGIN
   x_return_status := g_ret_sts_success;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
   THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_pkg_name || '.start_notify_workflow',
                      '0100: start'
                     );
   END IF;

   -- Get the Requstor user details:
   OPEN cur_user (p_requestor_id);

   FETCH cur_user
    INTO l_reqestor_name;

   CLOSE cur_user;

   l_reqestor_name := NVL (l_reqestor_name, fnd_global.user_name);

   -- Get the Actioner user details;
   OPEN cur_user (p_actioner_id);

   FETCH cur_user
    INTO l_actioner_name;

   CLOSE cur_user;

   IF l_actioner_name IS NULL
   THEN
      -- Actioner name cannot be found
      NULL;
   -- raise error;
   END IF;

   l_wf_item_key :=
      SUBSTR (   p_document_type
              || ':'
              || TO_CHAR (SYSDATE, 'DDMONRRHH24MISS')
              || ':'
              || TO_CHAR (p_document_id),
              1,
              240
             );
   l_wf_user_key :=
      SUBSTR (   p_document_type
              || ':'
              || TO_CHAR (p_document_id)
              || ':'
              || TO_CHAR (SYSDATE, 'DDMONRRHH24MISS'),
              1,
              240
             );
   -- Read the profile and use the item type
   l_wf_item_type := 'OKCDCACC';

   wf_engine.createprocess (itemtype      => l_wf_item_type,
                            itemkey       => l_wf_item_key,
                            process       => 'OKCDOCNOTIFY'
                           );

   wf_engine.setitemowner (itemtype      => l_wf_item_type,
                           itemkey       => l_wf_item_key,
                           owner         => l_reqestor_name
                          );
   wf_engine.setitemuserkey (itemtype      => l_wf_item_type,
                             itemkey       => l_wf_item_key,
                             userkey       => l_wf_user_key
                            );
   --
   -- Setting various Workflow Item Attributes
   --
   wf_engine.setitemattrtext (itemtype      => l_wf_item_type,
                              itemkey       => l_wf_item_key,
                              aname         => 'REQUESTOR',
                              avalue        => l_reqestor_name
                             );
   wf_engine.setitemattrtext (itemtype      => l_wf_item_type,
                              itemkey       => l_wf_item_key,
                              aname         => 'ACTIONER',
                              avalue        => l_actioner_name
                             );
   --action requested
   wf_engine.setitemattrtext (itemtype      => l_wf_item_type,
                              itemkey       => l_wf_item_key,
                              aname         => 'ACNREQUESTED',
                              avalue        => p_action_requested
                             );

   wf_engine.setitemattrtext (itemtype      => l_wf_item_type,
                              itemkey       => l_wf_item_key,
                              aname         => 'REQDETAILS',
                              avalue        => p_action_req_details
                             );

   OPEN cur_doc_type (p_document_type);

   FETCH cur_doc_type
    INTO l_doc_type;

   CLOSE cur_doc_type;

   l_doc_type := NVL (l_doc_type, p_document_type);
   wf_engine.setitemattrtext (itemtype      => l_wf_item_type,
                              itemkey       => l_wf_item_key,
                              aname         => 'DOCTYPE',
                              avalue        => l_doc_type
                             );
   wf_engine.setitemattrtext (itemtype      => l_wf_item_type,
                              itemkey       => l_wf_item_key,
                              aname         => 'DOCID',
                              avalue        => p_document_id
                             );

   l_document_number := get_document_number (p_document_type, p_document_id);
   wf_engine.setitemattrtext (itemtype      => l_wf_item_type,
                              itemkey       => l_wf_item_key,
                              aname         => 'DOCNUMBER',
                              avalue        => l_document_number
                             );
   wf_engine.startprocess (itemtype => l_wf_item_type, itemkey => l_wf_item_key);
   COMMIT;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
   THEN
      fnd_log.STRING (fnd_log.level_statement,
                      g_pkg_name || '.start_notify_workflow',
                      '1000: end'
                     );
   END IF;

   IF p_init_msg_list = fnd_api.g_true
   THEN
      fnd_msg_pub.initialize;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := g_ret_sts_error;
      okc_api.set_message (p_app_name          => g_app_name,
                           p_msg_name          => g_unexpected_error,
                           p_token1            => g_sqlcode_token,
                           p_token1_value      => SQLCODE,
                           p_token2            => g_sqlerrm_token,
                           p_token2_value      => SQLERRM
                          );
      fnd_msg_pub.count_and_get (p_encoded      => 'F',
                                 p_count        => x_msg_count,
                                 p_data         => x_msg_data
                                );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_pkg_name || '.start_notify_workflow',
                         '1000:' || SQLERRM
                        );
      END IF;
--wf_core.context(d_module,'NOTIFY_MOD_REQUEST_KO',l_itemtype,l_itemkey);
-- raise_application_error(-20041, 'Failure in start_concmods_notif_workflow ', true);
END start_notify_workflow;

END okc_k_entity_locks_grp;

/
