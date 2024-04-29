--------------------------------------------------------
--  DDL for Package Body PO_LINE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_TYPES_PKG" as
/* $Header: POXTILTB.pls 115.8 2004/03/23 22:04:12 dreddy ship $ */
X_progress varchar2(10) := '001';
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_LINE_TYPE_ID in out NOCOPY NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_OUTSIDE_OPERATION_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_RECEIVE_CLOSE_TOLERANCE in NUMBER,
  X_ORDER_TYPE_LOOKUP_CODE in VARCHAR2,
  X_PURCHASE_BASIS IN PO_LINE_TYPES_B.purchase_basis%TYPE,  -- <SERVICES FPJ>
  X_MATCHING_BASIS IN PO_LINE_TYPES_B.matching_basis%TYPE,  -- <SERVICES FPJ>
  X_CATEGORY_ID in NUMBER,
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_PRICE in NUMBER,
  X_RECEIVING_FLAG in VARCHAR2,
  X_INACTIVE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_LINE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PO_LINE_TYPES_B
    where LINE_TYPE_ID = X_LINE_TYPE_ID ;

   CURSOR C2 IS SELECT po_line_types_s.nextval FROM sys.dual;

begin

      BEGIN
	if (X_Line_Type_Id is NULL) then
           OPEN C2;
           FETCH C2 INTO X_Line_Type_ID;
           CLOSE C2;
        end if;
      end;
  begin
  insert into PO_LINE_TYPES_B (
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
    OUTSIDE_OPERATION_FLAG,
    REQUEST_ID,
    RECEIVE_CLOSE_TOLERANCE,
    LINE_TYPE_ID,
    ORDER_TYPE_LOOKUP_CODE,
    PURCHASE_BASIS,                   -- <SERVICES FPJ>
    MATCHING_BASIS,                   -- <SERVICES FPJ>
    CATEGORY_ID,
    UNIT_OF_MEASURE,
    UNIT_PRICE,
    RECEIVING_FLAG,
    INACTIVE_DATE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
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
    X_OUTSIDE_OPERATION_FLAG,
    X_REQUEST_ID,
    X_RECEIVE_CLOSE_TOLERANCE,
    X_LINE_TYPE_ID,
    X_ORDER_TYPE_LOOKUP_CODE,
    X_PURCHASE_BASIS,                 -- <SERVICES FPJ>
    X_MATCHING_BASIS,                 -- <SERVICES FPJ>
    X_CATEGORY_ID,
    X_UNIT_OF_MEASURE,
    X_UNIT_PRICE,
    X_RECEIVING_FLAG,
    X_INACTIVE_DATE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  exception
   WHEN OTHERS THEN
      po_message_s.sql_error('val_destination_info', x_progress, sqlcode);
   RAISE;
  end;

  begin

 x_progress := '002';
  insert into PO_LINE_TYPES_TL (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    LINE_TYPE_ID,
    DESCRIPTION,
    LINE_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_LOGIN,
    X_CREATION_DATE,
    X_LINE_TYPE_ID,
    X_DESCRIPTION,
    X_LINE_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PO_LINE_TYPES_TL T
    where T.LINE_TYPE_ID = X_LINE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  exception

   WHEN OTHERS THEN
      po_message_s.sql_error('val_destination_info', x_progress, sqlcode);
   RAISE;

  end;

end INSERT_ROW;

procedure LOCK_ROW (
  X_LINE_TYPE_ID in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_OUTSIDE_OPERATION_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_RECEIVE_CLOSE_TOLERANCE in NUMBER,
  X_ORDER_TYPE_LOOKUP_CODE in VARCHAR2,
  X_PURCHASE_BASIS IN PO_LINE_TYPES_B.purchase_basis%TYPE,  -- <SERVICES FPJ>
  X_MATCHING_BASIS IN PO_LINE_TYPES_B.matching_basis%TYPE,  -- <SERVICES FPJ>
  X_CATEGORY_ID in NUMBER,
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_PRICE in NUMBER,
  X_RECEIVING_FLAG in VARCHAR2,
  X_INACTIVE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_LINE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
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
      OUTSIDE_OPERATION_FLAG,
      REQUEST_ID,
      RECEIVE_CLOSE_TOLERANCE,
      ORDER_TYPE_LOOKUP_CODE,
      PURCHASE_BASIS,              -- <SERVICES FPJ>
      MATCHING_BASIS,              -- <SERVICES FPJ>
      CATEGORY_ID,
      UNIT_OF_MEASURE,
      UNIT_PRICE,
      RECEIVING_FLAG,
      INACTIVE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2
    from PO_LINE_TYPES_B
    where LINE_TYPE_ID = X_LINE_TYPE_ID
    for update of LINE_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LINE_TYPE,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PO_LINE_TYPES_TL
    where LINE_TYPE_ID = X_LINE_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LINE_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.OUTSIDE_OPERATION_FLAG = X_OUTSIDE_OPERATION_FLAG)
           OR ((recinfo.OUTSIDE_OPERATION_FLAG is null) AND (X_OUTSIDE_OPERATION_FLAG is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.RECEIVE_CLOSE_TOLERANCE = X_RECEIVE_CLOSE_TOLERANCE)
           OR ((recinfo.RECEIVE_CLOSE_TOLERANCE is null) AND (X_RECEIVE_CLOSE_TOLERANCE is null)))
      AND (recinfo.ORDER_TYPE_LOOKUP_CODE = X_ORDER_TYPE_LOOKUP_CODE)
      AND (recinfo.PURCHASE_BASIS = X_PURCHASE_BASIS)     -- <SERVICES FPJ>
      AND (recinfo.MATCHING_BASIS = X_MATCHING_BASIS)     -- <SERVICES FPJ>
      AND ((recinfo.CATEGORY_ID = X_CATEGORY_ID)
           OR ((recinfo.CATEGORY_ID is null) AND (X_CATEGORY_ID is null)))
      AND ((recinfo.UNIT_OF_MEASURE = X_UNIT_OF_MEASURE)
           OR ((recinfo.UNIT_OF_MEASURE is null) AND (X_UNIT_OF_MEASURE is null)))
      AND ((recinfo.UNIT_PRICE = X_UNIT_PRICE)
           OR ((recinfo.UNIT_PRICE is null) AND (X_UNIT_PRICE is null)))
      AND ((recinfo.RECEIVING_FLAG = X_RECEIVING_FLAG)
           OR ((recinfo.RECEIVING_FLAG is null) AND (X_RECEIVING_FLAG is null)))
      AND ((recinfo.INACTIVE_DATE = X_INACTIVE_DATE)
           OR ((recinfo.INACTIVE_DATE is null) AND (X_INACTIVE_DATE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.LINE_TYPE = X_LINE_TYPE)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LINE_TYPE_ID in NUMBER,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_OUTSIDE_OPERATION_FLAG in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_RECEIVE_CLOSE_TOLERANCE in NUMBER,
  X_ORDER_TYPE_LOOKUP_CODE in VARCHAR2,
  X_PURCHASE_BASIS IN PO_LINE_TYPES_B.purchase_basis%TYPE,  -- <SERVICES FPJ>
  X_MATCHING_BASIS IN PO_LINE_TYPES_B.matching_basis%TYPE,  -- <SERVICES FPJ>
  X_CATEGORY_ID in NUMBER,
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_PRICE in NUMBER,
  X_RECEIVING_FLAG in VARCHAR2,
  X_INACTIVE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_LINE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PO_LINE_TYPES_B set
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    OUTSIDE_OPERATION_FLAG = X_OUTSIDE_OPERATION_FLAG,
    REQUEST_ID = X_REQUEST_ID,
    RECEIVE_CLOSE_TOLERANCE = X_RECEIVE_CLOSE_TOLERANCE,
    ORDER_TYPE_LOOKUP_CODE = X_ORDER_TYPE_LOOKUP_CODE,
    PURCHASE_BASIS = X_PURCHASE_BASIS,                -- <SERVICES FPJ>
    MATCHING_BASIS = X_MATCHING_BASIS,                -- <SERVICES FPJ>
    CATEGORY_ID = X_CATEGORY_ID,
    UNIT_OF_MEASURE = X_UNIT_OF_MEASURE,
    UNIT_PRICE = X_UNIT_PRICE,
    RECEIVING_FLAG = X_RECEIVING_FLAG,
    INACTIVE_DATE = X_INACTIVE_DATE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LINE_TYPE_ID = X_LINE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PO_LINE_TYPES_TL set
    LINE_TYPE = X_LINE_TYPE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LINE_TYPE_ID = X_LINE_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LINE_TYPE_ID in NUMBER
) is
begin
  delete from PO_LINE_TYPES_TL
  where LINE_TYPE_ID = X_LINE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PO_LINE_TYPES_B
  where LINE_TYPE_ID = X_LINE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PO_LINE_TYPES_TL T
  where not exists
    (select NULL
    from PO_LINE_TYPES_B B
    where B.LINE_TYPE_ID = T.LINE_TYPE_ID
    );

  update PO_LINE_TYPES_TL T set (
      LINE_TYPE,
      DESCRIPTION
    ) = (select
      B.LINE_TYPE,
      B.DESCRIPTION
    from PO_LINE_TYPES_TL B
    where B.LINE_TYPE_ID = T.LINE_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LINE_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LINE_TYPE_ID,
      SUBT.LANGUAGE
    from PO_LINE_TYPES_TL SUBB, PO_LINE_TYPES_TL SUBT
    where SUBB.LINE_TYPE_ID = SUBT.LINE_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LINE_TYPE <> SUBT.LINE_TYPE
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PO_LINE_TYPES_TL (
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    LINE_TYPE_ID,
    DESCRIPTION,
    LINE_TYPE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.LINE_TYPE_ID,
    B.DESCRIPTION,
    B.LINE_TYPE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PO_LINE_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PO_LINE_TYPES_TL T
    where T.LINE_TYPE_ID = B.LINE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (X_LINE_TYPE_ID in NUMBER,
                         X_LINE_TYPE    in VARCHAR2,
                         X_DESCRIPTION  in VARCHAR2,
                         X_OWNER        in VARCHAR2,
                         X_LAST_UPDATE_DATE in VARCHAR2,
                         X_CUSTOM_MODE  in VARCHAR2) IS

f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db

begin

  f_luby := fnd_load_util.owner_id(X_OWNER);
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into  db_luby, db_ludate
  from PO_LINE_TYPES_TL
  where line_type_id = X_LINE_TYPE_ID
  and  language = userenv('LANG') ;

  if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE)) then

    update PO_LINE_TYPES_TL set
      line_type = X_LINE_TYPE,
      description = X_DESCRIPTION,
      last_update_date  = f_ludate ,
      last_updated_by   = f_luby,
      last_update_login = 0,
      source_lang       = userenv('LANG')
    where line_type_id = X_LINE_TYPE_ID
    and  userenv('LANG') in (language, source_lang);

  end if;

exception
 when no_data_found then
    -- Do not insert missing translations, skip this row
    null;
end TRANSLATE_ROW;

procedure LOAD_ROW
(   X_LINE_TYPE_ID in out NOCOPY NUMBER,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2,
    X_OUTSIDE_OPERATION_FLAG in VARCHAR2,
    X_REQUEST_ID in NUMBER,
    X_RECEIVE_CLOSE_TOLERANCE in NUMBER,
    X_ORDER_TYPE_LOOKUP_CODE in VARCHAR2,
    X_PURCHASE_BASIS IN PO_LINE_TYPES_B.purchase_basis%TYPE,  -- <SERVICES FPJ>
    X_MATCHING_BASIS IN PO_LINE_TYPES_B.matching_basis%TYPE,  -- <SERVICES FPJ>
    X_CATEGORY_CODE in VARCHAR2,
    X_UNIT_OF_MEASURE in VARCHAR2,
    X_UNIT_PRICE in NUMBER,
    X_RECEIVING_FLAG in VARCHAR2,
    X_INACTIVE_DATE in DATE,
    X_LINE_TYPE in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_OWNER in VARCHAR2,
    X_LAST_UPDATE_DATE in VARCHAR2,
    X_CUSTOM_MODE in VARCHAR2
) IS

l_row_id	varchar2(64);
l_category_id number;
f_luby    number;  -- entity owner in file
f_ludate  date;    -- entity update date in file
db_luby   number;  -- entity owner in db
db_ludate date;    -- entity update date in db

begin

   if x_category_code is not null then
      begin

       SELECT mck.category_id
       into   l_category_id
       FROM mtl_categories_kfv mck,
            mtl_category_sets mcs,
            mtl_default_category_sets mdcs
       WHERE
           mck.structure_id = mcs.structure_id
           AND mcs.category_set_id = mdcs.category_set_id
           AND mdcs.functional_area_id = 2
           AND concatenated_segments = x_category_code ;
      exception
         when others then null;
      end;

   end if;

  f_luby := fnd_load_util.owner_id(X_OWNER);
  f_ludate := nvl(to_date(X_LAST_UPDATE_DATE, 'DD/MM/YYYY'), sysdate);

  select LAST_UPDATED_BY, LAST_UPDATE_DATE
  into  db_luby, db_ludate
  from PO_LINE_TYPES_VL
  where line_type_id = X_LINE_TYPE_ID;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

     UPDATE_ROW (X_LINE_TYPE_ID ,
                 X_ATTRIBUTE3 ,
                 X_ATTRIBUTE4 ,
                 X_ATTRIBUTE5 ,
                 X_ATTRIBUTE6 ,
                 X_ATTRIBUTE7 ,
                 X_ATTRIBUTE8 ,
                 X_ATTRIBUTE9 ,
                 X_ATTRIBUTE10 ,
                 X_ATTRIBUTE11 ,
                 X_ATTRIBUTE12 ,
                 X_ATTRIBUTE13 ,
                 X_ATTRIBUTE14 ,
                 X_ATTRIBUTE15 ,
                 X_OUTSIDE_OPERATION_FLAG ,
                 X_REQUEST_ID ,
                 X_RECEIVE_CLOSE_TOLERANCE ,
                 X_ORDER_TYPE_LOOKUP_CODE ,
                 X_PURCHASE_BASIS ,       -- <SERVICES FPJ>
                 X_MATCHING_BASIS ,       -- <SERVICES FPJ>
                 L_CATEGORY_ID ,
                 X_UNIT_OF_MEASURE ,
                 X_UNIT_PRICE ,
                 X_RECEIVING_FLAG ,
                 X_INACTIVE_DATE ,
                 X_ATTRIBUTE_CATEGORY ,
                 X_ATTRIBUTE1 ,
                 X_ATTRIBUTE2 ,
                 X_LINE_TYPE ,
                 X_DESCRIPTION ,
                 f_ludate ,
                 f_luby ,
                 0);

     end if;

  exception
     when NO_DATA_FOUND then
         INSERT_ROW (l_row_id ,
                     X_LINE_TYPE_ID ,
                     X_ATTRIBUTE3 ,
                     X_ATTRIBUTE4 ,
                     X_ATTRIBUTE5 ,
                     X_ATTRIBUTE6 ,
                     X_ATTRIBUTE7 ,
                     X_ATTRIBUTE8 ,
                     X_ATTRIBUTE9 ,
                     X_ATTRIBUTE10 ,
                     X_ATTRIBUTE11 ,
                     X_ATTRIBUTE12 ,
                     X_ATTRIBUTE13 ,
                     X_ATTRIBUTE14 ,
                     X_ATTRIBUTE15 ,
                     X_OUTSIDE_OPERATION_FLAG ,
                     X_REQUEST_ID ,
                     X_RECEIVE_CLOSE_TOLERANCE ,
                     X_ORDER_TYPE_LOOKUP_CODE ,
                     X_PURCHASE_BASIS ,       -- <SERVICES FPJ>
                     X_MATCHING_BASIS ,       -- <SERVICES FPJ>
                     L_CATEGORY_ID ,
                     X_UNIT_OF_MEASURE ,
                     X_UNIT_PRICE ,
                     X_RECEIVING_FLAG ,
                     X_INACTIVE_DATE ,
                     X_ATTRIBUTE_CATEGORY ,
                     X_ATTRIBUTE1 ,
                     X_ATTRIBUTE2 ,
                     X_LINE_TYPE ,
                     X_DESCRIPTION ,
                     f_ludate ,
                     f_luby ,
                     f_ludate ,
                     f_luby ,
                     0 );

end LOAD_ROW;

end PO_LINE_TYPES_PKG;

/
