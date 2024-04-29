--------------------------------------------------------
--  DDL for Package Body AD_TRACKABLE_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AD_TRACKABLE_ENTITIES_PKG" AS
-- $Header: adcodlinb.pls 120.3 2006/03/10 08:08:26 rahkumar noship $

   PROCEDURE validate_name( p_te IN VARCHAR2) is
    l_te varchar2(30);
   BEGIN
    l_te := p_te;
   END validate_name;

   PROCEDURE validate_level( p_level IN VARCHAR2) is
    l_levl varchar2(30);
   BEGIN
    l_levl := p_level;
   END validate_level;

   PROCEDURE create_te ( p_trackable_entity_name IN  VARCHAR2 ,
                         P_desc IN VARCHAR2,
                         p_type IN  VARCHAR2,
                         x_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2 ) is
   BEGIN
     validate_name(p_trackable_entity_name);
     validate_name(p_type);

     insert into AD_TRACKABLE_ENTITIES (
                      abbreviation, name, type, baseline, codelevel,
                      used_flag, load_flag)
     values ( p_trackable_entity_name, p_desc, p_type, '0', '0',
                     'F' ,'F' );

     COMMIT;
     x_status := 'TRUE';

    EXCEPTION
      WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END create_te;

   PROCEDURE get_code_level (
              p_trackable_entity_name IN  VARCHAR2,
              x_te_level            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);
     -- Select the details of the event for the passed parameters.

       select baseline, codelevel
       into x_baseline, x_te_level
       from AD_TRACKABLE_ENTITIES
       where abbreviation = p_trackable_entity_name;

       x_status := 'TRUE';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_status := 'FALSE';
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END get_code_level;


  PROCEDURE set_code_level (
              p_trackable_entity_name IN  VARCHAR2,
              p_te_level            IN  VARCHAR2,
              p_baseline              IN  VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);
     validate_level(p_te_level);
     validate_level(p_baseline);

     update AD_TRACKABLE_ENTITIES
     set codelevel =  p_te_level ,
         baseline =  p_baseline
     where abbreviation = p_trackable_entity_name;

    if(SQL%ROWCOUNT = 0) then
      x_status := 'FALSE';
    else
      x_status := 'TRUE';
    end if;

     COMMIT;
    EXCEPTION
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END set_code_level;


  PROCEDURE get_used_status (
              p_trackable_entity_name IN  VARCHAR2,
              x_used_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_te_level            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);

       select baseline, codelevel, used_flag
       into x_baseline, x_te_level, x_used_status
       from AD_TRACKABLE_ENTITIES
       where abbreviation = p_trackable_entity_name;

       x_status := 'TRUE';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_status := 'FALSE';
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END get_used_status;


  PROCEDURE set_used_status (
              p_trackable_entity_name IN  VARCHAR2,
              p_used_status           IN  VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);

     update AD_TRACKABLE_ENTITIES
     set used_flag = p_used_status
     where abbreviation = p_trackable_entity_name;

    if(SQL%ROWCOUNT = 0) then
      x_status := 'FALSE';
    else
      x_status := 'TRUE';
    end if;

     COMMIT;

    EXCEPTION
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END set_used_status;

  PROCEDURE get_load_status (
              p_trackable_entity_name IN  VARCHAR2,
              x_load_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_te_level            OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);

       select baseline, codelevel, load_flag
       into x_baseline, x_te_level, x_load_status
       from AD_TRACKABLE_ENTITIES
       where abbreviation = p_trackable_entity_name;

       x_status := 'TRUE';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_status := 'FALSE';
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END get_load_status;

  PROCEDURE set_load_status (
              p_trackable_entity_name IN  VARCHAR2,
              p_load_status           IN  VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);

     update AD_TRACKABLE_ENTITIES
     set load_flag =  p_load_status
     where abbreviation = p_trackable_entity_name;

     COMMIT;

    if(SQL%ROWCOUNT = 0) then
      x_status := 'FALSE';
    else
      x_status := 'TRUE';
    end if;


    EXCEPTION
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END set_load_status;

 PROCEDURE get_te_info (
              p_trackable_entity_name IN  VARCHAR2,
              x_desc                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_type                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_te_level              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_baseline              OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_used_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_load_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);

       select name, type, baseline, codelevel, used_flag, load_flag
       into x_desc, x_type, x_baseline, x_te_level, x_used_status, x_load_status
       from AD_TRACKABLE_ENTITIES
       where abbreviation = p_trackable_entity_name;

       x_status := 'TRUE';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_status := 'FALSE';
        RAISE;
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END get_te_info;

 PROCEDURE set_te_info (
              p_trackable_entity_name IN  VARCHAR2,
              p_trackable_entity_desc IN VARCHAR2,
              p_type                  IN VARCHAR2,
              p_te_level              IN VARCHAR2,
              p_baseline              IN VARCHAR2,
              p_used_status           IN VARCHAR2,
              p_load_status           IN VARCHAR2,
              x_status                OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is
   BEGIN
     validate_name(p_trackable_entity_name);

     UPDATE AD_TRACKABLE_ENTITIES
     set name = p_trackable_entity_desc,
         type = p_type,
         baseline = p_baseline,
         codelevel = p_te_level,
         used_flag = p_used_status,
         load_flag = p_load_status
     where abbreviation = p_trackable_entity_name;

    if(SQL%ROWCOUNT = 0) then
     insert into AD_TRACKABLE_ENTITIES
         (abbreviation, name, type, baseline, codelevel, used_flag, load_flag)
     values (p_trackable_entity_name, p_trackable_entity_desc, p_type, p_te_level,
             p_baseline, p_used_status, p_load_status);
    end if;

    COMMIT;
    x_status := 'TRUE';

    EXCEPTION
     WHEN OTHERS THEN
        x_status := 'FALSE';
        RAISE;

   END set_te_info;



END AD_TRACKABLE_ENTITIES_PKG;

/
