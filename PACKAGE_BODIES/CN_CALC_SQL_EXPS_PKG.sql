--------------------------------------------------------
--  DDL for Package Body CN_CALC_SQL_EXPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_SQL_EXPS_PKG" AS
/* $Header: cntcexpb.pls 120.2 2005/07/14 22:33:54 kjayapau ship $ */

procedure INSERT_ROW (
  X_ORG_ID		  IN 	 CN_CALC_SQl_EXPS.ORG_ID%TYPE,
  X_CALC_SQL_EXP_ID       IN OUT NOCOPY CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
  X_NAME                  IN     CN_CALC_SQL_EXPS.NAME%TYPE,
  X_DESCRIPTION           IN     CN_CALC_SQL_EXPS.DESCRIPTION%TYPE           := NULL,
  X_STATUS                IN     CN_CALC_SQL_EXPS.STATUS%TYPE                := NULL,
  X_EXP_TYPE_CODE         IN     CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE         := NULL,
  X_EXPRESSION_DISP       IN     VARCHAR2                                    := NULL, -- CLOBs
  X_SQL_SELECT            IN     VARCHAR2                                    := NULL,
  X_SQL_FROM              IN     VARCHAR2                                    := NULL,
  X_PIPED_SQL_SELECT      IN     VARCHAR2                                    := NULL,
  X_PIPED_SQL_FROM        IN     VARCHAR2                                    := NULL,
  X_PIPED_EXPRESSION_DISP IN     VARCHAR2                                    := NULL,
  X_ATTRIBUTE_CATEGORY    IN     CN_CALC_SQL_EXPS.ATTRIBUTE_CATEGORY%TYPE    := NULL,
  X_ATTRIBUTE1            IN     CN_CALC_SQL_EXPS.ATTRIBUTE1%TYPE            := NULL,
  X_ATTRIBUTE2            IN     CN_CALC_SQL_EXPS.ATTRIBUTE2%TYPE            := NULL,
  X_ATTRIBUTE3            IN     CN_CALC_SQL_EXPS.ATTRIBUTE3%TYPE            := NULL,
  X_ATTRIBUTE4            IN     CN_CALC_SQL_EXPS.ATTRIBUTE4%TYPE            := NULL,
  X_ATTRIBUTE5            IN     CN_CALC_SQL_EXPS.ATTRIBUTE5%TYPE            := NULL,
  X_ATTRIBUTE6            IN     CN_CALC_SQL_EXPS.ATTRIBUTE6%TYPE            := NULL,
  X_ATTRIBUTE7            IN     CN_CALC_SQL_EXPS.ATTRIBUTE7%TYPE            := NULL,
  X_ATTRIBUTE8            IN     CN_CALC_SQL_EXPS.ATTRIBUTE8%TYPE            := NULL,
  X_ATTRIBUTE9            IN     CN_CALC_SQL_EXPS.ATTRIBUTE9%TYPE            := NULL,
  X_ATTRIBUTE10           IN     CN_CALC_SQL_EXPS.ATTRIBUTE10%TYPE           := NULL,
  X_ATTRIBUTE11           IN     CN_CALC_SQL_EXPS.ATTRIBUTE11%TYPE           := NULL,
  X_ATTRIBUTE12           IN     CN_CALC_SQL_EXPS.ATTRIBUTE12%TYPE           := NULL,
  X_ATTRIBUTE13           IN     CN_CALC_SQL_EXPS.ATTRIBUTE13%TYPE           := NULL,
  X_ATTRIBUTE14           IN     CN_CALC_SQL_EXPS.ATTRIBUTE14%TYPE           := NULL,
  X_ATTRIBUTE15           IN     CN_CALC_SQL_EXPS.ATTRIBUTE15%TYPE           := NULL,
  X_CREATION_DATE         IN     CN_CALC_SQL_EXPS.CREATION_DATE%TYPE         := SYSDATE,
  X_CREATED_BY            IN     CN_CALC_SQL_EXPS.CREATED_BY%TYPE            := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_DATE      IN     CN_CALC_SQL_EXPS.LAST_UPDATE_DATE%TYPE      := SYSDATE,
  X_LAST_UPDATED_BY       IN     CN_CALC_SQL_EXPS.LAST_UPDATED_BY%TYPE       := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN     IN     CN_CALC_SQL_EXPS.LAST_UPDATE_LOGIN%TYPE     := FND_GLOBAL.LOGIN_ID,
  X_OBJECT_VERSION_NUMBER OUT NOCOPY CN_CALC_SQL_EXPS.OBJECT_VERSION_NUMBER%TYPE
) is
  cursor C is select calc_sql_exp_id from CN_CALC_SQL_EXPS
    where CALC_SQL_EXP_ID = x_calc_sql_exp_id;
  CURSOR id IS SELECT cn_calc_sql_exps_s.NEXTVAL FROM dual;

  x_return_status  VARCHAR2(4000);
  l_note_msg	   VARCHAR2(4000);
  x_msg_data	   VARCHAR2(4000);
  x_msg_count	   NUMBER;
  x_note_id	   NUMBER;


BEGIN
   IF (x_calc_sql_exp_id IS NULL) THEN
      OPEN id;
      FETCH id INTO x_calc_sql_exp_id;
      IF (id%notfound) THEN
	 CLOSE id;
	 RAISE no_data_found;
      END IF;
      CLOSE id;
   END IF;

  X_OBJECT_VERSION_NUMBER := 0;

  insert into CN_CALC_SQL_EXPS (
    ORG_ID,
    CALC_SQL_EXP_ID,
    NAME,
    DESCRIPTION,
    STATUS,
    EXP_TYPE_CODE,
    EXPRESSION_DISP,
    SQL_SELECT,
    SQL_FROM,
    PIPED_SQL_SELECT,
    PIPED_SQL_FROM,
    PIPED_EXPRESSION_DISP,
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
    X_ORG_ID,
    X_CALC_SQL_EXP_ID,
    X_NAME,
    X_DESCRIPTION,
    X_STATUS,
    X_EXP_TYPE_CODE,
    X_EXPRESSION_DISP,
    X_SQL_SELECT,
    X_SQL_FROM,
    X_PIPED_SQL_SELECT,
    X_PIPED_SQL_FROM,
    X_PIPED_EXPRESSION_DISP,
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
    X_OBJECT_VERSION_NUMBER);

FND_MESSAGE.SET_NAME('CN', 'CN_EXPRESSION_CREATE');
FND_MESSAGE.SET_TOKEN('EXPRESSION_NAME', X_NAME);
l_note_msg := FND_MESSAGE.GET;

jtf_notes_pub.create_note
     ( p_api_version           => 1.0,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_source_object_id      => X_CALC_SQL_EXP_ID,
       p_source_object_code    => 'CN_CALC_SQL_EXPS',
       p_notes                 => l_note_msg,
       p_notes_detail          => l_note_msg,
       p_note_type             => 'CN_SYSGEN',
       x_jtf_note_id           => x_note_id
       );

end INSERT_ROW;

procedure LOCK_ROW (
  P_CALC_SQL_EXP_ID       IN     CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
  P_OBJECT_VERSION_NUMBER IN     CN_CALC_SQL_EXPS.OBJECT_VERSION_NUMBER%TYPE) IS

   cursor c is
   select object_version_number
     from cn_calc_sql_exps
    where calc_sql_exp_id = p_calc_sql_exp_id
      for update of CALC_SQL_EXP_ID nowait;

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

   if (tlinfo.object_version_number <> p_object_version_number) then
      fnd_message.set_name('CN', 'CN_RECORD_CHANGED');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_unexpected_error;
   end if;

END LOCK_ROW;

procedure UPDATE_ROW (
  X_ORG_ID		  IN 	 CN_CALC_SQl_EXPS.ORG_ID%TYPE,
  X_CALC_SQL_EXP_ID       IN     CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE,
  X_NAME                  IN     CN_CALC_SQL_EXPS.NAME%TYPE,
  X_DESCRIPTION           IN     CN_CALC_SQL_EXPS.DESCRIPTION%TYPE           := CN_API.G_MISS_CHAR,
  X_STATUS                IN     CN_CALC_SQL_EXPS.STATUS%TYPE                := CN_API.G_MISS_CHAR,
  X_EXP_TYPE_CODE         IN     CN_CALC_SQL_EXPS.EXP_TYPE_CODE%TYPE         := CN_API.G_MISS_CHAR,
  X_EXPRESSION_DISP       IN     VARCHAR2                                    := CN_API.G_MISS_CHAR,
  X_SQL_SELECT            IN     VARCHAR2                                    := CN_API.G_MISS_CHAR,
  X_SQL_FROM              IN     VARCHAR2                                    := CN_API.G_MISS_CHAR,
  X_PIPED_SQL_SELECT      IN     VARCHAR2                                    := CN_API.G_MISS_CHAR,
  X_PIPED_SQL_FROM        IN     VARCHAR2                                    := CN_API.G_MISS_CHAR,
  X_PIPED_EXPRESSION_DISP IN     VARCHAR2                                    := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE_CATEGORY    IN     CN_CALC_SQL_EXPS.ATTRIBUTE_CATEGORY%TYPE    := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE1            IN     CN_CALC_SQL_EXPS.ATTRIBUTE1%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE2            IN     CN_CALC_SQL_EXPS.ATTRIBUTE2%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE3            IN     CN_CALC_SQL_EXPS.ATTRIBUTE3%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE4            IN     CN_CALC_SQL_EXPS.ATTRIBUTE4%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE5            IN     CN_CALC_SQL_EXPS.ATTRIBUTE5%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE6            IN     CN_CALC_SQL_EXPS.ATTRIBUTE6%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE7            IN     CN_CALC_SQL_EXPS.ATTRIBUTE7%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE8            IN     CN_CALC_SQL_EXPS.ATTRIBUTE8%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE9            IN     CN_CALC_SQL_EXPS.ATTRIBUTE9%TYPE            := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE10           IN     CN_CALC_SQL_EXPS.ATTRIBUTE10%TYPE           := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE11           IN     CN_CALC_SQL_EXPS.ATTRIBUTE11%TYPE           := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE12           IN     CN_CALC_SQL_EXPS.ATTRIBUTE12%TYPE           := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE13           IN     CN_CALC_SQL_EXPS.ATTRIBUTE13%TYPE           := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE14           IN     CN_CALC_SQL_EXPS.ATTRIBUTE14%TYPE           := CN_API.G_MISS_CHAR,
  X_ATTRIBUTE15           IN     CN_CALC_SQL_EXPS.ATTRIBUTE15%TYPE           := CN_API.G_MISS_CHAR,
  X_LAST_UPDATE_DATE      IN     CN_CALC_SQL_EXPS.LAST_UPDATE_DATE%TYPE      := SYSDATE,
  X_LAST_UPDATED_BY       IN     CN_CALC_SQL_EXPS.LAST_UPDATED_BY%TYPE       := FND_GLOBAL.USER_ID,
  X_LAST_UPDATE_LOGIN     IN     CN_CALC_SQL_EXPS.LAST_UPDATE_LOGIN%TYPE     := FND_GLOBAL.LOGIN_ID,
  X_OBJECT_VERSION_NUMBER IN OUT NOCOPY CN_CALC_SQL_EXPS.OBJECT_VERSION_NUMBER%TYPE) IS

BEGIN

  X_OBJECT_VERSION_NUMBER := X_OBJECT_VERSION_NUMBER + 1;

  update CN_CALC_SQL_EXPS set
    NAME = Decode(X_NAME, fnd_api.g_miss_char, name, x_name),
    DESCRIPTION = Decode(X_DESCRIPTION, fnd_api.g_miss_char, description, x_description),
    STATUS = Decode(X_STATUS, fnd_api.g_miss_char, status, x_status),
    EXP_TYPE_CODE = Decode(X_EXP_TYPE_CODE, fnd_api.g_miss_char, exp_type_code, x_exp_type_code),
    EXPRESSION_DISP = Decode(X_EXPRESSION_DISP, fnd_api.g_miss_char, dbms_lob.substr(expression_disp), x_expression_disp),
    SQL_SELECT = Decode(X_SQL_SELECT, fnd_api.g_miss_char, dbms_lob.substr(sql_select), x_sql_select),
    SQL_FROM = Decode(X_SQL_FROM, fnd_api.g_miss_char, dbms_lob.substr(sql_from), x_sql_from),
    PIPED_SQL_SELECT = Decode(X_PIPED_SQL_SELECT, fnd_api.g_miss_char, dbms_lob.substr(piped_sql_select), x_piped_sql_select),
    PIPED_SQL_FROM = Decode(X_PIPED_SQL_FROM, fnd_api.g_miss_char, dbms_lob.substr(piped_sql_from), x_piped_sql_from),
    PIPED_EXPRESSION_DISP = Decode(X_PIPED_EXPRESSION_DISP, fnd_api.g_miss_char, dbms_lob.substr(piped_expression_disp), x_piped_expression_disp),
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
  where CALC_SQL_EXP_ID = x_calc_sql_exp_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CALC_SQL_EXP_ID       IN     CN_CALC_SQL_EXPS.CALC_SQL_EXP_ID%TYPE) is
begin
  delete from CN_CALC_SQL_EXPS
  where CALC_SQL_EXP_ID = X_CALC_SQL_EXP_ID;

  if (sql%notfound) then
     fnd_message.set_name('CN', 'CN_RECORD_DELETED');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;

end DELETE_ROW;

end CN_CALC_SQL_EXPS_PKG;

/
