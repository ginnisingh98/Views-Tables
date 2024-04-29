--------------------------------------------------------
--  DDL for Package Body ECX_XREF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_XREF_API" as
/* $Header: ECXXRFAB.pls 120.2 2005/06/30 11:19:07 appldev ship $ */

----------------------------------+
-- XREFHDRAPI
----------------------------------+
PROCEDURE create_code_category(
 x_return_status	OUT     NOCOPY PLS_INTEGER,
 x_msg                  OUT	NOCOPY VARCHAR2,
 x_xref_hdr_id          OUT	NOCOPY PLS_INTEGER,
 p_xref_category_code   IN	VARCHAR2,
 p_description          IN	VARCHAR2,
 p_owner                IN      VARCHAR2
) is

cursor c_xref_hdr_id
is select ecx_xref_hdr_s.nextval
from dual;

i_c_by 	pls_integer := 0;
i_rowid	varchar2(240) := null;

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;
     x_xref_hdr_id := -1;

     -- make sure xref_category_code is not null.
     if (p_xref_category_code is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
       return;
     end if;

     if(p_owner = 'SEED') then
         i_c_by := 1;
     else
         i_c_by := 0;
     end if;

     open c_xref_hdr_id;
     fetch c_xref_hdr_id into x_xref_hdr_id;
     close c_xref_hdr_id;

     ECX_XREF_HDR_PKG.insert_row (
        X_ROWID              => i_rowid,
        X_XREF_CATEGORY_CODE => p_xref_category_code,
        X_XREF_CATEGORY_ID   => x_xref_hdr_id,
        X_DESCRIPTION        => p_description,
        X_CREATION_DATE      => sysdate,
        X_CREATED_BY         => i_c_by,
        X_LAST_UPDATE_DATE   => sysdate,
        X_LAST_UPDATED_BY    => i_c_by,
        X_LAST_UPDATE_LOGIN  => i_c_by
    );
exception
    when dup_val_on_index then
        if c_xref_hdr_id%ISOPEN then
          CLOSE c_xref_hdr_id;
        end if;
        x_xref_hdr_id := -1;
        x_return_status := ECX_UTIL_API.G_DUP_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_EXISTS',
                                                'p_xref_category_code', p_xref_category_code);
    when others then
        if c_xref_hdr_id%ISOPEN then
          CLOSE c_xref_hdr_id;
        end if;
        x_xref_hdr_id := -1;
        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
end;


PROCEDURE delete_code_category(
   x_return_status     OUT  NOCOPY PLS_INTEGER,
   x_msg               OUT  NOCOPY VARCHAR2,
   p_xref_category_id  IN   PLS_INTEGER
 ) IS

i_num pls_integer := 0;
l_xref_cat_code varchar2(30);

 cursor c is
 select 1 from ecx_object_attributes
 where xref_category_id = p_xref_category_id;

 cursor get_refrences is
 select count(*) from ecx_xref_standards exs,
               ecx_xref_dtl exd
 where   exs.xref_category_id = p_xref_category_id
 and     exd.xref_category_id = p_xref_category_id;

begin

     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     if (p_xref_category_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CATEGORY_ID_NOT_NULL');
       return;
     end if;

     -- make sure xref_category is not used in any maps.
     open c;
     fetch c into i_num;
     close c;

     if (i_num = 1) then
         x_return_status := ECX_UTIL_API.G_REFER_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_REFERENCED',
                                    'p_category_id', p_xref_category_id);
         return;
     end if;

     i_num := 0;
     open get_refrences;
     fetch get_refrences into i_num;
     close get_refrences;

     if (i_num > 0)
     then
         x_return_status := ECX_UTIL_API.G_REFER_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_REFERENCED',
                                    'p_category_id', p_xref_category_id);
        return;
     end if;

     ECX_XREF_HDR_PKG.delete_row (
        X_XREF_CATEGORY_ID => p_xref_category_id
     );

  exception
    when no_data_found then
        x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
                                                'p_table', 'ecx_xref_hdr',
                                                'p_param_name', 'Category Code ID',
                                                'p_param_id', p_xref_category_id);
    when others then
      if get_refrences%ISOPEN then
         CLOSE get_refrences;
      end if;

      if c%ISOPEN then
         CLOSE c;
      end if;
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
end;


PROCEDURE update_code_category(
   x_return_status        OUT   NOCOPY PLS_INTEGER,
   x_msg                  OUT   NOCOPY VARCHAR2,
   p_xref_category_id     IN    PLS_INTEGER,
   p_xref_category_code   IN    VARCHAR2,
   p_description          IN    VARCHAR2,
   p_owner                IN    VARCHAR2
) is

i_u_by  		pls_integer := 0;

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     -- make sure xref_category_code is not null.
     if (p_xref_category_code is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
       return;
     elsif (p_xref_category_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CATEGORY_ID_NOT_NULL');
       return;
     end if;

     if(p_owner = 'SEED') then
         i_u_by := 1;
     else
         i_u_by := 0;
     end if;

     ECX_XREF_HDR_PKG.update_row (
        X_XREF_CATEGORY_ID    => p_xref_category_id,
        X_XREF_CATEGORY_CODE  => p_xref_category_code,
  	X_DESCRIPTION         => p_description,
	X_LAST_UPDATE_DATE    => sysdate,
  	X_LAST_UPDATED_BY     => i_u_by,
  	X_LAST_UPDATE_LOGIN   => i_u_by
     );

  exception
     when no_data_found then
        x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                                'p_table', 'ecx_xref_hdr_tl',
                                                'p_param_name', 'Cateogry Code ID',
                                                'p_param_id', p_xref_category_id);

     when dup_val_on_index then
       x_return_status := ECX_UTIL_API.G_DUP_ERROR;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_EXISTS',
                          'p_xref_category_code', p_xref_category_code);
     when others then
       x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
       x_msg := SQLERRM;
end;

----------------------------------+
-- XREFDTLAPI
----------------------------------+
PROCEDURE retrieve_tp_external_value(
      x_return_status       OUT  NOCOPY PLS_INTEGER,
      x_msg                 OUT  NOCOPY VARCHAR2,
      x_xref_ext_value      OUT  NOCOPY VARCHAR2,
      p_tp_header_id        IN   PLS_INTEGER,
      p_xref_category_code  IN   VARCHAR2,
      p_standard            IN   VARCHAR2,
      p_xref_int_value      IN   VARCHAR2,
      x_xref_dtl_id         OUT  NOCOPY PLS_INTEGER,
      p_standard_type	    IN   VARCHAR2
) IS
begin

     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     x_xref_dtl_id := -1;
     x_xref_ext_value := null;

     if (p_xref_category_code is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
          return;
     elsif p_standard is null then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
          return;
     elsif (p_tp_header_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
          return;
     elsif (p_xref_int_value is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_INT_VAL_NOT_NULL');
          return;
     end if;

     select xref_dtl_id,
            exd.xref_ext_value
       into x_xref_dtl_id,
            x_xref_ext_value
       from ECX_XREF_HDR exh,
            ECX_XREF_DTL exd,
            ECX_STANDARDS es
      where exh.xref_category_code = p_xref_category_code
        and exh.xref_category_id   = exd.xref_category_id
        and exd.direction          = 'OUT'
        and exd.xref_int_value     = p_xref_int_value
        and es.standard_id         = exd.standard_id
        and es.standard_code       = p_standard
        and exd.tp_header_id       = p_tp_header_id
        and es.standard_type       = nvl(p_standard_type, 'XML');
exception
       when too_many_rows then
         x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
         x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_INT_TOO_MANY_ROWS',
                           'p_standard_code', p_standard,
                           'p_xref_category_code', p_xref_category_code,
                           'p_tp_header_id', p_tp_header_id,
                           'p_xref_int_value',  p_xref_int_value);
       when no_data_found then
         x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_INT_ID_NOT_FOUND',
                            'p_standard_code', p_standard,
                            'p_xref_category_code', p_xref_category_code,
                            'p_tp_header_id', p_tp_header_id,
                            'p_xref_int_value',  p_xref_int_value);
       when others then
         x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
         x_msg := SQLERRM;
end;


PROCEDURE retrieve_tp_internal_value(
      x_return_status       OUT  NOCOPY PLS_INTEGER,
      x_msg                 OUT  NOCOPY VARCHAR2,
      x_xref_int_value      OUT  NOCOPY VARCHAR2,
      p_tp_header_id        IN   PLS_INTEGER,
      p_xref_category_code  IN   VARCHAR2,
      p_standard            IN   VARCHAR2,
      p_xref_ext_value      IN   VARCHAR2,
      x_xref_dtl_id         OUT  NOCOPY PLS_INTEGER,
      p_standard_type       IN   VARCHAR2
) IS
begin

     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;
     x_xref_int_value := null;
     x_xref_dtl_id := -1;

     if (p_xref_category_code is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
          return;
     elsif p_standard is null then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
          return;
     elsif (p_tp_header_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
          return;
     elsif (p_xref_ext_value is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_EXT_VAL_NOT_NULL');
          return;
     end if;

     select xref_dtl_id,
            exd.xref_int_value
       into x_xref_dtl_id,
            x_xref_int_value
       from ECX_XREF_HDR exh,
            ECX_XREF_DTL exd,
            ECX_STANDARDS es
      where exh.xref_category_code = p_xref_category_code
        and exh.xref_category_id   = exd.xref_category_id
        and exd.direction          = 'IN'
        and exd.xref_ext_value     = p_xref_ext_value
        and es.standard_id         = exd.standard_id
        and es.standard_code       = p_standard
        and exd.tp_header_id       = p_tp_header_id
        and es.standard_type       = nvl(p_standard_type, 'XML');
exception
        when too_many_rows then
         x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
         x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_EXT_TOO_MANY_ROWS',
                            'p_standard_code', p_standard,
                            'p_xref_category_code', p_xref_category_code,
                            'p_tp_header_id', p_tp_header_id,
                            'p_xref_ext_value', p_xref_ext_value);
       when no_data_found then
         x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_EXT_ID_NOT_FOUND',
                            'p_standard_code',  p_standard,
                            'p_xref_category_code',  p_xref_category_code,
                            'p_tp_header_id',  p_tp_header_id,
                            'p_xref_ext_value',  p_xref_ext_value);
       when others then
         x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
         x_msg := SQLERRM;
end;


PROCEDURE retrieve_tp_code_values_by_id(
   x_return_status       OUT  NOCOPY PLS_INTEGER,
   x_msg                 OUT  NOCOPY VARCHAR2,
   x_xref_category_code  OUT  NOCOPY VARCHAR2,
   x_standard_code       OUT  NOCOPY VARCHAR2,
   x_xref_ext_value      OUT  NOCOPY VARCHAR2,
   x_xref_int_value      OUT  NOCOPY VARCHAR2,
   x_direction           OUT  NOCOPY VARCHAR2,
   p_xref_dtl_id         IN   PLS_INTEGER,
   x_cat_description     OUT  NOCOPY VARCHAR2,
   x_xref_category_id    OUT  NOCOPY NUMBER,
   x_standard_id         OUT  NOCOPY PLS_INTEGER,
   x_tp_header_id        OUT  NOCOPY PLS_INTEGER,
   x_description         OUT  NOCOPY VARCHAR2,
   x_created_by          OUT  NOCOPY PLS_INTEGER,
   x_creation_date       OUT  NOCOPY DATE,
   x_last_updated_by     OUT  NOCOPY PLS_INTEGER,
   x_last_update_date    OUT  NOCOPY DATE
) is
begin

     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;


     if (p_xref_dtl_id is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_ID_NOT_NULL');
          return;
     end if;

    select
           exh.xref_category_code,
           es.standard_code,
           exd.xref_ext_value,
           exd.xref_int_value,
           exd.direction,
           exh.DESCRIPTION       HDR_DESCRIPTION,
           exd.XREF_CATEGORY_ID  XREF_CATEGORY_ID,
           es.STANDARD_ID,
           TP_HEADER_ID,
           exd.DESCRIPTION       DTL_DESCRIPTION,
           exd.LAST_UPDATE_DATE,
           exd.LAST_UPDATED_BY,
           exd.CREATION_DATE,
           exd.CREATED_BY
      into
           x_xref_category_code,
           x_standard_code,
           x_xref_ext_value,
           x_xref_int_value,
           x_direction,
           x_cat_description,
           x_xref_category_id,
           x_standard_id,
           x_tp_header_id,
           x_description,
           x_last_update_date,
           x_last_updated_by,
           x_creation_date,
           x_created_by
      from ECX_XREF_HDR_VL exh,
           ECX_XREF_DTL_VL exd,
           ECX_STANDARDS es
     where exh.xref_category_id      = exd.xref_category_id
       and exd.xref_dtl_id           = p_xref_dtl_id
       and es.standard_id            = exd.standard_id;
exception
      when too_many_rows then
         x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
         x_msg := ecx_debug.getTranslatedMessage('ECX_TOO_MANY_ROWS',
                                                 'p_table', 'ECX_XREF_DTL',
                                                 'p_key', p_xref_dtl_id);

       when no_data_found then
         x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_NOT_FOUND',
                                                 'p_table', 'ECX_XREF_DTL',
                                                 'p_key', p_xref_dtl_id);
       when others then
         x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
         x_msg := SQLERRM;
end;


PROCEDURE retrieve_tp_code_values(
   x_return_status       OUT  NOCOPY PLS_INTEGER,
   x_msg                 OUT  NOCOPY VARCHAR2,
   x_xref_dtl_id         OUT  NOCOPY PLS_INTEGER,
   x_xref_category_id    OUT  NOCOPY PLS_INTEGER,
   p_xref_category_code  IN   VARCHAR2,
   p_standard            IN   VARCHAR2,
   p_xref_ext_value      IN   VARCHAR2,
   p_xref_int_value      IN   VARCHAR2,
   p_direction           IN   VARCHAR2,
   x_cat_description     OUT  NOCOPY VARCHAR2,
   x_standard_id         OUT  NOCOPY PLS_INTEGER,
   x_tp_header_id        OUT  NOCOPY PLS_INTEGER,
   x_description         OUT  NOCOPY VARCHAR2,
   x_created_by          OUT  NOCOPY PLS_INTEGER,
   x_creation_date       OUT  NOCOPY DATE,
   x_last_updated_by     OUT  NOCOPY PLS_INTEGER,
   x_last_update_date    OUT  NOCOPY DATE,
   p_standard_type       IN  VARCHAR2
) is
begin

     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     x_xref_dtl_id := -1;

     if (p_xref_category_code is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
          return;
     elsif (p_standard is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
          return;
     elsif (p_xref_ext_value is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_EXT_VAL_NOT_NULL');
          return;
     elsif (p_xref_int_value is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_INT_VAL_NOT_NULL');
          return;
     elsif (p_direction is null) then
          x_return_status := ECX_UTIL_API.G_NULL_PARAM;
          x_msg := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
          return;
     end if;

     if NOT (ecx_util_api.validate_direction(p_direction)) then
       x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DIRECTION',
                                               'p_direction', p_direction);
       return;
     end if;


     select
           exh.DESCRIPTION       HDR_DESCRIPTION,
           XREF_DTL_ID,
           exd.XREF_CATEGORY_ID  XREF_CATEGORY_ID,
           es.STANDARD_ID,
           TP_HEADER_ID,
           exd.DESCRIPTION       DTL_DESCRIPTION,
           exd.LAST_UPDATE_DATE,
           exd.LAST_UPDATED_BY,
           exd.CREATION_DATE,
           exd.CREATED_BY
     into
           x_cat_description,
           x_xref_dtl_id,
           x_xref_category_id,
           x_standard_id,
           x_tp_header_id,
           x_description,
           x_last_update_date,
           x_last_updated_by,
           x_creation_date,
           x_created_by
      from ECX_XREF_HDR_VL exh,
           ECX_XREF_DTL_VL exd,
           ECX_STANDARDS es
     where exh.xref_category_code = p_xref_category_code
       and exh.xref_category_id   = exd.xref_category_id
       and exd.direction          = p_direction
       and exd.xref_ext_value     = p_xref_ext_value
       and exd.xref_int_value     = p_xref_int_value
       and es.standard_id         = exd.standard_id
       and es.standard_code       = p_standard
       and es.standard_type       = nvl(p_standard_type, 'XML');
exception
       when no_data_found then
         x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_NOT_FOUND',
                            'p_standard_code', p_standard,
                            'p_xref_category_code', p_xref_category_code,
                            'p_direction' , p_direction,
                            'p_xref_ext_value', p_xref_ext_value,
                            'p_xref_int_value', p_xref_int_value,
			    'p_standard_type', p_standard_type);
       when others then
         x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
         x_msg := SQLERRM;
end;


PROCEDURE create_tp_code_values(
   x_return_status        OUT   NOCOPY PLS_INTEGER,
   x_msg                  OUT   NOCOPY VARCHAR2,
   x_xref_dtl_id          OUT   NOCOPY PLS_INTEGER,
   x_xref_category_id     OUT   NOCOPY PLS_INTEGER,
   p_xref_category_code   IN    VARCHAR2,
   p_standard             IN    VARCHAR2,
   p_tp_header_id         IN    PLS_INTEGER,
   p_xref_ext_value       IN    VARCHAR2,
   p_xref_int_value       IN    VARCHAR2,
   p_description          IN    VARCHAR2,
   p_direction            IN    VARCHAR2,
   p_standard_type	  IN    VARCHAR2

) is

i_standard_id pls_integer := 0;
i_rowid	      varchar2(200) := null;

begin

     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     x_xref_dtl_id := -1;
     x_xref_category_id := -1;

     if (p_xref_category_code is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
       return;
     elsif (p_standard is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
       return;
     elsif (p_xref_ext_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_EXT_VAL_NOT_NULL');
       return;
     elsif (p_xref_int_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_INT_VAL_NOT_NULL');
       return;
     elsif (p_tp_header_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
       return;
     elsif (p_direction is null) then
        x_return_status := ECX_UTIL_API.G_NULL_PARAM;
        x_msg := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
        return;
     end if;

     if NOT (ecx_util_api.validate_direction(p_direction)) then
       x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DIRECTION',
                                               'p_direction', p_direction);
       return;
     end if;

    if NOT (ecx_util_api.validate_trading_partner(p_tp_header_id))
    then
       x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_TP_HDR_ID',
                                               'p_tp_header_id', p_tp_header_id);
       return;
    end if;

     begin
        select xref_category_id
          into x_xref_category_id
          from ecx_xref_hdr
         where xref_category_code = p_xref_category_code;
     exception
        when no_data_found then
          x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
          x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_FOUND',
                            'p_xref_category_code', p_xref_category_code);
          return;
     end;

     select standard_id
     into   i_standard_id
     from   ecx_standards
     where  standard_code = p_standard
     and    standard_type = nvl(p_standard_type, 'XML');

     select ecx_xref_dtl_s.nextval into x_xref_dtl_id from dual;

     ECX_XREF_DTL_PKG. insert_row (
        X_ROWID              => i_rowid,
        X_XREF_DTL_ID        => x_xref_dtl_id,
	X_XREF_CATEGORY_ID   => x_xref_category_id,
  	X_STANDARD_ID        => i_standard_id,
  	X_XREF_STANDARD_CODE => p_standard,
  	X_TP_HEADER_ID       => p_tp_header_id,
  	X_XREF_EXT_VALUE     => p_xref_ext_value,
  	X_XREF_INT_VALUE     => p_xref_int_value,
  	X_DIRECTION          => p_direction,
  	X_DESCRIPTION        => p_description,
  	X_CREATION_DATE      => sysdate,
  	X_CREATED_BY         => 0,
  	X_LAST_UPDATE_DATE   => sysdate,
  	X_LAST_UPDATED_BY    => 0,
  	X_LAST_UPDATE_LOGIN  => 0
     );
exception
   when no_data_found then
      x_xref_dtl_id := -1;
      x_xref_category_id := -1;
      x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
      x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_FOUND',
	                                      'p_standard', p_standard,
                                              'p_std_type', p_standard_type);
    when dup_val_on_index then
      x_xref_dtl_id := -1;
      x_xref_category_id := -1;
      x_return_status := ECX_UTIL_API.G_DUP_ERROR;
      x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_ROW_EXISTS',
                           'p_xref_category_code', p_xref_category_code,
                           'p_standard_code', p_standard,
                           'p_xref_ext_value',p_xref_ext_value,
                           'p_xref_int_value', p_xref_int_value,
                           'p_direction',  p_direction);
    when others then
      x_xref_dtl_id := -1;
      x_xref_category_id := -1;
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
end;


PROCEDURE update_tp_code_values(
   x_return_status      OUT    NOCOPY PLS_INTEGER,
   x_msg                OUT    NOCOPY VARCHAR2,
   p_xref_dtl_id        IN     PLS_INTEGER,
   p_xref_ext_value     IN     VARCHAR2,
   p_xref_int_value     IN     VARCHAR2,
   p_tp_header_id       IN     PLS_INTEGER,
   p_description        IN     VARCHAR2,
   p_direction          IN     VARCHAR2
) is

l_xref_cat_id		ecx_xref_hdr.xref_category_id%type;
l_standard_id		ecx_xref_standards.standard_id%type;
l_tp_header_id		ecx_xref_dtl.tp_header_id%type;
l_xref_int_value	ecx_xref_dtl.xref_int_value%type;
l_xref_ext_value	ecx_xref_dtl.xref_ext_value%type;
l_direction		ecx_xref_dtl.direction%type;

cursor get_xref_dtl_data is
select xref_category_id,
       standard_id,
       tp_header_id,
       xref_int_value,
       xref_ext_value,
       direction
from ecx_xref_dtl
where xref_dtl_id = p_xref_dtl_id;

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     if (p_xref_dtl_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_ID_NOT_NULL');
       return;
     elsif (p_xref_ext_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_EXT_VAL_NOT_NULL');
       return;
     elsif (p_xref_int_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_INT_VAL_NOT_NULL');
       return;
     elsif (p_tp_header_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_TP_HDR_ID_NOT_NULL');
       return;
     elsif (p_direction is null) then
        x_return_status := ECX_UTIL_API.G_NULL_PARAM;
        x_msg := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
        return;
     end if;

     if NOT(ecx_util_api.validate_direction(p_direction)) then
       x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DIRECTION',
                                               'p_direction', p_direction);
       return;
     end if;

     if NOT (ecx_util_api.validate_trading_partner(p_tp_header_id))
     then
       x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_TP_HDR_ID',
                                               'p_tp_header_id', p_tp_header_id);
       return;
     end if;

     open  get_xref_dtl_data;
     fetch get_xref_dtl_data
     into  l_xref_cat_id,
           l_standard_id,
           l_tp_header_id,
           l_xref_int_value,
           l_xref_ext_value,
           l_direction;
     close get_xref_dtl_data;

     update ECX_XREF_DTL set
	    XREF_EXT_VALUE = p_xref_ext_value,
            XREF_INT_VALUE = p_xref_int_value,
            TP_HEADER_ID = p_tp_header_id,
            DIRECTION = p_direction,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = 0
     where  XREF_DTL_ID = p_xref_dtl_id;

     if (sql%rowcount = 0) then
       x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
       x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                               'p_table', 'ecx_xref_dtl',
                                               'p_param_name', 'Xref detail ID',
                                               'p_param_id', p_xref_dtl_id);
       return;
     end if;

     -- update description for only the current language
     update ECX_XREF_DTL_TL set
            DESCRIPTION = p_description,
            SOURCE_LANG = userenv('LANG')
     where  XREF_DTL_ID = p_xref_dtl_id
     and    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

     if (sql%rowcount = 0) then
       x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
       x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                               'p_table', 'ecx_xref_dtl',
                                               'p_param_name', 'Xref detail ID',
                                               'p_param_id', p_xref_dtl_id);
       return;
     end if;
exception
   when dup_val_on_index then
	if get_xref_dtl_data%ISOPEN
   	then
     	   CLOSE get_xref_dtl_data;
        end if;

        x_return_status := ECX_UTIL_API.G_DUP_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_ID_ROW_EXISTS',
                           'p_tp_header_id', p_tp_header_id,
                           'p_xref_ext_value', p_xref_ext_value,
                           'p_xref_int_value', p_xref_int_value,
                           'p_direction', p_direction);
   when others then
	if get_xref_dtl_data%ISOPEN
   	then
     	   CLOSE get_xref_dtl_data;
        end if;

        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
end;


PROCEDURE delete_tp_code_values(
  x_return_status  OUT   NOCOPY PLS_INTEGER,
  x_msg            OUT   NOCOPY VARCHAR2,
  p_xref_dtl_id    IN    PLS_INTEGER
) is

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     if (p_xref_dtl_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_DTL_ID_NOT_NULL');
       return;
     end if;

     ECX_XREF_DTL_PKG.delete_row (
	X_XREF_DTL_ID  => p_xref_dtl_id
     );
exception
    when no_data_found then
       x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
       x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
                                               'p_table', 'ecx_xref_dtl',
                                               'p_param_name', 'Xref detail ID',
                                               'p_param_id', p_xref_dtl_id);
    when others then
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
end;

--------------------------------------+
-- XREFSTDAPI
--------------------------------------+
PROCEDURE retrieve_standard_code_values(
  x_return_status      OUT  NOCOPY PLS_INTEGER,
  x_msg                OUT  NOCOPY VARCHAR2,
  x_xref_std_id        OUT  NOCOPY PLS_INTEGER,
  x_xref_category_id   OUT  NOCOPY PLS_INTEGER,
  p_xref_category_code IN   VARCHAR2,
  p_standard           IN   VARCHAR2,
  p_xref_std_value     IN   VARCHAR2,
  p_xref_int_value     IN   VARCHAR2,
  x_cat_description    OUT  NOCOPY VARCHAR2,
  x_standard_id        OUT  NOCOPY PLS_INTEGER,
  x_description        OUT  NOCOPY VARCHAR2,
  x_data_seeded        OUT  NOCOPY VARCHAR2,
  x_created_by         OUT  NOCOPY PLS_INTEGER,
  x_creation_date      OUT  NOCOPY DATE,
  x_last_updated_by    OUT  NOCOPY PLS_INTEGER,
  x_last_update_date   OUT  NOCOPY DATE,
  p_standard_type      IN   VARCHAR2
) is

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     if (p_xref_category_code is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
       return;
     elsif (p_standard is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
       return;
     elsif (p_xref_std_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STD_VAL_NOT_NULL');
       return;
     elsif (p_xref_int_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_INT_VAL_NOT_NULL');
       return;
     end if;

     select exh.DESCRIPTION       HDR_DESCRIPTION,
            XREF_STANDARD_ID,
            exs.XREF_CATEGORY_ID  XREF_CATEGORY_ID,
            exs.STANDARD_ID       STANDARD_ID,
            exs.DESCRIPTION       DTL_DESCRIPTION,
            exs.DATA_SEEDED,
            exs.LAST_UPDATE_DATE,
            exs.LAST_UPDATED_BY,
            exs.CREATION_DATE,
            exs.CREATED_BY
      into  x_cat_description,
            x_xref_std_id,
            x_xref_category_id,
            x_standard_id,
            x_description,
            x_data_seeded,
            x_last_update_date,
            x_last_updated_by,
            x_creation_date,
            x_created_by
       from ECX_XREF_HDR_vl exh,
            ECX_XREF_STANDARDS_vl exs,
            ECX_STANDARDS es
      where exh.xref_category_code = p_xref_category_code
        and exh.xref_category_id   = exs.xref_category_id
        and exs.xref_std_value     = p_xref_std_value
        and exs.xref_int_value     = p_xref_int_value
        and es.standard_id         = exs.standard_id
        and es.standard_code       = p_standard
        and es.standard_type       = nvl(p_standard_type, 'XML');

    exception
       when no_data_found then
         x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STD_NOT_FOUND',
                            'p_xref_category_code', p_xref_category_code,
                            'p_xref_std_value', p_xref_std_value,
                            'p_xref_int_value', p_xref_int_value,
                            'p_standard', p_standard,
			    'p_std_type', p_standard_type);
       when others then
         x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
         x_msg := SQLERRM;
end;


PROCEDURE create_standard_code_values(
  x_return_status       OUT     NOCOPY PLS_INTEGER,
  x_msg                 OUT     NOCOPY VARCHAR2,
  x_xref_std_id         OUT     NOCOPY PLS_INTEGER,
  x_xref_category_id	OUT	NOCOPY PLS_INTEGER,
  p_xref_category_code	IN      VARCHAR2,
  p_standard            IN      VARCHAR2,
  p_xref_std_value	IN      VARCHAR2,
  p_xref_int_value	IN      VARCHAR2,
  p_description         IN      VARCHAR2,
  p_data_seeded         IN      VARCHAR2,
  p_owner               IN      VARCHAR2,
  p_standard_type       IN      VARCHAR2
) is

i_standard_id   number :=0;
i_c_by          pls_integer :=0;
i_rowid		varchar2(200) := null;

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     if (p_xref_category_code is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_NULL');
       return;
     elsif (p_standard is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
       return;
     elsif (p_xref_std_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STD_VAL_NOT_NULL');
       return;
     elsif (p_xref_int_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_INT_VAL_NOT_NULL');
       return;
     elsif (p_data_seeded is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_DATA_SEEDED_NOT_NULL');
       return;
     end if;

     -- validate data seeded flag
     If NOT ecx_util_api.validate_data_seeded_flag(p_data_seeded)
     then
        x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
        x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DATA_SEEDED',
                          'p_data_seeded', p_data_seeded);
        return;
     end If;

     begin
        select xref_category_id
          into x_xref_category_id
          from ecx_xref_hdr
         where xref_category_code = p_xref_category_code;

     exception
        when no_data_found then
          x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
          x_msg := ecx_debug.getTranslatedMessage('ECX_CODE_CATEGORY_NOT_FOUND',
                            'p_xref_category_code', p_xref_category_code);
          return;
     end;

     begin
       select standard_id
       into   i_standard_id
       from   ecx_standards
       where  standard_code = p_standard
       and    standard_type = nvl(p_standard_type, 'XML');
     exception
       when no_data_found then
         x_xref_category_id := -1;
         x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_FOUND',
                                                 'p_standard', p_standard,
                                                 'p_std_type', p_standard_type);
         return;
     end;

     if p_owner = 'SEED'
     then
            if p_data_seeded = 'Y'
            then
               i_c_by :=1;
            else
              x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
              x_msg := ecx_debug.getTranslatedMessage('ECX_DATA_OWNER_INCONSISTENT',
                                 'p_data_seeded', p_data_seeded,
                                 'p_owner', p_owner);
              return;
            end if;
     elsif p_owner = 'CUSTOM'
     then
            if NOT (p_data_seeded = 'Y')
            then
               i_c_by :=0;
            else
              x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
              x_msg := ecx_debug.getTranslatedMessage('ECX_DATA_OWNER_INCONSISTENT',
                                 'p_data_seeded', p_data_seeded,
                                 'p_owner', p_owner);

              return;
            end if;
     else
           x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
           x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_OWNER',
                                 'p_owner', p_owner);
           return;
     end if;

     select ecx_xref_standards_s.nextval
        into x_xref_std_id from dual;

     ECX_XREF_STANDARDS_PKG.insert_row (
  	X_ROWID               => i_rowid,
  	X_XREF_STANDARD_ID    => x_xref_std_id,
  	X_XREF_CATEGORY_ID    => x_xref_category_id,
  	X_STANDARD_ID         => i_standard_id,
  	X_XREF_STANDARD_CODE  => p_standard,
  	X_XREF_STD_VALUE      => p_xref_std_value,
  	X_XREF_INT_VALUE      => p_xref_int_value,
  	X_DATA_SEEDED         => p_data_seeded,
  	X_DESCRIPTION         => p_description,
  	X_CREATION_DATE       => sysdate,
  	X_CREATED_BY          => i_c_by,
  	X_LAST_UPDATE_DATE    => sysdate,
  	X_LAST_UPDATED_BY     => i_c_by,
  	X_LAST_UPDATE_LOGIN   => i_c_by
     );

    exception
       when dup_val_on_index then
         x_xref_category_id := -1;
         x_xref_std_id := -1;
         x_return_status := ECX_UTIL_API.G_DUP_ERROR;
         x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STD_ROW_EXISTS',
                           'p_standard', p_standard,
                           'p_xref_std_value',p_xref_std_value,
                           'p_xref_int_value', p_xref_int_value);
       when others then
         x_xref_category_id := -1;
         x_xref_std_id := -1;
         x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
         x_msg := SQLERRM;
end;


PROCEDURE update_standard_code_values(
  x_return_status     OUT  NOCOPY PLS_INTEGER,
  x_msg               OUT  NOCOPY VARCHAR2,
  p_xref_standard_id  IN   PLS_INTEGER,
  p_xref_std_value    IN   VARCHAR2,
  p_xref_int_value    IN   VARCHAR2,
  p_description       IN   VARCHAR2,
  p_owner             IN   VARCHAR2
) is
i_u_by 			pls_integer := 0;
l_xref_cat_id		ecx_xref_hdr.xref_category_id%type;
l_standard_id		ecx_xref_standards.standard_id%type;
l_xref_std_value	ecx_xref_standards.xref_std_value%type;
l_xref_int_value	ecx_xref_standards.xref_int_value%type;

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     if (p_xref_standard_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STANDARD_ID_NOT_NULL');
       return;
     elsif (p_xref_std_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STD_VAL_NOT_NULL');
       return;
     elsif (p_xref_int_value is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_INT_VAL_NOT_NULL');
       return;
     end if;

     if(p_owner = 'SEED') then
         i_u_by := 1;
     else
         i_u_by := 0;
     end if;

     update ECX_XREF_STANDARDS set
            XREF_STD_VALUE = p_xref_std_value,
            XREF_INT_VALUE = p_xref_int_value,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = i_u_by,
            LAST_UPDATE_LOGIN = i_u_by
     where  XREF_STANDARD_ID = p_xref_standard_id;

     if (sql%rowcount = 0) then
       x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
       x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                              'p_table', 'ecx_xref_standards',
                                              'p_param_name', 'Xref standard ID',
                                              'p_param_id', p_xref_standard_id);
       return;
     end if;

     -- update description for the current language
     update ECX_XREF_STANDARDS_TL set
            DESCRIPTION = p_description,
            SOURCE_LANG = userenv('LANG')
     where  XREF_STANDARD_ID = p_xref_standard_id
     and    userenv('LANG') in (LANGUAGE, SOURCE_LANG);

     if (sql%rowcount = 0) then
       x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
       x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                              'p_table', 'ecx_xref_standards',
                                              'p_param_name', 'Xref standard ID',
                                              'p_param_id', p_xref_standard_id);
       return;
     end if;
exception
   when dup_val_on_index then
        x_return_status := ECX_UTIL_API.G_DUP_ERROR;
        x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STD_ID_ROW_EXISTS',
                           'p_xref_standard_id', p_xref_standard_id,
                           'p_xref_std_value',p_xref_std_value,
                           'p_xref_int_value', p_xref_int_value);
   when others then
        x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := SQLERRM;
end;


PROCEDURE delete_standard_code_values(
  x_return_status     OUT  NOCOPY PLS_INTEGER,
  x_msg               OUT  NOCOPY VARCHAR2,
  p_xref_standard_id  IN   PLS_INTEGER
) is

begin
     x_return_status := ECX_UTIL_API.G_NO_ERROR;
     x_msg := null;

     if (p_xref_standard_id is null) then
       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
       x_msg := ecx_debug.getTranslatedMessage('ECX_XREF_STANDARD_ID_NOT_NULL');
       return;
     end if;

     ECX_XREF_STANDARDS_PKG.delete_row (
	X_XREF_STANDARD_ID  => p_xref_standard_id
     );

exception
    when no_data_found then
       x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
       x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
                                               'p_table', 'ecx_xref_standards',
                                               'p_param_name', 'Xref standard ID',
                                               'p_param_id', p_xref_standard_id);
    when others then
      x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
      x_msg := SQLERRM;
end;


end ECX_XREF_API;

/
