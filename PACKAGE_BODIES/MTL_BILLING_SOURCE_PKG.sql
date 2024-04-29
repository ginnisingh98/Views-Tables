--------------------------------------------------------
--  DDL for Package Body MTL_BILLING_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_BILLING_SOURCE_PKG" AS
/* $Header: INVBSRCB.pls 120.0.12010000.3 2010/03/26 05:12:11 damahaja noship $ */

  procedure INSERT_ROW(
        x_billing_source_id IN NUMBER ,
        x_name IN VARCHAR2 ,
        x_description IN VARCHAR2 ,
        x_procedure_code IN NUMBER,
        x_billing_source_code IN VARCHAR2 ,
        x_creation_date IN DATE,
        x_created_by IN NUMBER,
        x_last_update_date IN DATE,
        x_last_updated_by IN NUMBER ,
        x_last_update_login IN NUMBER
  ) AS

  BEGIN

          INSERT INTO mtl_billing_sources_b
          (   billing_source_id ,
              procedure_code ,
              billing_source_code ,
              creation_date ,
              created_by ,
              last_update_date ,
              last_updated_by ,
              last_update_login
          )
          VALUES
          (   x_billing_source_id ,
              x_procedure_code ,
              x_billing_source_code ,
              x_creation_date ,
              x_created_by ,
              x_last_update_date ,
              x_last_updated_by ,
              x_last_update_login
          );

-- INSERT INTO dp_debug VALUES('2');
-- commit;

          INSERT INTO mtl_billing_sources_tl
          (   billing_source_id ,
              name ,
              description ,
              creation_date ,
              created_by ,
              last_update_date ,
              last_updated_by ,
              last_update_login ,
              LANGUAGE ,
              source_lang
          )
          SELECT
              x_billing_source_id ,
              x_name ,
              x_description ,
              x_creation_date ,
              x_created_by ,
              x_last_update_date ,
              x_last_updated_by ,
              x_last_update_login ,
              L.LANGUAGE_CODE,
              userenv('LANG')
                from FND_LANGUAGES L
                where L.INSTALLED_FLAG in ('I', 'B')
                and not exists
                  (select NULL
                  from mtl_billing_sources_tl T
                  where T.billing_source_id = x_billing_source_id
            and T.LANGUAGE = L.LANGUAGE_CODE);

  END INSERT_ROW;

procedure UPDATE_ROW(
       x_billing_source_id IN NUMBER ,
       x_name IN VARCHAR2 ,
       x_description IN VARCHAR2 ,
       x_procedure_code IN NUMBER,
       x_billing_source_code IN VARCHAR2,
       x_creation_date IN DATE,
       x_created_by IN NUMBER,
       x_last_update_date IN DATE,
       x_last_updated_by IN NUMBER ,
       x_last_update_login IN NUMBER
) AS


  CURSOR cur_sources IS SELECT 1 FROM mtl_billing_sources_b
                                WHERE billing_Source_id  = x_billing_source_id;
  l_dummy        NUMBER;


 BEGIN

  OPEN cur_sources;
  FETCH cur_sources INTO l_dummy;

  update mtl_billing_sources_b set
              procedure_code = x_procedure_code,
              billing_source_code = x_billing_source_code ,
              last_update_date = x_last_update_date,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login
    where billing_source_id = x_billing_source_id;

      if (sql%notfound) then
    raise no_data_found;
  end if;

    update mtl_billing_sources_tl set
           name = x_name,
              description = x_description,
              last_update_date = x_last_update_date,
              last_updated_by = x_last_updated_by,
              last_update_login = x_last_update_login,
              SOURCE_LANG = userenv('LANG')
  where billing_source_id = x_billing_source_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

CLOSE cur_sources;

END UPDATE_ROW;


procedure DELETE_ROW (
  x_billing_source_id in NUMBER
) is
BEGIN


  delete from mtl_billing_sources_tl
  where billing_source_id = x_billing_source_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from mtl_billing_sources_b
  where billing_source_id = x_billing_source_id;

  if (sql%notfound) THEN
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOCK_ROW (
        x_billing_source_id IN NUMBER ,
        x_name IN VARCHAR2 ,
        x_description IN VARCHAR2 ,
        x_procedure_code IN NUMBER,
        x_billing_source_code IN VARCHAR2 ,
        x_creation_date IN DATE,
        x_created_by IN NUMBER,
        x_last_update_date IN DATE,
        x_last_updated_by IN NUMBER ,
        x_last_update_login IN NUMBER
) is
  cursor c is select
              billing_source_id ,
              procedure_code ,
              billing_source_code ,
              creation_date ,
              created_by ,
              last_update_date ,
              last_updated_by ,
              last_update_login
    from mtl_billing_sources_b
    where billing_source_id = x_billing_source_id
    for update of billing_source_id nowait;
  recinfo c%rowtype;

  cursor c1 is select
      name,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from mtl_billing_sources_tl
    where billing_source_id = x_billing_source_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of billing_source_id nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
      (recinfo.billing_source_id = X_billing_source_id)
     )
      then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.name = X_name)
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


/* Added following procedure for bug 9447716 */

procedure ADD_LANGUAGE
is
begin

    delete from mtl_billing_sources_tl T
    where not exists
         (select NULL
            from mtl_billing_sources_b B
           where B.billing_source_id = T.billing_source_id
         );

    update mtl_billing_sources_tl T
     set (
              name,
              description
         ) = (select
                      B.name,
                      B.description
                from mtl_billing_sources_tl B
               where B.billing_source_id = T.billing_source_id
                 and B.language = T.source_lang)
    where (
              T.billing_source_id,
              T.language
         )
        in (select
                  blsrct.billing_source_id,
                  blsrct.language
              from mtl_billing_sources_tl blsrcb, mtl_billing_sources_tl blsrct
             where blsrcb.billing_source_id = blsrct.billing_source_id
               and blsrcb.language = blsrct.source_lang
               and (blsrcb.name <> blsrct.name
                      or blsrcb.description <> blsrct.description
                      or (blsrcb.description is null and blsrct.description is not null)
                      or (blsrcb.description is not null and blsrct.description is null)
                    )
            );

    insert into mtl_billing_sources_tl
    (
        billing_source_id,
        name,
        description,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        language,
        source_lang
    ) select /*+ ORDERED */
            B.billing_source_id,
            B.name,
            B.description,
            B.creation_date,
            B.created_by,
            B.last_update_date,
            B.last_updated_by,
            B.last_update_login,
            L.language_code,
            B.source_lang
        from mtl_billing_sources_tl B, fnd_languages L
       where L.installed_flag in ('I', 'B')
         and B.language = userenv('LANG')
         and not exists
                (select NULL
                   from mtl_billing_sources_tl T
                  where T.billing_source_id = B.billing_source_id
                    and T.language = L.language_code);

end ADD_LANGUAGE;


END;

/
