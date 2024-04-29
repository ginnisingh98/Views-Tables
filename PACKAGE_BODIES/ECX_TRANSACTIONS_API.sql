--------------------------------------------------------
--  DDL for Package Body ECX_TRANSACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_TRANSACTIONS_API" AS
-- $Header: ECXTXNAB.pls 120.1.12000000.3 2007/07/20 07:39:46 susaha ship $

/**
This retrieves Transaction from the transaction definition in the ECX_TRANSACTIONS table.
**/
procedure retrieve_transaction
	(
	x_return_status                 Out NOCOPY     pls_integer,
	x_msg                           Out NOCOPY     varchar2,
	X_transaction_id                Out NOCOPY     Pls_integer,
	p_transaction_type              In             Varchar2,
	p_transaction_subtype           In             Varchar2,
	p_party_type                    In             Varchar2,
	x_transaction_description       OUT NOCOPY     Varchar2,
	x_created_by                    Out NOCOPY     pls_integer,
	x_creation_date                 Out NOCOPY     date,
	x_last_updated_by               Out NOCOPY     pls_integer,
	x_last_update_date              Out NOCOPY     date
	)
is
-- get data from ECX_TRANSACTIONS.
-- Bug #2183619 : Modify the cursor to add party_type
cursor c_transaction
	(
	p_transaction_type	in	varchar2,
	p_transaction_subtype	in	varchar2,
        p_party_type            in      varchar2
	)
is

Select 	TRANSACTION_ID,
	TRANSACTION_DESCRIPTION,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE
from 	ECX_TRANSACTIONS_VL
where 	transaction_type    = p_transaction_type
and   	transaction_subtype = p_transaction_subtype
and     party_type          = p_party_type; --Bug #2183619

begin
	x_transaction_id :=-1;
	x_return_status  := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;

	-- make sure the transaction_type, transaction_subtype and party_type are not null.
	if ( p_transaction_type is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_TYPE_NOT_NULL');
		return;
	end if;

	if ( p_transaction_subtype is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRAN_SUBTYPE_NOT_NULL');
		return;
	end if;

	if ( p_party_type is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_TYPE_NOT_NULL');
		return;
	end if;

	if NOT (ECX_UTIL_API.validate_party_type(p_party_type))
	then
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		x_transaction_id := -1;
		x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_PARTY_TYPE','p_party_type',p_party_type);
		return;
	end if;

	open 	c_transaction(p_transaction_type,p_transaction_subtype,
                              p_party_type);
	fetch 	c_transaction
	into	x_transaction_id,
		x_transaction_description,
		x_created_by,
		x_creation_date,
		x_last_updated_by,
		x_last_update_date;

	if c_transaction%NOTFOUND
	then
		raise no_data_found;
	end if;

	close	c_transaction;

Exception
when too_many_rows then
     x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
     x_msg := ecx_debug.getTranslatedMessage('ECX_TRANS_TOO_MANY_ROWS',
		'p_transaction_type', p_transaction_type,
		'p_transaction_subtype', p_transaction_subtype,
                'p_party_type',p_party_type
		);

	if c_transaction%ISOPEN
	then
		close	c_transaction;
	end if;

when no_data_found then
	x_msg := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_NOT_FOUND',
				'p_transaction_type',p_transaction_type,
				'p_transaction_subtype',p_transaction_subtype,
				'p_party_type',p_party_type
				);
	x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
	if c_transaction%ISOPEN
	then
		close	c_transaction;
	end if;

when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
	x_msg := substr(SQLERRM,1,200);

	if c_transaction%ISOPEN
	then
		close	c_transaction;
	end if;
end retrieve_transaction;

/**
This Create_Transaction API is used to create a new transaction definition in the ECX_TRANSACTIONS table.
**/
procedure create_transaction
	(
	x_return_status	 	 	Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	X_transaction_id	 	Out NOCOPY Pls_integer,
	p_transaction_type	 	In	   Varchar2,
	p_transaction_subtype	 	In	   Varchar2,
	p_transaction_description	In	   Varchar2,
        p_admin_user                    in         varchar2 default null,
	p_party_type	 	 	In	   Varchar2,
	p_owner				in	   varchar2
	)
is
i_transaction_description	varchar2(256);
i_created_by			pls_integer;
i_creation_date			date;
i_last_updated_by		pls_integer;
i_last_update_date		date;
x1_return_status		pls_integer;
x1_msg				varchar2(200);
x1_transaction_id		pls_integer;
i_rowid                         varchar2(2000);
begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_transaction_id :=-1;
	x_msg := null;

	-- make sure the transaction_type, transaction_subtype and party_type are not null.
	if ( p_transaction_type is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_TYPE_NOT_NULL');
		return;
	end if;

	if ( p_transaction_subtype is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRAN_SUBTYPE_NOT_NULL');
		return;
	end if;

	if ( p_party_type is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_PARTY_TYPE_NOT_NULL');
		return;
	end if;

	if NOT (ECX_UTIL_API.validate_party_type(p_party_type))
	then
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		x_transaction_id := -1;
		x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_PARTY_TYPE','p_party_type',p_party_type);
		return;
	end if;


	--- Make sure that the Transaction entry is existing or not. The Index is not sufficient.
	--- We will add the check on party_type later on.

	ecx_transactions_api.retrieve_transaction
		(
		x_return_status 		=>	x1_return_status,
		x_msg				=>	x1_msg,
		x_transaction_id		=>	x1_transaction_id,
		p_transaction_type		=>	p_transaction_type,
		p_transaction_subtype		=>	p_transaction_subtype,
		p_party_type			=>	p_party_type,
		x_transaction_description	=>	i_transaction_description,
		x_created_by			=>	i_created_by,
		x_creation_date			=>	i_creation_date,
		x_last_updated_by		=>	i_last_updated_by,
		x_last_update_date		=>	i_last_update_date
		);

	if ( x1_return_status = ECX_UTIL_API.G_NO_DATA_ERROR )
	then
		select 	ecx_transactions_s.nextval
		into 	x_transaction_id
		from 	dual;

		if p_owner = 'SEED'
		then
			i_last_updated_by :=1;
		else
			i_last_updated_by :=0;
		end if;

                /* Call the table handler API for insertion of data
                   into ecx_transactions_b and ecx_transactions_tl tables*/

                ECX_TRANSACTIONS_PKG.INSERT_ROW
                (
                   x_rowid                   =>   i_rowid,
                   x_transaction_id          =>   x_transaction_id ,
                   x_transaction_type        =>   upper(p_transaction_type),
                   x_transaction_subtype     =>   upper(p_transaction_subtype),
                   x_party_type              =>   p_party_type,
                   x_transaction_description =>   p_transaction_description,
                   x_admin_user              =>   p_admin_user,
                   x_creation_date           =>   sysdate,
                   x_created_by              =>   i_last_updated_by,
                   x_last_update_date        =>   sysdate,
                   x_last_updated_by         =>   i_last_updated_by,
                   x_last_update_login       =>   0);

        elsif ( x1_return_status = ECX_UTIL_API.G_NO_ERROR ) then
                raise dup_val_on_index;
	else
		x_return_status := x1_return_status;
		x_msg := x1_msg;
		return;
	end if;

Exception
when dup_val_on_index then
	x_return_status := ECX_UTIL_API.G_DUP_ERROR;
	x_msg := ecx_debug.getTranslatedMessage('ECX_DUPLICATE_TRANSACTIONS',
		'p_transaction_type',p_transaction_type,
		'p_transaction_subtype',p_transaction_subtype,
                'p_party_type',p_party_type);

when no_data_found then
       x_return_status   := ECX_UTIL_API.G_NO_DATA_ERROR;
       x_msg             := ecx_debug.getTranslatedMessage
                             ('ECX_TRANSACTION_NOT_FOUND',
                               'p_transaction_type'  ,p_transaction_type,
                               'p_transaction_subtype',p_transaction_subtype,
                               'p_party_type' , p_party_type);

when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
	x_msg := substr(SQLERRM,1,200);
end create_transaction;

/**
 This Update_Transaction API is used to update an existing transaction description in the ECX_TRANSACTIONS table.
**/
procedure update_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	p_transaction_id	 	In	   Pls_integer,
	p_transaction_type	 	In	   Varchar2,
	p_transaction_subtype	 	In	   Varchar2,
	p_party_type	 		In	   Varchar2,
	p_transaction_description	In	   Varchar2,
	p_owner				in	   varchar2
	)
is
i_last_updated_by	pls_integer;
begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;
	-- make sure the p_transaction_id is not null.
	If p_transaction_id is null
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_ID_NOT_NULL');
		return;
	end if;

	-- update description in ECX_TRANSACTIONS.
	-- We cannot update the Primary Key of the Entity.Only description should be updated.

		if p_owner = 'SEED'
		then
			i_last_updated_by :=1;
		else
			i_last_updated_by :=0;
		end if;

	Update  ecx_transactions_b
	set 	last_updated_by         = i_last_updated_by,
		last_update_date        = sysdate
	Where transaction_id = p_transaction_id;

        if (sql%rowcount = 0)
        then
                x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
                x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
                                                        'p_table',
                                                        'ECX_TRANSACTIONS_B',
                                                        'p_param_name',
                                                        'Transaction ID',
                                                         'p_param_id',
                                                         p_transaction_id);
                return;
        end if;


      Update ecx_transactions_tl
	set 	transaction_description = p_transaction_description,
		last_updated_by         = i_last_updated_by,
		last_update_date        = sysdate,
                source_lang             = userenv('LANG')
	Where transaction_id  = p_transaction_id and
              userenv('LANG') in (language, source_lang);

     if (sql%rowcount = 0)
     then
      x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
      x_msg := ecx_debug.getTranslatedMessage('ECX_NO_TRANS_ROWS_UPDATED',
                                              'p_table',
                                              'ECX_TRANSACTIONS_TL',
                                              'p_param_name',
                                              'Transaction ID',
                                              'p_param_id',
                                              'p_transaction_id');
		return;
	end if;

Exception
when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
	x_msg := substr(1,200,SQLERRM);
end update_transaction;

/**
 This Delete_Transaction API is used to delete an existing transaction
 definition in the ECX_TRANSACTIONS
 table and also the external processes that are associate to it.
 This API allows users to delete a
 transaction definition by specifying the transaction id.
**/
procedure delete_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	p_transaction_id		In	   Pls_integer
	)
is

num    pls_integer;

Begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;

	If p_transaction_id is null
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_ID_NOT_NULL');
		return;
	end if;

	-- make sure that is no TP using this transaction first.
	-- get all the external processes defined for the given transaction.
	-- Check if there any TP reference to any ext_process_id
        -- with the given transaction_id
	-- If any TP is using it, then return with
	-- a error return code.
	-- Otherwise, do the delete.

        -- make sure that is no TP using this process first.
	select  count(*)
	into    num
	from    ecx_tp_details etd,
		ecx_ext_processes eep
	where   eep.ext_process_id = etd.ext_process_id
	and	eep.transaction_id = p_transaction_id;

	if (num > 0)
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DETAIL_EXISTS');
		x_return_status := ECX_UTIL_API.G_REFER_ERROR;
		return;
	end if;

	delete from ecx_ext_processes
	where transaction_id = p_transaction_id;

        /* Call table handler API for deletion */
        ECX_TRANSACTIONS_PKG.DELETE_ROW(x_transaction_id  =>  p_transaction_id);
exception
when no_data_found then
      x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
      x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
                                              'p_table', 'ECX_TRANSACTIONS',
                                              'p_param_name','Transaction ID',
                                              'p_param_id',p_transaction_id);
when others then
	x_msg := substr(SQLERRM,1,200);
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
end delete_transaction;

/**
 Overloaded Procedure.This Retrieve_Ext_Process API is used to retrieve an existing external
 process definition from  the ECX_EXT_PROCESSES table.
**/
/* Bug #2183619, Added two additional input parameters for
   External Type and Subtype */
procedure retrieve_external_transaction
 	(
 	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
  	X_ext_process_id	 	Out NOCOPY pls_integer,
   	x_transaction_id	 	OUT NOCOPY pls_integer,
	p_transaction_type		IN	   varchar2,
	p_transaction_subtype		IN	   varchar2,
	p_party_type			IN	   varchar2,
       	p_standard	 		In	   Varchar2,
	p_direction	 		In	   Varchar2,
	x_transaction_description 	Out NOCOPY Varchar2,
	x_ext_type	 		Out NOCOPY Varchar2,
	x_ext_subtype	 		Out NOCOPY Varchar2,
	x_standard_id	 		Out NOCOPY pls_integer,
	x_queue_name	 		Out NOCOPY Varchar2,
	x_created_by	 		Out NOCOPY pls_integer,
	x_creation_date	 		Out NOCOPY date,
	x_last_updated_by	 	Out NOCOPY pls_integer,
	x_last_update_date	 	Out NOCOPY date,
        p_ext_type                      In         Varchar2 ,
        p_ext_subtype                   In         Varchar2,
	p_standard_type			IN	   varchar2
	)
is
   num varchar2(2000);

begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;
	x_ext_process_id :=-1;
	x_transaction_id :=-1;

        ecx_transactions_api.retrieve_transaction
                (
                x_return_status                 =>      x_return_status,
                x_msg                           =>      x_msg,
                x_transaction_id                =>      x_transaction_id,
                p_transaction_type              =>      p_transaction_type,
                p_transaction_subtype           =>      p_transaction_subtype,
                p_party_type                    =>      p_party_type,
                x_transaction_description       =>      x_transaction_description,
                x_created_by                    =>      x_created_by,
                x_creation_date                 =>      x_creation_date,
                x_last_updated_by               =>      x_last_updated_by,
                x_last_update_date              =>      x_last_update_date
                );
        if (x_transaction_id = -1)
        then
                return;
        end if;

	if ( p_direction is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
		return;
	end if;

	if ( p_standard is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
		return;
	end if;

	if NOT (ECX_UTIL_API.validate_direction(p_direction))
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DIRECTION','p_direction',p_direction);
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		return;
	end if;

	-- make sure it is a valid standard.
	begin
		select 	standard_id
		into 	x_standard_id
		from 	ecx_standards
		where  	standard_code = p_standard
		and	standard_type = p_standard_type;
	exception
	when no_data_found then
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_CODE_NOT_FOUND','p_standard',p_standard);
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		return;
	end;

	-- select data from ECX_EXT_PROCESSES
	/* Bug #2183619,Modified to add check for External Type and Sub type */
	select 	EXT_PROCESS_ID,
		EXT_TYPE,
		EXT_SUBTYPE,
		QUEUE_NAME,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE
	into 	x_ext_process_id,
		x_ext_type,
		x_ext_subtype,
		x_queue_name,
		x_created_by,
		x_creation_date,
		x_last_updated_by,
		x_last_update_date
	from 	ECX_EXT_PROCESSES
	where 	transaction_id  = x_transaction_id
	and   	standard_id     = x_standard_id
	and   	direction       = p_direction
        and     (p_ext_type is null or ext_type=p_ext_type)
        and     (p_ext_subtype is null or ext_subtype=p_ext_subtype);

exception
when too_many_rows then
	x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
	x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS_TOO_MANY_ROWS',
		'p_transaction_type', p_transaction_type,
		'p_transaction_subtype', p_transaction_subtype,
		'p_standard', p_standard,
		'p_direction', p_direction
		);
when no_data_found then

	x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_TRANSACTION_NOT_FOUND',
		'p_transaction_type',p_transaction_type,
		'p_transaction_subtype',p_transaction_subtype,
		'p_standard',p_standard
		);
	x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
when others then
	x_msg := substr(SQLERRM,1,200);
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
end retrieve_external_transaction;

/**
 This Retrieve_Ext_Process API is used to retrieve an existing external
 process definition from  the ECX_EXT_PROCESSES table.
**/
/* Bug #2183619, Added two additional input parameters for
   External Type and Subtype */
procedure retrieve_external_transaction
 	(
 	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
  	X_ext_process_id	 	Out NOCOPY pls_integer,
   	p_transaction_id	 	in	   pls_integer,
       	p_standard	 		In	   Varchar2,
	p_direction	 		In  	   Varchar2,
	x_transaction_description 	Out NOCOPY Varchar2,
	x_ext_type	 		Out NOCOPY Varchar2,
	x_ext_subtype	 		Out NOCOPY Varchar2,
	x_standard_id	 		Out NOCOPY pls_integer,
	x_queue_name	 		Out NOCOPY Varchar2,
	x_created_by	 		Out NOCOPY pls_integer,
	x_creation_date	 		Out NOCOPY date,
	x_last_updated_by	 	Out NOCOPY pls_integer,
	x_last_update_date	 	Out NOCOPY date,
        p_ext_type                      In         Varchar2 ,
        p_ext_subtype                   In         Varchar2 ,
	p_standard_type			IN	   varchar2
	)
is
begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;
	x_ext_process_id :=-1;

	If p_transaction_id is null
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_ID_NOT_NULL');
		return;
	end if;

	if ( p_direction is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
		return;
	end if;

	if ( p_standard is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
		return;
	end if;

	if NOT (ECX_UTIL_API.validate_direction(p_direction))
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DIRECTION','p_direction',p_direction);
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		return;
	end if;

	-- make sure it is a valid standard.
	begin
		select 	standard_id
		into 	x_standard_id
		from 	ecx_standards
		where  	standard_code = p_standard
		and	standard_type = p_standard_type;
	exception
	when no_data_found then
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_FOUND',
                                                        'p_standard',p_standard,
                                                        'p_std_type', p_standard_type);
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		return;
	end;

	-- select data from ECX_EXT_PROCESSES
	/* Bug #2183619,Modified to add check for External Type and Sub type */
	select 	TRANSACTION_DESCRIPTION,
		EXT_PROCESS_ID,
		EXT_TYPE,
		EXT_SUBTYPE,
		QUEUE_NAME,
		eep.CREATED_BY,
		eep.CREATION_DATE,
		eep.LAST_UPDATED_BY,
		eep.LAST_UPDATE_DATE
	into 	x_transaction_description,
		x_ext_process_id,
		x_ext_type,
		x_ext_subtype,
		x_queue_name,
		x_created_by,
		x_creation_date,
		x_last_updated_by,
		x_last_update_date
	from 	ECX_EXT_PROCESSES eep,
		ECX_TRANSACTIONS_VL et
	where  	et.transaction_id	= p_transaction_id
	and	et.transaction_id      = eep.transaction_id
	and   	eep.standard_id        = x_standard_id
	and   	eep.direction          = p_direction
        and     (p_ext_type is null or eep.ext_type=p_ext_type)
        and     (p_ext_subtype is null or eep.ext_subtype=p_ext_subtype);
exception
when too_many_rows then
	x_return_status := ECX_UTIL_API.G_TOO_MANY_ROWS;
	x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS1_TOO_MANY_ROWS', 'p_transaction_id', p_transaction_id,
                'p_standard', p_standard,
		'p_direction', p_direction
                );

when no_data_found then
	x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_TRANSACTION1_NOT_FOUND',
		'p_transaction_id', p_transaction_id,
		'p_standard',p_standard,
		'p_direction',p_direction
		);
	x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
when others then
	x_msg := substr(SQLERRM,1,200);
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
end retrieve_external_transaction;

/**
This Create_Ext_Process API is used to create a new external process definition in the ECX_EXT_PROCESSES table.
If the transaction doesnt exists, then create one.
**/

procedure create_external_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	X_ext_process_id	 	Out NOCOPY Pls_integer,
	p_transaction_id	 	in	   Pls_integer,
	p_ext_type	 		In	   Varchar2,
	p_ext_subtype	 		In	   Varchar2,
	p_standard	 		In	   Varchar2,
	p_queue_name	 		In	   Varchar2,
	p_direction	 		In	   Varchar2,
	p_owner				in	   varchar2 ,
	p_standard_type			IN	   varchar2
	)
is
I_stand_id	pls_integer;
x_return_code	pls_integer;
i_last_updated_by	pls_integer;
begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;
	x_ext_process_id :=-1;

	If (p_transaction_id is null)
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_TRANSACTION_ID_NOT_NULL');
		return;
	end if;

	If (p_ext_type is null)
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_TYPE_NOT_NULL');
		return;
	end if;

	If (p_ext_subtype is null)
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_SUBTYPE_NOT_NULL');
		return;
	end if;

	if ( p_direction is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
		return;
	end if;

	if ( p_standard is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
		return;
	end if;

	if NOT (ECX_UTIL_API.validate_direction(p_direction))
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DIRECTION','p_direction',p_direction);
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		return;
	end if;

	if p_direction = 'IN'
	then
		if ( p_queue_name is null )
		then
			x_return_status := ECX_UTIL_API.G_NULL_PARAM;
			x_msg := ecx_debug.getTranslatedMessage('ECX_QUEUE_NAME_NOT_NULL');
			return;
		end if;

		-- make sure it is a valid queue name.
		If NOT (ECX_UTIL_API.validate_queue_name(p_queue_name))
		then
			x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_QUEUE_NAME','p_queue_name',p_queue_name);
			x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
			return;
		end if;
	end if;

	-- make sure it is a valid standard.
	begin
		select 	standard_id
		into 	I_stand_id
		from 	ecx_standards
		where  	standard_code = p_standard
		and	standard_type = p_standard_type;
	exception
	when no_data_found then
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_FOUND',
                                                        'p_standard', p_standard,
                                                        'p_std_type', p_standard_type);
		return;
	end;

	-- make sure the ext_type and ext_subtype doesnt exists.
	-- If the code is already exists, then
	-- return an error status G_DUP_ERROR and return.

	select 	ecx_ext_processes_s.nextval
	into 	x_ext_process_id
	from 	dual;

		if p_owner = 'SEED'
		then
			i_last_updated_by :=1;
		else
			i_last_updated_by :=0;
		end if;

	-- Insert data into ECX_EXT_PROCESSES
	insert into ecx_ext_processes
		(
		EXT_PROCESS_ID,
		EXT_TYPE,
		EXT_SUBTYPE,
		TRANSACTION_ID,
		STANDARD_ID,
		QUEUE_NAME,
		DIRECTION,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE
		)
	Values (
		X_ext_process_id,
		P_ext_type,
		p_ext_subtype,
		p_transaction_id,
		I_stand_id,
		p_queue_name,
		p_direction,
		i_last_updated_by,
		sysdate,
		i_last_updated_by,
		sysdate
		);

exception
when dup_val_on_index then
	x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESSES_EXISTS',
		'p_transaction_id', p_transaction_id,
		'p_ext_type', p_ext_type,
		'p_ext_subtype', p_ext_subtype
		);
	x_return_status := ECX_UTIL_API.G_DUP_ERROR;
when others then
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
	x_msg := substr(SQLERRM,1,200);
end create_external_transaction;

/**
This Create_Ext_Process API is used to create a new external process definition in the ECX_EXT_PROCESSES table.
If the transaction doesnt exists, then create one.
**/

procedure create_external_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	X_ext_process_id	 	Out NOCOPY Pls_integer,
	X_transaction_id	 	Out NOCOPY Pls_integer,
	p_transaction_type	 	In	   Varchar2,
	p_transaction_subtype	 	In	   Varchar2,
	p_party_type	 		In	   Varchar2,
	p_ext_type	 		In	   Varchar2,
	p_ext_subtype	 		In	   Varchar2,
	p_standard	 		In	   Varchar2,
	p_queue_name	 		In	   Varchar2,
	p_direction	 		In	   Varchar2,
	p_owner				IN	   varchar2 ,
	p_standard_type			IN	   varchar2
	)
is
i_transaction_description	varchar2(256);
i_created_by			pls_integer;
i_creation_date			date;
i_last_updated_by		pls_integer;
i_last_update_date		date;
begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;
	x_transaction_id :=-1;
	x_ext_process_id :=-1;
	ecx_transactions_api.retrieve_transaction
		(
		x_return_status 		=>	x_return_status,
		x_msg				=>	x_msg,
		x_transaction_id		=>	x_transaction_id,
		p_transaction_type		=>	p_transaction_type,
		p_transaction_subtype		=>	p_transaction_subtype,
		p_party_type			=>	p_party_type,
		x_transaction_description	=>	i_transaction_description,
		x_created_by			=>	i_created_by,
		x_creation_date			=>	i_creation_date,
		x_last_updated_by		=>	i_last_updated_by,
		x_last_update_date		=>	i_last_update_date
		);
	if (x_transaction_id = -1)
	then
		return;
	end if;

	ecx_transactions_api.create_external_transaction
		(
		x_return_status 	=>	x_return_status,
		x_msg			=>	x_msg,
		x_ext_process_id	=>	x_ext_process_id,
		p_transaction_id	=>	x_transaction_id,
		p_ext_type		=>	p_ext_type,
		p_ext_subtype		=>	p_ext_subtype,
		p_standard		=>	p_standard,
		p_queue_name		=>	p_queue_name,
		p_direction		=>	p_direction,
		p_owner			=> 	p_owner,
		p_standard_type		=>	p_standard_type
		);
exception
when others then
	x_msg := substr(SQLERRM,1,200);
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
end create_external_transaction;

/**
 Update_Ext_Process API is used to update an existing external process definition in the ECX_EXT_PROCESSES table.
 This API allows users to update the ext_type, ext_subtype, standard, queue_name and direction by
 specifying the ext_process_id.
**/
procedure update_external_transaction
	(
 	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
  	p_ext_process_id	 	In	   pls_integer,
   	p_ext_type	 		In	   Varchar2,
    	p_ext_subtype	 		In	   Varchar2,
     	p_standard	 		In	   Varchar2,
      	p_queue_name	 		In	   Varchar2,
       	p_direction	 		In	   Varchar2,
	p_owner				in	   varchar2 ,
	p_standard_type			IN	   varchar2
	)
is
I_stand_id	pls_integer;
i_last_updated_by	pls_integer;
begin
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	x_msg := null;

	If 	(	p_ext_process_id is null )
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS_ID_NOT_NULL','p_ext_process_id',p_ext_process_id);
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		return;
	end if;

	If (p_ext_type is null)
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_TYPE_NOT_NULL');
		return;
	end if;

	If (p_ext_subtype is null)
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_SUBTYPE_NOT_NULL');
		return;
	end if;

	if ( p_direction is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_DIRECTION_NOT_NULL');
		return;
	end if;

	if ( p_standard is null )
	then
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_NULL');
		return;
	end if;

	if NOT (ECX_UTIL_API.validate_direction(p_direction))
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_DIRECTION','p_direction',p_direction);
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		return;
	end if;

	if p_direction = 'IN'
	then
		if ( p_queue_name is null )
		then
			x_return_status := ECX_UTIL_API.G_NULL_PARAM;
			x_msg := ecx_debug.getTranslatedMessage('ECX_QUEUE_NAME_NOT_NULL');
			return;
		end if;

		-- make sure it is a valid queue name.
		If NOT (ECX_UTIL_API.validate_queue_name(p_queue_name))
		then
			x_msg := ecx_debug.getTranslatedMessage('ECX_INVALID_QUEUE_NAME','p_queue_name',p_queue_name);
			x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
			return;
		end if;
	end if;

	-- make sure it is a valid standard.
	begin
		select 	standard_id
		into 	I_stand_id
		from 	ecx_standards
		where  	standard_code = p_standard
		and	standard_type = p_standard_type;
	exception
	when no_data_found then
		x_msg := ecx_debug.getTranslatedMessage('ECX_STANDARD_NOT_FOUND',
                                                        'p_standard', p_standard,
                                                        'p_std_type', p_standard_type);
		x_return_status := ECX_UTIL_API.G_INVALID_PARAM;
		return;
	end;

		if p_owner = 'SEED'
		then
			i_last_updated_by :=1;
		else
			i_last_updated_by :=0;
		end if;

	-- update data into ECX_EXT_PROCESSES
	-- SHould we allow to update the Unqiue itself?
	update 	ECX_EXT_PROCESSES
	set 	ext_type    = p_ext_type,
		ext_subtype = p_ext_subtype,
		standard_id = I_stand_id,
		queue_name  = p_queue_name,
		direction   = p_direction,
		last_updated_by = i_last_updated_by,
		last_update_date = sysdate
	where 	ext_process_id = p_ext_process_id;

	if (sql%rowcount = 0)
	then
		x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
		x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_UPDATED',
			'p_table', 'ecx_ext_processes', 'p_key', p_ext_process_id);
		return;
	end if;

exception
when dup_val_on_index then
	x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS_EXISTS',
		'p_ext_process_id', p_ext_process_id,
		'p_ext_type', p_ext_type,
		'p_ext_subtype', p_ext_subtype
		);
	x_return_status := ECX_UTIL_API.G_DUP_ERROR;
when others then
	x_msg := substr(SQLERRM,1,200);
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
end update_external_transaction;

/**
This Delete_Ext_Process API is used to delete an existing external process definition in the ECX_EXT_PROCESSES table.
This API allows users to delete a process definition by specifying the ext_process_id.
**/
procedure delete_external_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	p_ext_process_id	 	In	   pls_integer
	)
is
num   pls_integer;
begin
	x_msg := null;
	x_return_status := ECX_UTIL_API.G_NO_ERROR;
	if (p_ext_process_id is null)
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_EXT_PROCESS_ID_NOT_NULL');
		x_return_status := ECX_UTIL_API.G_NULL_PARAM;
		return;
	end if;

	-- make sure that is no TP using this process first.
	select 	count(*)
	into 	num
	from 	ecx_tp_details
	where  	ext_process_id = p_ext_process_id;

	if (num > 0)
	then
		x_msg := ecx_debug.getTranslatedMessage('ECX_TP_DETAIL_EXISTS','p_ext_process_id',p_ext_process_id);
		x_return_status := ECX_UTIL_API.G_REFER_ERROR;
		return;
	end if;

	delete from ecx_ext_processes
	where ext_process_id = p_ext_process_id;

     	if (sql%rowcount = 0)
	then
		x_return_status := ECX_UTIL_API.G_NO_DATA_ERROR;
		x_msg := ecx_debug.getTranslatedMessage('ECX_NO_ROWS_DELETED',
		'p_table', 'ECX_EXT_PROCESSES', 'p_key', p_ext_process_id);
		return;
	end if;

exception
when others then
	x_msg := substr(SQLERRM,1,200);
	x_return_status := ECX_UTIL_API.G_UNEXP_ERROR;
end delete_external_transaction;

END ECX_TRANSACTIONS_API;

/
