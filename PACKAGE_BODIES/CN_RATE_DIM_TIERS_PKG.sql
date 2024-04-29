--------------------------------------------------------
--  DDL for Package Body CN_RATE_DIM_TIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RATE_DIM_TIERS_PKG" AS
/* $Header: cntrdtib.pls 120.3 2005/10/20 03:24:26 chanthon ship $ */

procedure INSERT_ROW (
  X_RATE_DIM_TIER_ID      IN OUT NOCOPY CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE,
  X_RATE_DIMENSION_ID     IN     CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
  X_DIM_UNIT_CODE         IN     CN_RATE_DIM_TIERS.DIM_UNIT_CODE%TYPE  := NULL,
  X_MINIMUM_AMOUNT        IN     CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE := NULL,
  X_MAXIMUM_AMOUNT        IN     CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE := NULL,
  X_MIN_EXP_ID            IN     CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE     := NULL,
  X_MAX_EXP_ID            IN     CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE     := NULL,
  X_STRING_VALUE          IN     CN_RATE_DIM_TIERS.STRING_VALUE%TYPE   := NULL,
  X_TIER_SEQUENCE         IN     CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE,
  -- R12 MOAC Changes--Start
  X_ORG_ID                IN     CN_RATE_DIM_TIERS.ORG_ID%TYPE, --new
  -- R12 MOAC Changes--End
  X_ATTRIBUTE_CATEGORY    IN     CN_RATE_DIM_TIERS.ATTRIBUTE_CATEGORY%TYPE := NULL,
  X_ATTRIBUTE1            IN     CN_RATE_DIM_TIERS.ATTRIBUTE1%TYPE  := NULL,
  X_ATTRIBUTE2            IN     CN_RATE_DIM_TIERS.ATTRIBUTE2%TYPE  := NULL,
  X_ATTRIBUTE3            IN     CN_RATE_DIM_TIERS.ATTRIBUTE3%TYPE  := NULL,
  X_ATTRIBUTE4            IN     CN_RATE_DIM_TIERS.ATTRIBUTE4%TYPE  := NULL,
  X_ATTRIBUTE5            IN     CN_RATE_DIM_TIERS.ATTRIBUTE5%TYPE  := NULL,
  X_ATTRIBUTE6            IN     CN_RATE_DIM_TIERS.ATTRIBUTE6%TYPE  := NULL,
  X_ATTRIBUTE7            IN     CN_RATE_DIM_TIERS.ATTRIBUTE7%TYPE  := NULL,
  X_ATTRIBUTE8            IN     CN_RATE_DIM_TIERS.ATTRIBUTE8%TYPE  := NULL,
  X_ATTRIBUTE9            IN     CN_RATE_DIM_TIERS.ATTRIBUTE9%TYPE  := NULL,
  X_ATTRIBUTE10           IN     CN_RATE_DIM_TIERS.ATTRIBUTE10%TYPE := NULL,
  X_ATTRIBUTE11           IN     CN_RATE_DIM_TIERS.ATTRIBUTE11%TYPE := NULL,
  X_ATTRIBUTE12           IN     CN_RATE_DIM_TIERS.ATTRIBUTE12%TYPE := NULL,
  X_ATTRIBUTE13           IN     CN_RATE_DIM_TIERS.ATTRIBUTE13%TYPE := NULL,
  X_ATTRIBUTE14           IN     CN_RATE_DIM_TIERS.ATTRIBUTE14%TYPE := NULL,
  X_ATTRIBUTE15           IN     CN_RATE_DIM_TIERS.ATTRIBUTE15%TYPE := NULL,
  X_CREATION_DATE         IN     CN_RATE_DIM_TIERS.CREATION_DATE%TYPE     := SYSDATE,
  X_CREATED_BY            IN     CN_RATE_DIM_TIERS.CREATED_BY%TYPE        := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_DATE      IN     CN_RATE_DIM_TIERS.LAST_UPDATE_DATE%TYPE  := SYSDATE,
  X_LAST_UPDATED_BY       IN     CN_RATE_DIM_TIERS.LAST_UPDATED_BY%TYPE   := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN     IN     CN_RATE_DIM_TIERS.LAST_UPDATE_LOGIN%TYPE := FND_GLOBAL.LOGIN_ID) IS

  cursor C is select rate_dim_tier_id from CN_RATE_DIM_TIERS
    where RATE_DIM_TIER_ID = x_rate_dim_tier_id;

  CURSOR id IS SELECT cn_rate_dim_tiers_s.NEXTVAL FROM dual;
BEGIN
   IF (x_rate_dim_tier_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_rate_dim_tier_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;

  insert into CN_RATE_DIM_TIERS (
    RATE_DIM_TIER_ID,
    RATE_DIMENSION_ID,
    DIM_UNIT_CODE,
    MINIMUM_AMOUNT,
    MAXIMUM_AMOUNT,
    MIN_EXP_ID,
    MAX_EXP_ID,
    STRING_VALUE,
    TIER_SEQUENCE,
    -- R12 MOAC Changes--Start
    ORG_ID,
    -- R12 MOAC Changes--End
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
    X_RATE_DIM_TIER_ID,
    X_RATE_DIMENSION_ID,
    X_DIM_UNIT_CODE,
    X_MINIMUM_AMOUNT,
    X_MAXIMUM_AMOUNT,
    X_MIN_EXP_ID,
    X_MAX_EXP_ID,
    X_STRING_VALUE,
    X_TIER_SEQUENCE,
    -- R12 MOAC Changes--Start
    X_ORG_ID,
    -- R12 MOAC Changes--End
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
  fetch c into x_rate_dim_tier_id;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_RATE_DIM_TIER_ID      IN     CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE,
  X_OBJECT_VERSION_NUMBER IN     CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE) IS

   cursor c is
   select object_version_number
     from CN_RATE_DIM_TIERS
    where RATE_DIM_TIER_ID = X_RATE_DIM_TIER_ID
      for update of RATE_DIM_TIER_ID nowait;

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
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;

END LOCK_ROW;

procedure UPDATE_ROW (
  X_RATE_DIM_TIER_ID      IN     CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE,
  X_RATE_DIMENSION_ID     IN     CN_RATE_DIM_TIERS.RATE_DIMENSION_ID%TYPE,
  X_DIM_UNIT_CODE         IN     CN_RATE_DIM_TIERS.DIM_UNIT_CODE%TYPE  := FND_API.G_MISS_CHAR,
  X_MINIMUM_AMOUNT        IN     CN_RATE_DIM_TIERS.MINIMUM_AMOUNT%TYPE := FND_API.G_MISS_NUM,
  X_MAXIMUM_AMOUNT        IN     CN_RATE_DIM_TIERS.MAXIMUM_AMOUNT%TYPE := FND_API.G_MISS_NUM,
  X_MIN_EXP_ID            IN     CN_RATE_DIM_TIERS.MIN_EXP_ID%TYPE     := FND_API.G_MISS_NUM,
  X_MAX_EXP_ID            IN     CN_RATE_DIM_TIERS.MAX_EXP_ID%TYPE     := FND_API.G_MISS_NUM,
  X_STRING_VALUE          IN     CN_RATE_DIM_TIERS.STRING_VALUE%TYPE   := FND_API.G_MISS_CHAR,
  X_TIER_SEQUENCE         IN     CN_RATE_DIM_TIERS.TIER_SEQUENCE%TYPE  := FND_API.G_MISS_NUM,
  X_ATTRIBUTE_CATEGORY    IN     CN_RATE_DIM_TIERS.ATTRIBUTE_CATEGORY%TYPE := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE1            IN     CN_RATE_DIM_TIERS.ATTRIBUTE1%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE2            IN     CN_RATE_DIM_TIERS.ATTRIBUTE2%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE3            IN     CN_RATE_DIM_TIERS.ATTRIBUTE3%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE4            IN     CN_RATE_DIM_TIERS.ATTRIBUTE4%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE5            IN     CN_RATE_DIM_TIERS.ATTRIBUTE5%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE6            IN     CN_RATE_DIM_TIERS.ATTRIBUTE6%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE7            IN     CN_RATE_DIM_TIERS.ATTRIBUTE7%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE8            IN     CN_RATE_DIM_TIERS.ATTRIBUTE8%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE9            IN     CN_RATE_DIM_TIERS.ATTRIBUTE9%TYPE  := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE10           IN     CN_RATE_DIM_TIERS.ATTRIBUTE10%TYPE := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE11           IN     CN_RATE_DIM_TIERS.ATTRIBUTE11%TYPE := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE12           IN     CN_RATE_DIM_TIERS.ATTRIBUTE12%TYPE := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE13           IN     CN_RATE_DIM_TIERS.ATTRIBUTE13%TYPE := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE14           IN     CN_RATE_DIM_TIERS.ATTRIBUTE14%TYPE := FND_API.G_MISS_CHAR,
  X_ATTRIBUTE15           IN     CN_RATE_DIM_TIERS.ATTRIBUTE15%TYPE := FND_API.G_MISS_CHAR,
  X_LAST_UPDATE_DATE      IN     CN_RATE_DIM_TIERS.LAST_UPDATE_DATE%TYPE  := SYSDATE,
  X_LAST_UPDATED_BY       IN     CN_RATE_DIM_TIERS.LAST_UPDATED_BY%TYPE   := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN     IN     CN_RATE_DIM_TIERS.LAST_UPDATE_LOGIN%TYPE := FND_GLOBAL.LOGIN_ID,
  X_OBJECT_VERSION_NUMBER IN OUT NOCOPY CN_RATE_DIM_TIERS.OBJECT_VERSION_NUMBER%TYPE) IS

BEGIN
  X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;
  update CN_RATE_DIM_TIERS set
    DIM_UNIT_CODE = Decode(X_DIM_UNIT_CODE, fnd_api.g_miss_char, dim_unit_code, x_dim_unit_code),
    MINIMUM_AMOUNT = Decode(X_MINIMUM_AMOUNT, fnd_api.g_miss_num, minimum_amount, x_minimum_amount),
    MAXIMUM_AMOUNT = Decode(X_MAXIMUM_AMOUNT, fnd_api.g_miss_num, maximum_amount, x_maximum_amount),
    MIN_EXP_ID = Decode(X_MIN_EXP_ID, fnd_api.g_miss_num, min_exp_id, x_min_exp_id),
    MAX_EXP_ID = Decode(X_MAX_EXP_ID, fnd_api.g_miss_num, max_exp_id, x_max_exp_id),
    STRING_VALUE = Decode(X_STRING_VALUE, fnd_api.g_miss_char, string_value, x_string_value),
    TIER_SEQUENCE = Decode(X_TIER_SEQUENCE, fnd_api.g_miss_num, tier_sequence, x_tier_sequence),
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
  where RATE_DIM_TIER_ID = x_rate_dim_tier_id;

  if (sql%notfound) then
     fnd_message.set_name('CN', 'CN_RECORD_DELETED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
   X_RATE_DIM_TIER_ID      IN     CN_RATE_DIM_TIERS.RATE_DIM_TIER_ID%TYPE) is
begin
  delete from CN_RATE_DIM_TIERS
  where RATE_DIM_TIER_ID = X_RATE_DIM_TIER_ID;

  if (sql%notfound) then
     fnd_message.set_name('CN', 'CN_RECORD_DELETED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;

end DELETE_ROW;

end CN_RATE_DIM_TIERS_PKG;

/
