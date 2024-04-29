--------------------------------------------------------
--  DDL for Package Body CN_RT_FORMULA_ASGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RT_FORMULA_ASGNS_PKG" as
/* $Header: cntrtasb.pls 120.1 2005/06/22 16:32:50 appldev ship $ */

procedure INSERT_ROW
  (X_RT_FORMULA_ASGN_ID    IN OUT NOCOPY CN_RT_FORMULA_ASGNS.RT_FORMULA_ASGN_ID%TYPE,
   X_CALC_FORMULA_ID       IN     CN_RT_FORMULA_ASGNS.CALC_FORMULA_ID%TYPE,
   X_RATE_SCHEDULE_ID      IN     CN_RT_FORMULA_ASGNS.RATE_SCHEDULE_ID%TYPE,
   X_START_DATE            IN     CN_RT_FORMULA_ASGNS.START_DATE%TYPE,
   X_END_DATE              IN     CN_RT_FORMULA_ASGNS.END_DATE%TYPE           := NULL,
   --R12 MOAC Changes--Start
   X_ORG_ID                IN     CN_RT_FORMULA_ASGNS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   X_ATTRIBUTE_CATEGORY    IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE_CATEGORY%TYPE := NULL,
   X_ATTRIBUTE1            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE1%TYPE         := NULL,
   X_ATTRIBUTE2            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE2%TYPE         := NULL,
   X_ATTRIBUTE3            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE3%TYPE         := NULL,
   X_ATTRIBUTE4            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE4%TYPE         := NULL,
   X_ATTRIBUTE5            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE5%TYPE         := NULL,
   X_ATTRIBUTE6            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE6%TYPE         := NULL,
   X_ATTRIBUTE7            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE7%TYPE         := NULL,
   X_ATTRIBUTE8            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE8%TYPE         := NULL,
   X_ATTRIBUTE9            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE9%TYPE         := NULL,
   X_ATTRIBUTE10           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE10%TYPE        := NULL,
   X_ATTRIBUTE11           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE11%TYPE        := NULL,
   X_ATTRIBUTE12           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE12%TYPE        := NULL,
   X_ATTRIBUTE13           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE13%TYPE        := NULL,
   X_ATTRIBUTE14           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE14%TYPE        := NULL,
   X_ATTRIBUTE15           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE15%TYPE        := NULL,
   X_CREATION_DATE         IN     CN_RT_FORMULA_ASGNS.CREATION_DATE%TYPE      := SYSDATE,
   X_CREATED_BY            IN     CN_RT_FORMULA_ASGNS.CREATED_BY%TYPE         := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_DATE      IN     CN_RT_FORMULA_ASGNS.LAST_UPDATE_DATE%TYPE   := SYSDATE,
   X_LAST_UPDATED_BY       IN     CN_RT_FORMULA_ASGNS.LAST_UPDATED_BY%TYPE    := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_LOGIN     IN     CN_RT_FORMULA_ASGNS.LAST_UPDATE_LOGIN%TYPE  := FND_GLOBAL.LOGIN_ID) IS

  cursor C is select rt_formula_asgn_id from CN_RT_FORMULA_ASGNS
    where RT_FORMULA_ASGN_ID = x_rt_formula_asgn_id;

  CURSOR id IS SELECT cn_rt_formula_asgns_s.NEXTVAL FROM dual;
BEGIN
   IF (x_rt_formula_asgn_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_rt_formula_asgn_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;

  insert into CN_RT_FORMULA_ASGNS (
    RT_FORMULA_ASGN_ID,
    CALC_FORMULA_ID,
    RATE_SCHEDULE_ID,
    START_DATE,
    END_DATE,
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
    X_RT_FORMULA_ASGN_ID,
    X_CALC_FORMULA_ID,
    X_RATE_SCHEDULE_ID,
    X_START_DATE,
    X_END_DATE,
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
  fetch c into x_rt_formula_asgn_id;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW
  (X_RT_FORMULA_ASGN_ID    IN     CN_RT_FORMULA_ASGNS.RT_FORMULA_ASGN_ID%TYPE,
   X_OBJECT_VERSION_NUMBER IN     CN_RT_FORMULA_ASGNS.OBJECT_VERSION_NUMBER%TYPE) IS

   cursor c is
   select object_version_number
     from cn_rt_formula_asgns
    where rt_formula_asgn_id = x_rt_formula_asgn_id
      for update of rt_formula_asgn_id nowait;
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

procedure UPDATE_ROW
  (X_RT_FORMULA_ASGN_ID    IN     CN_RT_FORMULA_ASGNS.RT_FORMULA_ASGN_ID%TYPE,
   X_CALC_FORMULA_ID       IN     CN_RT_FORMULA_ASGNS.CALC_FORMULA_ID%TYPE,
   X_RATE_SCHEDULE_ID      IN     CN_RT_FORMULA_ASGNS.RATE_SCHEDULE_ID%TYPE   := CN_API.G_MISS_NUM,
   X_START_DATE            IN     CN_RT_FORMULA_ASGNS.START_DATE%TYPE         := CN_API.G_MISS_DATE,
   X_END_DATE              IN     CN_RT_FORMULA_ASGNS.END_DATE%TYPE           := CN_API.G_MISS_DATE,
   X_ATTRIBUTE_CATEGORY    IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE_CATEGORY%TYPE := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE1            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE1%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE2            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE2%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE3            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE3%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE4            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE4%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE5            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE5%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE6            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE6%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE7            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE7%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE8            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE8%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE9            IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE9%TYPE         := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE10           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE10%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE11           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE11%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE12           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE12%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE13           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE13%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE14           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE14%TYPE        := CN_API.G_MISS_CHAR,
   X_ATTRIBUTE15           IN     CN_RT_FORMULA_ASGNS.ATTRIBUTE15%TYPE        := CN_API.G_MISS_CHAR,
   X_OBJECT_VERSION_NUMBER IN     CN_RT_FORMULA_ASGNS.OBJECT_VERSION_NUMBER%TYPE,
   X_LAST_UPDATE_DATE      IN     CN_RT_FORMULA_ASGNS.LAST_UPDATE_DATE%TYPE   := SYSDATE,
   X_LAST_UPDATED_BY       IN     CN_RT_FORMULA_ASGNS.LAST_UPDATED_BY%TYPE    := FND_GLOBAL.USER_ID,
   X_LAST_UPDATE_LOGIN     IN     CN_RT_FORMULA_ASGNS.LAST_UPDATE_LOGIN%TYPE  := FND_GLOBAL.LOGIN_ID) IS

BEGIN
  update CN_RT_FORMULA_ASGNS set
    RATE_SCHEDULE_ID = Decode(X_RATE_SCHEDULE_ID, fnd_api.g_miss_char, rate_schedule_id, x_rate_schedule_id),
    START_DATE = Decode(X_START_DATE, fnd_api.g_miss_char, start_date, x_start_date),
    END_DATE = Decode(X_END_DATE, fnd_api.g_miss_char, end_date, x_end_date),
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
  where RT_FORMULA_ASGN_ID = x_rt_formula_asgn_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW
  (X_RT_FORMULA_ASGN_ID       IN     CN_RT_FORMULA_ASGNS.RT_FORMULA_ASGN_ID%TYPE) IS
begin
   delete from CN_RT_FORMULA_ASGNS
     where RT_FORMULA_ASGN_ID = X_RT_FORMULA_ASGN_ID;

   if (sql%notfound) then
      fnd_message.set_name('CN', 'CN_RECORD_DELETED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
   end if;

end DELETE_ROW;

end CN_RT_FORMULA_ASGNS_PKG;

/
