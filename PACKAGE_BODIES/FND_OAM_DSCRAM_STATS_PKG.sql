--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_STATS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_STATS_PKG" as
/* $Header: AFOAMDSSTATB.pls 120.5 2006/06/07 17:56:52 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_STATS_PKG.';

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Private, does the grunt work for a create_entry call.
   PROCEDURE INTERNAL_CREATE_ENTRY(p_run_stat_id        IN NUMBER,
                                   p_source_object_type IN VARCHAR2,
                                   p_source_object_id   IN NUMBER,
                                   p_start_time         IN DATE,
                                   p_prestart_status    IN VARCHAR2,
                                   p_start_message      IN VARCHAR2,
                                   x_stat_id            OUT NOCOPY      NUMBER,
                                   x_return_status      OUT NOCOPY      VARCHAR2,
                                   x_return_msg         OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_CREATE_ENTRY';

      l_stat_id NUMBER(15);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --do the insert
      INSERT
         INTO fnd_oam_dscram_stats (STAT_ID,
                                    RUN_STAT_ID,
                                    SOURCE_OBJECT_TYPE,
                                    SOURCE_OBJECT_ID,
                                    OBJECT_START,
                                    PRESTART_OBJECT_STATUS,
                                    MESSAGE,
                                    CREATED_BY,
                                    CREATION_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATE_LOGIN)
         VALUES (FND_OAM_DSCRAM_STATS_S.NEXTVAL,
                 p_run_stat_id,
                 p_source_object_type,
                 p_source_object_id,
                 p_start_time,
                 p_prestart_status,
                 p_start_message,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID)
         RETURNING STAT_ID INTO l_stat_id;

      x_stat_id := l_stat_id;

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         --don't log it here, let the caller log it
   END;

   --Private, does the grunt work for completing a stats entry
   PROCEDURE INTERNAL_COMPLETE_ENTRY(p_run_stat_id              IN NUMBER,
                                     p_source_object_type       IN VARCHAR2,
                                     p_source_object_id         IN NUMBER,
                                     p_end_time                 IN DATE,
                                     p_postend_status           IN VARCHAR2,
                                     p_end_message              IN VARCHAR2,
                                     x_return_status            OUT NOCOPY      VARCHAR2,
                                     x_return_msg               OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_COMPLETE_ENTRY';

      l_stat_id NUMBER(15);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --do the update
      UPDATE fnd_oam_dscram_stats
         SET object_end = p_end_time,
             postend_object_status = p_postend_status,
             message = p_end_message,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.user_id,
             last_update_date = SYSDATE
         WHERE run_stat_id = p_run_stat_id
         AND source_object_type = p_source_object_type
         AND source_object_id = p_source_object_id;

      --make sure we completed a row
      IF SQL%ROWCOUNT <> 1 THEN
         x_return_msg := 'Stat Complete for Run Stat ID('||p_run_stat_id||'), source type ('||p_source_object_type||'), source id ('||p_source_object_id||') updated '||SQL%ROWCOUNT||' stat rows. Should be 1.';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE CREATE_ENTRY_FOR_RUN(p_run_id              IN NUMBER,
                                  p_start_time          IN DATE,
                                  p_prestart_status     IN VARCHAR2,
                                  p_start_message       IN VARCHAR2,
                                  x_run_stat_id         OUT NOCOPY      NUMBER,
                                  x_return_status       OUT NOCOPY      VARCHAR2,
                                  x_return_msg          OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CREATE_ENTRY_FOR_RUN';

      l_run_stat_id     NUMBER(15);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --select the stat_id first so we can use it as the run_stat_id also
      SELECT FND_OAM_DSCRAM_STATS_S.NEXTVAL
         INTO l_run_stat_id
         FROM DUAL;

      --can't use INTERNAL_CREATE since we are creating the run_stat_id at the same time
      INSERT
         INTO fnd_oam_dscram_stats (STAT_ID,
                                    RUN_STAT_ID,
                                    SOURCE_OBJECT_TYPE,
                                    SOURCE_OBJECT_ID,
                                    OBJECT_START,
                                    PRESTART_OBJECT_STATUS,
                                    MESSAGE,
                                    CREATED_BY,
                                    CREATION_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATE_LOGIN)
         VALUES (l_run_stat_id,
                 l_run_stat_id,
                 FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RUN,
                 p_run_id,
                 p_start_time,
                 p_prestart_status,
                 p_start_message,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID);

      x_run_stat_id := l_run_stat_id;

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END;

   -- Public
   PROCEDURE CREATE_ENTRY(p_run_stat_id         IN NUMBER,
                          p_source_object_type  IN VARCHAR2,
                          p_source_object_id    IN NUMBER,
                          p_start_time          IN DATE,
                          p_prestart_status     IN VARCHAR2,
                          p_start_message       IN VARCHAR2,
                          x_stat_id             OUT NOCOPY      NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CREATE_ENTRY';

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(4000);
   BEGIN
      INTERNAL_CREATE_ENTRY(p_run_stat_id               => p_run_stat_id,
                            p_source_object_type        => p_source_object_type,
                            p_source_object_id          => p_source_object_id,
                            p_start_time                => p_start_time,
                            p_prestart_status           => p_prestart_status,
                            p_start_message             => p_start_message,
                            x_stat_id                   => x_stat_id,
                            x_return_status             => l_return_status,
                            x_return_msg                => l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         --just log the message
         fnd_oam_debug.log(6, l_ctxt, l_return_msg);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
   END;

   -- Public
   PROCEDURE CREATE_ENTRY(p_source_object_type  IN VARCHAR2,
                          p_source_object_id    IN NUMBER,
                          p_start_time          IN DATE,
                          p_prestart_status     IN VARCHAR2,
                          p_start_message       IN VARCHAR2,
                          x_stat_id             OUT NOCOPY      NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CREATE_ENTRY(no_run_id)';

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      CREATE_ENTRY(p_run_stat_id        => FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_STAT_ID,
                   p_source_object_type => p_source_object_type,
                   p_source_object_id   => p_source_object_id,
                   p_start_time         => p_start_time,
                   p_prestart_status    => p_prestart_status,
                   p_start_message      => p_start_message,
                   x_stat_id            => x_stat_id);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
   END;

   -- Public
   PROCEDURE CREATE_ENTRY_AUTONOMOUSLY(p_source_object_type     IN VARCHAR2,
                                       p_source_object_id       IN NUMBER,
                                       p_start_time             IN DATE,
                                       p_prestart_status        IN VARCHAR2,
                                       p_start_message          IN VARCHAR2,
                                       p_dismiss_failure        IN VARCHAR2,
                                       x_stat_id                OUT NOCOPY NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'CREATE_ENTRY_AUTONOMOUSLY';
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      INTERNAL_CREATE_ENTRY(p_run_stat_id               => FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_STAT_ID,
                            p_source_object_type        => p_source_object_type,
                            p_source_object_id          => p_source_object_id,
                            p_start_time                => p_start_time,
                            p_prestart_status           => p_prestart_status,
                            p_start_message             => p_start_message,
                            x_stat_id                   => x_stat_id,
                            x_return_status             => l_return_status,
                            x_return_msg                => l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF NOT FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(p_dismiss_failure) THEN
            fnd_oam_debug.log(6, l_ctxt, l_return_msg);
         END IF;
         ROLLBACK;
      ELSE
         COMMIT;
         fnd_oam_debug.log(1, l_ctxt, 'Created stats row.');
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
   END;

   -- Public
   PROCEDURE COMPLETE_ENTRY_FOR_RUN(p_run_id            IN NUMBER,
                                    p_end_time          IN DATE,
                                    p_postend_status    IN VARCHAR2,
                                    p_end_message       IN VARCHAR2,
                                    x_return_status     OUT NOCOPY      VARCHAR2,
                                    x_return_msg        OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'CREATE_ENTRY_FOR_RUN';

      l_run_stat_id     NUMBER(15);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      SELECT last_run_stat_id
         INTO l_run_stat_id
         FROM fnd_oam_dscram_runs_b
         WHERE run_id = p_run_id;

      INTERNAL_COMPLETE_ENTRY(p_run_stat_id             => l_run_stat_id,
                              p_source_object_type      => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RUN,
                              p_source_object_id        => p_run_id,
                              p_end_time                => p_end_time,
                              p_postend_status          => p_postend_status,
                              p_end_message             => p_end_message,
                              x_return_status           => x_return_status,
                              x_return_msg              => x_return_msg);

      --success
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
   END;

   -- Public
   PROCEDURE COMPLETE_ENTRY(p_run_stat_id               IN NUMBER,
                            p_source_object_type        IN VARCHAR2,
                            p_source_object_id          IN NUMBER,
                            p_end_time                  IN DATE,
                            p_postend_status            IN VARCHAR2,
                            p_end_message               IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_ENTRY';

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      --make sure it's a valid finishing state
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_FINAL(p_postend_status) THEN
         fnd_oam_debug.log(6, l_ctxt, 'Skipping update because of non-final status '||p_postend_status||'.  This should not happen.');
         RETURN;
      END IF;

      INTERNAL_COMPLETE_ENTRY(p_run_stat_id             => p_run_stat_id,
                              p_source_object_type      => p_source_object_type,
                              p_source_object_id        => p_source_object_id,
                              p_end_time                => p_end_time,
                              p_postend_status          => p_postend_status,
                              p_end_message             => p_end_message,
                              x_return_status           => l_return_status,
                              x_return_msg              => l_return_msg);

   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
   END;

   -- Public
   PROCEDURE COMPLETE_ENTRY(p_source_object_type        IN VARCHAR2,
                            p_source_object_id          IN NUMBER,
                            p_end_time                  IN DATE,
                            p_postend_status            IN VARCHAR2,
                            p_end_message               IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_ENTRY(no run_id)';

   BEGIN
      COMPLETE_ENTRY(p_run_stat_id              => FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_STAT_ID,
                     p_source_object_type       => p_source_object_type,
                     p_source_object_id         => p_source_object_id,
                     p_end_time                 => p_end_time,
                     p_postend_status           => p_postend_status,
                     p_end_message              => p_end_message);

   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
   END;

   -- Public
   FUNCTION HAS_ENTRY(p_run_stat_id             IN NUMBER,
                      p_source_object_type      IN VARCHAR2,
                      p_source_object_id        IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'HAS_ENTRY(run_stat_id)';
      l_stat_id         NUMBER;
   BEGIN
      SELECT stat_id
         INTO l_stat_id
         FROM fnd_oam_dscram_stats
         WHERE run_stat_id = p_run_stat_id
         AND source_object_type = p_source_object_type
         AND source_object_id = p_source_object_id;

      --if no exception then yes.
      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

   -- Public
   FUNCTION HAS_ENTRY(p_source_object_type      IN VARCHAR2,
                      p_source_object_id        IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'HAS_ENTRY';
   BEGIN
      RETURN HAS_ENTRY(p_run_stat_id            => FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_STAT_ID,
                       p_source_object_type     => p_source_object_type,
                       p_source_object_id       => p_source_object_id);
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         RETURN FALSE;
   END;

END FND_OAM_DSCRAM_STATS_PKG;

/
