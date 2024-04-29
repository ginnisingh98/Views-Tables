--------------------------------------------------------
--  DDL for Package Body PN_VAR_LINE_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_LINE_TEMPLATES_PKG" as
/* $Header: PNVRLITB.pls 120.3 2006/09/14 04:08:27 pikhar noship $*/

-----------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-----------------------------------------------------------------------
procedure INSERT_ROW (
   X_ROWID                    in out NOCOPY VARCHAR2,
   X_LINE_TEMPLATE_ID         in out NOCOPY NUMBER,
   X_LINE_DETAIL_NUM          in out NOCOPY NUMBER,
   X_AGREEMENT_TEMPLATE_ID    in NUMBER,
   X_SALES_TYPE_CODE          in VARCHAR2,
   X_ITEM_CATEGORY_CODE       in VARCHAR2,
   X_ORG_ID                   in NUMBER,
   X_CREATION_DATE            in DATE,
   X_CREATED_BY               in NUMBER,
   X_LAST_UPDATE_DATE         in DATE,
   X_LAST_UPDATED_BY          in NUMBER,
   X_LAST_UPDATE_LOGIN        in NUMBER,
   X_ATTRIBUTE_CATEGORY       in VARCHAR2,
   X_ATTRIBUTE1               in VARCHAR2,
   X_ATTRIBUTE2               in VARCHAR2,
   X_ATTRIBUTE3               in VARCHAR2,
   X_ATTRIBUTE4               in VARCHAR2,
   X_ATTRIBUTE5               in VARCHAR2,
   X_ATTRIBUTE6               in VARCHAR2,
   X_ATTRIBUTE7               in VARCHAR2,
   X_ATTRIBUTE8               in VARCHAR2,
   X_ATTRIBUTE9               in VARCHAR2,
   X_ATTRIBUTE10              in VARCHAR2,
   X_ATTRIBUTE11              in VARCHAR2,
   X_ATTRIBUTE12              in VARCHAR2,
   X_ATTRIBUTE13              in VARCHAR2,
   X_ATTRIBUTE14              in VARCHAR2,
   X_ATTRIBUTE15              in VARCHAR2
 ) is

        cursor C is
              select ROWID
              from   PN_VAR_LINE_TEMPLATES_ALL
              where  LINE_TEMPLATE_ID = X_LINE_TEMPLATE_ID
              ;

    l_return_status         VARCHAR2(30)    := NULL;

BEGIN

        PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.INSERT_ROW (+)');

        -------------------------------------------------------
        -- We need to generate the breakpoints details number
        -------------------------------------------------------
        select  nvl(max(bkdetails.LINE_DETAIL_NUM),0)
        into    X_LINE_DETAIL_NUM
        from    PN_VAR_LINE_TEMPLATES_ALL      bkdetails
        where   bkdetails.AGREEMENT_TEMPLATE_ID    =  X_AGREEMENT_TEMPLATE_ID;

        X_LINE_DETAIL_NUM    := X_LINE_DETAIL_NUM + 1;

        -------------------------------------------------------
        -- Select the nextval for breakpoints details id
        -------------------------------------------------------
        IF ( X_LINE_TEMPLATE_ID IS NULL) THEN
                select  PN_VAR_LINE_TEMPLATES_S.nextval
                into    X_LINE_TEMPLATE_ID
                from    dual;
        END IF;

    insert into PN_VAR_LINE_TEMPLATES_ALL
    (
            LINE_TEMPLATE_ID,
            LINE_DETAIL_NUM,
            AGREEMENT_TEMPLATE_ID,
            SALES_TYPE_CODE,
            ITEM_CATEGORY_CODE,
            ORG_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN,
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
    values
    (
            X_LINE_TEMPLATE_ID,
            X_LINE_DETAIL_NUM,
            X_AGREEMENT_TEMPLATE_ID,
            X_SALES_TYPE_CODE,
            X_ITEM_CATEGORY_CODE,
            X_ORG_ID,
            X_CREATION_DATE,
            X_CREATED_BY,
            X_LAST_UPDATE_DATE,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_LOGIN,
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

        PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-----------------------------------------------------------------------
-- PROCDURE : LOCK_ROW
-----------------------------------------------------------------------
procedure LOCK_ROW (
    X_LINE_TEMPLATE_ID        in NUMBER,
    X_LINE_DETAIL_NUM     in NUMBER,
    X_AGREEMENT_TEMPLATE_ID    in NUMBER,
    X_SALES_TYPE_CODE          in VARCHAR2,
    X_ITEM_CATEGORY_CODE       in VARCHAR2,
    X_ATTRIBUTE_CATEGORY       in VARCHAR2,
    X_ATTRIBUTE1               in VARCHAR2,
    X_ATTRIBUTE2               in VARCHAR2,
    X_ATTRIBUTE3               in VARCHAR2,
    X_ATTRIBUTE4               in VARCHAR2,
    X_ATTRIBUTE5               in VARCHAR2,
    X_ATTRIBUTE6               in VARCHAR2,
    X_ATTRIBUTE7               in VARCHAR2,
    X_ATTRIBUTE8               in VARCHAR2,
    X_ATTRIBUTE9               in VARCHAR2,
    X_ATTRIBUTE10              in VARCHAR2,
    X_ATTRIBUTE11              in VARCHAR2,
    X_ATTRIBUTE12              in VARCHAR2,
    X_ATTRIBUTE13              in VARCHAR2,
    X_ATTRIBUTE14              in VARCHAR2,
    X_ATTRIBUTE15              in VARCHAR2
  ) is

    cursor c1 is
        select *
            from PN_VAR_LINE_TEMPLATES_ALL
            where  LINE_TEMPLATE_ID = X_LINE_TEMPLATE_ID
            for update of  LINE_TEMPLATE_ID nowait;

    tlinfo c1%rowtype;

BEGIN

    PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.LOCK_ROW (+)');

    open c1;
        fetch c1 into tlinfo;
        if (c1%notfound) then
                close c1;
                return;
        end if;
    close c1;

          if (tlinfo. LINE_TEMPLATE_ID = X_LINE_TEMPLATE_ID) then
               null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION(' LINE_TEMPLATE_ID',
         to_char(tlinfo. LINE_TEMPLATE_ID));

          end if;
          if (tlinfo.LINE_DETAIL_NUM = X_LINE_DETAIL_NUM) then
               null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('LINE_DETAIL_NUM',
         to_char(tlinfo.LINE_DETAIL_NUM));

          end if;

          if ((tlinfo.AGREEMENT_TEMPLATE_ID = X_AGREEMENT_TEMPLATE_ID)
               OR ((tlinfo.AGREEMENT_TEMPLATE_ID is null) AND
                     (X_AGREEMENT_TEMPLATE_ID is null))) then
               null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('AGREEMENT_TEMPLATE_ID',
                      to_char(tlinfo.AGREEMENT_TEMPLATE_ID));
          end if;
          if ((tlinfo.SALES_TYPE_CODE = X_SALES_TYPE_CODE)
               OR ((tlinfo.SALES_TYPE_CODE is null) AND
                     (X_SALES_TYPE_CODE is null))) then
               null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('SALES_TYPE_CODE',
                      tlinfo.SALES_TYPE_CODE);
          end if;
          if ((tlinfo.ITEM_CATEGORY_CODE = X_ITEM_CATEGORY_CODE)
               OR ((tlinfo.ITEM_CATEGORY_CODE is null) AND
                     (X_ITEM_CATEGORY_CODE is null))) then
               null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ITEM_CATEGORY_CODE',
                      tlinfo.ITEM_CATEGORY_CODE);
          end if;

          if ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
               OR ((tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE_CATEGORY', to_char(tlinfo.ATTRIBUTE_CATEGORY));
          end if;


          if ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
               OR ((tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE1', to_char(tlinfo.ATTRIBUTE1));
          end if;

          if ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
               OR ((tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE2', to_char(tlinfo.ATTRIBUTE2));
          end if;

          if ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
               OR ((tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE3', to_char(tlinfo.ATTRIBUTE3));
          end if;

          if ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
               OR ((tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE4', to_char(tlinfo.ATTRIBUTE4));
          end if;

          if ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
               OR ((tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE5', to_char(tlinfo.ATTRIBUTE5));
          end if;

          if ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
               OR ((tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE6', to_char(tlinfo.ATTRIBUTE6));
          end if;

          if ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
               OR ((tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE7', to_char(tlinfo.ATTRIBUTE7));
          end if;

          if ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
               OR ((tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE8', to_char(tlinfo.ATTRIBUTE8));
          end if;

          if ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
               OR ((tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE9', to_char(tlinfo.ATTRIBUTE9));
          end if;

          if ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
               OR ((tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE10', to_char(tlinfo.ATTRIBUTE10));
          end if;

          if ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
               OR ((tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE11', to_char(tlinfo.ATTRIBUTE11));
          end if;

          if ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
               OR ((tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE12', to_char(tlinfo.ATTRIBUTE12));
          end if;

          if ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
               OR ((tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE13', to_char(tlinfo.ATTRIBUTE13));
          end if;

          if ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
               OR ((tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE14', to_char(tlinfo.ATTRIBUTE14));
          end if;

          if ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
               OR ((tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null))) then
             null;
          else
             PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('ATTRIBUTE15', to_char(tlinfo.ATTRIBUTE15));
          end if;

    PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-----------------------------------------------------------------------
-- PROCDURE : UPDATE_ROW
-----------------------------------------------------------------------
procedure UPDATE_ROW (
    X_LINE_TEMPLATE_ID         in NUMBER,
    X_LINE_DETAIL_NUM          in NUMBER,
    X_AGREEMENT_TEMPLATE_ID    in NUMBER,
    X_SALES_TYPE_CODE          in VARCHAR2,
    X_ITEM_CATEGORY_CODE       in VARCHAR2,
    X_LAST_UPDATE_DATE         in DATE,
    X_LAST_UPDATED_BY          in NUMBER,
    X_LAST_UPDATE_LOGIN        in NUMBER,
    X_ATTRIBUTE_CATEGORY       in VARCHAR2,
    X_ATTRIBUTE1               in VARCHAR2,
    X_ATTRIBUTE2               in VARCHAR2,
    X_ATTRIBUTE3               in VARCHAR2,
    X_ATTRIBUTE4               in VARCHAR2,
    X_ATTRIBUTE5               in VARCHAR2,
    X_ATTRIBUTE6               in VARCHAR2,
    X_ATTRIBUTE7               in VARCHAR2,
    X_ATTRIBUTE8               in VARCHAR2,
    X_ATTRIBUTE9               in VARCHAR2,
    X_ATTRIBUTE10              in VARCHAR2,
    X_ATTRIBUTE11              in VARCHAR2,
    X_ATTRIBUTE12              in VARCHAR2,
    X_ATTRIBUTE13              in VARCHAR2,
    X_ATTRIBUTE14              in VARCHAR2,
    X_ATTRIBUTE15              in VARCHAR2
  ) is

    l_return_status         VARCHAR2(30)    := NULL;

BEGIN

    PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.UPDATE_ROW (+)');


  update PN_VAR_LINE_TEMPLATES_ALL set
    LINE_TEMPLATE_ID         = X_LINE_TEMPLATE_ID,
    LINE_DETAIL_NUM          = X_LINE_DETAIL_NUM,
    AGREEMENT_TEMPLATE_ID    = X_AGREEMENT_TEMPLATE_ID,
    SALES_TYPE_CODE          = X_SALES_TYPE_CODE,
    ITEM_CATEGORY_CODE       = X_ITEM_CATEGORY_CODE,
    LAST_UPDATE_DATE         = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY          = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN        = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY       = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1               = X_ATTRIBUTE1,
    ATTRIBUTE2               = X_ATTRIBUTE2,
    ATTRIBUTE3               = X_ATTRIBUTE3,
    ATTRIBUTE4               = X_ATTRIBUTE4,
    ATTRIBUTE5               = X_ATTRIBUTE5,
    ATTRIBUTE6               = X_ATTRIBUTE6,
    ATTRIBUTE7               = X_ATTRIBUTE7,
    ATTRIBUTE8               = X_ATTRIBUTE8,
    ATTRIBUTE9               = X_ATTRIBUTE9,
    ATTRIBUTE10              = X_ATTRIBUTE10,
    ATTRIBUTE11              = X_ATTRIBUTE11,
    ATTRIBUTE12              = X_ATTRIBUTE12,
    ATTRIBUTE13              = X_ATTRIBUTE13,
    ATTRIBUTE14              = X_ATTRIBUTE14,
    ATTRIBUTE15              = X_ATTRIBUTE15
  where LINE_TEMPLATE_ID = X_LINE_TEMPLATE_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

    PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.UPDATE_ROW (+)');

END UPDATE_ROW;

-----------------------------------------------------------------------
-- PROCDURE : DELETE_ROW
-----------------------------------------------------------------------
procedure DELETE_ROW (
  X_LINE_TEMPLATE_ID    in NUMBER
) is

BEGIN

    PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.DELETE_ROW (+)');

  delete from PN_VAR_LINE_TEMPLATES_ALL
  where LINE_TEMPLATE_ID = X_LINE_TEMPLATE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

    PNP_DEBUG_PKG.debug ('PN_VAR_LINE_TEMPLATES_PKG.DELETE_ROW (-)');

END DELETE_ROW;

END PN_VAR_LINE_TEMPLATES_PKG;

/
