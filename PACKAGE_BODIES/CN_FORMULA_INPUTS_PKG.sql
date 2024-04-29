--------------------------------------------------------
--  DDL for Package Body CN_FORMULA_INPUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_FORMULA_INPUTS_PKG" as
/* $Header: cntfinpb.pls 120.1 2005/06/22 16:38:51 appldev ship $ */

procedure INSERT_ROW
  (X_FORMULA_INPUT_ID      IN OUT NOCOPY CN_FORMULA_INPUTS.FORMULA_INPUT_ID%TYPE,
   X_CALC_FORMULA_ID       IN     CN_FORMULA_INPUTS.CALC_FORMULA_ID%TYPE,
   X_CALC_SQL_EXP_ID       IN     CN_FORMULA_INPUTS.CALC_SQL_EXP_ID%TYPE,
   X_F_CALC_SQL_EXP_ID     IN     CN_FORMULA_INPUTS.F_CALC_SQL_EXP_ID%TYPE  := NULL,
   X_RATE_DIM_SEQUENCE     IN     CN_FORMULA_INPUTS.RATE_DIM_SEQUENCE%TYPE,
   X_CUMULATIVE_FLAG       IN     CN_FORMULA_INPUTS.CUMULATIVE_FLAG%TYPE,
   X_SPLIT_FLAG            IN     CN_FORMULA_INPUTS.SPLIT_FLAG%TYPE,
   --R12 MOAC Changes--Start
   X_ORG_ID                IN     CN_FORMULA_INPUTS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   X_ATTRIBUTE_CATEGORY    IN     CN_FORMULA_INPUTS.ATTRIBUTE_CATEGORY%TYPE := NULL,
   X_ATTRIBUTE1            IN     CN_FORMULA_INPUTS.ATTRIBUTE1%TYPE         := NULL,
   X_ATTRIBUTE2            IN     CN_FORMULA_INPUTS.ATTRIBUTE2%TYPE         := NULL,
   X_ATTRIBUTE3            IN     CN_FORMULA_INPUTS.ATTRIBUTE3%TYPE         := NULL,
   X_ATTRIBUTE4            IN     CN_FORMULA_INPUTS.ATTRIBUTE4%TYPE         := NULL,
   X_ATTRIBUTE5            IN     CN_FORMULA_INPUTS.ATTRIBUTE5%TYPE         := NULL,
   X_ATTRIBUTE6            IN     CN_FORMULA_INPUTS.ATTRIBUTE6%TYPE         := NULL,
   X_ATTRIBUTE7            IN     CN_FORMULA_INPUTS.ATTRIBUTE7%TYPE         := NULL,
   X_ATTRIBUTE8            IN     CN_FORMULA_INPUTS.ATTRIBUTE8%TYPE         := NULL,
   X_ATTRIBUTE9            IN     CN_FORMULA_INPUTS.ATTRIBUTE9%TYPE         := NULL,
   X_ATTRIBUTE10           IN     CN_FORMULA_INPUTS.ATTRIBUTE10%TYPE        := NULL,
   X_ATTRIBUTE11           IN     CN_FORMULA_INPUTS.ATTRIBUTE11%TYPE        := NULL,
   X_ATTRIBUTE12           IN     CN_FORMULA_INPUTS.ATTRIBUTE12%TYPE        := NULL,
   X_ATTRIBUTE13           IN     CN_FORMULA_INPUTS.ATTRIBUTE13%TYPE        := NULL,
   X_ATTRIBUTE14           IN     CN_FORMULA_INPUTS.ATTRIBUTE14%TYPE        := NULL,
   X_ATTRIBUTE15           IN     CN_FORMULA_INPUTS.ATTRIBUTE15%TYPE        := NULL,
   X_CREATION_DATE         IN     CN_FORMULA_INPUTS.CREATION_DATE%TYPE      := SYSDATE,
   X_CREATED_BY            IN     CN_FORMULA_INPUTS.CREATED_BY%TYPE         := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_DATE      IN     CN_FORMULA_INPUTS.LAST_UPDATE_DATE%TYPE   := SYSDATE,
   X_LAST_UPDATED_BY       IN     CN_FORMULA_INPUTS.LAST_UPDATED_BY%TYPE    := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_LOGIN     IN     CN_FORMULA_INPUTS.LAST_UPDATE_LOGIN%TYPE  := FND_GLOBAL.LOGIN_ID) IS

  cursor C is select formula_input_id from CN_FORMULA_INPUTS
    where FORMULA_INPUT_ID = x_formula_input_id;

  CURSOR id IS SELECT cn_formula_inputs_s.NEXTVAL FROM dual;
BEGIN
   IF (x_formula_input_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_formula_input_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;
  insert into CN_FORMULA_INPUTS
   (FORMULA_INPUT_ID,
    CALC_FORMULA_ID,
    CALC_SQL_EXP_ID,
    F_CALC_SQL_EXP_ID,
    RATE_DIM_SEQUENCE,
    CUMULATIVE_FLAG,
    SPLIT_FLAG,
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
    X_FORMULA_INPUT_ID,
    X_CALC_FORMULA_ID,
    X_CALC_SQL_EXP_ID,
    X_F_CALC_SQL_EXP_ID,
    X_RATE_DIM_SEQUENCE,
    X_CUMULATIVE_FLAG,
    X_SPLIT_FLAG,
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
    0);

  open c;
  fetch c into x_formula_input_id;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW
  (X_FORMULA_INPUT_ID      IN     CN_FORMULA_INPUTS.FORMULA_INPUT_ID%TYPE,
   X_OBJECT_VERSION_NUMBER IN     CN_FORMULA_INPUTS.OBJECT_VERSION_NUMBER%TYPE) IS

   cursor c is
   select object_version_number
     from cn_formula_inputs
    where formula_input_id = x_formula_input_id
      for update of formula_input_id nowait;
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
end LOCK_ROW;

procedure UPDATE_ROW
  (X_FORMULA_INPUT_ID      IN     CN_FORMULA_INPUTS.FORMULA_INPUT_ID%TYPE,
   X_CALC_FORMULA_ID       IN     CN_FORMULA_INPUTS.CALC_FORMULA_ID%TYPE,
   X_CALC_SQL_EXP_ID       IN     CN_FORMULA_INPUTS.CALC_SQL_EXP_ID%TYPE,
   X_F_CALC_SQL_EXP_ID     IN     CN_FORMULA_INPUTS.F_CALC_SQL_EXP_ID%TYPE  := CN_API.G_MISS_NUM,
   X_RATE_DIM_SEQUENCE     IN     CN_FORMULA_INPUTS.RATE_DIM_SEQUENCE%TYPE,
   X_CUMULATIVE_FLAG       IN     CN_FORMULA_INPUTS.CUMULATIVE_FLAG%TYPE,
   X_SPLIT_FLAG            IN     CN_FORMULA_INPUTS.SPLIT_FLAG%TYPE,
   X_ATTRIBUTE_CATEGORY    IN     CN_FORMULA_INPUTS.ATTRIBUTE_CATEGORY%TYPE := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE1            IN     CN_FORMULA_INPUTS.ATTRIBUTE1%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE2            IN     CN_FORMULA_INPUTS.ATTRIBUTE2%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE3            IN     CN_FORMULA_INPUTS.ATTRIBUTE3%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE4            IN     CN_FORMULA_INPUTS.ATTRIBUTE4%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE5            IN     CN_FORMULA_INPUTS.ATTRIBUTE5%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE6            IN     CN_FORMULA_INPUTS.ATTRIBUTE6%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE7            IN     CN_FORMULA_INPUTS.ATTRIBUTE7%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE8            IN     CN_FORMULA_INPUTS.ATTRIBUTE8%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE9            IN     CN_FORMULA_INPUTS.ATTRIBUTE9%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE10           IN     CN_FORMULA_INPUTS.ATTRIBUTE10%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE11           IN     CN_FORMULA_INPUTS.ATTRIBUTE11%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE12           IN     CN_FORMULA_INPUTS.ATTRIBUTE12%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE13           IN     CN_FORMULA_INPUTS.ATTRIBUTE13%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE14           IN     CN_FORMULA_INPUTS.ATTRIBUTE14%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE15           IN     CN_FORMULA_INPUTS.ATTRIBUTE15%TYPE        := CN_API.G_MISS_CHAR,
   X_OBJECT_VERSION_NUMBER IN     CN_FORMULA_INPUTS.OBJECT_VERSION_NUMBER%TYPE,
   X_LAST_UPDATE_DATE      IN     CN_FORMULA_INPUTS.LAST_UPDATE_DATE%TYPE   := SYSDATE,
   X_LAST_UPDATED_BY       IN     CN_FORMULA_INPUTS.LAST_UPDATED_BY%TYPE    := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_LOGIN     IN     CN_FORMULA_INPUTS.LAST_UPDATE_LOGIN%TYPE  := FND_GLOBAL.LOGIN_ID) IS

BEGIN
  update CN_FORMULA_INPUTS set
    CALC_SQL_EXP_ID = Decode(X_CALC_SQL_EXP_ID, fnd_api.g_miss_num, calc_sql_exp_id, x_calc_sql_exp_id),
    F_CALC_SQL_EXP_ID = Decode(X_F_CALC_SQL_EXP_ID, fnd_api.g_miss_num, f_calc_sql_exp_id, x_f_calc_sql_exp_id),
    RATE_DIM_SEQUENCE = Decode(X_RATE_DIM_SEQUENCE, fnd_api.g_miss_num, rate_dim_sequence, x_rate_dim_sequence),
    CUMULATIVE_FLAG = Decode(X_CUMULATIVE_FLAG, fnd_api.g_miss_char, CUMULATIVE_FLAG, X_CUMULATIVE_FLAG),
    SPLIT_FLAG = Decode(X_SPLIT_FLAG, fnd_api.g_miss_char, SPLIT_FLAG, X_SPLIT_FLAG),
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
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER + 1
  where FORMULA_INPUT_ID = x_formula_input_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW
  (X_FORMULA_INPUT_ID      IN     CN_FORMULA_INPUTS.FORMULA_INPUT_ID%TYPE) IS
begin
  delete from CN_FORMULA_INPUTS
  where FORMULA_INPUT_ID = X_FORMULA_INPUT_ID;

  if (sql%notfound) then
    fnd_message.set_name('CN', 'CN_RECORD_DELETED');
    fnd_msg_pub.add;
    raise fnd_api.g_exc_error;
  end if;

end DELETE_ROW;

end CN_FORMULA_INPUTS_PKG;

/
