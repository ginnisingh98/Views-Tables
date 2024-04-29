--------------------------------------------------------
--  DDL for Package Body MSD_CS_DEFN_DIM_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_DEFN_DIM_LOAD_DATA" as
/* $Header: msdcsddb.pls 115.6 2003/09/12 22:16:43 pinamati ship $ */

    Procedure load_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_collect_flag               in varchar2,
/*       p_collect_level_name         in varchar2, */
       p_collect_level_id           in number,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in  varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2
       ) is
    Begin

         Update_row(
           p_definition_name    ,
           p_dimension_code     ,
           p_collect_flag       ,
           p_collect_level_id ,
           p_aggregation_type   ,
           p_allocation_type    ,
           p_owner              ,
           p_last_update_date   ,
           p_custom_mode        );
    Exception
    when no_data_found then
        Insert_row(
           p_definition_name    ,
           p_dimension_code     ,
           p_collect_flag       ,
           p_collect_level_id   ,
           p_aggregation_type   ,
           p_allocation_type    ,
           p_owner              ,
           p_last_update_date   );

    End;

    Procedure Update_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_collect_flag               in varchar2,
       p_collect_level_id           in number,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in  varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2
       )  is

        l_user              number;
        l_definition_id     number;
        l_cs_definition_id  number;
        l_level_id          number;

        f_ludate            date;    -- entity update date in file
        db_luby             number;  -- entity owner in db
        db_ludate           date;    -- entity update date in db


        cursor c1 is
        select cs_definition_id from msd_cs_definitions
        where name = p_definition_name;

/*        cursor c2 is
        select level_id from msd_levels
        where level_name = p_collect_level_name;
*/
        cursor c3(p_cs_def_id in number, p_dim_code in varchar2) is
        select last_updated_by, last_update_date
        from msd_cs_defn_dim_dtls
        where cs_definition_id = p_cs_def_id
        and dimension_code = p_dim_code;

    Begin

        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

        open c1;
        fetch c1 into l_cs_definition_id;
        close c1;

        if l_cs_definition_id is null then
            raise no_data_found;
/*            fnd_message.set_name('MSD', 'MSD_CS_LOAD_INVALID_DEFN');
            fnd_message.raise_error;
*/
        end if;

/*       if p_collect_level_name is not null then

            l_level_id := msd_cs_dfn_utl.get_level_id(p_dimension_code, p_collect_level_name);
*/
            l_level_id := p_collect_level_id;

 /*       end if; */

        open c3(l_cs_definition_id, p_dimension_code);
        fetch c3 into db_luby, db_ludate;

        if (c3%notfound) then
          raise no_data_found;
        end if;

        close c3;

        --
        -- Update record, honoring customization mode.
        -- Record should be updated only if:
        -- a. CUSTOM_MODE = FORCE, or
        -- b. file owner is CUSTOM, db owner is SEED
        -- c. owners are the same, and file_date > db_date
         if ((p_custom_mode = 'FORCE') or
             ((l_user = 0) and (db_luby = 1)) or
             ((l_user = db_luby) and (f_ludate > db_ludate)))
         then

             update MSD_CS_DEFN_DIM_DTLS set
                collect_flag     = p_collect_flag,
                collect_level_id = l_level_id,
                aggregation_type = p_aggregation_type,
                allocation_type  = p_allocation_type,
                last_updated_by   = l_user,
                last_update_date = f_ludate
             where
                 cs_definition_id = l_cs_definition_id and
                 dimension_code   = p_dimension_code;
          end if;

      if (sql%notfound) then
        raise no_data_found;
      end if;

End;

Procedure Insert_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_collect_flag               in varchar2,
       p_collect_level_id           in number  ,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in  varchar2,
       p_last_update_date           in varchar2
       ) is


       l_user               number;
       l_pk_id              number;
       l_level_id           number;
       l_cs_definition_id   number;
       f_ludate             date;    -- entity update date in file

        cursor c1 is
        select cs_definition_id
            from msd_cs_definitions
        where
            name = p_definition_name;
/*
        cursor c2 is
        select level_id
            from msd_levels
        where
            level_name = p_collect_level_name;
*/
    Begin
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;

        open c1;
        fetch c1 into l_cs_definition_id;
        close c1;

        if l_cs_definition_id is null then
            fnd_message.set_name('MSD', 'MSD_CS_LOAD_INVALID_DEFN');
            fnd_message.raise_error;
        end if;

/*        if p_collect_level_name is not null then

            l_level_id := msd_cs_dfn_utl.get_level_id(p_dimension_code, p_collect_level_name);

            open c2;
            fetch c2 into l_level_id;
            close c2;
*/
            l_level_id := p_collect_level_id;

/*         end if; */

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

        select MSD_CS_DEFN_DIM_DTLS_S.nextval into l_pk_id from dual;

        insert into MSD_CS_DEFN_DIM_DTLS(
            cs_defn_dim_dtls_id,
            cs_definition_id,
            dimension_code,
            collect_flag,
            collect_level_id,
            aggregation_type,
            allocation_type,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date ,
            last_update_login
        )
        values
          (
            l_pk_id,
            l_cs_definition_id,
            p_dimension_code,
            p_collect_flag,
            l_level_id,
            p_aggregation_type,
            p_allocation_type,
            l_user,
            f_ludate,
            l_user,
            f_ludate,
            fnd_global.login_id
        );

End;

End;

/
