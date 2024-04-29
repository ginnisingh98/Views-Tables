--------------------------------------------------------
--  DDL for Package Body CN_RATE_SCH_DIMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RATE_SCH_DIMS_PKG" AS
/* $Header: cntschdb.pls 120.2 2005/10/05 22:25:08 kjayapau ship $ */

procedure INSERT_ROW (
  X_RATE_SCH_DIM_ID       IN OUT NOCOPY CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE,
  X_RATE_DIMENSION_ID     IN     CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE,
  X_RATE_SCHEDULE_ID      IN     CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE,
  X_RATE_DIM_SEQUENCE     IN     CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE,
  --R12 MOAC Changes--Start
  X_ORG_ID                IN     CN_RATE_SCH_DIMS.ORG_ID%TYPE, --new
  --R12 MOAC Changes--End
  X_ATTRIBUTE_CATEGORY    IN     CN_RATE_SCH_DIMS.ATTRIBUTE_CATEGORY%TYPE := NULL,
  X_ATTRIBUTE1            IN     CN_RATE_SCH_DIMS.ATTRIBUTE1%TYPE := NULL,
  X_ATTRIBUTE2            IN     CN_RATE_SCH_DIMS.ATTRIBUTE2%TYPE := NULL,
  X_ATTRIBUTE3            IN     CN_RATE_SCH_DIMS.ATTRIBUTE3%TYPE := NULL,
  X_ATTRIBUTE4            IN     CN_RATE_SCH_DIMS.ATTRIBUTE4%TYPE := NULL,
  X_ATTRIBUTE5            IN     CN_RATE_SCH_DIMS.ATTRIBUTE5%TYPE := NULL,
  X_ATTRIBUTE6            IN     CN_RATE_SCH_DIMS.ATTRIBUTE6%TYPE := NULL,
  X_ATTRIBUTE7            IN     CN_RATE_SCH_DIMS.ATTRIBUTE7%TYPE := NULL,
  X_ATTRIBUTE8            IN     CN_RATE_SCH_DIMS.ATTRIBUTE8%TYPE := NULL,
  X_ATTRIBUTE9            IN     CN_RATE_SCH_DIMS.ATTRIBUTE9%TYPE := NULL,
  X_ATTRIBUTE10           IN     CN_RATE_SCH_DIMS.ATTRIBUTE10%TYPE := NULL,
  X_ATTRIBUTE11           IN     CN_RATE_SCH_DIMS.ATTRIBUTE11%TYPE := NULL,
  X_ATTRIBUTE12           IN     CN_RATE_SCH_DIMS.ATTRIBUTE12%TYPE := NULL,
  X_ATTRIBUTE13           IN     CN_RATE_SCH_DIMS.ATTRIBUTE13%TYPE := NULL,
  X_ATTRIBUTE14           IN     CN_RATE_SCH_DIMS.ATTRIBUTE14%TYPE := NULL,
  X_ATTRIBUTE15           IN     CN_RATE_SCH_DIMS.ATTRIBUTE15%TYPE := NULL,
  X_CREATION_DATE         IN     CN_RATE_SCH_DIMS.CREATION_DATE%TYPE    := SYSDATE,
  X_CREATED_BY            IN     CN_RATE_SCH_DIMS.CREATED_BY%TYPE       := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_DATE      IN     CN_RATE_SCH_DIMS.LAST_UPDATE_DATE%TYPE := SYSDATE,
  X_LAST_UPDATED_BY       IN     CN_RATE_SCH_DIMS.LAST_UPDATED_BY%TYPE  := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN     IN     CN_RATE_SCH_DIMS.LAST_UPDATE_LOGIN%TYPE:= FND_GLOBAL.LOGIN_ID) is
  cursor C is select rate_sch_dim_id from CN_RATE_SCH_DIMS
    where RATE_SCH_DIM_ID = x_rate_sch_dim_id;

  CURSOR id IS SELECT cn_rate_sch_dims_s.NEXTVAL FROM dual;
BEGIN
   IF (x_rate_sch_dim_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_rate_sch_dim_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;

  insert into CN_RATE_SCH_DIMS (
    RATE_SCH_DIM_ID,
    RATE_DIMENSION_ID,
    RATE_SCHEDULE_ID,
    RATE_DIM_SEQUENCE,
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
    X_RATE_SCH_DIM_ID,
    X_RATE_DIMENSION_ID,
    X_RATE_SCHEDULE_ID,
    X_RATE_DIM_SEQUENCE,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_RATE_SCH_DIM_ID       IN     CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE,
  X_OBJECT_VERSION_NUMBER IN     CN_RATE_SCH_DIMS.OBJECT_VERSION_NUMBER%TYPE) IS

   cursor c is
   select object_version_number
     from CN_RATE_SCH_DIMS
    where RATE_SCH_DIM_ID = X_RATE_SCH_DIM_ID;

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
  X_RATE_SCH_DIM_ID       IN     CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE,
  X_RATE_DIMENSION_ID     IN     CN_RATE_SCH_DIMS.RATE_DIMENSION_ID%TYPE  := cn_api.g_miss_num,
  X_RATE_SCHEDULE_ID      IN     CN_RATE_SCH_DIMS.RATE_SCHEDULE_ID%TYPE   := cn_api.g_miss_num,
  X_RATE_DIM_SEQUENCE     IN     CN_RATE_SCH_DIMS.RATE_DIM_SEQUENCE%TYPE  := cn_api.g_miss_num,
  X_ATTRIBUTE_CATEGORY    IN     CN_RATE_SCH_DIMS.ATTRIBUTE_CATEGORY%TYPE := cn_api.g_miss_char,
  X_ATTRIBUTE1            IN     CN_RATE_SCH_DIMS.ATTRIBUTE1%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE2            IN     CN_RATE_SCH_DIMS.ATTRIBUTE2%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE3            IN     CN_RATE_SCH_DIMS.ATTRIBUTE3%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE4            IN     CN_RATE_SCH_DIMS.ATTRIBUTE4%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE5            IN     CN_RATE_SCH_DIMS.ATTRIBUTE5%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE6            IN     CN_RATE_SCH_DIMS.ATTRIBUTE6%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE7            IN     CN_RATE_SCH_DIMS.ATTRIBUTE7%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE8            IN     CN_RATE_SCH_DIMS.ATTRIBUTE8%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE9            IN     CN_RATE_SCH_DIMS.ATTRIBUTE9%TYPE         := cn_api.g_miss_char,
  X_ATTRIBUTE10           IN     CN_RATE_SCH_DIMS.ATTRIBUTE10%TYPE        := cn_api.g_miss_char,
  X_ATTRIBUTE11           IN     CN_RATE_SCH_DIMS.ATTRIBUTE11%TYPE        := cn_api.g_miss_char,
  X_ATTRIBUTE12           IN     CN_RATE_SCH_DIMS.ATTRIBUTE12%TYPE        := cn_api.g_miss_char,
  X_ATTRIBUTE13           IN     CN_RATE_SCH_DIMS.ATTRIBUTE13%TYPE        := cn_api.g_miss_char,
  X_ATTRIBUTE14           IN     CN_RATE_SCH_DIMS.ATTRIBUTE14%TYPE        := cn_api.g_miss_char,
  X_ATTRIBUTE15           IN     CN_RATE_SCH_DIMS.ATTRIBUTE15%TYPE        := cn_api.g_miss_char,
  X_OBJECT_VERSION_NUMBER IN OUT NOCOPY CN_RATE_SCH_DIMS.OBJECT_VERSION_NUMBER%TYPE,
  X_LAST_UPDATE_DATE      IN     CN_RATE_SCH_DIMS.LAST_UPDATE_DATE%TYPE := SYSDATE,
  X_LAST_UPDATED_BY       IN     CN_RATE_SCH_DIMS.LAST_UPDATED_BY%TYPE  := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN     IN     CN_RATE_SCH_DIMS.LAST_UPDATE_LOGIN%TYPE:= FND_GLOBAL.LOGIN_ID) is
BEGIN

X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;

  update CN_RATE_SCH_DIMS set
    RATE_DIMENSION_ID = Decode(X_RATE_DIMENSION_ID, fnd_api.g_miss_num, rate_dimension_id, x_rate_dimension_id),
    -- RATE_SCHEDULE_ID = Decode(X_RATE_SCHEDULE_ID, fnd_api.g_miss_num, rate_schedule_id, x_rate_schedule_id),
    RATE_DIM_SEQUENCE = Decode(X_RATE_DIM_SEQUENCE, fnd_api.g_miss_num, rate_dim_sequence, x_rate_dim_sequence),
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
  where RATE_SCH_DIM_ID = x_rate_sch_dim_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RATE_SCH_DIM_ID         IN     CN_RATE_SCH_DIMS.RATE_SCH_DIM_ID%TYPE) is
begin
  delete from CN_RATE_SCH_DIMS
  where RATE_SCH_DIM_ID = X_RATE_SCH_DIM_ID;

  if (sql%notfound) then
     fnd_message.set_name('CN', 'CN_RECORD_DELETED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;

end DELETE_ROW;

end CN_RATE_SCH_DIMS_PKG;

/
