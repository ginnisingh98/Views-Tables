--------------------------------------------------------
--  DDL for Package Body MSD_CS_DEFN_CLMN_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_DEFN_CLMN_LOAD_DATA" as
/* $Header: msdcsdcb.pls 115.6 2003/08/18 18:53:04 pinamati ship $ */

    Procedure load_row (
       p_definition_name            in varchar2,
       p_table_column               in varchar2,
       p_column_identifier          in varchar2,
       p_source_view_column_name    in varchar2,
       p_planning_view_column_name  in varchar2,
--       p_alt_key_flag               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_uom_conversion_flag        in varchar2,
       p_owner                      in  varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2
       ) is
    Begin
        --
         Update_row(
           p_definition_name            ,
           p_table_column               ,
           p_column_identifier          ,
           p_source_view_column_name    ,
           p_planning_view_column_name  ,
--           p_alt_key_flag               ,
           p_aggregation_type           ,
           p_allocation_type            ,
           p_uom_conversion_flag        ,
           p_owner                      ,
           p_last_update_date           ,
           p_custom_mode                );
    Exception
    when no_data_found then
        Insert_row(
           p_definition_name            ,
           p_table_column               ,
           p_column_identifier          ,
           p_source_view_column_name    ,
           p_planning_view_column_name  ,
--           p_alt_key_flag             ,
           p_aggregation_type           ,
           p_allocation_type            ,
           p_uom_conversion_flag        ,
           p_owner                      ,
           p_last_update_date           );

    End;
    --
--
    Procedure Update_row (
       p_definition_name            in varchar2,
       p_table_column               in varchar2,
       p_column_identifier          in varchar2,
       p_source_view_column_name    in varchar2,
       p_planning_view_column_name  in varchar2,
--       p_alt_key_flag               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_uom_conversion_flag        in varchar2,
       p_owner                      in  varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2
       )  is
        --
        --
        l_user              number;
        l_definition_id     number;
        l_cs_definition_id  number;
        f_ludate            date;    -- entity update date in file
        db_luby             number;  -- entity owner in db
        db_ludate           date;    -- entity update date in db
        --
        cursor c1 is
        select
            cs_definition_id
        from
            msd_cs_definitions
        where
            name = p_definition_name;

        cursor c2 (p_id in number, p_column in varchar2) is
        select last_updated_by,
               last_update_date
          from msd_cs_defn_column_dtls
         where cs_definition_id = p_id
           and table_column = p_column;

    Begin
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;
        --
        open c1;
        fetch c1 into l_cs_definition_id;
        close c1;
        --
        if l_cs_definition_id is null then
            fnd_message.set_name('MSD', 'MSD_CS_LOAD_INVALID_DEFN');
            fnd_message.raise_error;
        end if;
        --
        open c2(l_cs_definition_id, p_table_column);
        fetch c2 into db_luby, db_ludate;

        if (c2%notfound) then
          raise no_data_found;
        end if;

        close c2;

        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
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
            update MSD_CS_DEFN_COLUMN_DTLS set
                source_view_column_name     = p_source_view_column_name,
                planning_view_column_name   = p_planning_view_column_name,
                column_identifier           = p_column_identifier,
          --            alt_key_flag                = p_alt_key_flag,
                uom_conversion_flag         = p_uom_conversion_flag,
                aggregation_type            = p_aggregation_type,
                allocation_type             = p_allocation_type,
                last_updated_by             = l_user,
                last_update_date            = f_ludate
              where
                cs_definition_id = l_cs_definition_id and
                table_column     = p_table_column;
          --
          end if;
      if (sql%notfound) then
        raise no_data_found;
      end if;
      --

End;
--
Procedure Insert_row (
       p_definition_name            in varchar2,
       p_table_column               in varchar2,
       p_column_identifier          in varchar2,
       p_source_view_column_name    in varchar2,
       p_planning_view_column_name  in varchar2,
--       p_alt_key_flag               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_uom_conversion_flag        in varchar2,
       p_owner                      in  varchar2,
       p_last_update_date           in varchar2
       ) is
       --
       --
       l_user               number;
       l_cs_column_dtls_id  number;
       l_cs_definition_id   number;
       f_ludate             date;    -- entity update date in file

        cursor c1 is
        select
            cs_definition_id
        from
            msd_cs_definitions
        where
            name = p_definition_name;
    Begin
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;
        --
        open c1;
        fetch c1 into l_cs_definition_id;
        close c1;
        --
        if l_cs_definition_id is null then
            fnd_message.set_name('MSD', 'MSD_CS_LOAD_INVALID_DEFN');
            fnd_message.raise_error;
        end if;
        -- Translate char last_update_date to date
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
        --
        select MSD_CS_DEFN_COLUMN_DTLS_S.nextval into l_cs_column_dtls_id from dual;
        --
        insert into MSD_CS_DEFN_COLUMN_DTLS(
            cs_column_dtls_id,
            cs_definition_id,
            source_view_column_name,
            planning_view_column_name,
            column_identifier,
            table_column,
--            alt_key_flag,
            uom_conversion_flag,
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
            l_cs_column_dtls_id,
            l_cs_definition_id,
            p_source_view_column_name,
            p_planning_view_column_name,
            p_column_identifier,
            p_table_column,
--            p_alt_key_flag,
            p_uom_conversion_flag,
            p_aggregation_type,
            p_allocation_type,
            l_user,
            f_ludate,
            l_user,
            f_ludate,
            fnd_global.login_id
        );
        --
End;
--
End;

/
