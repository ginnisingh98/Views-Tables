--------------------------------------------------------
--  DDL for Package Body HZ_WORD_RPL_COND_ATTRIBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_RPL_COND_ATTRIBS_PKG" as
/*$Header: ARHWRCAB.pls 120.0 2004/12/26 04:27:35 cvijayan noship $ */

PROCEDURE Insert_Row (
    x_condition_id                          IN  NUMBER,
    x_assoc_cond_attrib_id                  IN NUMBER,
    x_object_version_number                 IN  NUMBER
) IS
BEGIN
              INSERT INTO HZ_WORD_RPL_COND_ATTRIBS (
                condition_id,
                assoc_cond_attrib_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                object_version_number
                )
               VALUES (
                x_condition_id,
                x_assoc_cond_attrib_id,
                hz_utility_v2pub.last_update_date,
                hz_utility_v2pub.last_updated_by,
                hz_utility_v2pub.creation_date,
                hz_utility_v2pub.created_by,
                hz_utility_v2pub.last_update_login,
                DECODE(x_object_version_number,
                    FND_API.G_MISS_NUM, NULL,
                    x_object_version_number)
                ) ;


END Insert_Row;

PROCEDURE Update_Row (
    x_condition_id                          IN  NUMBER,
    x_assoc_cond_attrib_id                  IN NUMBER,
    x_new_cond_attrib_id                    IN NUMBER,
    x_object_version_number                 IN  OUT NOCOPY NUMBER
)
IS
p_object_version_number NUMBER ;
BEGIN
   p_object_version_number := NVL(x_object_version_number, 1) + 1;

 UPDATE HZ_WORD_RPL_COND_ATTRIBS set
        assoc_cond_attrib_id = x_new_cond_attrib_id,
        object_version_number = p_object_version_number,
        last_update_date = hz_utility_v2pub.last_update_date,
        last_updated_by = hz_utility_v2pub.last_updated_by,
        last_update_login = hz_utility_v2pub.last_update_login
  where condition_id = x_condition_id  and assoc_cond_attrib_id = x_assoc_cond_attrib_id ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END ;


PROCEDURE Delete_Row (
    x_condition_id                          IN  NUMBER,
    x_assoc_cond_attrib_id                  IN NUMBER
)
IS
BEGIN

    DELETE FROM HZ_WORD_RPL_COND_ATTRIBS
    where condition_id = x_condition_id and assoc_cond_attrib_id = x_assoc_cond_attrib_id ;

END ;



PROCEDURE Delete_Row (
    x_condition_id                          IN  NUMBER
)
IS
BEGIN

    DELETE FROM HZ_WORD_RPL_COND_ATTRIBS
    where condition_id = x_condition_id ;

END ;

procedure Lock_Row (
  x_condition_id in NUMBER,
  x_assoc_cond_attrib_id in NUMBER,
  x_object_version_number in  NUMBER
)
IS
cursor c is select
    object_version_number
    from HZ_WORD_RPL_COND_ATTRIBS B
    where condition_id = x_condition_id
    and assoc_cond_attrib_id = x_assoc_cond_attrib_id
    for update of condition_id, assoc_cond_attrib_id nowait;

recinfo c%rowtype;

BEGIN

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if(
       ( recinfo.object_version_number IS NULL AND x_object_version_number IS NULL )
       OR ( recinfo.object_version_number IS NOT NULL AND
          x_object_version_number IS NOT NULL AND
          recinfo.object_version_number = x_object_version_number )
     ) then
       null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;

END Lock_Row ;


END HZ_WORD_RPL_COND_ATTRIBS_PKG ;

/
