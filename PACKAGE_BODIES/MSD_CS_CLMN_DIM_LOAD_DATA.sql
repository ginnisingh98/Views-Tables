--------------------------------------------------------
--  DDL for Package Body MSD_CS_CLMN_DIM_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CS_CLMN_DIM_LOAD_DATA" as
/* $Header: msdcscdb.pls 120.2 2006/06/02 08:58:48 brampall noship $ */

    Procedure load_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_table_column               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2
       ) is
    Begin
        --
         Update_row(
           p_definition_name            ,
           p_dimension_code             ,
           p_table_column               ,
           p_aggregation_type           ,
           p_allocation_type            ,
           p_owner                      ,
           p_last_update_date           ,
           p_custom_mode                );
    Exception
    when no_data_found then
        Insert_row(
           p_definition_name            ,
           p_dimension_code             ,
           p_table_column               ,
           p_aggregation_type           ,
           p_allocation_type            ,
           p_owner                      ,
           p_last_update_date           );
    End;
    --
--
    Procedure Update_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_table_column               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2,
       p_custom_mode                in varchar2
       )  is
        --
        --
        l_user              number;
        l_cs_id             number;

        cursor c1 is
        select cs_clmn_dim_dtls_id,
               last_updated_by,
               last_update_date
            from MSD_CS_CLMN_DIM_DTLS_V
        where
            cs_definition_id = (select cs_definition_id from msd_cs_definitions where name = p_definition_name) and
            table_column = p_table_column and
            dimension_code = p_dimension_code;

        f_ludate  date;    -- entity update date in file
        db_luby   number;  -- entity owner in db
        db_ludate date;    -- entity update date in db
    --
    Begin
        --
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;
        --
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
        --
        open c1;
        fetch c1 into l_cs_id, db_luby, db_ludate;
        close c1;
        --
        if l_cs_id is null then
            raise no_data_found;
        end if;
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

            update MSD_CS_CLMN_DIM_DTLS set
               aggregation_type            = p_aggregation_type,
               allocation_type             = p_allocation_type,
               last_updated_by             = l_user,
               last_update_date            = f_ludate
            where
               cs_clmn_dim_dtls_id = l_cs_id;

          end if;
      --
      if (sql%notfound) then
        raise no_data_found;
      end if;
      --

End;
--
Procedure Insert_row (
       p_definition_name            in varchar2,
       p_dimension_code             in varchar2,
       p_table_column               in varchar2,
       p_aggregation_type           in varchar2,
       p_allocation_type            in varchar2,
       p_owner                      in varchar2,
       p_last_update_date           in varchar2
       ) is
       --
        --
        l_user               number;
        --
        l_cs_id1            number;
        l_cs_id2            number;
        l_pk_id             number;
        f_ludate            date;    -- entity update date in file
        --
        cursor c1 is
        select cs_defn_dim_dtls_id
            from msd_cs_defn_dim_dtls
        where
            cs_definition_id = (select cs_definition_id from msd_cs_definitions where name = p_definition_name) and
            dimension_code = p_dimension_code;
        --
        cursor c2 is
        select cs_column_dtls_id
    		from msd_cs_defn_column_dtls
				where cs_definition_id = (select cs_definition_id from msd_cs_definitions where name =p_definition_name)
				and table_column = p_table_column;

      Begin
        --
        if p_owner = 'SEED' then
            l_user  := 1;
        else
            l_user := 0;
        end if;
        --
        f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
        --
        open c1;
        fetch c1 into l_cs_id1;
        close c1;
        --
        open c2;
        fetch c2 into l_cs_id2;
        close c2;
        --
        if l_cs_id1 is null or l_cs_id2 is null then
            raise NO_DATA_FOUND;
        end if;
        --
        select MSD_CS_CLMN_DIM_DTLS_S.nextval into l_PK_id from dual;
        --
        insert into MSD_CS_CLMN_DIM_DTLS(
            cs_clmn_dim_dtls_id,
            cs_defn_dim_dtls_id,
            cs_column_dtls_id,
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
            l_cs_id1,
            l_cs_id2,
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
