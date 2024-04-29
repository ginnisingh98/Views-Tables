--------------------------------------------------------
--  DDL for Package Body IEX_AG_DN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_AG_DN_PKG" AS
/* $Header: iextadub.pls 120.2 2004/11/30 21:08:12 clchang ship $ */

     PG_DEBUG NUMBER(2) ;

PROCEDURE insert_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_ag_dn_xref_id                  IN OUT NOCOPY NUMBER
        , p_aging_bucket_id                  NUMBER
        , p_aging_bucket_line_id             NUMBER
        , p_callback_flag                    VARCHAR2
        , p_callback_days                    NUMBER
        , p_FM_METHOD                        VARCHAR2
        , p_template_id                      NUMBER
        , p_xdo_template_id                  NUMBER
        , p_score_RANGE_LOW                  NUMBER
        , p_score_RANGE_HIGH                 NUMBER
        , p_dunning_level                    VARCHAR2
        , p_object_version_number            NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
            FROM iex_ag_dn_xref
           WHERE ag_dn_xref_id = px_ag_dn_xref_id;
        --
        CURSOR get_seq_csr is
          SELECT IEX_AG_DN_XREF_S.nextval
            FROM sys.dual;
     BEGIN
     --
        If (px_ag_dn_xref_ID IS NULL) OR (px_ag_dn_xref_ID = FND_API.G_MISS_NUM) then
            OPEN get_seq_csr;
            FETCH get_seq_csr INTO px_ag_dn_xref_ID;
            CLOSE get_seq_csr;
        End If;
        --
        INSERT INTO IEX_AG_DN_XREF (
          AG_DN_XREF_ID
        , AGING_BUCKET_ID
        , AGING_BUCKET_LINE_ID
        , CALLBACK_FLAG
        , CALLBACK_DAYS
        , FM_METHOD
        , TEMPLATE_ID
        , XDO_TEMPLATE_ID
        , SCORE_RANGE_LOW
        , SCORE_RANGE_HIGH
        , DUNNING_LEVEL
        , OBJECT_VERSION_NUMBER
        , last_update_date
        , last_updated_by
        , creation_date
        , created_by
        , last_update_login
        ) VALUES (
          px_ag_dn_xref_id
        , DECODE(p_aging_bucket_id, FND_API.G_MISS_NUM, NULL, p_aging_bucket_id)
        , DECODE(p_aging_bucket_line_id, FND_API.G_MISS_NUM, NULL, p_aging_bucket_line_id)
        , DECODE(p_callback_flag, FND_API.G_MISS_CHAR, NULL, p_callback_flag)
        , DECODE(p_callback_days, FND_API.G_MISS_NUM, NULL, p_callback_days)
        , DECODE(p_fm_method, FND_API.G_MISS_CHAR, NULL, p_fm_method)
        , DECODE(p_template_id, FND_API.G_MISS_NUM, NULL, p_template_id)
        , DECODE(p_xdo_template_id, FND_API.G_MISS_NUM, NULL, p_xdo_template_id)
        , DECODE(p_score_range_low, FND_API.G_MISS_NUM, NULL, p_score_range_low)
        , DECODE(p_score_range_high, FND_API.G_MISS_NUM, NULL, p_score_range_high)
        , DECODE(p_dunning_level, FND_API.G_MISS_CHAR, NULL, p_dunning_level)
        , DECODE(p_object_version_number, FND_API.G_MISS_NUM, NULL, p_object_version_number)
        , DECODE(p_last_update_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_last_update_date)
        , DECODE(p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by)
        , DECODE(p_creation_date, FND_API.G_MISS_DATE, TO_DATE(NULL), p_creation_date)
        , DECODE(p_created_by, FND_API.G_MISS_NUM, NULL, p_created_by)
        , DECODE(p_last_update_login, FND_API.G_MISS_NUM, NULL, p_last_update_login)
        );

        OPEN l_insert;
        FETCH l_insert INTO px_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;



     PROCEDURE delete_row(
        p_ag_dn_xref_id                     NUMBER
     ) IS
     BEGIN
        DELETE FROM iex_ag_dn_xref
        WHERE ag_dn_xref_id = p_ag_dn_xref_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;


     PROCEDURE update_row(
          p_rowid                            VARCHAR2
        , p_ag_dn_xref_id                    NUMBER
        , p_aging_bucket_id                  NUMBER
        , p_aging_bucket_line_id             NUMBER
        , p_callback_flag                    VARCHAR2
        , p_callback_days                    NUMBER
        , p_FM_METHOD                        VARCHAR2
        , p_template_id                      NUMBER
        , p_xdo_template_id                  NUMBER
        , p_score_RANGE_LOW                  NUMBER
        , p_score_RANGE_HIGH                 NUMBER
        , p_dunning_level                    VARCHAR2
        , p_object_version_number            NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
     ) IS
     BEGIN
        UPDATE iex_ag_dn_xref
        SET
          ag_dn_xref_id          = DECODE(p_ag_dn_xref_id, FND_API.G_MISS_NUM, NULL, p_ag_dn_xref_id)
        , aging_bucket_id        = DECODE(p_aging_bucket_id, FND_API.G_MISS_NUM, NULL, p_aging_bucket_id)
        , aging_bucket_line_id   = DECODE(p_aging_bucket_line_id, FND_API.G_MISS_NUM, NULL, p_aging_bucket_line_id)
        , callback_flag          = DECODE(p_callback_flag, FND_API.G_MISS_CHAR, NULL, p_callback_flag)
        , callback_days          = DECODE(p_callback_days, FND_API.G_MISS_NUM, NULL, p_callback_days)
        , fm_method              = DECODE(p_fm_method, FND_API.G_MISS_CHAR, NULL, p_fm_method)
        , template_id            = DECODE(p_template_id, FND_API.G_MISS_NUM, NULL, p_template_id)
        , xdo_template_id        = DECODE(p_xdo_template_id, FND_API.G_MISS_NUM, NULL, p_xdo_template_id)
        , score_range_low        = DECODE(p_score_range_low, FND_API.G_MISS_NUM, NULL, p_score_range_low)
        , score_range_high       = DECODE(p_score_range_high, FND_API.G_MISS_NUM, NULL, p_score_range_high)
        , dunning_level          = DECODE(p_dunning_level, FND_API.G_MISS_CHAR, NULL, p_dunning_level)
        , object_version_number  = DECODE(p_object_version_number, FND_API.G_MISS_NUM, NULL, p_object_version_number)
        , last_update_date  = DECODE(p_last_update_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_last_update_date)
        , last_updated_by   = DECODE(p_last_updated_by,FND_API.G_MISS_NUM,NULL,p_last_updated_by)
        , creation_date     = DECODE(p_creation_date,FND_API.G_MISS_DATE,TO_DATE(NULL),p_creation_date)
        , created_by        = DECODE(p_created_by,FND_API.G_MISS_NUM,NULL,p_created_by)
        , last_update_login = DECODE(p_last_update_login,FND_API.G_MISS_NUM,NULL,p_last_update_login)
        WHERE ROWID         = p_rowid;
        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;



     PROCEDURE lock_row(
          p_rowid                            VARCHAR2
        , p_ag_dn_xref_id                    NUMBER
        , p_aging_bucket_id                  NUMBER
        , p_aging_bucket_line_id             NUMBER
        , p_callback_flag                    VARCHAR2
        , p_callback_days                    NUMBER
        , p_FM_METHOD                        VARCHAR2
        , p_template_id                      NUMBER
        , p_xdo_template_id                  NUMBER
        , p_score_RANGE_LOW                  NUMBER
        , p_score_RANGE_HIGH                 NUMBER
        , p_dunning_level                    VARCHAR2
        , p_object_version_number            NUMBER
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
     ) IS
        CURSOR l_lock IS
          SELECT *
          FROM iex_ag_dn_xref
          WHERE rowid = p_rowid
          FOR UPDATE OF ag_dn_xref_id NOWAIT;
        l_table_rec l_lock%ROWTYPE;
     BEGIN
        OPEN l_lock;
        FETCH l_lock INTO l_table_rec;
        IF (l_lock%NOTFOUND) THEN
             CLOSE l_lock;
             FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
             APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE l_lock;
        IF (
          ((l_table_rec.ag_dn_xref_id = p_ag_dn_xref_id)
            OR ((l_table_rec.ag_dn_xref_id IS NULL)
                AND ( p_ag_dn_xref_id IS NULL)))
          AND           ((l_table_rec.aging_bucket_id = p_aging_bucket_id)
            OR ((l_table_rec.aging_bucket_id IS NULL)
                AND ( p_aging_bucket_id IS NULL)))
          AND           ((l_table_rec.aging_bucket_line_id = p_aging_bucket_line_id)
            OR ((l_table_rec.aging_bucket_line_id IS NULL)
                AND ( p_aging_bucket_line_id IS NULL)))
          AND		((l_table_rec.callback_flag = p_callback_flag)
            OR ((l_table_rec.callback_flag IS NULL)
                AND ( p_callback_flag IS NULL)))
          AND		((l_table_rec.callback_days = p_callback_days)
            OR ((l_table_rec.callback_days IS NULL)
                AND ( p_callback_days IS NULL)))
          AND		((l_table_rec.fm_method = p_fm_method)
            OR ((l_table_rec.fm_method IS NULL)
                AND ( p_fm_method IS NULL)))
          AND		((l_table_rec.template_id = p_template_id)
            OR ((l_table_rec.template_id IS NULL)
                AND ( p_template_id IS NULL)))
          AND		((l_table_rec.xdo_template_id = p_xdo_template_id)
            OR ((l_table_rec.xdo_template_id IS NULL)
                AND ( p_xdo_template_id IS NULL)))
          AND		((l_table_rec.score_range_low = p_score_range_low)
            OR ((l_table_rec.score_range_low IS NULL)
                AND ( p_score_range_low IS NULL)))
          AND		((l_table_rec.score_range_high = p_score_range_high)
            OR ((l_table_rec.score_range_high IS NULL)
                AND ( p_score_range_high IS NULL)))
          AND		((l_table_rec.dunning_level = p_dunning_level)
            OR ((l_table_rec.dunning_level IS NULL)
                AND ( p_dunning_level IS NULL)))
          AND		((l_table_rec.object_version_number = p_object_version_number)
            OR ((l_table_rec.object_version_number IS NULL)
                AND ( p_object_version_number IS NULL)))
          AND           ((l_table_rec.last_update_date = p_last_update_date)
            OR ((l_table_rec.last_update_date IS NULL)
                AND ( p_last_update_date IS NULL)))
          AND           ((l_table_rec.last_updated_by = p_last_updated_by)
            OR ((l_table_rec.last_updated_by IS NULL)
                AND ( p_last_updated_by IS NULL)))
          AND           ((l_table_rec.creation_date = p_creation_date)
            OR ((l_table_rec.creation_date IS NULL)
                AND ( p_creation_date IS NULL)))
          AND           ((l_table_rec.created_by = p_created_by)
            OR ((l_table_rec.created_by IS NULL)
                AND ( p_created_by IS NULL)))
          AND           ((l_table_rec.last_update_login = p_last_update_login)
            OR ((l_table_rec.last_update_login IS NULL)
                AND ( p_last_update_login IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;

BEGIN
     PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END iex_ag_dn_pkg;

/
