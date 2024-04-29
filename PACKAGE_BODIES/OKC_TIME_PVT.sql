--------------------------------------------------------
--  DDL for Package Body OKC_TIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TIME_PVT" AS
/* $Header: OKCCTVEB.pls 120.0 2005/05/25 22:39:52 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------

  PROCEDURE add_language IS
  BEGIN
--Bug 3122962
null;

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

    DELETE FROM OKC_TIMEVALUES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_TIMEVALUES_B B
         WHERE B.ID = T.ID
        );
*/

   /* commented out smallya 03/04/2003 for bug 2831959 as this does not make any sense.*/
   /* Also it takes a lot of time doing this redundant update*/
   /* UPDATE OKC_TIMEVALUES_TL T SET (
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS,
        NAME) = (SELECT
                                  B.DESCRIPTION,
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS,
                                  B.NAME
                                FROM OKC_TIMEVALUES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_TIMEVALUES_TL SUBB, OKC_TIMEVALUES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.NAME <> SUBT.NAME
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
              )); */

--Bug 3122962
/*
    INSERT INTO OKC_TIMEVALUES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS,
        NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.SHORT_DESCRIPTION,
            B.COMMENTS,
            B.NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_TIMEVALUES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_TIMEVALUES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
    okc_tcu_pvt.add_language;
    DELETE FROM OKC_TIMEVALUES_TLH T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_TIMEVALUES_BH B
         WHERE B.ID = T.ID
           AND B.MAJOR_VERSION = T.MAJOR_VERSION
        );

    UPDATE OKC_TIMEVALUES_TLH T SET (
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS,
        NAME) = (SELECT
                                  B.DESCRIPTION,
                                  B.SHORT_DESCRIPTION,
                                  B.COMMENTS,
                                  B.NAME
                                FROM OKC_TIMEVALUES_TLH B
                               WHERE B.ID = T.ID
                                 AND B.MAJOR_VERSION = T.MAJOR_VERSION
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.MAJOR_VERSION,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.MAJOR_VERSION,
                  SUBT.LANGUAGE
                FROM OKC_TIMEVALUES_TLH SUBB, OKC_TIMEVALUES_TLH SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.NAME <> SUBT.NAME
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
              ));

    INSERT INTO OKC_TIMEVALUES_TLH (
        ID,
        LANGUAGE,
        MAJOR_VERSION,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        SHORT_DESCRIPTION,
        COMMENTS,
        NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.MAJOR_VERSION,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.SHORT_DESCRIPTION,
            B.COMMENTS,
            B.NAME,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_TIMEVALUES_TLH B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_TIMEVALUES_TLH T
                     WHERE T.ID = B.ID
                       AND T.MAJOR_VERSION = B.MAJOR_VERSION
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
*/
  END add_language;


  PROCEDURE DELETE_TIMEVALUES_N_TASKS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_chr_id            IN NUMBER  ,
    p_tve_id                IN NUMBER) IS
    CURSOR tve_csr(p_tve_id IN NUMBER) is
--Bug 3122962
	SELECT TVE_TYPE, TVE_ID_OFFSET,TVE_ID_STARTED,TVE_ID_ENDED FROM OKC_TIMEVALUES
	 WHERE id = p_tve_id;
    l_tve_rec tve_csr%ROWTYPE;
    l_not_found BOOLEAN := TRUE;
    item_not_found_error EXCEPTION;
    p_talv_evt_rec	        OKC_TIME_PVT.talv_event_rec_type;
    p_tgnv_rec              OKC_TIME_PVT.tgnv_rec_type;
    p_tavv_rec              OKC_TIME_PVT.tavv_rec_type;
    p_cylv_ext_rec          OKC_TIME_PVT.cylv_extended_rec_type;
    p_tgdv_ext_rec	        OKC_TIME_PVT.tgdv_extended_rec_type;
    p_isev_ext_rec          OKC_TIME_PVT.isev_extended_rec_type;
    p_igsv_ext_rec	        OKC_TIME_PVT.igsv_extended_rec_type;
    l_api_name              CONSTANT VARCHAR2(30) := 'delete_timevalues_n_tasks';
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    if p_chr_id <> 0 Then
     if OKC_TIME_RES_PUB.Check_Res_Time_N_Tasks(p_tve_id, sysdate) Then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => 'OKC_RTV_EXISTS');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
     end if;
   end if;
   open tve_csr(p_tve_id);
   fetch tve_csr into l_tve_rec;
   l_not_found := tve_csr%NOTFOUND;
   close tve_csr;
   if l_not_found THEN
     OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID');
     raise item_not_found_error;
   end if;
   if l_tve_rec.tve_type = 'TAL' Then
     p_talv_evt_rec.id := p_tve_id;
     p_talv_evt_rec.tve_id_offset := l_tve_rec.tve_id_offset;
	OKC_TIME_PVT.DELETE_TPA_RELTV(
       p_api_version	,
       p_init_msg_list   ,
       x_return_status   ,
       x_msg_count       ,
       x_msg_data        ,
       p_talv_evt_rec) ;
  elsif l_tve_rec.tve_type = 'TGN' Then
    p_tgnv_rec.id := p_tve_id;
    OKC_TIME_PVT.DELETE_TPG_NAMED(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec);
  elsif l_tve_rec.tve_type = 'TAV' Then
    p_tavv_rec.id := p_tve_id;
    OKC_TIME_PVT.DELETE_TPA_VALUE(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec);
  elsif l_tve_rec.tve_type = 'TGD' Then
    p_tgdv_ext_rec.id := p_tve_id;
    OKC_TIME_PVT.DELETE_TPG_DELIMITED(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_ext_rec);
  elsif l_tve_rec.tve_type = 'CYL' Then
    p_cylv_ext_rec.id := p_tve_id;
    OKC_TIME_PVT.DELETE_CYCLE(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cylv_ext_rec);
  elsif l_tve_rec.tve_type = 'ISE' Then
    p_isev_ext_rec.id := p_tve_id;
    --Bug#3080839 Timevalues not getting deleted
    p_isev_ext_rec.tve_id_started := l_tve_rec.tve_id_started;
    p_isev_ext_rec.tve_id_ended := l_tve_rec.tve_id_ended;
      OKC_TIME_PVT.DELETE_IA_STARTEND(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_ext_rec);
  elsif l_tve_rec.tve_type = 'IGS' Then
    p_igsv_ext_rec.id := p_tve_id;
    --Bug#3080839 Timevalues not getting deleted
    p_igsv_ext_rec.tve_id_started := l_tve_rec.tve_id_started;
    p_igsv_ext_rec.tve_id_ended := l_tve_rec.tve_id_ended;
    OKC_TIME_PVT.DELETE_IG_STARTEND(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_igsv_ext_rec);
  end if;
  if x_return_status = OKC_API.G_RET_STS_SUCCESS Then
    OKC_TIME_RES_PUB.Delete_Res_Time_N_Tasks(
      p_tve_id,
      sysdate,
      p_api_version,
      p_init_msg_list,
      x_return_status);
   end if;

  EXCEPTION
    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PVT');
  END DELETE_TIMEVALUES_N_TASKS;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPA_RELTV
 --------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN talv_event_rec_type,
    p_to	IN OUT NOCOPY talv_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_offset := p_from.tve_id_offset;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.uom_code := p_from.uom_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.duration := p_from.duration;
    p_to.operator := p_from.operator;
    p_to.before_after := p_from.before_after;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE migrate (
    p_from	IN talv_rec_type,
    p_to	IN OUT NOCOPY talv_event_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_offset := p_from.tve_id_offset;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.uom_code := p_from.uom_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.duration := p_from.duration;
    p_to.operator := p_from.operator;
    p_to.before_after := p_from.before_after;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type,
    x_talv_rec          OUT NOCOPY talv_rec_type) IS
  BEGIN
    okc_tal_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec,
      x_talv_rec);
  END CREATE_TPA_RELTV;

  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type,
    x_talv_rec          OUT NOCOPY talv_rec_type) IS
  BEGIN
    okc_tal_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec,
      x_talv_rec);
  END UPDATE_TPA_RELTV;
  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type) IS
  BEGIN
    okc_tal_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec);
  END DELETE_TPA_RELTV;
  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type) IS
  BEGIN
    okc_tal_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec);
  END LOCK_TPA_RELTV;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_rec	    IN talv_rec_type) IS
  BEGIN
    okc_tal_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec);
  END VALID_TPA_RELTV;

  PROCEDURE CREATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type,
    x_talv_evt_rec          OUT NOCOPY talv_event_rec_type) IS
    p_talv_rec	            talv_rec_type;
    x_talv_rec	            talv_rec_type;
    p_tgnv_rec	            tgnv_rec_type;
    x_tgnv_rec	            tgnv_rec_type;
  BEGIN
    x_return_status         := OKC_API.G_RET_STS_SUCCESS;
    x_talv_evt_rec          := p_talv_evt_rec;
    p_tgnv_rec.cnh_id       := p_talv_evt_rec.cnh_id;
    p_tgnv_rec.comments := 'Generated by TAL';
    p_tgnv_rec.dnz_chr_id  := p_talv_evt_rec.dnz_chr_id;
    OKC_TIME_pub.create_tpg_named(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec,
      x_tgnv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    x_talv_evt_rec.tve_id_offset := x_tgnv_rec.id;
    x_talv_evt_rec.cnh_id := x_tgnv_rec.cnh_id;
    migrate(x_talv_evt_rec,p_talv_rec);
    okc_tal_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec,
      x_talv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_talv_rec,x_talv_evt_rec);
  END CREATE_TPA_RELTV;
  PROCEDURE UPDATE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type,
    x_talv_evt_rec          OUT NOCOPY talv_event_rec_type) IS
    p_talv_rec	            talv_rec_type;
    x_talv_rec	            talv_rec_type;
    p_tgnv_rec              tgnv_rec_type;
    x_tgnv_rec              tgnv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    p_tgnv_rec.cnh_id       := p_talv_evt_rec.cnh_id;
    p_tgnv_rec.id           := p_talv_evt_rec.tve_id_offset;
    OKC_TIME_pub.update_tpg_named(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec,
      x_tgnv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    x_talv_evt_rec          := p_talv_evt_rec;
    migrate(p_talv_evt_rec,p_talv_rec);
    okc_tal_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec,
      x_talv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_talv_rec,x_talv_evt_rec);
  END UPDATE_TPA_RELTV;
  PROCEDURE DELETE_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type) IS
    p_talv_rec	            talv_rec_type;
    x_talv_rec	            talv_rec_type;
    p_tgnv_rec              tgnv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    p_tgnv_rec.id           := p_talv_evt_rec.tve_id_offset;
    OKC_TIME_pub.delete_tpg_named(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(p_talv_evt_rec,p_talv_rec);
    okc_tal_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec);
  END DELETE_TPA_RELTV;
  PROCEDURE LOCK_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type) IS
    p_talv_rec              talv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_talv_evt_rec,p_talv_rec);
    okc_tal_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec);
  END LOCK_TPA_RELTV;

  PROCEDURE VALID_TPA_RELTV(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_talv_evt_rec	    IN talv_event_rec_type) IS
    p_talv_rec              talv_rec_type;
    p_tgnv_rec              tgnv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    p_tgnv_rec.id           := p_talv_evt_rec.tve_id_offset;
    p_tgnv_rec.cnh_id           := p_talv_evt_rec.cnh_id;
    OKC_TIME_pub.valid_tpg_named(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(p_talv_evt_rec,p_talv_rec);
    okc_tal_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec);
  END VALID_TPA_RELTV;


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPA_VALUE
 --------------------------------------------------------------------------
  PROCEDURE CREATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type,
    x_tavv_rec          OUT NOCOPY tavv_rec_type) IS
  BEGIN
    okc_tav_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec,
      x_tavv_rec);
  END CREATE_TPA_VALUE;
  PROCEDURE UPDATE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type,
    x_tavv_rec          OUT NOCOPY tavv_rec_type) IS
  BEGIN
    okc_tav_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec,
      x_tavv_rec);
  END UPDATE_TPA_VALUE;
  PROCEDURE DELETE_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type) IS
  BEGIN
    okc_tav_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec);
  END DELETE_TPA_VALUE;
  PROCEDURE LOCK_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type) IS
  BEGIN
    okc_tav_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec);
  END LOCK_TPA_VALUE;

  PROCEDURE VALID_TPA_VALUE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tavv_rec	    IN tavv_rec_type) IS
  BEGIN
    okc_tav_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec);
  END VALID_TPA_VALUE;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_DELIMITED
 --------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN tgdv_rec_type,
    p_to	IN OUT NOCOPY tgdv_extended_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.month := p_from.month;
    p_to.day := p_from.day;
    p_to.hour := p_from.hour;
    p_to.minute := p_from.minute;
    p_to.second := p_from.second;
    p_to.nth := p_from.nth;
    p_to.day_of_week := p_from.day_of_week;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE migrate (
    p_from	IN tgdv_extended_rec_type,
    p_to	IN OUT NOCOPY tgdv_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.month := p_from.month;
    p_to.day := p_from.day;
    p_to.hour := p_from.hour;
    p_to.minute := p_from.minute;
    p_to.second := p_from.second;
    p_to.nth := p_from.nth;
    p_to.day_of_week := p_from.day_of_week;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE CREATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type,
    x_tgdv_ext_rec          OUT NOCOPY tgdv_extended_rec_type) IS
    p_tgdv_rec	            tgdv_rec_type;
    x_tgdv_rec	            tgdv_rec_type;
    p_isev_ext_rec	        isev_extended_rec_type;
    x_isev_ext_rec	        isev_extended_rec_type;
  BEGIN
    x_return_status         := OKC_API.G_RET_STS_SUCCESS;
    x_tgdv_ext_rec          := p_tgdv_ext_rec;
    if p_tgdv_ext_rec.limited_start_date <> OKC_API.G_MISS_DATE and
       p_tgdv_ext_rec.limited_start_date is not null and
       p_tgdv_ext_rec.limited_end_date <> OKC_API.G_MISS_DATE and
       p_tgdv_ext_rec.limited_end_date is not null then
      p_isev_ext_rec.start_date := p_tgdv_ext_rec.limited_start_date;
      p_isev_ext_rec.end_date := p_tgdv_ext_rec.limited_end_date;
      p_isev_ext_rec.description := 'Limited by of Generic';
      p_isev_ext_rec.short_description := 'Limited by of Generic';
      p_isev_ext_rec.comments := 'Generated by TGD';
      p_isev_ext_rec.dnz_chr_id  := p_tgdv_ext_rec.dnz_chr_id;
      OKC_TIME_pub.create_ia_startend(
        p_api_version,
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_isev_ext_rec,
        x_isev_ext_rec);
      if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        return;
      end if;
	 x_tgdv_ext_rec.tve_id_limited := x_isev_ext_rec.id;
	 x_tgdv_ext_rec.limited_start_date := x_isev_ext_rec.start_date;
	 x_tgdv_ext_rec.limited_end_date := x_isev_ext_rec.end_date;
    end if;
    migrate(x_tgdv_ext_rec,p_tgdv_rec);
    okc_tgd_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_rec,
      x_tgdv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_tgdv_rec,x_tgdv_ext_rec);
  END CREATE_TPG_DELIMITED;

  PROCEDURE UPDATE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type,
    x_tgdv_ext_rec          OUT NOCOPY tgdv_extended_rec_type) IS
    p_tgdv_rec	            tgdv_rec_type;
    x_tgdv_rec	            tgdv_rec_type;
    l_row_notfound          BOOLEAN := TRUE;
    l_api_name              CONSTANT VARCHAR2(30) := 'update_tpg_delimited';
    p_isev_ext_rec	        isev_extended_rec_type;
    x_isev_ext_rec	        isev_extended_rec_type;
    CURSOR okc_tve_csr (p_id                 IN NUMBER) IS
      SELECT tve_id_limited, dnz_chr_id
        FROM okc_timevalues
       WHERE id = p_id
	   and tve_type = 'TGD';
    CURSOR okc_limited_csr (p_id                 IN NUMBER) IS
      SELECT id, start_date, end_date
        FROM okc_time_ia_startend_val_v
       WHERE id = p_id;
    l_okc_limited              okc_limited_csr%ROWTYPE;
    l_okc_tve              okc_tve_csr%ROWTYPE;
  BEGIN
    x_return_status         := OKC_API.G_RET_STS_SUCCESS;
    x_tgdv_ext_rec          := p_tgdv_ext_rec;
    OPEN okc_tve_csr(x_tgdv_ext_rec.id);
    FETCH okc_tve_csr INTO l_okc_tve;
    l_row_notfound := okc_tve_csr%NOTFOUND;
    CLOSE okc_tve_csr;
    if (l_okc_tve.tve_id_limited = OKC_API.G_MISS_NUM or
        l_okc_tve.tve_id_limited is NULL) then
      if p_tgdv_ext_rec.limited_start_date <> OKC_API.G_MISS_DATE and
         p_tgdv_ext_rec.limited_start_date is not null and
         p_tgdv_ext_rec.limited_end_date <> OKC_API.G_MISS_DATE and
         p_tgdv_ext_rec.limited_end_date is not null then
        p_isev_ext_rec.start_date := p_tgdv_ext_rec.limited_start_date;
        p_isev_ext_rec.end_date := p_tgdv_ext_rec.limited_end_date;
        p_isev_ext_rec.description := 'Limited by of Generic';
        p_isev_ext_rec.short_description := 'Limited by of Generic';
        p_isev_ext_rec.comments := 'Generated by TGD';
        p_isev_ext_rec.dnz_chr_id  := l_okc_tve.dnz_chr_id;
        OKC_TIME_pub.create_ia_startend(
          p_api_version,
          p_init_msg_list,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_isev_ext_rec,
          x_isev_ext_rec);
        if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
          return;
        end if;
	x_tgdv_ext_rec.tve_id_limited := x_isev_ext_rec.id;
	x_tgdv_ext_rec.limited_start_date := x_isev_ext_rec.start_date;
	x_tgdv_ext_rec.limited_end_date := x_isev_ext_rec.end_date;
      end if;
    else
      if p_tgdv_ext_rec.limited_start_date is null then
        p_isev_ext_rec.id := l_okc_tve.tve_id_limited;
        OKC_TIME_pub.delete_ia_startend(
          p_api_version,
          p_init_msg_list,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_isev_ext_rec);
        if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
          return;
        end if;
	x_tgdv_ext_rec.tve_id_limited := NULL;
	x_tgdv_ext_rec.limited_start_date := NULL;
	x_tgdv_ext_rec.limited_end_date := NULL;
      else
        OPEN okc_limited_csr(l_okc_tve.tve_id_limited);
        FETCH okc_limited_csr INTO l_okc_limited;
        l_row_notfound := okc_limited_csr%NOTFOUND;
        CLOSE okc_limited_csr;
	if (((l_okc_limited.start_date <> p_tgdv_ext_rec.limited_start_date) and
	   (p_tgdv_ext_rec.limited_start_date <> OKC_API.G_MISS_DATE)) or
	   ((l_okc_limited.end_date <> p_tgdv_ext_rec.limited_end_date) and
	   (p_tgdv_ext_rec.limited_end_date <> OKC_API.G_MISS_DATE))) then
          p_isev_ext_rec.start_date := p_tgdv_ext_rec.limited_start_date;
          p_isev_ext_rec.end_date := p_tgdv_ext_rec.limited_end_date;
	  p_isev_ext_rec.id := l_okc_tve.tve_id_limited;
          OKC_TIME_pub.update_ia_startend(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_isev_ext_rec,
            x_isev_ext_rec);
          if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
            return;
          end if;
	  x_tgdv_ext_rec.tve_id_limited := x_isev_ext_rec.id;
	  x_tgdv_ext_rec.limited_start_date := x_isev_ext_rec.start_date;
	  x_tgdv_ext_rec.limited_end_date := x_isev_ext_rec.end_date;
        end if;
      end if;
    end if;
    migrate(x_tgdv_ext_rec,p_tgdv_rec);
    okc_tgd_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_rec,
      x_tgdv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_tgdv_rec,x_tgdv_ext_rec);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PVT');
  END UPDATE_TPG_DELIMITED;
  PROCEDURE DELETE_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type) IS
    p_tgdv_rec	            tgdv_rec_type;
    x_tgdv_rec	            tgdv_rec_type;
    p_isev_ext_rec	        isev_extended_rec_type;
    x_isev_ext_rec	        isev_extended_rec_type;
    l_row_notfound          BOOLEAN := TRUE;
    CURSOR okc_limited_csr (p_id                 IN NUMBER) IS
      SELECT id, tve_id_limited
        FROM okc_timevalues
       WHERE id = p_id
	   AND tve_type = 'TGD';
    l_okc_limited              okc_limited_csr%ROWTYPE;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    OPEN okc_limited_csr(p_tgdv_ext_rec.id);
    FETCH okc_limited_csr INTO l_okc_limited;
    l_row_notfound := okc_limited_csr%NOTFOUND;
    CLOSE okc_limited_csr;
    if l_okc_limited.tve_id_limited is not null and
	  l_okc_limited.tve_id_limited <> OKC_API.G_MISS_NUM then
	  p_isev_ext_rec.id := l_okc_limited.tve_id_limited;
      OKC_TIME_pub.delete_ia_startend(
        p_api_version,
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_isev_ext_rec);
    end if;
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(p_tgdv_ext_rec,p_tgdv_rec);
    okc_tgd_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_rec);
  END DELETE_TPG_DELIMITED;
  PROCEDURE LOCK_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type) IS
    p_tgdv_rec	            tgdv_rec_type;
  BEGIN
    migrate(p_tgdv_ext_rec,p_tgdv_rec);
    okc_tgd_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_rec);
  END LOCK_TPG_DELIMITED;

  PROCEDURE VALID_TPG_DELIMITED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgdv_ext_rec	    IN tgdv_extended_rec_type) IS
    p_tgdv_rec              tgdv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_tgdv_ext_rec,p_tgdv_rec);
    okc_tgd_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_rec);
  END VALID_TPG_DELIMITED;

 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_TPG_NAMED
 --------------------------------------------------------------------------

  PROCEDURE CREATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type,
    x_tgnv_rec          OUT NOCOPY tgnv_rec_type) IS
  BEGIN
    okc_tgn_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec,
      x_tgnv_rec);
  END CREATE_TPG_NAMED;
  PROCEDURE UPDATE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type,
    x_tgnv_rec          OUT NOCOPY tgnv_rec_type) IS
  BEGIN
    okc_tgn_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec,
      x_tgnv_rec);
  END UPDATE_TPG_NAMED;
  PROCEDURE DELETE_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type) IS
  BEGIN
    okc_tgn_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec);
  END DELETE_TPG_NAMED;
  PROCEDURE LOCK_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type) IS
  BEGIN
    okc_tgn_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec);
  END LOCK_TPG_NAMED;

  PROCEDURE VALID_TPG_NAMED(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tgnv_rec	    IN tgnv_rec_type) IS
  BEGIN
    okc_tgn_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgnv_rec);
  END VALID_TPG_NAMED;


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IA_STARTEND
 --------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN isev_extended_rec_type,
    p_to	IN OUT NOCOPY isev_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.tve_id_started := p_from.tve_id_started;
    p_to.tve_id_ended := p_from.tve_id_ended;
    p_to.duration := p_from.duration;
    p_to.uom_code := p_from.uom_code;
    p_to.before_after := p_from.before_after;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.operator := p_from.operator;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE migrate (
    p_from	IN isev_rec_type,
    p_to	IN OUT NOCOPY isev_extended_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.tve_id_started := p_from.tve_id_started;
    p_to.tve_id_ended := p_from.tve_id_ended;
    p_to.duration := p_from.duration;
    p_to.uom_code := p_from.uom_code;
    p_to.before_after := p_from.before_after;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.operator := p_from.operator;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE migrate (
    p_from	IN isev_reltv_rec_type,
    p_to	IN OUT NOCOPY isev_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.tve_id_started := p_from.tve_id_started;
    p_to.tve_id_ended := p_from.tve_id_ended;
    p_to.duration := p_from.duration;
    p_to.uom_code := p_from.uom_code;
    p_to.before_after := p_from.before_after;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.operator := p_from.operator;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE migrate (
    p_from	IN isev_rec_type,
    p_to	IN OUT NOCOPY isev_reltv_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.tve_id_started := p_from.tve_id_started;
    p_to.tve_id_ended := p_from.tve_id_ended;
    p_to.duration := p_from.duration;
    p_to.uom_code := p_from.uom_code;
    p_to.before_after := p_from.before_after;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.operator := p_from.operator;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type,
    x_isev_ext_rec          OUT NOCOPY isev_extended_rec_type) IS
    p_tavv_rec          tavv_rec_type;
    x_tavv_rec          tavv_rec_type;
    p_isev_rec              isev_rec_type;
    x_isev_rec              isev_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    if (p_isev_ext_rec.start_date > p_isev_ext_rec.end_date) and
	 (p_isev_ext_rec.end_date is NOT NULL and p_isev_ext_rec.end_date <> OKC_API.G_MISS_DATE) then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => G_DATE_ERROR,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'START_DATE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
    end if;
    x_isev_ext_rec          := p_isev_ext_rec;
    p_tavv_rec.datetime := p_isev_ext_rec.start_date;
    p_tavv_rec.description := 'Start date of Absolute Interval';
    p_tavv_rec.short_description := 'Start of Abs Intrvl';
    p_tavv_rec.comments := 'Generated by ISE';
    p_tavv_rec.dnz_chr_id  := p_isev_ext_rec.dnz_chr_id;
    OKC_TIME_PUB.create_tpa_value(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec,
      x_tavv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    x_isev_ext_rec.tve_id_started := x_tavv_rec.id;
    if p_isev_ext_rec.duration is null or
	  p_isev_ext_rec.duration = OKC_API.G_MISS_NUM then
      if p_isev_ext_rec.end_date is NOT NULL and
	   p_isev_ext_rec.end_date <> OKC_API.G_MISS_DATE then
	   okc_time_util_pub.get_duration(p_isev_ext_rec.start_date, p_isev_ext_rec.end_date,x_isev_ext_rec.duration,
						    x_isev_ext_rec.uom_code,x_return_status);
        if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	     return;
        end if;
      else
	   x_isev_ext_rec.duration := NULL;
	   x_isev_ext_rec.uom_code := NULL;
	 end if;
    end if;
    migrate(x_isev_ext_rec,p_isev_rec);
    okc_ise_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec,
      x_isev_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_isev_rec,x_isev_ext_rec);
  END CREATE_IA_STARTEND;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type,
    x_isev_ext_rec          OUT NOCOPY isev_extended_rec_type) IS
    p_tavv_rec          tavv_rec_type;
    x_tavv_rec          tavv_rec_type;
    p_isev_rec              isev_rec_type;
    x_isev_rec              isev_rec_type;
    l_row_notfound          BOOLEAN := TRUE;
    l_api_name              CONSTANT VARCHAR2(30) := 'update_ia_startend';
    item_not_found_error    EXCEPTION;
    CURSOR okc_tve_csr (p_id                 IN NUMBER) IS
      SELECT start_date
        FROM okc_time_ia_startend_val_v
       WHERE id = p_id ;
    l_okc_tve              okc_tve_csr%ROWTYPE;
  BEGIN
   x_return_status                := OKC_API.G_RET_STS_SUCCESS;
   if (p_isev_ext_rec.start_date > p_isev_ext_rec.end_date) and
	 (p_isev_ext_rec.end_date is NOT NULL and p_isev_ext_rec.end_date <> OKC_API.G_MISS_DATE) then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => G_DATE_ERROR,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'START_DATE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
    end if;
    if p_isev_ext_rec.start_date is NULL then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => G_DATE_ERROR,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'START_DATE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
    end if;
    x_isev_ext_rec          := p_isev_ext_rec;
    IF (p_isev_ext_rec.start_date = OKC_API.G_MISS_DATE) then
      OPEN okc_tve_csr(p_isev_ext_rec.id);
      FETCH okc_tve_csr INTO l_okc_tve;
      l_row_notfound := okc_tve_csr%NOTFOUND;
      CLOSE okc_tve_csr;
      IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID_STARTED');
        RAISE item_not_found_error;
      END IF;
      x_isev_ext_rec.start_date := l_okc_tve.start_date;
    END IF;
    if p_isev_ext_rec.duration is null or
	  p_isev_ext_rec.duration = OKC_API.G_MISS_NUM then
      if p_isev_ext_rec.end_date is NOT NULL and
	   p_isev_ext_rec.end_date <> OKC_API.G_MISS_DATE then
	   okc_time_util_pub.get_duration(x_isev_ext_rec.start_date, p_isev_ext_rec.end_date,x_isev_ext_rec.duration,
						    x_isev_ext_rec.uom_code,x_return_status);
        if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	     return;
        end if;
      elsif p_isev_ext_rec.end_date is NULL then
	   x_isev_ext_rec.duration := NULL;
	   x_isev_ext_rec.uom_code := NULL;
	 end if;
    end if;
    migrate(x_isev_ext_rec,p_isev_rec);
    okc_ise_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec,
      x_isev_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_isev_rec,x_isev_ext_rec);
    if (p_isev_ext_rec.start_date <> OKC_API.G_MISS_DATE) then
       p_tavv_rec.id := x_isev_rec.tve_id_started;
       p_tavv_rec.datetime := p_isev_ext_rec.start_date;
       OKC_TIME_pub.update_tpa_value(
         p_api_version,
         p_init_msg_list,
         x_return_status,
         x_msg_count,
         x_msg_data,
         p_tavv_rec,
         x_tavv_rec);
    end if;
  EXCEPTION
    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PVT');
  END UPDATE_IA_STARTEND;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type) IS
    p_isev_rec              isev_rec_type;
    x_isev_rec              isev_rec_type;
    p_tavv_rec          tavv_rec_type;
    x_tavv_rec          tavv_rec_type;
    CURSOR okc_tve_csr (p_id                 IN NUMBER) IS
      SELECT tve_id_started
        FROM okc_timevalues
       WHERE id = p_id
	   AND tve_type = 'ISE';
    l_okc_tve              okc_tve_csr%ROWTYPE;
    l_api_name              CONSTANT VARCHAR2(30) := 'delete_ia_startend';
    l_row_notfound          BOOLEAN := TRUE;
    item_not_found_error    EXCEPTION;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    if p_isev_ext_rec.tve_id_started is NULL or
	  p_isev_ext_rec.tve_id_started = OKC_API.G_MISS_NUM then
      OPEN okc_tve_csr(p_isev_ext_rec.id);
      FETCH okc_tve_csr INTO l_okc_tve;
      l_row_notfound := okc_tve_csr%NOTFOUND;
      CLOSE okc_tve_csr;
      IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID_STARTED');
        RAISE item_not_found_error;
      END IF;
      p_tavv_rec.id := l_okc_tve.tve_id_started;
    else
      p_tavv_rec.id := p_isev_ext_rec.tve_id_started;
    end if;
    OKC_TIME_pub.delete_tpa_value(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tavv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(p_isev_ext_rec,p_isev_rec);
    okc_ise_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec);
  EXCEPTION
    WHEN item_not_found_error THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OTHERS',
       x_msg_count,
       x_msg_data,
       '_PVT');
  END DELETE_IA_STARTEND;

  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type) IS
    p_isev_rec              isev_rec_type;
  BEGIN
    migrate(p_isev_ext_rec,p_isev_rec);
    okc_ise_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec);
  END LOCK_IA_STARTEND;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_ext_rec	    IN isev_extended_rec_type) IS
    p_isev_rec              isev_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_isev_ext_rec,p_isev_rec);
    okc_ise_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec);
  END VALID_IA_STARTEND;
  PROCEDURE CREATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type,
    x_isev_rel_rec          OUT NOCOPY isev_reltv_rec_type) IS
    p_talv_rec          talv_rec_type;
    x_talv_rec          talv_rec_type;
    p_isev_rec              isev_rec_type;
    x_isev_rec              isev_rec_type;
    p_date                  date;
    l_api_name              CONSTANT VARCHAR2(30) := 'create_ia_startend';
    l_row_notfound          BOOLEAN := TRUE;
    item_not_found_error    EXCEPTION;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    x_isev_rel_rec          := p_isev_rel_rec;
    p_talv_rec.tve_id_offset := p_isev_rel_rec.start_tve_id_offset;
    if p_isev_rel_rec.start_duration >= 0 then
       p_talv_rec.before_after := 'A';
       p_talv_rec.duration := p_isev_rel_rec.start_duration;
    else
       p_talv_rec.before_after := 'B';
       p_talv_rec.duration := -1 * p_isev_rel_rec.start_duration;
    end if;
    p_talv_rec.uom_code := p_isev_rel_rec.start_uom_code;
    p_talv_rec.operator := p_isev_rel_rec.start_operator;
    p_talv_rec.description := 'Start date of Relative Interval';
    p_talv_rec.short_description := 'Start of Rel Intrvl';
    p_talv_rec.comments := 'Generated by ISE';
    p_talv_rec.dnz_chr_id  := p_isev_rel_rec.dnz_chr_id;
    OKC_TIME_pub.create_tpa_reltv(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec,
      x_talv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    p_date := OKC_TIME_UTIL_PUB.get_enddate(p_isev_rel_rec.start_parent_date,
								    p_isev_rel_rec.start_uom_code,
								    p_isev_rel_rec.start_duration);
    if p_date is NULL THEN
      return;
    end if;
    if p_isev_rel_rec.end_date is NOT NULL and
      p_isev_rel_rec.end_date <> OKC_API.G_MISS_DATE then
	 okc_time_util_pub.get_duration(p_date, p_isev_rel_rec.end_date,x_isev_rel_rec.duration,
						    x_isev_rel_rec.uom_code,x_return_status);
      if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	   return;
      end if;
    else
      x_isev_rel_rec.duration := NULL;
      x_isev_rel_rec.uom_code := NULL;
    end if;
    x_isev_rel_rec.tve_id_started := x_talv_rec.id;
    migrate(x_isev_rel_rec,p_isev_rec);
    okc_ise_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec,
      x_isev_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_isev_rec,x_isev_rel_rec);
  END CREATE_IA_STARTEND;

  PROCEDURE UPDATE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type,
    x_isev_rel_rec          OUT NOCOPY isev_reltv_rec_type) IS
    p_talv_rec          talv_rec_type;
    x_talv_rec          talv_rec_type;
    p_isev_rec              isev_rec_type;
    x_isev_rec              isev_rec_type;
    l_row_notfound          BOOLEAN := TRUE;
    l_api_name              CONSTANT VARCHAR2(30) := 'update_ia_startend';
    p_date                  date;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    x_isev_rel_rec          := p_isev_rel_rec;
    p_date := OKC_TIME_UTIL_PUB.get_enddate(p_isev_rel_rec.start_parent_date,
								    p_isev_rel_rec.start_uom_code,
								    p_isev_rel_rec.start_duration);
    if p_date is NULL THEN
	 return;
    end if;
    if p_isev_rel_rec.end_date is NOT NULL and
      p_isev_rel_rec.end_date <> OKC_API.G_MISS_DATE then
	 okc_time_util_pub.get_duration(p_date, p_isev_rel_rec.end_date,x_isev_rel_rec.duration,
						    x_isev_rel_rec.uom_code,x_return_status);
      if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	   return;
      end if;
    elsif p_isev_rel_rec.end_date is NULL then
      x_isev_rel_rec.duration := NULL;
      x_isev_rel_rec.uom_code := NULL;
    end if;
    migrate(x_isev_rel_rec,p_isev_rec);
    okc_ise_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec,
      x_isev_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_isev_rec,x_isev_rel_rec);
    p_talv_rec.id := x_isev_rel_rec.tve_id_started;
    p_talv_rec.tve_id_offset := x_isev_rel_rec.start_tve_id_offset;
    if x_isev_rel_rec.start_duration >= 0 then
       p_talv_rec.duration := x_isev_rel_rec.start_duration;
       p_talv_rec.before_after := 'A';
    else
       p_talv_rec.before_after := 'B';
       p_talv_rec.duration := -1 * x_isev_rel_rec.start_duration;
    end if;
    p_talv_rec.uom_code := x_isev_rel_rec.start_uom_code;
    p_talv_rec.operator := x_isev_rel_rec.start_operator;
    OKC_TIME_pub.update_tpa_reltv(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec,
      x_talv_rec);
  END UPDATE_IA_STARTEND;

  PROCEDURE DELETE_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type) IS
    p_isev_rec              isev_rec_type;
    x_isev_rec              isev_rec_type;
    p_talv_rec          talv_rec_type;
    x_talv_rec          talv_rec_type;
    CURSOR okc_tve_csr (p_id                 IN NUMBER) IS
      SELECT tve_id_started
        FROM okc_timevalues
       WHERE id = p_id
	   AND tve_type = 'ISE';
    l_okc_tve              okc_tve_csr%ROWTYPE;
    l_api_name              CONSTANT VARCHAR2(30) := 'delete_ia_startend';
    l_row_notfound          BOOLEAN := TRUE;
    item_not_found_error    EXCEPTION;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    if p_isev_rel_rec.tve_id_started is NULL or
	  p_isev_rel_rec.tve_id_started = OKC_API.G_MISS_NUM then
      OPEN okc_tve_csr(p_isev_rel_rec.id);
      FETCH okc_tve_csr INTO l_okc_tve;
      l_row_notfound := okc_tve_csr%NOTFOUND;
      CLOSE okc_tve_csr;
      IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TVE_ID_STARTED');
        RAISE item_not_found_error;
      END IF;
      p_talv_rec.id := l_okc_tve.tve_id_started;
    else
      p_talv_rec.id := p_isev_rel_rec.tve_id_started;
    end if;
    OKC_TIME_pub.delete_tpa_reltv(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_talv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(p_isev_rel_rec,p_isev_rec);
    okc_ise_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec);
  END DELETE_IA_STARTEND;
  PROCEDURE LOCK_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type) IS
    p_isev_rec              isev_rec_type;
  BEGIN
    migrate(p_isev_rel_rec,p_isev_rec);
    okc_ise_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec);
  END LOCK_IA_STARTEND;

  PROCEDURE VALID_IA_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_isev_rel_rec	    IN isev_reltv_rec_type) IS
    p_isev_rec              isev_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_isev_rel_rec,p_isev_rec);
    okc_ise_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_isev_rec);
  END VALID_IA_STARTEND;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_IG_STARTEND
 --------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN igsv_rec_type,
    p_to	IN OUT NOCOPY igsv_extended_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.tve_id_started := p_from.tve_id_started;
    p_to.tve_id_ended := p_from.tve_id_ended;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE migrate (
    p_from	IN igsv_extended_rec_type,
    p_to	IN OUT NOCOPY igsv_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.tve_id_started := p_from.tve_id_started;
    p_to.tve_id_ended := p_from.tve_id_ended;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE CREATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type,
    x_igsv_ext_rec          OUT NOCOPY igsv_extended_rec_type) IS
    p_tgdv_ext_rec          tgdv_extended_rec_type;
    x_tgdv_ext_rec          tgdv_extended_rec_type;
    p_igsv_rec              igsv_rec_type;
    x_igsv_rec              igsv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    x_igsv_ext_rec          := p_igsv_ext_rec;
    p_tgdv_ext_rec.month := p_igsv_ext_rec.start_month;
    p_tgdv_ext_rec.day := p_igsv_ext_rec.start_day;
    p_tgdv_ext_rec.day_of_week := p_igsv_ext_rec.start_day_of_week;
    p_tgdv_ext_rec.hour := p_igsv_ext_rec.start_hour;
    p_tgdv_ext_rec.minute := p_igsv_ext_rec.start_minute;
    p_tgdv_ext_rec.second := p_igsv_ext_rec.start_second;
    p_tgdv_ext_rec.nth := p_igsv_ext_rec.start_nth;
    p_tgdv_ext_rec.description := 'Start of Generic Interval Startend';
    p_tgdv_ext_rec.short_description := 'Start Generic Intrvl';
    p_tgdv_ext_rec.comments := 'Generated by IGS';
    p_tgdv_ext_rec.dnz_chr_id  := p_igsv_ext_rec.dnz_chr_id;
    OKC_TIME_pub.create_tpg_delimited(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_ext_rec,
      x_tgdv_ext_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    x_igsv_ext_rec.tve_id_started := x_tgdv_ext_rec.id;
    p_tgdv_ext_rec.month := p_igsv_ext_rec.end_month;
    p_tgdv_ext_rec.day := p_igsv_ext_rec.end_day;
    p_tgdv_ext_rec.day_of_week := p_igsv_ext_rec.end_day_of_week;
    p_tgdv_ext_rec.hour := p_igsv_ext_rec.end_hour;
    p_tgdv_ext_rec.minute := p_igsv_ext_rec.end_minute;
    p_tgdv_ext_rec.second := p_igsv_ext_rec.end_second;
    p_tgdv_ext_rec.nth := p_igsv_ext_rec.end_nth;
    p_tgdv_ext_rec.description := 'End of Generic Interval Startend';
    p_tgdv_ext_rec.short_description := 'End Generic Intrvl';
    p_tgdv_ext_rec.comments := 'Generated by IGS';
    p_tgdv_ext_rec.dnz_chr_id  := p_igsv_ext_rec.dnz_chr_id;
    OKC_TIME_pub.create_tpg_delimited(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_ext_rec,
      x_tgdv_ext_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    x_igsv_ext_rec.tve_id_ended := x_tgdv_ext_rec.id;
    migrate(x_igsv_ext_rec,p_igsv_rec);
    okc_igs_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_igsv_rec,
      x_igsv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_igsv_rec,x_igsv_ext_rec);
  END CREATE_IG_STARTEND;

  PROCEDURE UPDATE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type,
    x_igsv_ext_rec          OUT NOCOPY igsv_extended_rec_type) IS
    p_tgdv_ext_rec          tgdv_extended_rec_type;
    x_tgdv_ext_rec          tgdv_extended_rec_type;
    p_igsv_rec              igsv_rec_type;
    x_igsv_rec              igsv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    x_igsv_ext_rec          := p_igsv_ext_rec;
    migrate(p_igsv_ext_rec,p_igsv_rec);
    okc_igs_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_igsv_rec,
      x_igsv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_igsv_rec,x_igsv_ext_rec);
    p_tgdv_ext_rec.id := x_igsv_ext_rec.tve_id_started;
    p_tgdv_ext_rec.month := p_igsv_ext_rec.start_month;
    p_tgdv_ext_rec.day := p_igsv_ext_rec.start_day;
    p_tgdv_ext_rec.day_of_week := p_igsv_ext_rec.start_day_of_week;
    p_tgdv_ext_rec.hour := p_igsv_ext_rec.start_hour;
    p_tgdv_ext_rec.minute := p_igsv_ext_rec.start_minute;
    p_tgdv_ext_rec.second := p_igsv_ext_rec.start_second;
    p_tgdv_ext_rec.nth := p_igsv_ext_rec.start_nth;
    OKC_TIME_pub.update_tpg_delimited(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_ext_rec,
      x_tgdv_ext_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    p_tgdv_ext_rec.id := x_igsv_ext_rec.tve_id_ended;
    p_tgdv_ext_rec.month := p_igsv_ext_rec.end_month;
    p_tgdv_ext_rec.day := p_igsv_ext_rec.end_day;
    p_tgdv_ext_rec.day_of_week := p_igsv_ext_rec.end_day_of_week;
    p_tgdv_ext_rec.hour := p_igsv_ext_rec.end_hour;
    p_tgdv_ext_rec.minute := p_igsv_ext_rec.end_minute;
    p_tgdv_ext_rec.second := p_igsv_ext_rec.end_second;
    p_tgdv_ext_rec.nth := p_igsv_ext_rec.end_nth;
    OKC_TIME_pub.update_tpg_delimited(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_ext_rec,
      x_tgdv_ext_rec);
  END UPDATE_IG_STARTEND;
  PROCEDURE DELETE_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type) IS
    p_igsv_rec              igsv_rec_type;
    x_igsv_rec              igsv_rec_type;
    p_tgdv_ext_rec          tgdv_extended_rec_type;
    x_tgdv_ext_rec          tgdv_extended_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_igsv_ext_rec,p_igsv_rec);
    okc_igs_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_igsv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    p_tgdv_ext_rec.id := p_igsv_rec.tve_id_started;
    OKC_TIME_pub.delete_tpg_delimited(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_ext_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    p_tgdv_ext_rec.id := p_igsv_rec.tve_id_ended;
    OKC_TIME_pub.delete_tpg_delimited(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_tgdv_ext_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
  END DELETE_IG_STARTEND;
  PROCEDURE LOCK_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type) IS
    p_igsv_rec              igsv_rec_type;
  BEGIN
    migrate(p_igsv_ext_rec,p_igsv_rec);
    okc_igs_pvt.lock_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_igsv_rec);
  END LOCK_IG_STARTEND;

  PROCEDURE VALID_IG_STARTEND(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_igsv_ext_rec	    IN igsv_extended_rec_type) IS
    p_igsv_rec              igsv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_igsv_ext_rec,p_igsv_rec);
    okc_igs_pvt.validate_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_igsv_rec);
  END VALID_IG_STARTEND;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_SPAN
 --------------------------------------------------------------------------

  PROCEDURE CREATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type,
    x_spnv_rec              OUT NOCOPY spnv_rec_type) IS
  BEGIN
    okc_spn_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_spnv_rec,
    x_spnv_rec);
  END CREATE_SPAN;
  PROCEDURE UPDATE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type,
    x_spnv_rec              OUT NOCOPY spnv_rec_type) IS
  BEGIN
    okc_spn_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_spnv_rec,
    x_spnv_rec);
  END UPDATE_SPAN;
  PROCEDURE DELETE_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) IS
  BEGIN
    okc_spn_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_spnv_rec);
  END DELETE_SPAN;
  PROCEDURE LOCK_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) IS
  BEGIN
    okc_spn_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_spnv_rec);
  END LOCK_SPAN;

  PROCEDURE VALID_SPAN(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_spnv_rec		    IN spnv_rec_type) IS
  BEGIN
    okc_spn_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_spnv_rec);
  END VALID_SPAN;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_CODE_UNITS
 --------------------------------------------------------------------------

  PROCEDURE CREATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type,
    x_tcuv_rec              OUT NOCOPY tcuv_rec_type) IS
  BEGIN
    okc_tcu_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tcuv_rec,
    x_tcuv_rec);
  END CREATE_TIME_CODE_UNITS;
  PROCEDURE UPDATE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type,
    x_tcuv_rec              OUT NOCOPY tcuv_rec_type) IS
  BEGIN
    okc_tcu_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tcuv_rec,
    x_tcuv_rec);
  END UPDATE_TIME_CODE_UNITS;
  PROCEDURE DELETE_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) IS
  BEGIN
    okc_tcu_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tcuv_rec);
  END DELETE_TIME_CODE_UNITS;
  PROCEDURE LOCK_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) IS
  BEGIN
    okc_tcu_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tcuv_rec);
  END LOCK_TIME_CODE_UNITS;

  PROCEDURE VALID_TIME_CODE_UNITS(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_tcuv_rec		    IN tcuv_rec_type) IS
  BEGIN
    okc_tcu_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_tcuv_rec);
  END VALID_TIME_CODE_UNITS;


 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_RESOLVED_TIMEVALUES
 --------------------------------------------------------------------------

  PROCEDURE CREATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type,
    x_rtvv_rec              OUT NOCOPY rtvv_rec_type) IS
  BEGIN
    okc_rtv_pvt.insert_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rtvv_rec,
    x_rtvv_rec);
  END CREATE_RESOLVED_TIMEVALUES;

  PROCEDURE UPDATE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type,
    x_rtvv_rec              OUT NOCOPY rtvv_rec_type) IS
  BEGIN
    okc_rtv_pvt.update_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rtvv_rec,
    x_rtvv_rec);
  END UPDATE_RESOLVED_TIMEVALUES;

  PROCEDURE DELETE_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) IS
  BEGIN
    okc_rtv_pvt.delete_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rtvv_rec);
  END DELETE_RESOLVED_TIMEVALUES;

  PROCEDURE LOCK_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) IS
  BEGIN
    okc_rtv_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rtvv_rec);
  END LOCK_RESOLVED_TIMEVALUES;

  PROCEDURE VALID_RESOLVED_TIMEVALUES(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_rtvv_rec		    IN rtvv_rec_type) IS
  BEGIN
    okc_rtv_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_rtvv_rec);
  END VALID_RESOLVED_TIMEVALUES;
 --------------------------------------------------------------------------
---The following procedures cater to handling of OKC_TIME_CYCLE
 --------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cylv_extended_rec_type,
    p_to	IN OUT NOCOPY cylv_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.name := p_from.name;
    p_to.interval_yn := p_from.interval_yn;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE migrate (
    p_from	IN cylv_rec_type,
    p_to	IN OUT NOCOPY cylv_extended_rec_type
  ) IS
  BEGIN
--Bug 3122962    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.comments := p_from.comments;
    p_to.id := p_from.id;
    p_to.spn_id := p_from.spn_id;
    p_to.tve_id_limited := p_from.tve_id_limited;
    p_to.tze_id := p_from.tze_id;
    p_to.name := p_from.name;
    p_to.interval_yn := p_from.interval_yn;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  PROCEDURE CREATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		   IN cylv_extended_rec_type,
    x_cylv_ext_rec          OUT NOCOPY cylv_extended_rec_type) IS
    p_cylv_rec              cylv_rec_type;
    x_cylv_rec              cylv_rec_type;
    p_spnv_rec              spnv_rec_type;
    x_spnv_rec              spnv_rec_type;
    p_isev_ext_rec	        isev_extended_rec_type;
    x_isev_ext_rec	        isev_extended_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    x_cylv_ext_rec          := p_cylv_ext_rec;
    if p_cylv_ext_rec.limited_start_date <> OKC_API.G_MISS_DATE and
       p_cylv_ext_rec.limited_start_date is not null and
       p_cylv_ext_rec.limited_end_date <> OKC_API.G_MISS_DATE and
       p_cylv_ext_rec.limited_end_date is not null then
      p_isev_ext_rec.start_date := p_cylv_ext_rec.limited_start_date;
      p_isev_ext_rec.end_date := p_cylv_ext_rec.limited_end_date;
      p_isev_ext_rec.description := 'Limited by of Cycle';
      p_isev_ext_rec.short_description := 'Limited by of Cycle';
      p_isev_ext_rec.comments := 'Generated by cyl';
      p_isev_ext_rec.dnz_chr_id  := p_cylv_ext_rec.dnz_chr_id;
      OKC_TIME_pub.create_ia_startend(
        p_api_version,
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_isev_ext_rec,
        x_isev_ext_rec);
      if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        return;
      end if;
      x_cylv_ext_rec.tve_id_limited := x_isev_ext_rec.id;
      x_cylv_ext_rec.limited_start_date := x_isev_ext_rec.start_date;
      x_cylv_ext_rec.limited_end_date := x_isev_ext_rec.end_date;
    end if;
    migrate(x_cylv_ext_rec,p_cylv_rec);
    okc_cyl_pvt.insert_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cylv_rec,
      x_cylv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_cylv_rec,x_cylv_ext_rec);
    p_spnv_rec.uom_code := x_cylv_ext_rec.uom_code;
    p_spnv_rec.duration := x_cylv_ext_rec.duration;
    p_spnv_rec.active_yn := x_cylv_ext_rec.active_yn;
    p_spnv_rec.tve_id := x_cylv_ext_rec.id;
    p_spnv_rec.object_version_number := x_cylv_ext_rec.object_version_number;
    OKC_TIME_pub.create_span(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_spnv_rec,
      x_spnv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    x_cylv_ext_rec.uom_code := x_spnv_rec.uom_code;
    x_cylv_ext_rec.duration := x_spnv_rec.duration;
    x_cylv_ext_rec.active_yn := x_spnv_rec.active_yn;
    x_cylv_ext_rec.spn_id := x_spnv_rec.id;
    p_cylv_rec.spn_id := x_spnv_rec.id;
    p_cylv_rec.id := x_cylv_ext_rec.id;
    UPDATE OKC_TIMEVALUES
    SET SPN_ID = x_cylv_ext_rec.spn_id
    WHERE TVE_TYPE = 'CYL'
    AND id = x_cylv_ext_rec.id;
  END CREATE_CYCLE;

  PROCEDURE UPDATE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec		   IN cylv_extended_rec_type,
    x_cylv_ext_rec          OUT NOCOPY cylv_extended_rec_type) IS
    p_cylv_rec              cylv_rec_type;
    x_cylv_rec              cylv_rec_type;
    p_spnv_rec              spnv_rec_type;
    x_spnv_rec              spnv_rec_type;
    p_isev_ext_rec	        isev_extended_rec_type;
    x_isev_ext_rec	        isev_extended_rec_type;
    l_row_notfound          BOOLEAN := TRUE;
    l_api_name              CONSTANT VARCHAR2(30) := 'update_cycle';
    CURSOR okc_tve_csr (p_id                 IN NUMBER) IS
      SELECT tve_id_limited, dnz_chr_id
        FROM okc_timevalues
       WHERE id = p_id
	  AND tve_type = 'CYL';
    CURSOR okc_limited_csr (p_id                 IN NUMBER) IS
      SELECT id, start_date, end_date
        FROM okc_time_ia_startend_val_v
       WHERE id = p_id;
    l_okc_limited              okc_limited_csr%ROWTYPE;
    l_okc_tve              okc_tve_csr%ROWTYPE;
  BEGIN
    x_return_status         := OKC_API.G_RET_STS_SUCCESS;
    x_cylv_ext_rec          := p_cylv_ext_rec;
    OPEN okc_tve_csr(x_cylv_ext_rec.id);
    FETCH okc_tve_csr INTO l_okc_tve;
    l_row_notfound := okc_tve_csr%NOTFOUND;
    CLOSE okc_tve_csr;
    if (l_okc_tve.tve_id_limited = OKC_API.G_MISS_NUM or
        l_okc_tve.tve_id_limited is NULL) then
      if p_cylv_ext_rec.limited_start_date <> OKC_API.G_MISS_DATE and
         p_cylv_ext_rec.limited_start_date is not null and
         p_cylv_ext_rec.limited_end_date <> OKC_API.G_MISS_DATE and
         p_cylv_ext_rec.limited_end_date is not null then
        p_isev_ext_rec.start_date := p_cylv_ext_rec.limited_start_date;
        p_isev_ext_rec.end_date := p_cylv_ext_rec.limited_end_date;
        p_isev_ext_rec.description := 'Limited by of Generic';
        p_isev_ext_rec.short_description := 'Limited by of Generic';
        p_isev_ext_rec.comments := 'Generated by cyl';
        p_isev_ext_rec.dnz_chr_id  := l_okc_tve.dnz_chr_id;
        OKC_TIME_pub.create_ia_startend(
          p_api_version,
          p_init_msg_list,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_isev_ext_rec,
          x_isev_ext_rec);
        if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
          return;
        end if;
	x_cylv_ext_rec.tve_id_limited := x_isev_ext_rec.id;
      end if;
    else
      if p_cylv_ext_rec.limited_start_date is null then
        p_isev_ext_rec.id := l_okc_tve.tve_id_limited;
        OKC_TIME_pub.delete_ia_startend(
          p_api_version,
          p_init_msg_list,
          x_return_status,
          x_msg_count,
          x_msg_data,
          p_isev_ext_rec);
        if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
          return;
        end if;
	x_cylv_ext_rec.tve_id_limited := NULL;
      else
        OPEN okc_limited_csr(l_okc_tve.tve_id_limited);
        FETCH okc_limited_csr INTO l_okc_limited;
        l_row_notfound := okc_limited_csr%NOTFOUND;
        CLOSE okc_limited_csr;
	if (((l_okc_limited.start_date <> p_cylv_ext_rec.limited_start_date) and
	   (p_cylv_ext_rec.limited_start_date <> OKC_API.G_MISS_DATE)) or
	   ((l_okc_limited.end_date <> p_cylv_ext_rec.limited_end_date) and
	   (p_cylv_ext_rec.limited_end_date <> OKC_API.G_MISS_DATE))) then
          p_isev_ext_rec.start_date := p_cylv_ext_rec.limited_start_date;
          p_isev_ext_rec.end_date := p_cylv_ext_rec.limited_end_date;
	  p_isev_ext_rec.id := l_okc_tve.tve_id_limited;
          OKC_TIME_pub.update_ia_startend(
            p_api_version,
            p_init_msg_list,
            x_return_status,
            x_msg_count,
            x_msg_data,
            p_isev_ext_rec,
            x_isev_ext_rec);
          if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
            return;
          end if;
	end if;
      end if;
    end if;
    migrate(x_cylv_ext_rec,p_cylv_rec);
    okc_cyl_pvt.update_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cylv_rec,
      x_cylv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(x_cylv_rec,x_cylv_ext_rec);
    p_spnv_rec.tve_id := x_cylv_ext_rec.id;
    p_spnv_rec.id := x_cylv_ext_rec.spn_id;
    p_spnv_rec.uom_code := x_cylv_ext_rec.uom_code;
    p_spnv_rec.duration := x_cylv_ext_rec.duration;
    p_spnv_rec.active_yn := x_cylv_ext_rec.active_yn;
    p_spnv_rec.object_version_number := p_cylv_ext_rec.object_version_number;
    OKC_TIME_pub.update_span(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_spnv_rec,
      x_spnv_rec);
    x_cylv_ext_rec.uom_code := x_spnv_rec.uom_code;
    x_cylv_ext_rec.duration := x_spnv_rec.duration;
    x_cylv_ext_rec.active_yn := x_spnv_rec.active_yn;
  END UPDATE_CYCLE;

  PROCEDURE DELETE_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec          IN cylv_extended_rec_type) IS
    p_cylv_rec              cylv_rec_type;
    p_spnv_rec              spnv_rec_type;
    p_isev_ext_rec	        isev_extended_rec_type;
    x_isev_ext_rec	        isev_extended_rec_type;
    l_row_notfound          BOOLEAN := TRUE;
    CURSOR okc_limited_csr (p_id                 IN NUMBER) IS
      SELECT id, tve_id_limited, spn_id
        FROM okc_timevalues
       WHERE id = p_id
	    AND tve_type = 'CYL';
    l_okc_limited              okc_limited_csr%ROWTYPE;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    OPEN okc_limited_csr(p_cylv_ext_rec.id);
    FETCH okc_limited_csr INTO l_okc_limited;
    l_row_notfound := okc_limited_csr%NOTFOUND;
    CLOSE okc_limited_csr;
    if l_okc_limited.tve_id_limited is not null and
       l_okc_limited.tve_id_limited <> OKC_API.G_MISS_NUM then
       p_isev_ext_rec.id := l_okc_limited.tve_id_limited;
      OKC_TIME_pub.delete_ia_startend(
        p_api_version,
        p_init_msg_list,
        x_return_status,
        x_msg_count,
        x_msg_data,
        p_isev_ext_rec);
      if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        return;
      end if;
    end if;
    if p_cylv_rec.spn_id is not null and
      p_cylv_rec.spn_id <> OKC_API.G_MISS_NUM Then
      p_spnv_rec.id := p_cylv_rec.spn_id;
    else
      p_spnv_rec.id := l_okc_limited.spn_id;
    end if;
    OKC_TIME_pub.delete_span(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_spnv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    migrate(p_cylv_ext_rec,p_cylv_rec);
    okc_cyl_pvt.delete_row(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_cylv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
  END DELETE_CYCLE;

  PROCEDURE LOCK_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec          IN cylv_extended_rec_type) IS
    p_cylv_rec              cylv_rec_type;
    p_spnv_rec              spnv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_cylv_ext_rec,p_cylv_rec);
    okc_cyl_pvt.lock_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cylv_rec);
  END LOCK_CYCLE;

  PROCEDURE VALID_CYCLE(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cylv_ext_rec          IN cylv_extended_rec_type) IS
    p_cylv_rec              cylv_rec_type;
    p_spnv_rec              spnv_rec_type;
  BEGIN
    x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    migrate(p_cylv_ext_rec,p_cylv_rec);
    okc_cyl_pvt.validate_row(
    p_api_version,
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_cylv_rec);
    if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      return;
    end if;
    p_spnv_rec.id := p_cylv_rec.spn_id;
    OKC_TIME_pub.valid_span(
      p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_spnv_rec);
  END VALID_CYCLE;

---------------------------------------------------------------
-- Procedure for mass insert in OKC_TIMEVALUES _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_IGS_ROW_UPG(p_igsv_ext_tbl IN igsv_ext_tbl_type) IS
  l_tabsize NUMBER := p_igsv_ext_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
--Bug 3122962  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_spn_id                        OKC_DATATYPES.NumberTabTyp;
  in_tve_id_offset                 OKC_DATATYPES.NumberTabTyp;
  in_uom_code                      OKC_DATATYPES.Var3TabTyp;
  in_tve_id_generated_by           OKC_DATATYPES.NumberTabTyp;
  in_tve_id_started                OKC_DATATYPES.NumberTabTyp;
  in_tve_id_ended                  OKC_DATATYPES.NumberTabTyp;
  in_tve_id_limited                OKC_DATATYPES.NumberTabTyp;
  in_cnh_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_tze_id                        OKC_DATATYPES.NumberTabTyp;
  in_description                   OKC_DATATYPES.Var1995TabTyp;
  in_short_description             OKC_DATATYPES.Var600TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_duration                      OKC_DATATYPES.NumberTabTyp;
  in_operator                      OKC_DATATYPES.Var10TabTyp;
  in_before_after                  OKC_DATATYPES.Var3TabTyp;
  in_datetime                      OKC_DATATYPES.DateTabTyp;
  in_month                         OKC_DATATYPES.NumberTabTyp;
  in_day                           OKC_DATATYPES.NumberTabTyp;
  in_day_of_week                   OKC_DATATYPES.Var10TabTyp;
  in_hour                          OKC_DATATYPES.NumberTabTyp;
  in_minute                        OKC_DATATYPES.NumberTabTyp;
  in_second                        OKC_DATATYPES.NumberTabTyp;
  in_name                          OKC_DATATYPES.Var150TabTyp;
  in_interval_yn                   OKC_DATATYPES.Var3TabTyp;
  in_nth                           OKC_DATATYPES.NumberTabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_tve_type                      OKC_DATATYPES.Var10TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  l_tve_id_started                 NUMBER;
  l_tve_id_ended                   NUMBER;
  i                                NUMBER := p_igsv_ext_tbl.FIRST;
  j                                NUMBER := 0;
BEGIN
  while i is NOT NULL
  LOOP
  /* FOR TGD STARTED */
    j := j+1;
    in_id                       (j) := okc_p_util.raw_to_number(sys_guid());
    l_tve_id_started             := in_id(j);
    in_object_version_number    (j) := p_igsv_ext_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_igsv_ext_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := NULL;
    in_uom_code                 (j) := NULL;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := NULL;
    in_tve_id_ended             (j) := NULL;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_igsv_ext_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_igsv_ext_tbl(i).tze_id;
    in_description              (j) := 'Start of Generic Interval Startend';
    in_short_description        (j) := 'Start Generic Intrvl';
    in_comments                 (j) := 'Generated by IGS';
    in_duration                 (j) := NULL;
    in_operator                 (j) := NULL;
    in_before_after             (j) := NULL;
    in_datetime                 (j) := NULL;
    in_month                    (j) := p_igsv_ext_tbl(i).start_month;
    in_day                      (j) := p_igsv_ext_tbl(i).start_day;
    in_day_of_week              (j) := p_igsv_ext_tbl(i).start_day_of_week;
    in_hour                     (j) := p_igsv_ext_tbl(i).start_hour;
    in_minute                   (j) := p_igsv_ext_tbl(i).start_minute;
    in_second                   (j) := p_igsv_ext_tbl(i).start_second;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := p_igsv_ext_tbl(i).start_nth;
    in_attribute_category       (j) := p_igsv_ext_tbl(i).attribute_category;
    in_attribute1               (j) := p_igsv_ext_tbl(i).attribute1;
    in_attribute2               (j) := p_igsv_ext_tbl(i).attribute2;
    in_attribute3               (j) := p_igsv_ext_tbl(i).attribute3;
    in_attribute4               (j) := p_igsv_ext_tbl(i).attribute4;
    in_attribute5               (j) := p_igsv_ext_tbl(i).attribute5;
    in_attribute6               (j) := p_igsv_ext_tbl(i).attribute6;
    in_attribute7               (j) := p_igsv_ext_tbl(i).attribute7;
    in_attribute8               (j) := p_igsv_ext_tbl(i).attribute8;
    in_attribute9               (j) := p_igsv_ext_tbl(i).attribute9;
    in_attribute10              (j) := p_igsv_ext_tbl(i).attribute10;
    in_attribute11              (j) := p_igsv_ext_tbl(i).attribute11;
    in_attribute12              (j) := p_igsv_ext_tbl(i).attribute12;
    in_attribute13              (j) := p_igsv_ext_tbl(i).attribute13;
    in_attribute14              (j) := p_igsv_ext_tbl(i).attribute14;
    in_attribute15              (j) := p_igsv_ext_tbl(i).attribute15;
    in_tve_type                 (j) := 'TGD';
    in_created_by               (j) := p_igsv_ext_tbl(i).created_by;
    in_creation_date            (j) := p_igsv_ext_tbl(i).creation_date;
    in_last_updated_by          (j) := p_igsv_ext_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_igsv_ext_tbl(i).last_update_date;
    in_last_update_login        (j) := p_igsv_ext_tbl(i).last_update_login;
  /* FOR TGD ENDED */
    j := j+1;
    in_id                       (j) := okc_p_util.raw_to_number(sys_guid());
    l_tve_id_ended             := in_id(j);
    in_object_version_number    (j) := p_igsv_ext_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_igsv_ext_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := NULL;
    in_uom_code                 (j) := NULL;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := NULL;
    in_tve_id_ended             (j) := NULL;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_igsv_ext_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_igsv_ext_tbl(i).tze_id;
    in_description              (j) := 'End of Generic Interval Startend';
    in_short_description        (j) := 'End Generic Intrvl';
    in_comments                 (j) := 'Generated by IGS';
    in_duration                 (j) := NULL;
    in_operator                 (j) := NULL;
    in_before_after             (j) := NULL;
    in_datetime                 (j) := NULL;
    in_month                    (j) := p_igsv_ext_tbl(i).end_month;
    in_day                      (j) := p_igsv_ext_tbl(i).end_day;
    in_day_of_week              (j) := p_igsv_ext_tbl(i).end_day_of_week;
    in_hour                     (j) := p_igsv_ext_tbl(i).end_hour;
    in_minute                   (j) := p_igsv_ext_tbl(i).end_minute;
    in_second                   (j) := p_igsv_ext_tbl(i).end_second;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := p_igsv_ext_tbl(i).end_nth;
    in_attribute_category       (j) := p_igsv_ext_tbl(i).attribute_category;
    in_attribute1               (j) := p_igsv_ext_tbl(i).attribute1;
    in_attribute2               (j) := p_igsv_ext_tbl(i).attribute2;
    in_attribute3               (j) := p_igsv_ext_tbl(i).attribute3;
    in_attribute4               (j) := p_igsv_ext_tbl(i).attribute4;
    in_attribute5               (j) := p_igsv_ext_tbl(i).attribute5;
    in_attribute6               (j) := p_igsv_ext_tbl(i).attribute6;
    in_attribute7               (j) := p_igsv_ext_tbl(i).attribute7;
    in_attribute8               (j) := p_igsv_ext_tbl(i).attribute8;
    in_attribute9               (j) := p_igsv_ext_tbl(i).attribute9;
    in_attribute10              (j) := p_igsv_ext_tbl(i).attribute10;
    in_attribute11              (j) := p_igsv_ext_tbl(i).attribute11;
    in_attribute12              (j) := p_igsv_ext_tbl(i).attribute12;
    in_attribute13              (j) := p_igsv_ext_tbl(i).attribute13;
    in_attribute14              (j) := p_igsv_ext_tbl(i).attribute14;
    in_attribute15              (j) := p_igsv_ext_tbl(i).attribute15;
    in_tve_type                 (j) := 'TGD';
    in_created_by               (j) := p_igsv_ext_tbl(i).created_by;
    in_creation_date            (j) := p_igsv_ext_tbl(i).creation_date;
    in_last_updated_by          (j) := p_igsv_ext_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_igsv_ext_tbl(i).last_update_date;
    in_last_update_login        (j) := p_igsv_ext_tbl(i).last_update_login;
  /* FOR IGS */
    j := j+1;
    in_id                       (j) := p_igsv_ext_tbl(i).id;
    in_object_version_number    (j) := p_igsv_ext_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_igsv_ext_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := NULL;
    in_uom_code                 (j) := NULL;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := l_tve_id_started;
    in_tve_id_ended             (j) := l_tve_id_ended;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_igsv_ext_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_igsv_ext_tbl(i).tze_id;
    in_description              (j) := p_igsv_ext_tbl(i).description;
    in_short_description        (j) := p_igsv_ext_tbl(i).short_description;
    in_comments                 (j) := p_igsv_ext_tbl(i).comments;
    in_duration                 (j) := NULL;
    in_operator                 (j) := NULL;
    in_before_after             (j) := NULL;
    in_datetime                 (j) := NULL;
    in_month                    (j) := NULL;
    in_day                      (j) := NULL;
    in_day_of_week              (j) := NULL;
    in_hour                     (j) := NULL;
    in_minute                   (j) := NULL;
    in_second                   (j) := NULL;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := NULL;
    in_attribute_category       (j) := p_igsv_ext_tbl(i).attribute_category;
    in_attribute1               (j) := p_igsv_ext_tbl(i).attribute1;
    in_attribute2               (j) := p_igsv_ext_tbl(i).attribute2;
    in_attribute3               (j) := p_igsv_ext_tbl(i).attribute3;
    in_attribute4               (j) := p_igsv_ext_tbl(i).attribute4;
    in_attribute5               (j) := p_igsv_ext_tbl(i).attribute5;
    in_attribute6               (j) := p_igsv_ext_tbl(i).attribute6;
    in_attribute7               (j) := p_igsv_ext_tbl(i).attribute7;
    in_attribute8               (j) := p_igsv_ext_tbl(i).attribute8;
    in_attribute9               (j) := p_igsv_ext_tbl(i).attribute9;
    in_attribute10              (j) := p_igsv_ext_tbl(i).attribute10;
    in_attribute11              (j) := p_igsv_ext_tbl(i).attribute11;
    in_attribute12              (j) := p_igsv_ext_tbl(i).attribute12;
    in_attribute13              (j) := p_igsv_ext_tbl(i).attribute13;
    in_attribute14              (j) := p_igsv_ext_tbl(i).attribute14;
    in_attribute15              (j) := p_igsv_ext_tbl(i).attribute15;
    in_tve_type                 (j) := 'IGS';
    in_created_by               (j) := p_igsv_ext_tbl(i).created_by;
    in_creation_date            (j) := p_igsv_ext_tbl(i).creation_date;
    in_last_updated_by          (j) := p_igsv_ext_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_igsv_ext_tbl(i).last_update_date;
    in_last_update_login        (j) := p_igsv_ext_tbl(i).last_update_login;
    i                           := p_igsv_ext_tbl.NEXT(i);
  END LOOP;
--Bug 3122962
  FORALL i in 1..j
    INSERT
      INTO OKC_TIMEVALUES
      (
        id,
        spn_id,
        tve_id_offset,
        tve_id_generated_by,
        tve_id_started,
        tve_id_ended,
        tve_id_limited,
        cnh_id,
        dnz_chr_id,
        tve_type,
        tze_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        uom_code,
        duration,
        operator,
        before_after,
        datetime,
        month,
        day,
        hour,
        minute,
        second,
        interval_yn,
        last_update_login,
        nth,
        day_of_week,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
--Bug 3122962
        name,
        description,
        short_description,
        comments
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        DECODE(in_spn_id(i),OKC_API.G_MISS_NUM,NULL,in_spn_id(i)),
        DECODE(in_tve_id_offset(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_offset(i)),
        DECODE(in_tve_id_generated_by(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_generated_by(i)),
        DECODE(in_tve_id_started(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_started(i)),
        DECODE(in_tve_id_ended(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_ended(i)),
        DECODE(in_tve_id_limited(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_limited(i)),
        DECODE(in_cnh_id(i),OKC_API.G_MISS_NUM,NULL,in_cnh_id(i)),
        DECODE(in_dnz_chr_id(i),OKC_API.G_MISS_NUM,NULL,in_dnz_chr_id(i)),
        DECODE(in_tve_type(i),OKC_API.G_MISS_CHAR,NULL,in_tve_type(i)),
        DECODE(in_tze_id(i),OKC_API.G_MISS_NUM,NULL,in_tze_id(i)),
        DECODE(in_object_version_number(i),OKC_API.G_MISS_NUM,NULL,in_object_version_number(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_uom_code(i),OKC_API.G_MISS_CHAR,NULL,in_uom_code(i)),
        DECODE(in_duration(i),OKC_API.G_MISS_NUM,NULL,in_duration(i)),
        DECODE(in_operator(i),OKC_API.G_MISS_CHAR,NULL,in_operator(i)),
        DECODE(in_before_after(i),OKC_API.G_MISS_CHAR,NULL,in_before_after(i)),
        DECODE(in_datetime(i),OKC_API.G_MISS_DATE,NULL,in_datetime(i)),
        DECODE(in_month(i),OKC_API.G_MISS_NUM,NULL,in_month(i)),
        DECODE(in_day(i),OKC_API.G_MISS_NUM,NULL,in_day(i)),
        DECODE(in_hour(i),OKC_API.G_MISS_NUM,NULL,in_hour(i)),
        DECODE(in_minute(i),OKC_API.G_MISS_NUM,NULL,in_minute(i)),
        DECODE(in_second(i),OKC_API.G_MISS_NUM,NULL,in_second(i)),
        DECODE(in_interval_yn(i),OKC_API.G_MISS_CHAR,NULL,in_interval_yn(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i)),
        DECODE(in_nth(i),OKC_API.G_MISS_NUM,NULL,in_nth(i)),
        DECODE(in_day_of_week(i),OKC_API.G_MISS_CHAR,NULL,in_day_of_week(i)),
        DECODE(in_attribute_category(i),OKC_API.G_MISS_CHAR,NULL,in_attribute_category(i)),
        DECODE(in_attribute1(i),OKC_API.G_MISS_CHAR,NULL,in_attribute1(i)),
        DECODE(in_attribute2(i),OKC_API.G_MISS_CHAR,NULL,in_attribute2(i)),
        DECODE(in_attribute3(i),OKC_API.G_MISS_CHAR,NULL,in_attribute3(i)),
        DECODE(in_attribute4(i),OKC_API.G_MISS_CHAR,NULL,in_attribute4(i)),
        DECODE(in_attribute5(i),OKC_API.G_MISS_CHAR,NULL,in_attribute5(i)),
        DECODE(in_attribute6(i),OKC_API.G_MISS_CHAR,NULL,in_attribute6(i)),
        DECODE(in_attribute7(i),OKC_API.G_MISS_CHAR,NULL,in_attribute7(i)),
        DECODE(in_attribute8(i),OKC_API.G_MISS_CHAR,NULL,in_attribute8(i)),
        DECODE(in_attribute9(i),OKC_API.G_MISS_CHAR,NULL,in_attribute9(i)),
        DECODE(in_attribute10(i),OKC_API.G_MISS_CHAR,NULL,in_attribute10(i)),
        DECODE(in_attribute11(i),OKC_API.G_MISS_CHAR,NULL,in_attribute11(i)),
        DECODE(in_attribute12(i),OKC_API.G_MISS_CHAR,NULL,in_attribute12(i)),
        DECODE(in_attribute13(i),OKC_API.G_MISS_CHAR,NULL,in_attribute13(i)),
        DECODE(in_attribute14(i),OKC_API.G_MISS_CHAR,NULL,in_attribute14(i)),
        DECODE(in_attribute15(i),OKC_API.G_MISS_CHAR,NULL,in_attribute15(i)),
--Bug 3122962
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i))
     );

--Bug 3122962
/*
  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..j
      INSERT INTO OKC_TIMEVALUES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        description,
        short_description,
        comments,
        name,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        DECODE(in_sfwt_flag(i),OKC_API.G_MISS_CHAR,NULL,in_sfwt_flag(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i)),
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i))
      );
      END LOOP;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END INSERT_IGS_ROW_UPG;

PROCEDURE INSERT_TGD_ROW_UPG(p_tgdv_ext_tbl IN tgdv_ext_tbl_type) IS
  l_tabsize NUMBER := p_tgdv_ext_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
--Bug 3122962  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_spn_id                        OKC_DATATYPES.NumberTabTyp;
  in_tve_id_offset                 OKC_DATATYPES.NumberTabTyp;
  in_uom_code                      OKC_DATATYPES.Var3TabTyp;
  in_tve_id_generated_by           OKC_DATATYPES.NumberTabTyp;
  in_tve_id_started                OKC_DATATYPES.NumberTabTyp;
  in_tve_id_ended                  OKC_DATATYPES.NumberTabTyp;
  in_tve_id_limited                OKC_DATATYPES.NumberTabTyp;
  in_cnh_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_tze_id                        OKC_DATATYPES.NumberTabTyp;
  in_description                   OKC_DATATYPES.Var1995TabTyp;
  in_short_description             OKC_DATATYPES.Var600TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_duration                      OKC_DATATYPES.NumberTabTyp;
  in_operator                      OKC_DATATYPES.Var10TabTyp;
  in_before_after                  OKC_DATATYPES.Var3TabTyp;
  in_datetime                      OKC_DATATYPES.DateTabTyp;
  in_month                         OKC_DATATYPES.NumberTabTyp;
  in_day                           OKC_DATATYPES.NumberTabTyp;
  in_day_of_week                   OKC_DATATYPES.Var10TabTyp;
  in_hour                          OKC_DATATYPES.NumberTabTyp;
  in_minute                        OKC_DATATYPES.NumberTabTyp;
  in_second                        OKC_DATATYPES.NumberTabTyp;
  in_name                          OKC_DATATYPES.Var150TabTyp;
  in_interval_yn                   OKC_DATATYPES.Var3TabTyp;
  in_nth                           OKC_DATATYPES.NumberTabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_tve_type                      OKC_DATATYPES.Var10TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i                                NUMBER := p_tgdv_ext_tbl.FIRST;
  j                                NUMBER := 0;
BEGIN
  while i is not NULL
  LOOP
    j := j+1;
    in_id                       (j) := p_tgdv_ext_tbl(i).id;
    in_object_version_number    (j) := p_tgdv_ext_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_tgdv_ext_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := NULL;
    in_uom_code                 (j) := NULL;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := NULL;
    in_tve_id_ended             (j) := NULL;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_tgdv_ext_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_tgdv_ext_tbl(i).tze_id;
    in_description              (j) := p_tgdv_ext_tbl(i).description;
    in_short_description        (j) := p_tgdv_ext_tbl(i).short_description;
    in_comments                 (j) := p_tgdv_ext_tbl(i).comments;
    in_duration                 (j) := NULL;
    in_operator                 (j) := NULL;
    in_before_after             (j) := NULL;
    in_datetime                 (j) := NULL;
    in_month                    (j) := p_tgdv_ext_tbl(i).month;
    in_day                      (j) := p_tgdv_ext_tbl(i).day;
    in_day_of_week              (j) := p_tgdv_ext_tbl(i).day_of_week;
    in_hour                     (j) := p_tgdv_ext_tbl(i).hour;
    in_minute                   (j) := p_tgdv_ext_tbl(i).minute;
    in_second                   (j) := p_tgdv_ext_tbl(i).second;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := p_tgdv_ext_tbl(i).nth;
    in_attribute_category       (j) := p_tgdv_ext_tbl(i).attribute_category;
    in_attribute1               (j) := p_tgdv_ext_tbl(i).attribute1;
    in_attribute2               (j) := p_tgdv_ext_tbl(i).attribute2;
    in_attribute3               (j) := p_tgdv_ext_tbl(i).attribute3;
    in_attribute4               (j) := p_tgdv_ext_tbl(i).attribute4;
    in_attribute5               (j) := p_tgdv_ext_tbl(i).attribute5;
    in_attribute6               (j) := p_tgdv_ext_tbl(i).attribute6;
    in_attribute7               (j) := p_tgdv_ext_tbl(i).attribute7;
    in_attribute8               (j) := p_tgdv_ext_tbl(i).attribute8;
    in_attribute9               (j) := p_tgdv_ext_tbl(i).attribute9;
    in_attribute10              (j) := p_tgdv_ext_tbl(i).attribute10;
    in_attribute11              (j) := p_tgdv_ext_tbl(i).attribute11;
    in_attribute12              (j) := p_tgdv_ext_tbl(i).attribute12;
    in_attribute13              (j) := p_tgdv_ext_tbl(i).attribute13;
    in_attribute14              (j) := p_tgdv_ext_tbl(i).attribute14;
    in_attribute15              (j) := p_tgdv_ext_tbl(i).attribute15;
    in_tve_type                 (j) := 'TGD';
    in_created_by               (j) := p_tgdv_ext_tbl(i).created_by;
    in_creation_date            (j) := p_tgdv_ext_tbl(i).creation_date;
    in_last_updated_by          (j) := p_tgdv_ext_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_tgdv_ext_tbl(i).last_update_date;
    in_last_update_login        (j) := p_tgdv_ext_tbl(i).last_update_login;
    i := p_tgdv_ext_tbl.NEXT(i);
  END LOOP;
--Bug 3122962
  FORALL i in 1..j
    INSERT
      INTO OKC_TIMEVALUES
      (
        id,
        spn_id,
        tve_id_offset,
        tve_id_generated_by,
        tve_id_started,
        tve_id_ended,
        tve_id_limited,
        cnh_id,
        dnz_chr_id,
        tve_type,
        tze_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        uom_code,
        duration,
        operator,
        before_after,
        datetime,
        month,
        day,
        hour,
        minute,
        second,
        interval_yn,
        last_update_login,
        nth,
        day_of_week,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
--Bug 3122962
        name,
        description,
        short_description,
        comments
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        DECODE(in_spn_id(i),OKC_API.G_MISS_NUM,NULL,in_spn_id(i)),
        DECODE(in_tve_id_offset(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_offset(i)),
        DECODE(in_tve_id_generated_by(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_generated_by(i)),
        DECODE(in_tve_id_started(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_started(i)),
        DECODE(in_tve_id_ended(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_ended(i)),
        DECODE(in_tve_id_limited(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_limited(i)),
        DECODE(in_cnh_id(i),OKC_API.G_MISS_NUM,NULL,in_cnh_id(i)),
        DECODE(in_dnz_chr_id(i),OKC_API.G_MISS_NUM,NULL,in_dnz_chr_id(i)),
        DECODE(in_tve_type(i),OKC_API.G_MISS_CHAR,NULL,in_tve_type(i)),
        DECODE(in_tze_id(i),OKC_API.G_MISS_NUM,NULL,in_tze_id(i)),
        DECODE(in_object_version_number(i),OKC_API.G_MISS_NUM,NULL,in_object_version_number(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_uom_code(i),OKC_API.G_MISS_CHAR,NULL,in_uom_code(i)),
        DECODE(in_duration(i),OKC_API.G_MISS_NUM,NULL,in_duration(i)),
        DECODE(in_operator(i),OKC_API.G_MISS_CHAR,NULL,in_operator(i)),
        DECODE(in_before_after(i),OKC_API.G_MISS_CHAR,NULL,in_before_after(i)),
        DECODE(in_datetime(i),OKC_API.G_MISS_DATE,NULL,in_datetime(i)),
        DECODE(in_month(i),OKC_API.G_MISS_NUM,NULL,in_month(i)),
        DECODE(in_day(i),OKC_API.G_MISS_NUM,NULL,in_day(i)),
        DECODE(in_hour(i),OKC_API.G_MISS_NUM,NULL,in_hour(i)),
        DECODE(in_minute(i),OKC_API.G_MISS_NUM,NULL,in_minute(i)),
        DECODE(in_second(i),OKC_API.G_MISS_NUM,NULL,in_second(i)),
        DECODE(in_interval_yn(i),OKC_API.G_MISS_CHAR,NULL,in_interval_yn(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i)),
        DECODE(in_nth(i),OKC_API.G_MISS_NUM,NULL,in_nth(i)),
        DECODE(in_day_of_week(i),OKC_API.G_MISS_CHAR,NULL,in_day_of_week(i)),
        DECODE(in_attribute_category(i),OKC_API.G_MISS_CHAR,NULL,in_attribute_category(i)),
        DECODE(in_attribute1(i),OKC_API.G_MISS_CHAR,NULL,in_attribute1(i)),
        DECODE(in_attribute2(i),OKC_API.G_MISS_CHAR,NULL,in_attribute2(i)),
        DECODE(in_attribute3(i),OKC_API.G_MISS_CHAR,NULL,in_attribute3(i)),
        DECODE(in_attribute4(i),OKC_API.G_MISS_CHAR,NULL,in_attribute4(i)),
        DECODE(in_attribute5(i),OKC_API.G_MISS_CHAR,NULL,in_attribute5(i)),
        DECODE(in_attribute6(i),OKC_API.G_MISS_CHAR,NULL,in_attribute6(i)),
        DECODE(in_attribute7(i),OKC_API.G_MISS_CHAR,NULL,in_attribute7(i)),
        DECODE(in_attribute8(i),OKC_API.G_MISS_CHAR,NULL,in_attribute8(i)),
        DECODE(in_attribute9(i),OKC_API.G_MISS_CHAR,NULL,in_attribute9(i)),
        DECODE(in_attribute10(i),OKC_API.G_MISS_CHAR,NULL,in_attribute10(i)),
        DECODE(in_attribute11(i),OKC_API.G_MISS_CHAR,NULL,in_attribute11(i)),
        DECODE(in_attribute12(i),OKC_API.G_MISS_CHAR,NULL,in_attribute12(i)),
        DECODE(in_attribute13(i),OKC_API.G_MISS_CHAR,NULL,in_attribute13(i)),
        DECODE(in_attribute14(i),OKC_API.G_MISS_CHAR,NULL,in_attribute14(i)),
        DECODE(in_attribute15(i),OKC_API.G_MISS_CHAR,NULL,in_attribute15(i)),
--Bug 3122962
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i))
     );
--Bug 3122962
/*
  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..j
      INSERT INTO OKC_TIMEVALUES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        description,
        short_description,
        comments,
        name,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        DECODE(in_sfwt_flag(i),OKC_API.G_MISS_CHAR,NULL,in_sfwt_flag(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i)),
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i))
      );
      END LOOP;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END INSERT_TGD_ROW_UPG;

PROCEDURE INSERT_ISE_ROW_UPG(p_isev_ext_tbl IN isev_ext_tbl_type) IS
  l_tabsize NUMBER := p_isev_ext_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
--Bug 3122962  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_spn_id                        OKC_DATATYPES.NumberTabTyp;
  in_tve_id_offset                 OKC_DATATYPES.NumberTabTyp;
  in_uom_code                      OKC_DATATYPES.Var3TabTyp;
  in_tve_id_generated_by           OKC_DATATYPES.NumberTabTyp;
  in_tve_id_started                OKC_DATATYPES.NumberTabTyp;
  in_tve_id_ended                  OKC_DATATYPES.NumberTabTyp;
  in_tve_id_limited                OKC_DATATYPES.NumberTabTyp;
  in_cnh_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_tze_id                        OKC_DATATYPES.NumberTabTyp;
  in_description                   OKC_DATATYPES.Var1995TabTyp;
  in_short_description             OKC_DATATYPES.Var600TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_duration                      OKC_DATATYPES.NumberTabTyp;
  in_operator                      OKC_DATATYPES.Var10TabTyp;
  in_before_after                  OKC_DATATYPES.Var3TabTyp;
  in_datetime                      OKC_DATATYPES.DateTabTyp;
  in_month                         OKC_DATATYPES.NumberTabTyp;
  in_day                           OKC_DATATYPES.NumberTabTyp;
  in_day_of_week                   OKC_DATATYPES.Var10TabTyp;
  in_hour                          OKC_DATATYPES.NumberTabTyp;
  in_minute                        OKC_DATATYPES.NumberTabTyp;
  in_second                        OKC_DATATYPES.NumberTabTyp;
  in_name                          OKC_DATATYPES.Var150TabTyp;
  in_interval_yn                   OKC_DATATYPES.Var3TabTyp;
  in_nth                           OKC_DATATYPES.NumberTabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_tve_type                      OKC_DATATYPES.Var10TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  l_tve_id_started                 NUMBER;
  l_tve_id_ended                   NUMBER;
  i                                NUMBER := p_isev_ext_tbl.FIRST;
  j                                NUMBER := 0;
  x_return_status                 VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  while i is NOT NULL
  LOOP
  /* FOR ISE STARTED */
    j := j+1;
    in_id                       (j) := okc_p_util.raw_to_number(sys_guid());
    l_tve_id_started             := in_id(j);
    in_object_version_number    (j) := p_isev_ext_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_isev_ext_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := NULL;
    in_uom_code                 (j) := NULL;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := NULL;
    in_tve_id_ended             (j) := NULL;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_isev_ext_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_isev_ext_tbl(i).tze_id;
    in_description              (j) := 'Start of Absolute Interval Startend';
    in_short_description        (j) := 'Start Absolute Intrvl';
    in_comments                 (j) := 'Generated by ise';
    in_duration                 (j) := NULL;
    in_operator                 (j) := NULL;
    in_before_after             (j) := NULL;
    in_datetime                 (j) := p_isev_ext_tbl(i).start_date;
    in_month                    (j) := NULL;
    in_day                      (j) := NULL;
    in_day_of_week              (j) := NULL;
    in_hour                     (j) := NULL;
    in_minute                   (j) := NULL;
    in_second                   (j) := NULL;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := NULL;
    in_attribute_category       (j) := p_isev_ext_tbl(i).attribute_category;
    in_attribute1               (j) := p_isev_ext_tbl(i).attribute1;
    in_attribute2               (j) := p_isev_ext_tbl(i).attribute2;
    in_attribute3               (j) := p_isev_ext_tbl(i).attribute3;
    in_attribute4               (j) := p_isev_ext_tbl(i).attribute4;
    in_attribute5               (j) := p_isev_ext_tbl(i).attribute5;
    in_attribute6               (j) := p_isev_ext_tbl(i).attribute6;
    in_attribute7               (j) := p_isev_ext_tbl(i).attribute7;
    in_attribute8               (j) := p_isev_ext_tbl(i).attribute8;
    in_attribute9               (j) := p_isev_ext_tbl(i).attribute9;
    in_attribute10              (j) := p_isev_ext_tbl(i).attribute10;
    in_attribute11              (j) := p_isev_ext_tbl(i).attribute11;
    in_attribute12              (j) := p_isev_ext_tbl(i).attribute12;
    in_attribute13              (j) := p_isev_ext_tbl(i).attribute13;
    in_attribute14              (j) := p_isev_ext_tbl(i).attribute14;
    in_attribute15              (j) := p_isev_ext_tbl(i).attribute15;
    in_tve_type                 (j) := 'TAV';
    in_created_by               (j) := p_isev_ext_tbl(i).created_by;
    in_creation_date            (j) := p_isev_ext_tbl(i).creation_date;
    in_last_updated_by          (j) := p_isev_ext_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_isev_ext_tbl(i).last_update_date;
    in_last_update_login        (j) := p_isev_ext_tbl(i).last_update_login;
  /* FOR ISE */
    j := j+1;
    in_id                       (j) := p_isev_ext_tbl(i).id;
    in_object_version_number    (j) := p_isev_ext_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_isev_ext_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := NULL;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := l_tve_id_started;
    in_tve_id_ended             (j) := NULL;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_isev_ext_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_isev_ext_tbl(i).tze_id;
    in_description              (j) := p_isev_ext_tbl(i).description;
    in_short_description        (j) := p_isev_ext_tbl(i).short_description;
    in_comments                 (j) := p_isev_ext_tbl(i).comments;
    if p_isev_ext_tbl(i).duration is null or
	  p_isev_ext_tbl(i).duration = OKC_API.G_MISS_NUM then
      if p_isev_ext_tbl(i).end_date is NOT NULL and
	   p_isev_ext_tbl(i).end_date <> OKC_API.G_MISS_DATE then
	   okc_time_util_pub.get_duration(p_isev_ext_tbl(i).start_date, p_isev_ext_tbl(i).end_date,in_duration(j),
						    in_uom_code(j),x_return_status);
        if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	     return;
        end if;
      else
	   in_duration(j) := NULL;
	   in_uom_code(j) := NULL;
	 end if;
    else
	 in_duration(j) := p_isev_ext_tbl(i).duration;
	 in_uom_code(j) := p_isev_ext_tbl(i).uom_code;
    end if;
    in_operator                 (j) := NULL;
    in_before_after             (j) := NULL;
    in_datetime                 (j) := NULL;
    in_month                    (j) := NULL;
    in_day                      (j) := NULL;
    in_day_of_week              (j) := NULL;
    in_hour                     (j) := NULL;
    in_minute                   (j) := NULL;
    in_second                   (j) := NULL;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := NULL;
    in_attribute_category       (j) := p_isev_ext_tbl(i).attribute_category;
    in_attribute1               (j) := p_isev_ext_tbl(i).attribute1;
    in_attribute2               (j) := p_isev_ext_tbl(i).attribute2;
    in_attribute3               (j) := p_isev_ext_tbl(i).attribute3;
    in_attribute4               (j) := p_isev_ext_tbl(i).attribute4;
    in_attribute5               (j) := p_isev_ext_tbl(i).attribute5;
    in_attribute6               (j) := p_isev_ext_tbl(i).attribute6;
    in_attribute7               (j) := p_isev_ext_tbl(i).attribute7;
    in_attribute8               (j) := p_isev_ext_tbl(i).attribute8;
    in_attribute9               (j) := p_isev_ext_tbl(i).attribute9;
    in_attribute10              (j) := p_isev_ext_tbl(i).attribute10;
    in_attribute11              (j) := p_isev_ext_tbl(i).attribute11;
    in_attribute12              (j) := p_isev_ext_tbl(i).attribute12;
    in_attribute13              (j) := p_isev_ext_tbl(i).attribute13;
    in_attribute14              (j) := p_isev_ext_tbl(i).attribute14;
    in_attribute15              (j) := p_isev_ext_tbl(i).attribute15;
    in_tve_type                 (j) := 'ISE';
    in_created_by               (j) := p_isev_ext_tbl(i).created_by;
    in_creation_date            (j) := p_isev_ext_tbl(i).creation_date;
    in_last_updated_by          (j) := p_isev_ext_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_isev_ext_tbl(i).last_update_date;
    in_last_update_login        (j) := p_isev_ext_tbl(i).last_update_login;
    i                           := p_isev_ext_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..j
    INSERT
      INTO OKC_TIMEVALUES
      (
        id,
        spn_id,
        tve_id_offset,
        tve_id_generated_by,
        tve_id_started,
        tve_id_ended,
        tve_id_limited,
        cnh_id,
        dnz_chr_id,
        tve_type,
        tze_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        uom_code,
        duration,
        operator,
        before_after,
        datetime,
        month,
        day,
        hour,
        minute,
        second,
        interval_yn,
        last_update_login,
        nth,
        day_of_week,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
--Bug 3122962
        name,
        description,
        short_description,
        comments
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        DECODE(in_spn_id(i),OKC_API.G_MISS_NUM,NULL,in_spn_id(i)),
        DECODE(in_tve_id_offset(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_offset(i)),
        DECODE(in_tve_id_generated_by(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_generated_by(i)),
        DECODE(in_tve_id_started(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_started(i)),
        DECODE(in_tve_id_ended(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_ended(i)),
        DECODE(in_tve_id_limited(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_limited(i)),
        DECODE(in_cnh_id(i),OKC_API.G_MISS_NUM,NULL,in_cnh_id(i)),
        DECODE(in_dnz_chr_id(i),OKC_API.G_MISS_NUM,NULL,in_dnz_chr_id(i)),
        DECODE(in_tve_type(i),OKC_API.G_MISS_CHAR,NULL,in_tve_type(i)),
        DECODE(in_tze_id(i),OKC_API.G_MISS_NUM,NULL,in_tze_id(i)),
        DECODE(in_object_version_number(i),OKC_API.G_MISS_NUM,NULL,in_object_version_number(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_uom_code(i),OKC_API.G_MISS_CHAR,NULL,in_uom_code(i)),
        DECODE(in_duration(i),OKC_API.G_MISS_NUM,NULL,in_duration(i)),
        DECODE(in_operator(i),OKC_API.G_MISS_CHAR,NULL,in_operator(i)),
        DECODE(in_before_after(i),OKC_API.G_MISS_CHAR,NULL,in_before_after(i)),
        DECODE(in_datetime(i),OKC_API.G_MISS_DATE,NULL,in_datetime(i)),
        DECODE(in_month(i),OKC_API.G_MISS_NUM,NULL,in_month(i)),
        DECODE(in_day(i),OKC_API.G_MISS_NUM,NULL,in_day(i)),
        DECODE(in_hour(i),OKC_API.G_MISS_NUM,NULL,in_hour(i)),
        DECODE(in_minute(i),OKC_API.G_MISS_NUM,NULL,in_minute(i)),
        DECODE(in_second(i),OKC_API.G_MISS_NUM,NULL,in_second(i)),
        DECODE(in_interval_yn(i),OKC_API.G_MISS_CHAR,NULL,in_interval_yn(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i)),
        DECODE(in_nth(i),OKC_API.G_MISS_NUM,NULL,in_nth(i)),
        DECODE(in_day_of_week(i),OKC_API.G_MISS_CHAR,NULL,in_day_of_week(i)),
        DECODE(in_attribute_category(i),OKC_API.G_MISS_CHAR,NULL,in_attribute_category(i)),
        DECODE(in_attribute1(i),OKC_API.G_MISS_CHAR,NULL,in_attribute1(i)),
        DECODE(in_attribute2(i),OKC_API.G_MISS_CHAR,NULL,in_attribute2(i)),
        DECODE(in_attribute3(i),OKC_API.G_MISS_CHAR,NULL,in_attribute3(i)),
        DECODE(in_attribute4(i),OKC_API.G_MISS_CHAR,NULL,in_attribute4(i)),
        DECODE(in_attribute5(i),OKC_API.G_MISS_CHAR,NULL,in_attribute5(i)),
        DECODE(in_attribute6(i),OKC_API.G_MISS_CHAR,NULL,in_attribute6(i)),
        DECODE(in_attribute7(i),OKC_API.G_MISS_CHAR,NULL,in_attribute7(i)),
        DECODE(in_attribute8(i),OKC_API.G_MISS_CHAR,NULL,in_attribute8(i)),
        DECODE(in_attribute9(i),OKC_API.G_MISS_CHAR,NULL,in_attribute9(i)),
        DECODE(in_attribute10(i),OKC_API.G_MISS_CHAR,NULL,in_attribute10(i)),
        DECODE(in_attribute11(i),OKC_API.G_MISS_CHAR,NULL,in_attribute11(i)),
        DECODE(in_attribute12(i),OKC_API.G_MISS_CHAR,NULL,in_attribute12(i)),
        DECODE(in_attribute13(i),OKC_API.G_MISS_CHAR,NULL,in_attribute13(i)),
        DECODE(in_attribute14(i),OKC_API.G_MISS_CHAR,NULL,in_attribute14(i)),
        DECODE(in_attribute15(i),OKC_API.G_MISS_CHAR,NULL,in_attribute15(i)),
--Bug 3122962
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i))
     );
--Bug 3122962
/*
  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..j
      INSERT INTO OKC_TIMEVALUES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        description,
        short_description,
        comments,
        name,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        DECODE(in_sfwt_flag(i),OKC_API.G_MISS_CHAR,NULL,in_sfwt_flag(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i)),
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i))
      );
      END LOOP;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END INSERT_ISE_ROW_UPG;

PROCEDURE INSERT_ISE_ROW_UPG(p_isev_rel_tbl IN isev_rel_tbl_type) IS
  l_tabsize NUMBER := p_isev_rel_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
--Bug 3122962  in_sfwt_flag                     OKC_DATATYPES.Var3TabTyp;
  in_spn_id                        OKC_DATATYPES.NumberTabTyp;
  in_tve_id_offset                 OKC_DATATYPES.NumberTabTyp;
  in_uom_code                      OKC_DATATYPES.Var3TabTyp;
  in_tve_id_generated_by           OKC_DATATYPES.NumberTabTyp;
  in_tve_id_started                OKC_DATATYPES.NumberTabTyp;
  in_tve_id_ended                  OKC_DATATYPES.NumberTabTyp;
  in_tve_id_limited                OKC_DATATYPES.NumberTabTyp;
  in_cnh_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_tze_id                        OKC_DATATYPES.NumberTabTyp;
  in_description                   OKC_DATATYPES.Var1995TabTyp;
  in_short_description             OKC_DATATYPES.Var600TabTyp;
  in_comments                      OKC_DATATYPES.Var1995TabTyp;
  in_duration                      OKC_DATATYPES.NumberTabTyp;
  in_operator                      OKC_DATATYPES.Var10TabTyp;
  in_before_after                  OKC_DATATYPES.Var3TabTyp;
  in_datetime                      OKC_DATATYPES.DateTabTyp;
  in_month                         OKC_DATATYPES.NumberTabTyp;
  in_day                           OKC_DATATYPES.NumberTabTyp;
  in_day_of_week                   OKC_DATATYPES.Var10TabTyp;
  in_hour                          OKC_DATATYPES.NumberTabTyp;
  in_minute                        OKC_DATATYPES.NumberTabTyp;
  in_second                        OKC_DATATYPES.NumberTabTyp;
  in_name                          OKC_DATATYPES.Var150TabTyp;
  in_interval_yn                   OKC_DATATYPES.Var3TabTyp;
  in_nth                           OKC_DATATYPES.NumberTabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_tve_type                      OKC_DATATYPES.Var10TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  l_tve_id_started                 NUMBER;
  l_tve_id_ended                   NUMBER;
  i                                NUMBER := p_isev_rel_tbl.FIRST;
  j                                NUMBER := 0;
  l_date                           DATE := NULL;
  x_return_status                 VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  while i is NOT NULL
  LOOP
  /* FOR TPA RELATIVE */
    j := j+1;
    in_id                       (j) := okc_p_util.raw_to_number(sys_guid());
    l_tve_id_started             := in_id(j);
    in_object_version_number    (j) := p_isev_rel_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_isev_rel_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := p_isev_rel_tbl(i).start_tve_id_offset;
    in_uom_code                 (j) := p_isev_rel_tbl(i).start_uom_code;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := NULL;
    in_tve_id_ended             (j) := NULL;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_isev_rel_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_isev_rel_tbl(i).tze_id;
    in_description              (j) := 'Start Date of Relative Interval';
    in_short_description        (j) := 'Start of Rel Intrvl';
    in_comments                 (j) := 'Generated by ISE';
    in_duration                 (j) := p_isev_rel_tbl(i).start_duration;
    if p_isev_rel_tbl(i).start_duration >= 0 then
       in_before_after(j) := 'A';
    else
       in_before_after(j) := 'B';
    end if;
    in_operator                 (j) := p_isev_rel_tbl(i).start_operator;
    in_datetime                 (j) := NULL;
    in_month                    (j) := NULL;
    in_day                      (j) := NULL;
    in_day_of_week              (j) := NULL;
    in_hour                     (j) := NULL;
    in_minute                   (j) := NULL;
    in_second                   (j) := NULL;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := NULL;
    in_attribute_category       (j) := p_isev_rel_tbl(i).attribute_category;
    in_attribute1               (j) := p_isev_rel_tbl(i).attribute1;
    in_attribute2               (j) := p_isev_rel_tbl(i).attribute2;
    in_attribute3               (j) := p_isev_rel_tbl(i).attribute3;
    in_attribute4               (j) := p_isev_rel_tbl(i).attribute4;
    in_attribute5               (j) := p_isev_rel_tbl(i).attribute5;
    in_attribute6               (j) := p_isev_rel_tbl(i).attribute6;
    in_attribute7               (j) := p_isev_rel_tbl(i).attribute7;
    in_attribute8               (j) := p_isev_rel_tbl(i).attribute8;
    in_attribute9               (j) := p_isev_rel_tbl(i).attribute9;
    in_attribute10              (j) := p_isev_rel_tbl(i).attribute10;
    in_attribute11              (j) := p_isev_rel_tbl(i).attribute11;
    in_attribute12              (j) := p_isev_rel_tbl(i).attribute12;
    in_attribute13              (j) := p_isev_rel_tbl(i).attribute13;
    in_attribute14              (j) := p_isev_rel_tbl(i).attribute14;
    in_attribute15              (j) := p_isev_rel_tbl(i).attribute15;
    in_tve_type                 (j) := 'TAL';
    in_created_by               (j) := p_isev_rel_tbl(i).created_by;
    in_creation_date            (j) := p_isev_rel_tbl(i).creation_date;
    in_last_updated_by          (j) := p_isev_rel_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_isev_rel_tbl(i).last_update_date;
    in_last_update_login        (j) := p_isev_rel_tbl(i).last_update_login;
  /* FOR ISE */
    j := j+1;
    in_id                       (j) := p_isev_rel_tbl(i).id;
    in_object_version_number    (j) := p_isev_rel_tbl(i).object_version_number;
--Bug 3122962    in_sfwt_flag                (j) := p_isev_rel_tbl(i).sfwt_flag;
    in_spn_id                   (j) := NULL;
    in_tve_id_offset            (j) := NULL;
    in_tve_id_generated_by      (j) := NULL;
    in_tve_id_started           (j) := l_tve_id_started;
    in_tve_id_ended             (j) := NULL;
    in_tve_id_limited           (j) := NULL;
    in_cnh_id                   (j) := NULL;
    in_dnz_chr_id               (j) := p_isev_rel_tbl(i).dnz_chr_id;
    in_tze_id                   (j) := p_isev_rel_tbl(i).tze_id;
    in_description              (j) := p_isev_rel_tbl(i).description;
    in_short_description        (j) := p_isev_rel_tbl(i).short_description;
    in_comments                 (j) := p_isev_rel_tbl(i).comments;
    l_date := OKC_TIME_UTIL_PUB.get_enddate(p_isev_rel_tbl(i).start_parent_date,
								    p_isev_rel_tbl(i).start_uom_code,
								    p_isev_rel_tbl(i).start_duration);
    if l_date is NULL THEN
	 return;
    end if;
    if p_isev_rel_tbl(i).end_date is NOT NULL and
      p_isev_rel_tbl(i).end_date <> OKC_API.G_MISS_DATE then
	 okc_time_util_pub.get_duration(l_date, p_isev_rel_tbl(i).end_date,in_duration(j),
						    in_uom_code(j),x_return_status);
      if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	   return;
      end if;
    else
      in_duration(j) := NULL;
      in_uom_code(j) := NULL;
    end if;
    in_operator                 (j) := NULL;
    in_before_after             (j) := NULL;
    in_datetime                 (j) := NULL;
    in_month                    (j) := NULL;
    in_day                      (j) := NULL;
    in_day_of_week              (j) := NULL;
    in_hour                     (j) := NULL;
    in_minute                   (j) := NULL;
    in_second                   (j) := NULL;
    in_name                     (j) := NULL;
    in_interval_yn              (j) := NULL;
    in_nth                      (j) := NULL;
    in_attribute_category       (j) := p_isev_rel_tbl(i).attribute_category;
    in_attribute1               (j) := p_isev_rel_tbl(i).attribute1;
    in_attribute2               (j) := p_isev_rel_tbl(i).attribute2;
    in_attribute3               (j) := p_isev_rel_tbl(i).attribute3;
    in_attribute4               (j) := p_isev_rel_tbl(i).attribute4;
    in_attribute5               (j) := p_isev_rel_tbl(i).attribute5;
    in_attribute6               (j) := p_isev_rel_tbl(i).attribute6;
    in_attribute7               (j) := p_isev_rel_tbl(i).attribute7;
    in_attribute8               (j) := p_isev_rel_tbl(i).attribute8;
    in_attribute9               (j) := p_isev_rel_tbl(i).attribute9;
    in_attribute10              (j) := p_isev_rel_tbl(i).attribute10;
    in_attribute11              (j) := p_isev_rel_tbl(i).attribute11;
    in_attribute12              (j) := p_isev_rel_tbl(i).attribute12;
    in_attribute13              (j) := p_isev_rel_tbl(i).attribute13;
    in_attribute14              (j) := p_isev_rel_tbl(i).attribute14;
    in_attribute15              (j) := p_isev_rel_tbl(i).attribute15;
    in_tve_type                 (j) := 'ISE';
    in_created_by               (j) := p_isev_rel_tbl(i).created_by;
    in_creation_date            (j) := p_isev_rel_tbl(i).creation_date;
    in_last_updated_by          (j) := p_isev_rel_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_isev_rel_tbl(i).last_update_date;
    in_last_update_login        (j) := p_isev_rel_tbl(i).last_update_login;
    i                           := p_isev_rel_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..j
    INSERT
      INTO OKC_TIMEVALUES
      (
        id,
        spn_id,
        tve_id_offset,
        tve_id_generated_by,
        tve_id_started,
        tve_id_ended,
        tve_id_limited,
        cnh_id,
        dnz_chr_id,
        tve_type,
        tze_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        uom_code,
        duration,
        operator,
        before_after,
        datetime,
        month,
        day,
        hour,
        minute,
        second,
        interval_yn,
        last_update_login,
        nth,
        day_of_week,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
--Bug 3122962
        name,
        description,
        short_description,
        comments
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        DECODE(in_spn_id(i),OKC_API.G_MISS_NUM,NULL,in_spn_id(i)),
        DECODE(in_tve_id_offset(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_offset(i)),
        DECODE(in_tve_id_generated_by(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_generated_by(i)),
        DECODE(in_tve_id_started(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_started(i)),
        DECODE(in_tve_id_ended(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_ended(i)),
        DECODE(in_tve_id_limited(i),OKC_API.G_MISS_NUM,NULL,in_tve_id_limited(i)),
        DECODE(in_cnh_id(i),OKC_API.G_MISS_NUM,NULL,in_cnh_id(i)),
        DECODE(in_dnz_chr_id(i),OKC_API.G_MISS_NUM,NULL,in_dnz_chr_id(i)),
        DECODE(in_tve_type(i),OKC_API.G_MISS_CHAR,NULL,in_tve_type(i)),
        DECODE(in_tze_id(i),OKC_API.G_MISS_NUM,NULL,in_tze_id(i)),
        DECODE(in_object_version_number(i),OKC_API.G_MISS_NUM,NULL,in_object_version_number(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_uom_code(i),OKC_API.G_MISS_CHAR,NULL,in_uom_code(i)),
        DECODE(in_duration(i),OKC_API.G_MISS_NUM,NULL,in_duration(i)),
        DECODE(in_operator(i),OKC_API.G_MISS_CHAR,NULL,in_operator(i)),
        DECODE(in_before_after(i),OKC_API.G_MISS_CHAR,NULL,in_before_after(i)),
        DECODE(in_datetime(i),OKC_API.G_MISS_DATE,NULL,in_datetime(i)),
        DECODE(in_month(i),OKC_API.G_MISS_NUM,NULL,in_month(i)),
        DECODE(in_day(i),OKC_API.G_MISS_NUM,NULL,in_day(i)),
        DECODE(in_hour(i),OKC_API.G_MISS_NUM,NULL,in_hour(i)),
        DECODE(in_minute(i),OKC_API.G_MISS_NUM,NULL,in_minute(i)),
        DECODE(in_second(i),OKC_API.G_MISS_NUM,NULL,in_second(i)),
        DECODE(in_interval_yn(i),OKC_API.G_MISS_CHAR,NULL,in_interval_yn(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i)),
        DECODE(in_nth(i),OKC_API.G_MISS_NUM,NULL,in_nth(i)),
        DECODE(in_day_of_week(i),OKC_API.G_MISS_CHAR,NULL,in_day_of_week(i)),
        DECODE(in_attribute_category(i),OKC_API.G_MISS_CHAR,NULL,in_attribute_category(i)),
        DECODE(in_attribute1(i),OKC_API.G_MISS_CHAR,NULL,in_attribute1(i)),
        DECODE(in_attribute2(i),OKC_API.G_MISS_CHAR,NULL,in_attribute2(i)),
        DECODE(in_attribute3(i),OKC_API.G_MISS_CHAR,NULL,in_attribute3(i)),
        DECODE(in_attribute4(i),OKC_API.G_MISS_CHAR,NULL,in_attribute4(i)),
        DECODE(in_attribute5(i),OKC_API.G_MISS_CHAR,NULL,in_attribute5(i)),
        DECODE(in_attribute6(i),OKC_API.G_MISS_CHAR,NULL,in_attribute6(i)),
        DECODE(in_attribute7(i),OKC_API.G_MISS_CHAR,NULL,in_attribute7(i)),
        DECODE(in_attribute8(i),OKC_API.G_MISS_CHAR,NULL,in_attribute8(i)),
        DECODE(in_attribute9(i),OKC_API.G_MISS_CHAR,NULL,in_attribute9(i)),
        DECODE(in_attribute10(i),OKC_API.G_MISS_CHAR,NULL,in_attribute10(i)),
        DECODE(in_attribute11(i),OKC_API.G_MISS_CHAR,NULL,in_attribute11(i)),
        DECODE(in_attribute12(i),OKC_API.G_MISS_CHAR,NULL,in_attribute12(i)),
        DECODE(in_attribute13(i),OKC_API.G_MISS_CHAR,NULL,in_attribute13(i)),
        DECODE(in_attribute14(i),OKC_API.G_MISS_CHAR,NULL,in_attribute14(i)),
        DECODE(in_attribute15(i),OKC_API.G_MISS_CHAR,NULL,in_attribute15(i)),
--Bug 3122962
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i))
     );
--Bug 3122962
/*
  FOR lang_i IN OKC_UTIL.g_language_code.FIRST..OKC_UTIL.g_language_code.LAST LOOP
    FORALL i in 1..j
      INSERT INTO OKC_TIMEVALUES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        description,
        short_description,
        comments,
        name,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        DECODE(in_id(i),OKC_API.G_MISS_NUM,NULL,in_id(i)),
        OKC_UTIL.g_language_code(lang_i),
        l_source_lang,
        DECODE(in_sfwt_flag(i),OKC_API.G_MISS_CHAR,NULL,in_sfwt_flag(i)),
        DECODE(in_description(i),OKC_API.G_MISS_CHAR,NULL,in_description(i)),
        DECODE(in_short_description(i),OKC_API.G_MISS_CHAR,NULL,in_short_description(i)),
        DECODE(in_comments(i),OKC_API.G_MISS_CHAR,NULL,in_comments(i)),
        DECODE(in_name(i),OKC_API.G_MISS_CHAR,NULL,in_name(i)),
        DECODE(in_created_by(i),OKC_API.G_MISS_NUM,NULL,in_created_by(i)),
        DECODE(in_creation_date(i),OKC_API.G_MISS_DATE,NULL,in_creation_date(i)),
        DECODE(in_last_updated_by(i),OKC_API.G_MISS_NUM,NULL,in_last_updated_by(i)),
        DECODE(in_last_update_date(i),OKC_API.G_MISS_DATE,NULL,in_last_update_date(i)),
        DECODE(in_last_update_login(i),OKC_API.G_MISS_NUM,NULL,in_last_update_login(i))
      );
      END LOOP;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END INSERT_ise_ROW_UPG;
END OKC_TIME_PVT;

/
