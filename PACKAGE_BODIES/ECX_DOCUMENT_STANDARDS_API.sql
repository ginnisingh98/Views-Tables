--------------------------------------------------------
--  DDL for Package Body ECX_DOCUMENT_STANDARDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_DOCUMENT_STANDARDS_API" AS
-- $Header: ECXSTDAB.pls 120.2 2005/06/30 11:17:57 appldev ship $

/**
This Retrieve_XML_Standard API is used to retrieve an existing XML standard definition from the ECX_Standards table.
**/
procedure retrieve_standard
	(
	x_return_status	 	Out	 nocopy pls_integer,
	x_msg	 		Out	 nocopy Varchar2,
	x_standard_id	 	Out	 nocopy pls_integer,
	p_standard_code	 	In	 Varchar2,
	x_standard_type	 	In Out	 nocopy Varchar2,
	x_standard_desc	 	Out	 nocopy Varchar2,
	x_data_seeded	 	Out	 nocopy Varchar2
	)
is
x_last_update_date	date;
x_last_updated_by	pls_integer;
x_created_by		pls_integer;
x_creation_date		date;
l_standard_type         varchar2(80);
begin
        x_return_status := ECX_UTIL_API.G_NO_ERROR;
        x_msg := null;
        l_standard_type := x_standard_type;

	-- make sure p_standard_code is not null.
	If (p_standard_code is null)
	then
	   x_return_status := ECX_UTIL_API.G_NULL_PARAM;
	   x_msg :=ecx_debug.getTranslatedMessage('ECX_STANDARD_CODE_NULL');
	   return;
        elsif (l_standard_type is null)
        then
           l_standard_type := 'XML';
	end if;


	select 	STANDARD_ID,
		STANDARD_TYPE,
		STANDARD_DESC,
		DATA_SEEDED,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATED_BY,
		CREATION_DATE
	into 	x_standard_id,
		x_standard_type,
		x_standard_desc,
		x_data_seeded,
		x_last_update_date,
		x_last_updated_by,
		x_created_by,
		x_creation_date
	from 	ecx_standards_vl
	where 	standard_code = p_standard_code
          and   standard_type = l_standard_type;
exception
when no_data_found then
	x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
	x_msg :=ecx_debug.getTranslatedMessage('ECX_STANDARD_ROW_NOT_FOUND',
                                               'p_standard_code',
                                                p_standard_code,
                                               'p_standard_type',
                                                l_standard_type);
when too_many_rows then
       x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
       x_msg :=ecx_debug.getTranslatedMessage('ECX_STANDARD_TOO_MANY_ROWS',
                                              'p_standard_code',
                                                p_standard_code,
                                               'p_standard_type',
                                                l_standard_type);

when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := substr(SQLERRM,1,200);
end retrieve_standard;

/**
This Create_XML_Standard API is used to create a new XML standard definition in the ECX_Standards table.
**/
procedure create_standard
	(
 	x_return_status	 	Out	 nocopy pls_integer,
  	x_msg	 		Out	 nocopy Varchar2,
   	x_standard_id	 	Out	 nocopy pls_integer,
    	p_standard_code	 	In	 Varchar2,
     	p_standard_type	 	In	 Varchar2,
      	p_standard_desc	 	In	 Varchar2,
       	p_data_seeded	 	In	 Varchar2,
        p_owner                 In       varchar2
	)
is
i_last_updated_by               pls_integer;
i_rowid                         varchar2(2000);
l_standard_type                 varchar2(80);
begin

        x_return_status := ECX_UTIL_API.G_NO_ERROR;
        x_standard_id :=-1;
        x_msg := null;
        l_standard_type := p_standard_type;

	-- make sure p_standard_code is not null.
	If (p_standard_code is null)
	then
	    x_return_status := ECX_UTIL_API.G_NULL_PARAM;
	    x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_CODE_NULL');
	    return;
        elsIf (l_standard_type is null)
        then
            l_standard_type := 'XML';
	end If;

        -- validate data seeded flag
        If NOT ecx_util_api.validate_data_seeded_flag(p_data_seeded)
        then
           x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
           x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DATA_SEEDED',
                              'p_data_seeded', p_data_seeded);
           return;
        end If;

	select 	ecx_standards_s.nextval
	into 	x_standard_id
	from 	dual;

       if p_owner = 'SEED'
       then
            if p_data_seeded = 'Y'
            then
               i_last_updated_by :=1;
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
               i_last_updated_by :=0;
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

       /* Call the table handler APIS to insert data into
          ecx_standards_b , ecx_standards_tl table */

        ECX_STANDARDS_PKG.INSERT_ROW(
          X_ROWID             =>  i_rowid,
          X_STANDARD_ID       =>  x_standard_id,
          X_STANDARD_CODE     =>  p_standard_code,
          X_STANDARD_TYPE     =>  l_standard_type,
          X_DATA_SEEDED       =>  p_data_seeded,
          X_STANDARD_DESC     =>  p_standard_desc,
          X_CREATION_DATE     =>  sysdate,
          X_CREATED_BY        =>  i_last_updated_by,
          X_LAST_UPDATE_DATE  =>  sysdate,
          X_LAST_UPDATED_BY   =>  i_last_updated_by,
          X_LAST_UPDATE_LOGIN =>  0);


exception
when dup_val_on_index then
	x_return_status := ECX_UTIL_API.G_DUP_ERROR;
	x_msg:=ecx_debug.getTranslatedMessage('ECX_DOCUMENT_STANDARD_EXISTS',
                                             'p_standard_code',
                                              p_standard_code,
                                             'p_standard_type',
                                              l_standard_type);

when no_data_found then
        x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
        x_msg :=ecx_debug.getTranslatedMessage('ECX_STANDARD_ROW_NOT_FOUND',
                                               'p_standard_code',
                                                p_standard_code,
                                               'p_standard_type',
                                                l_standard_type);

when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := substr(SQLERRM,1,200);

end create_standard;

/**
Update_Standards API is used to update an existing XML Standard definition in the ECX_Standards table.
This API allows users to update the description and data seeded fields by specifying standard id
**/

procedure update_standard
	(
 	x_return_status	 	Out	 nocopy pls_integer,
  	x_msg	 		Out	 nocopy Varchar2,
   	p_standard_id	 	In	 pls_integer,
    	p_standard_desc	 	In	 Varchar2,
     	p_data_seeded	 	In	 Varchar2,
        p_owner                 In       varchar2
	)
is
i_last_updated_by       pls_integer;

begin

        x_return_status := ECX_UTIL_API.G_NO_ERROR;
        x_msg := null;

	-- make sure standard_id is not null.
	If (p_standard_id is null)
	then
       	       x_return_status := ECX_UTIL_API.G_NULL_PARAM;
               x_msg           := ecx_debug.getTranslatedMessage('ECX_STANDARD_ID_NOT_NULL');
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


        if p_owner = 'SEED'
        then
            if p_data_seeded = 'Y'
            then
              i_last_updated_by :=1;
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
              i_last_updated_by :=0;
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

	update ECX_STANDARDS_B
        set     DATA_SEEDED      = p_data_seeded,
		LAST_UPDATED_BY  = i_last_updated_by,
		LAST_UPDATE_DATE = sysdate
	where standard_id   = p_standard_id;

        if (sql%rowcount = 0)
        then
                x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
                x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                'p_table', 'ECX_STANDARDS_B', 'p_param_name', 'Document Standard ID','p_param_id',p_standard_id);
                return;
        end if;

         update  ECX_STANDARDS_TL
         set     STANDARD_DESC    = p_standard_desc,
                 LAST_UPDATED_BY  = i_last_updated_by,
                 LAST_UPDATE_DATE = sysdate,
                 source_lang      = userenv('LANG')
         where   standard_id = p_standard_id and
                 userenv('LANG') in (language, source_lang);

        if (sql%rowcount = 0)
        then
             x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
             x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                                     'p_table',
                                                     'ECX_STANDARDS_TL',
                                                     'p_param_name',
                                                      'Document Standard ID',
                                                     'p_param_id',
                                                      p_standard_id);
                return;
        end if;


exception
when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := substr(SQLERRM,1,200);
end update_standard;

/**
Delete_XML_Standard API is used to delete an existing XML Standard definition in the ECX_STANDARDS
table and its attributes.  This API allows users to delete the definitions by specifying the standard id.
**/
procedure delete_standard
	(
      	x_return_status	 	Out	 nocopy pls_integer,
       	x_msg	 		Out	 nocopy Varchar2,
	p_standard_id	 	In	 pls_integer
	)
is
begin

        x_return_status := ECX_UTIL_API.G_NO_ERROR;
        x_msg := null;

     	if (p_standard_id is null)
	then
	   x_return_status := ECX_UTIL_API.G_NULL_PARAM;
	   x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_ID_NOT_NULL');
		return;
	end if;

-- make sure standard is not used in any code conversion or external process.
-- if there is a reference to this standard id, then return G_REFER_ERROR.

	delete from ecx_standard_attributes
	where standard_id = p_standard_id;

/* Call tbale handler DELETE_ROW for the deletion */

        ECX_STANDARDS_PKG.DELETE_ROW(x_standard_id => p_standard_id);

exception

when no_data_found then
      x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
      x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
                                              'p_table',
                                              'ECX_STANDARDS',
                                              'p_param_name',
                                              'Document Standard ID',
                                              'p_param_id',p_standard_id);

when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
        x_msg := substr(SQLERRM,1,200);
end delete_standard;

END ECX_DOCUMENT_STANDARDS_API;

/
