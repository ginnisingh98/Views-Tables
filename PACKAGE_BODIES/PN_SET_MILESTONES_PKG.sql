--------------------------------------------------------
--  DDL for Package Body PN_SET_MILESTONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_SET_MILESTONES_PKG" as
  -- $Header: PNTSTMLB.pls 120.1 2005/08/05 06:24:44 appldev ship $

procedure INSERT_ROW (
                       X_ROWID                in out NOCOPY VARCHAR2,
                       X_MILESTONES_SET_ID    in out NOCOPY NUMBER,
                       X_SET_ID               in NUMBER,
                       X_USER_ID              in NUMBER,
                       X_NOTIFICATION_DATE    in DATE,
                       X_LEAD_DAYS            in NUMBER,
                       X_ATTRIBUTE_CATEGORY   in VARCHAR2,
                       X_ATTRIBUTE1           in VARCHAR2,
                       X_ATTRIBUTE2           in VARCHAR2,
                       X_ATTRIBUTE3           in VARCHAR2,
                       X_ATTRIBUTE4           in VARCHAR2,
                       X_ATTRIBUTE5           in VARCHAR2,
                       X_ATTRIBUTE6           in VARCHAR2,
                       X_ATTRIBUTE7           in VARCHAR2,
                       X_ATTRIBUTE8           in VARCHAR2,
                       X_ATTRIBUTE9           in VARCHAR2,
                       X_ATTRIBUTE10          in VARCHAR2,
                       X_ATTRIBUTE11          in VARCHAR2,
                       X_ATTRIBUTE12          in VARCHAR2,
                       X_ATTRIBUTE13          in VARCHAR2,
                       X_ATTRIBUTE14          in VARCHAR2,
                       X_ATTRIBUTE15          in VARCHAR2,
                       X_MILESTONE_TYPE_CODE  in VARCHAR2,
                       X_FREQUENCY            in NUMBER,
                       X_CREATION_DATE        in DATE,
                       X_CREATED_BY           in NUMBER,
                       X_LAST_UPDATE_DATE     in DATE,
                       X_LAST_UPDATED_BY      in NUMBER,
                       X_LAST_UPDATE_LOGIN    in NUMBER
                    )  IS
  cursor C is
  select ROWID
  from   PN_SET_MILESTONES
  where MILESTONES_SET_ID = X_MILESTONES_SET_ID ;

begin

  if X_MILESTONES_SET_ID is null then

    select PN_SET_MILESTONES_S.nextval
    into   X_MILESTONES_SET_ID
    from   dual;

  end if;

  insert into PN_SET_MILESTONES (
                                  MILESTONES_SET_ID,
                                  SET_ID,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_LOGIN,
                                  MILESTONE_TYPE_CODE,
                                  USER_ID,
                                  NOTIFICATION_DATE,
                                  LEAD_DAYS,
                                  FREQUENCY,
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
                                  ATTRIBUTE15
                                )
  values                        (
                                  X_MILESTONES_SET_ID,
                                  X_SET_ID,
                                  X_LAST_UPDATE_DATE,
                                  X_LAST_UPDATED_BY,
                                  X_CREATION_DATE,
                                  X_CREATED_BY,
                                  X_LAST_UPDATE_LOGIN,
                                  X_MILESTONE_TYPE_CODE,
                                  X_USER_ID,
                                  X_NOTIFICATION_DATE,
                                  X_LEAD_DAYS,
                                  X_FREQUENCY,
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
                                  X_ATTRIBUTE15
                                );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
                       X_MILESTONES_SET_ID    in NUMBER,
                       X_SET_ID               in NUMBER,
                       X_USER_ID              in NUMBER,
                       X_NOTIFICATION_DATE    in DATE,
                       X_LEAD_DAYS            in NUMBER,
                       X_ATTRIBUTE_CATEGORY   in VARCHAR2,
                       X_ATTRIBUTE1           in VARCHAR2,
                       X_ATTRIBUTE2           in VARCHAR2,
                       X_ATTRIBUTE3           in VARCHAR2,
                       X_ATTRIBUTE4           in VARCHAR2,
                       X_ATTRIBUTE5           in VARCHAR2,
                       X_ATTRIBUTE6           in VARCHAR2,
                       X_ATTRIBUTE7           in VARCHAR2,
                       X_ATTRIBUTE8           in VARCHAR2,
                       X_ATTRIBUTE9           in VARCHAR2,
                       X_ATTRIBUTE10          in VARCHAR2,
                       X_ATTRIBUTE11          in VARCHAR2,
                       X_ATTRIBUTE12          in VARCHAR2,
                       X_ATTRIBUTE13          in VARCHAR2,
                       X_ATTRIBUTE14          in VARCHAR2,
                       X_ATTRIBUTE15          in VARCHAR2,
                       X_MILESTONE_TYPE_CODE  in VARCHAR2,
                       X_FREQUENCY            in NUMBER
                     ) IS
  cursor c1 is
  select *
  from   PN_SET_MILESTONES
  where  MILESTONES_SET_ID = X_MILESTONES_SET_ID
  for    update of MILESTONES_SET_ID nowait;

  tlinfo c1%rowtype;

begin

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.MILESTONE_TYPE_CODE = X_MILESTONE_TYPE_CODE)
      AND ((tlinfo.FREQUENCY = X_FREQUENCY)
           OR ((tlinfo.FREQUENCY is null) AND (X_FREQUENCY is null)))
      AND (tlinfo.SET_ID = X_SET_ID)
      AND (tlinfo.USER_ID = X_USER_ID)
      AND ((tlinfo.NOTIFICATION_DATE = X_NOTIFICATION_DATE)
           OR ((tlinfo.NOTIFICATION_DATE is null) AND (X_NOTIFICATION_DATE is null)))
      AND ((tlinfo.LEAD_DAYS = X_LEAD_DAYS)
           OR ((tlinfo.LEAD_DAYS is null) AND (X_LEAD_DAYS is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
                       X_MILESTONES_SET_ID    in NUMBER,
                       X_SET_ID               in NUMBER,
                       X_USER_ID              in NUMBER,
                       X_NOTIFICATION_DATE    in DATE,
                       X_LEAD_DAYS            in NUMBER,
                       X_ATTRIBUTE_CATEGORY   in VARCHAR2,
                       X_ATTRIBUTE1           in VARCHAR2,
                       X_ATTRIBUTE2           in VARCHAR2,
                       X_ATTRIBUTE3           in VARCHAR2,
                       X_ATTRIBUTE4           in VARCHAR2,
                       X_ATTRIBUTE5           in VARCHAR2,
                       X_ATTRIBUTE6           in VARCHAR2,
                       X_ATTRIBUTE7           in VARCHAR2,
                       X_ATTRIBUTE8           in VARCHAR2,
                       X_ATTRIBUTE9           in VARCHAR2,
                       X_ATTRIBUTE10          in VARCHAR2,
                       X_ATTRIBUTE11          in VARCHAR2,
                       X_ATTRIBUTE12          in VARCHAR2,
                       X_ATTRIBUTE13          in VARCHAR2,
                       X_ATTRIBUTE14          in VARCHAR2,
                       X_ATTRIBUTE15          in VARCHAR2,
                       X_MILESTONE_TYPE_CODE  in VARCHAR2,
                       X_FREQUENCY            in NUMBER,
                       X_LAST_UPDATE_DATE     in DATE,
                       X_LAST_UPDATED_BY      in NUMBER,
                       X_LAST_UPDATE_LOGIN    in NUMBER
                     ) IS
begin

  update PN_SET_MILESTONES
  set
         USER_ID             = X_USER_ID,
         NOTIFICATION_DATE   = X_NOTIFICATION_DATE,
         LEAD_DAYS           = X_LEAD_DAYS,
         ATTRIBUTE_CATEGORY  = X_ATTRIBUTE_CATEGORY,
         ATTRIBUTE1          = X_ATTRIBUTE1,
         ATTRIBUTE2          = X_ATTRIBUTE2,
         ATTRIBUTE3          = X_ATTRIBUTE3,
         ATTRIBUTE4          = X_ATTRIBUTE4,
         ATTRIBUTE5          = X_ATTRIBUTE5,
         ATTRIBUTE6          = X_ATTRIBUTE6,
         ATTRIBUTE7          = X_ATTRIBUTE7,
         ATTRIBUTE8          = X_ATTRIBUTE8,
         ATTRIBUTE9          = X_ATTRIBUTE9,
         ATTRIBUTE10         = X_ATTRIBUTE10,
         ATTRIBUTE11         = X_ATTRIBUTE11,
         ATTRIBUTE12         = X_ATTRIBUTE12,
         ATTRIBUTE13         = X_ATTRIBUTE13,
         ATTRIBUTE14         = X_ATTRIBUTE14,
         ATTRIBUTE15         = X_ATTRIBUTE15,
         MILESTONE_TYPE_CODE = X_MILESTONE_TYPE_CODE,
         FREQUENCY           = X_FREQUENCY,
         LAST_UPDATE_DATE    = X_LAST_UPDATE_DATE,
         LAST_UPDATED_BY     = X_LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN
  where  MILESTONES_SET_ID   = X_MILESTONES_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
                       X_MILESTONES_SET_ID in NUMBER
                     ) IS
begin

  delete from PN_SET_MILESTONES
  where MILESTONES_SET_ID = X_MILESTONES_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


end PN_SET_MILESTONES_PKG;

/
