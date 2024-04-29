--------------------------------------------------------
--  DDL for Package Body CN_CALC_FORMULAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_FORMULAS_PKG" as
/* $Header: cntformb.pls 120.4 2006/05/26 00:49:04 jxsingh ship $ */

procedure INSERT_ROW (
  X_CALC_FORMULA_ID         IN OUT NOCOPY CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
  X_NAME                    IN     CN_CALC_FORMULAS.NAME%TYPE,
  X_DESCRIPTION             IN     CN_CALC_FORMULAS.DESCRIPTION%TYPE             := NULL,
  X_FORMULA_STATUS          IN     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE  := 'INCOMPLETE',
  X_FORMULA_TYPE            IN     CN_CALC_FORMULAS.FORMULA_TYPE%TYPE            := NULL,
  X_TRX_GROUP_CODE          IN     CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE          := NULL,
  X_NUMBER_DIM              IN     CN_CALC_FORMULAS.NUMBER_DIM%TYPE              := NULL,
  X_CUMULATIVE_FLAG         IN     CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE         := NULL,
  X_ITD_FLAG                IN     CN_CALC_FORMULAS.ITD_FLAG%TYPE                := NULL,
  X_SPLIT_FLAG              IN     CN_CALC_FORMULAS.SPLIT_FLAG%TYPE              := NULL,
  X_THRESHOLD_ALL_TIER_FLAG IN     CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE := NULL,
  X_MODELING_FLAG           IN     CN_CALC_FORMULAS.MODELING_FLAG%TYPE           := NULL,
  X_PERF_MEASURE_ID         IN     CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE         := NULL,
  X_OUTPUT_EXP_ID           IN     CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE           := NULL,
  X_F_OUTPUT_EXP_ID         IN     CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE         := NULL,
  --R12 MOAC Changes--Start
  X_ORG_ID                  IN     CN_CALC_FORMULAS.ORG_ID%TYPE,
  --R12 MOAC Changes--End
  X_ATTRIBUTE_CATEGORY      IN     CN_CALC_FORMULAS.ATTRIBUTE_CATEGORY%TYPE      := NULL,
  X_ATTRIBUTE1              IN     CN_CALC_FORMULAS.ATTRIBUTE1%TYPE              := NULL,
  X_ATTRIBUTE2              IN     CN_CALC_FORMULAS.ATTRIBUTE2%TYPE              := NULL,
  X_ATTRIBUTE3              IN     CN_CALC_FORMULAS.ATTRIBUTE3%TYPE              := NULL,
  X_ATTRIBUTE4              IN     CN_CALC_FORMULAS.ATTRIBUTE4%TYPE              := NULL,
  X_ATTRIBUTE5              IN     CN_CALC_FORMULAS.ATTRIBUTE5%TYPE              := NULL,
  X_ATTRIBUTE6              IN     CN_CALC_FORMULAS.ATTRIBUTE6%TYPE              := NULL,
  X_ATTRIBUTE7              IN     CN_CALC_FORMULAS.ATTRIBUTE7%TYPE              := NULL,
  X_ATTRIBUTE8              IN     CN_CALC_FORMULAS.ATTRIBUTE8%TYPE              := NULL,
  X_ATTRIBUTE9              IN     CN_CALC_FORMULAS.ATTRIBUTE9%TYPE              := NULL,
  X_ATTRIBUTE10             IN     CN_CALC_FORMULAS.ATTRIBUTE10%TYPE             := NULL,
  X_ATTRIBUTE11             IN     CN_CALC_FORMULAS.ATTRIBUTE11%TYPE             := NULL,
  X_ATTRIBUTE12             IN     CN_CALC_FORMULAS.ATTRIBUTE12%TYPE             := NULL,
  X_ATTRIBUTE13             IN     CN_CALC_FORMULAS.ATTRIBUTE13%TYPE             := NULL,
  X_ATTRIBUTE14             IN     CN_CALC_FORMULAS.ATTRIBUTE14%TYPE             := NULL,
  X_ATTRIBUTE15             IN     CN_CALC_FORMULAS.ATTRIBUTE15%TYPE             := NULL,
  X_CREATION_DATE           IN     CN_CALC_FORMULAS.CREATION_DATE%TYPE           := SYSDATE,
  X_CREATED_BY              IN     CN_CALC_FORMULAS.CREATED_BY%TYPE              := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_DATE        IN     CN_CALC_FORMULAS.LAST_UPDATE_DATE%TYPE        := SYSDATE,
  X_LAST_UPDATED_BY         IN     CN_CALC_FORMULAS.LAST_UPDATED_BY%TYPE         := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN       IN     CN_CALC_FORMULAS.LAST_UPDATE_LOGIN%TYPE       := FND_GLOBAL.LOGIN_ID) IS

  cursor C is select calc_formula_id from CN_CALC_FORMULAS
    where CALC_FORMULA_ID = x_calc_formula_id;

  CURSOR id IS SELECT cn_calc_formulas_s.NEXTVAL FROM dual;
BEGIN
   IF (x_calc_formula_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_calc_formula_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;

  insert into CN_CALC_FORMULAS (
    CALC_FORMULA_ID,
    NAME,
    DESCRIPTION,
    FORMULA_STATUS,
    FORMULA_TYPE,
    TRX_GROUP_CODE,
    NUMBER_DIM,
    CUMULATIVE_FLAG,
    ITD_FLAG,
    SPLIT_FLAG,
    THRESHOLD_ALL_TIER_FLAG,
    MODELING_FLAG,
    PERF_MEASURE_ID,
    OUTPUT_EXP_ID,
    F_OUTPUT_EXP_ID,
    --R12 MOAC Changes--Start
    ORG_ID,
    --R12 MOAC Changes--End
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER
  ) VALUES (
    X_CALC_FORMULA_ID,
    X_NAME,
    X_DESCRIPTION,
    X_FORMULA_STATUS,
    X_FORMULA_TYPE,
    X_TRX_GROUP_CODE,
    X_NUMBER_DIM,
    X_CUMULATIVE_FLAG,
    X_ITD_FLAG,
    X_SPLIT_FLAG,
    X_THRESHOLD_ALL_TIER_FLAG,
    X_MODELING_FLAG,
    X_PERF_MEASURE_ID,
    X_OUTPUT_EXP_ID,
    X_F_OUTPUT_EXP_ID,
    --R12 MOAC Changes--Start
    X_ORG_ID,
    --R12 MOAC Changes--End
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    1);

  open c;
  fetch c into x_calc_formula_id;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_CALC_FORMULA_ID         IN     CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
  X_OBJECT_VERSION_NUMBER   IN     CN_CALC_FORMULAS.OBJECT_VERSION_NUMBER%TYPE) IS

  cursor c is
   select object_version_number
     from cn_calc_formulas
    where calc_formula_id = x_calc_formula_id
      for update of calc_formula_id nowait;
    tlinfo c%rowtype ;
BEGIN
   open  c;
   fetch c into tlinfo;
   if (c%notfound) then
      close c;
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;
   close c;

   if (tlinfo.object_version_number <> x_object_version_number) then
      fnd_message.set_name('CN', 'CN_INVALID_OBJECT_VERSION');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;

END LOCK_ROW;

procedure UPDATE_ROW (
  X_CALC_FORMULA_ID         IN     CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
  X_NAME                    IN     CN_CALC_FORMULAS.NAME%TYPE,
  X_DESCRIPTION             IN     CN_CALC_FORMULAS.DESCRIPTION%TYPE             := CN_API.G_MISS_CHAR,
  X_FORMULA_STATUS          IN     CN_CALC_FORMULAS.FORMULA_STATUS%TYPE          := 'INCOMPLETE',
  X_FORMULA_TYPE            IN     CN_CALC_FORMULAS.FORMULA_TYPE%TYPE            := CN_API.G_MISS_CHAR,
  X_TRX_GROUP_CODE          IN     CN_CALC_FORMULAS.TRX_GROUP_CODE%TYPE          := CN_API.G_MISS_CHAR,
  X_NUMBER_DIM              IN     CN_CALC_FORMULAS.NUMBER_DIM%TYPE              := CN_API.G_MISS_NUM,
  X_CUMULATIVE_FLAG         IN     CN_CALC_FORMULAS.CUMULATIVE_FLAG%TYPE         := CN_API.G_MISS_CHAR,
  X_ITD_FLAG                IN     CN_CALC_FORMULAS.ITD_FLAG%TYPE                := CN_API.G_MISS_CHAR,
  X_SPLIT_FLAG              IN     CN_CALC_FORMULAS.SPLIT_FLAG%TYPE              := CN_API.G_MISS_CHAR,
  X_THRESHOLD_ALL_TIER_FLAG IN     CN_CALC_FORMULAS.THRESHOLD_ALL_TIER_FLAG%TYPE := CN_API.G_MISS_CHAR,
  X_MODELING_FLAG           IN     CN_CALC_FORMULAS.MODELING_FLAG%TYPE           := CN_API.G_MISS_CHAR,
  X_PERF_MEASURE_ID         IN     CN_CALC_FORMULAS.PERF_MEASURE_ID%TYPE         := CN_API.G_MISS_NUM,
  X_OUTPUT_EXP_ID           IN     CN_CALC_FORMULAS.OUTPUT_EXP_ID%TYPE           := CN_API.G_MISS_NUM,
  X_F_OUTPUT_EXP_ID         IN     CN_CALC_FORMULAS.F_OUTPUT_EXP_ID%TYPE         := CN_API.G_MISS_NUM,
  X_ATTRIBUTE_CATEGORY      IN     CN_CALC_FORMULAS.ATTRIBUTE_CATEGORY%TYPE      := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE1              IN     CN_CALC_FORMULAS.ATTRIBUTE1%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE2              IN     CN_CALC_FORMULAS.ATTRIBUTE2%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE3              IN     CN_CALC_FORMULAS.ATTRIBUTE3%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE4              IN     CN_CALC_FORMULAS.ATTRIBUTE4%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE5              IN     CN_CALC_FORMULAS.ATTRIBUTE5%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE6              IN     CN_CALC_FORMULAS.ATTRIBUTE6%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE7              IN     CN_CALC_FORMULAS.ATTRIBUTE7%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE8              IN     CN_CALC_FORMULAS.ATTRIBUTE8%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE9              IN     CN_CALC_FORMULAS.ATTRIBUTE9%TYPE              := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE10             IN     CN_CALC_FORMULAS.ATTRIBUTE10%TYPE             := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE11             IN     CN_CALC_FORMULAS.ATTRIBUTE11%TYPE             := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE12             IN     CN_CALC_FORMULAS.ATTRIBUTE12%TYPE             := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE13             IN     CN_CALC_FORMULAS.ATTRIBUTE13%TYPE             := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE14             IN     CN_CALC_FORMULAS.ATTRIBUTE14%TYPE             := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE15             IN     CN_CALC_FORMULAS.ATTRIBUTE15%TYPE             := CN_API.G_MISS_CHAR,
  X_OBJECT_VERSION_NUMBER   IN OUT NOCOPY     CN_CALC_FORMULAS.OBJECT_VERSION_NUMBER%TYPE,
  X_LAST_UPDATE_DATE        IN     CN_CALC_FORMULAS.LAST_UPDATE_DATE%TYPE        := SYSDATE,
  X_LAST_UPDATED_BY         IN     CN_CALC_FORMULAS.LAST_UPDATED_BY%TYPE         := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN       IN     CN_CALC_FORMULAS.LAST_UPDATE_LOGIN%TYPE       := FND_GLOBAL.LOGIN_ID) IS
BEGIN

  X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;

  update CN_CALC_FORMULAS set
    NAME = Decode(X_NAME, fnd_api.g_miss_char, name, x_name),
    DESCRIPTION = Decode(X_DESCRIPTION, fnd_api.g_miss_char, description, x_description),
    FORMULA_STATUS = Decode(X_FORMULA_STATUS, fnd_api.g_miss_char, formula_status, x_formula_status),
    FORMULA_TYPE = Decode(X_FORMULA_TYPE, fnd_api.g_miss_char, formula_type, x_formula_type),
    TRX_GROUP_CODE = Decode(X_TRX_GROUP_CODE, fnd_api.g_miss_char, trx_group_code, x_trx_group_code),
    NUMBER_DIM = Decode(X_NUMBER_DIM, fnd_api.g_miss_char, number_dim, x_number_dim),
    CUMULATIVE_FLAG = Decode(X_CUMULATIVE_FLAG, fnd_api.g_miss_char, cumulative_flag, x_cumulative_flag),
    ITD_FLAG = Decode(X_ITD_FLAG, fnd_api.g_miss_char, itd_flag, x_itd_flag),
    SPLIT_FLAG = Decode(X_SPLIT_FLAG, fnd_api.g_miss_char, split_flag, x_split_flag),
    THRESHOLD_ALL_TIER_FLAG = Decode(X_THRESHOLD_ALL_TIER_FLAG, fnd_api.g_miss_char, threshold_all_tier_flag, x_threshold_all_tier_flag),
    MODELING_FLAG = Decode(X_MODELING_FLAG, fnd_api.g_miss_char, modeling_flag, x_modeling_flag),
    PERF_MEASURE_ID = Decode(X_PERF_MEASURE_ID, fnd_api.g_miss_char, perf_measure_id, x_perf_measure_id),
    OUTPUT_EXP_ID = Decode(X_OUTPUT_EXP_ID, fnd_api.g_miss_char, output_exp_id, x_output_exp_id),
    F_OUTPUT_EXP_ID = Decode(X_F_OUTPUT_EXP_ID, fnd_api.g_miss_char, f_output_exp_id, x_f_output_exp_id),
    ATTRIBUTE_CATEGORY = Decode(X_ATTRIBUTE_CATEGORY, fnd_api.g_miss_char, attribute_category, x_attribute_category),
    ATTRIBUTE1 = Decode(X_ATTRIBUTE1, fnd_api.g_miss_char, attribute1, x_attribute1),
    ATTRIBUTE2 = Decode(X_ATTRIBUTE2, fnd_api.g_miss_char, attribute2, x_attribute2),
    ATTRIBUTE3 = Decode(X_ATTRIBUTE3, fnd_api.g_miss_char, attribute3, x_attribute3),
    ATTRIBUTE4 = Decode(X_ATTRIBUTE4, fnd_api.g_miss_char, attribute4, x_attribute4),
    ATTRIBUTE5 = Decode(X_ATTRIBUTE5, fnd_api.g_miss_char, attribute5, x_attribute5),
    ATTRIBUTE6 = Decode(X_ATTRIBUTE6, fnd_api.g_miss_char, attribute6, x_attribute6),
    ATTRIBUTE7 = Decode(X_ATTRIBUTE7, fnd_api.g_miss_char, attribute7, x_attribute7),
    ATTRIBUTE8 = Decode(X_ATTRIBUTE8, fnd_api.g_miss_char, attribute8, x_attribute8),
    ATTRIBUTE9 = Decode(X_ATTRIBUTE9, fnd_api.g_miss_char, attribute9, x_attribute9),
    ATTRIBUTE10 = Decode(X_ATTRIBUTE10, fnd_api.g_miss_char, attribute10, x_attribute10),
    ATTRIBUTE11 = Decode(X_ATTRIBUTE11, fnd_api.g_miss_char, attribute11, x_attribute11),
    ATTRIBUTE12 = Decode(X_ATTRIBUTE12, fnd_api.g_miss_char, attribute12, x_attribute12),
    ATTRIBUTE13 = Decode(X_ATTRIBUTE13, fnd_api.g_miss_char, attribute13, x_attribute13),
    ATTRIBUTE14 = Decode(X_ATTRIBUTE14, fnd_api.g_miss_char, attribute14, x_attribute14),
    ATTRIBUTE15 = Decode(X_ATTRIBUTE15, fnd_api.g_miss_char, attribute15, x_attribute15),
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
  where CALC_FORMULA_ID = x_calc_formula_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
   X_CALC_FORMULA_ID         IN     CN_CALC_FORMULAS.CALC_FORMULA_ID%TYPE,
   X_ORG_ID                  IN     CN_CALC_FORMULAS.ORG_ID%TYPE) IS
begin
  delete from CN_CALC_FORMULAS
  where CALC_FORMULA_ID = X_CALC_FORMULA_ID
  and   ORG_ID          = X_ORG_ID;

  if (sql%notfound) then
    fnd_message.set_name('CN', 'CN_RECORD_DELETED');
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
  end if;

end DELETE_ROW;

end CN_CALC_FORMULAS_PKG;

/
