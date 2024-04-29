--------------------------------------------------------
--  DDL for Package ECX_TRANSACTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_TRANSACTIONS_API" AUTHID CURRENT_USER AS
-- $Header: ECXTXNAS.pls 120.1.12000000.3 2007/07/20 07:38:44 susaha ship $

/**
This retrieves Transaction from the transaction definition in the ECX_TRANSACTIONS table.
**/
procedure retrieve_transaction
	(
	x_return_status	 	 	Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	X_transaction_id	 	Out NOCOPY Pls_integer,
	p_transaction_type	 	In	   Varchar2,
	p_transaction_subtype	 	In	   Varchar2,
	p_party_type	 	 	In	   Varchar2,
	x_transaction_description	OUT NOCOPY Varchar2,
	x_created_by	 		Out NOCOPY pls_integer,
	x_creation_date	 		Out NOCOPY date,
	x_last_updated_by	 	Out NOCOPY pls_integer,
	x_last_update_date	 	Out NOCOPY date
	);

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
	p_owner				IN	   varchar2 default 'CUSTOM'
	);

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
	p_owner				IN	   varchar2 default 'CUSTOM'
	);

/**
 This Delete_Transaction API is used to delete an existing transaction definition in the ECX_TRANSACTIONS
 table and also the external processes that are associate to it.  This API allows users to delete a
 transaction definition by specifying the transaction id.
**/
procedure delete_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	p_transaction_id		In	   Pls_integer
	);
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
        p_ext_type                      In         Varchar2 default null,
        p_ext_subtype                   In         Varchar2 default null,
	p_standard_type			IN	   varchar2 default 'XML'
	);


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
        p_ext_type                      In         Varchar2 default null,
        p_ext_subtype                   In         Varchar2 default null,
	p_standard_type			IN	   varchar2 default 'XML'
	);
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
	p_owner				IN	   varchar2 default 'CUSTOM',
	p_standard_type			IN	   varchar2 default 'XML'
	);

/**
Overloaded.This Create_Ext_Process API is used to create a new external process definition in the ECX_EXT_PROCESSES table.
If the transaction doesnt exists, then create one.
**/

procedure create_external_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	X_ext_process_id	 	Out NOCOPY Pls_integer,
	X_transaction_id	 	Out NOCOPY Pls_integer,
	p_transaction_type		in	   varchar2,
	p_transaction_subtype		in	   varchar2,
	p_party_type			in	   varchar2,
	p_ext_type	 		In	   Varchar2,
	p_ext_subtype	 		In	   Varchar2,
	p_standard	 		In	   Varchar2,
	p_queue_name	 		In	   Varchar2,
	p_direction	 		In	   Varchar2,
	p_owner				in	   varchar2 default 'CUSTOM',
	p_standard_type			IN	   varchar2 default 'XML'
	);

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
	p_owner				IN	   varchar2 default 'CUSTOM',
	p_standard_type			IN	   varchar2 default 'XML'
	);

/**
This Delete_Ext_Process API is used to delete an existing external process definition in the ECX_EXT_PROCESSES table.
This API allows users to delete a process definition by specifying the ext_process_id.
**/
procedure delete_external_transaction
	(
	x_return_status	 		Out NOCOPY pls_integer,
	x_msg	 	 		Out NOCOPY varchar2,
	p_ext_process_id	 	In	   pls_integer
	);

END ECX_TRANSACTIONS_API;

 

/
