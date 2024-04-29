--------------------------------------------------------
--  DDL for Package Body WIP_SUBS_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SUBS_MERGE" as
/* $Header: wipsbcpb.pls 115.11 2002/11/29 15:34:42 rmahidha ship $ */

/*********************************************************
-- 			Private Procedures
*********************************************************/

    -- Procedure to delete the Children
    function Delete_Children(Interface_id in number)
	return number is
    begin

	delete from mtl_transaction_lots_interface
	where transaction_interface_id = Interface_Id ;

	delete from mtl_serial_numbers_interface
	where transaction_interface_id = Interface_Id ;

	delete from mtl_serial_numbers_interface msni
	where msni.transaction_interface_id in
	(select serial_transaction_temp_id
	 from mtl_transaction_lots_interface mtli
	 where mtli.transaction_interface_id = Interface_Id);

	return 1;

     exception
	when others then
 	  return 0;

   end Delete_Children ;


    -- Procedure to delete the substitutes at the end
    -- of the compare merge
    Function Delete_Substitutes(p_parent_id number)
			return number is
    begin

        delete from mtl_transactions_interface
        where parent_id = p_parent_id
	and substitution_type_id is not null;

	return 1 ;

    exception
	when others then
	  return 0 ;
   end Delete_Substitutes;



/* This function is a set processing after the Sub Merge */

function Post_SubMerge(p_interface_id in number,
		       p_org_id in number,
		       p_src_prj_id in number,
		       p_src_tsk_id in number,
		       p_wip_entity_id in number,
		       p_transaction_date in varchar2,
		       p_txn_hdr_id in number,
		       p_err_num in out nocopy number,
		       p_err_mesg in out nocopy varchar2) return number is
x_txn_act_id NUMBER ;
x_direction NUMBER;
begin
   -- CFM Scrap. This function has been modified

	select 	transaction_action_id, Sign(transaction_quantity)
	into    x_txn_act_id, x_direction
	from	mtl_transactions_interface
	where	transaction_interface_id = p_interface_id ;

/* Direction is used to distinguish a scrap transaction from a return from scrap transaction. here is what the decode statement below is...
	Scrap Transaction , Component Quantity = +ve => Comp. Issue.
	Scrap Transaction , Component Quantity = -ve => Neg. Comp. Issue.
	Return from Scrap Txn. , Component Quantity = +ve => Comp. Return.
	Return from Scrap Txn. , Component Quantity = -ve => Neg. Comp. Return.

*/
	Update mtl_transactions_interface
	set  transaction_source_type_id = nvl(transaction_source_type_id,5),
	     flow_schedule = nvl(flow_schedule,'Y'),
	     transaction_action_id = Decode( x_txn_act_id,
					     31,Decode(Sign(transaction_quantity),
						       -1, 1,
						       33),
					     32,Decode(Sign(transaction_quantity),
						       -1,34 ,
						       27),
					     30,Decode(x_direction,
						       1,Decode(Sign(transaction_quantity),
								-1, 1,
								 33),
						       -1,Decode(Sign(transaction_quantity),
								 -1,34 ,
								 27))),
	     transaction_type_id = Decode( x_txn_act_id,
					   31, Decode(Sign(transaction_quantity),
						      -1, 35,
						      38),
					   32, Decode(Sign(transaction_quantity),
						      -1, 48,
						      43),
					   30, Decode(x_direction,
						       1,Decode(Sign(transaction_quantity),
								-1, 35,
								38),
						      -1,Decode(Sign(transaction_quantity),
								-1, 48,
								43))),
	     source_project_id = decode(p_src_prj_id, -1, null,
					p_src_prj_id),
	     source_task_id = decode(p_src_tsk_id, -1, null,
					p_src_tsk_id),
	     transaction_header_id = p_txn_hdr_id,
	     transaction_source_id = p_wip_entity_id,
	     transaction_date = to_date(p_transaction_date,WIP_CONSTANTS.DT_NOSEC_FMT)
	where
	     substitution_type_id is NULL
	AND  process_flag = 2
	AND  parent_id = p_interface_id
	AND  organization_id = p_org_id ;


	return 1;

 exception

	when others then
		p_err_num := 0;
		fnd_message.set_name('WIP', 'WIP_ERROR_POST_MERGE');
                fnd_message.set_token('ENTITY1',
                                        to_char(p_interface_id) );
                p_err_mesg := fnd_message.get ;
		return 0;

end Post_SubMerge ;


-- Public Procedures and functions
/************************************************************************
* 		Public Procedures and functions
*
*	  1. Cmp_Merge_Subs :
*  This function merges the Substitutes and the Backflushed Components
*  It further maintains the relation between the Parent and the children
*  records. The following are the cases for maintaining the parent
*  child relationship :
*
*		1. Replace :
*			- As the Original backflushed item will not
*			- have any information in MLTI and MSNI
*			- update the originals txn_id to the txn_id of
*			- the substitutes

*		2. Delete :
*			- Make sure the children are deleted.
*
*		3. Addition :
*			- There is no impact for this, as the child
*			- Information will be stored already.
*
*		4. Lot/Serial :
*			- The transaction interface id of the original
*			  should be modfied to that of the substitution
*
*  At the end of it all, it makes sure that the Substitutes are deleted
*  In case of exception the calling function would be returned, so the
*  calling program can perform the Roll Back.
************************************************************************/

function Cmp_Merge_Subs(
                        interface_id in number,
                        organization_id in number,
                        err_num in out nocopy number,
                        err_mesg in out nocopy varchar2
                          ) return number is

/************************************************************************
-- THis Cursor is used for going through the substitutes one after the other
-- the order in which it would go through is :
--	1. Initially Replacment
--	2. Deletion
--	3. Addition	and
--	4. Replace
************************************************************************/
CURSOR Substitute_Cursor(interface_id NUMBER,
		 Org_Id NUMBER) is
        Select
		SUBSTITUTION_TYPE_ID,
		TRANSACTION_INTERFACE_ID,
		OPERATION_SEQ_NUM,
		INVENTORY_ITEM_ID,
		SUBSTITUTION_ITEM_ID,
		REVISION,
		SUBINVENTORY_CODE,
		LOCATOR_ID,
		TRANSACTION_UOM,
		TRANSACTION_QUANTITY,
		REASON_ID,
		TRANSACTION_REFERENCE,
		ORGANIZATION_ID
        from mtl_transactions_interface
	where parent_id = interface_id
	and   substitution_type_id is not null
	and   process_flag = 2
	and   organization_id = Org_Id
	order by substitution_type_id;

/************************************************************************
-- This cursor is used to go through the backflushed transaction one after the
-- other, and return the OP Seq and the Item ID, if a particular Item exists in
-- a Operation Sequence for that parent_id
************************************************************************/
CURSOR BackFlush_Cursor(Interface_Id NUMBER, Op_Seq NUMBER, Source_Item NUMBER,
			Org_Id NUMBER) is
       	SELECT Transaction_Interface_Id,
	       operation_seq_num,
	       inventory_item_id,
	       transaction_quantity
	FROM mtl_transactions_interface
	WHERE parent_id = interface_Id
	AND   substitution_type_id is NULL
	AND   process_flag = 2
	AND   operation_seq_num = Op_Seq
	AND   inventory_item_id = Source_Item
	AND   organization_id = Org_Id ;

Op_Seq	NUMBER;
Result_Item	VARCHAR2(2000);
Item_Source_Id NUMBER;
Txn_Interface_Id NUMBER;
x_transaction_qty NUMBER;
x_pri_uom VARCHAR2(3);
Deletion_Exception EXCEPTION;
Replacement_Exception EXCEPTION;
Lot_Serial_Exception EXCEPTION;

BEGIN



		/* **************************************************
		-- Note the newly seed WIP_SUBSTITUTION_TYPE data are
		-- 	1 	Add
		--	2	Replace
		--	3	Delete
		--	4	Lot/Serial

		-- I execute this cursor first as I believe that the
		-- substitions information will be small compared
		-- to the backflushed information

		-- Note: The enteries for the Substitution Item Id and the
		-- Inventory Item for the various kind of operation is
		-- listed below :
		--	Operation	Subst. Item	Inv Item
		--
		--      Replace		     X		    X
		--      Deletion			    X
		--	Addition	     X
		--	Lot/Serial	     		    X

		*****************************************************/

		-- Get Reason, Op_Seq, Source, Substitute, Revision,
		-- Supply_Locator, Supply_Subinv, Quantity, UOM, Department
		For Substitute_Record IN
		     Substitute_Cursor(Interface_Id, Organization_Id) LOOP


		  -- This is for Replacement
		  if (Substitute_Record.Substitution_Type_Id = 1 ) then

			/******************************************************
			-- Conditions for Replacement
			--	1. Replace
			--		a. If Op Seq and Item Exists
			--			- Replace the Item
			--		b. Else
			--		   (Cases: Op. Seq doesn't exist,
			--			   Op. Seq Exists but item doesn't)
			--			- Error it out
			******************************************************/

			OPEN BackFlush_Cursor( interface_id,
					Substitute_Record.operation_seq_num,
					Substitute_Record.Inventory_Item_Id,
					Substitute_Record.Organization_Id );

			FETCH BackFlush_Cursor INTO Txn_Interface_Id, Op_Seq,
					Result_Item, x_transaction_qty ;

			-- Operation ID and the Item is found.
			if(BackFlush_Cursor%FOUND) then

                                DELETE from mtl_transactions_interface
                                        WHERE OPERATION_SEQ_NUM
                                        = Substitute_Record.operation_seq_num
                                        AND   INVENTORY_ITEM_ID
                                        = Substitute_Record.inventory_item_id
                                        AND   ORGANIZATION_ID
                                        = Substitute_Record.organization_id
                                        AND parent_id
                                        = interface_id
                                        AND Transaction_Interface_Id
                                        = Txn_Interface_Id
                                        AND Substitution_Type_Id is NULL;

				UPDATE  mtl_transactions_interface
					SET INVENTORY_ITEM_ID =
					Substitute_Record.Substitution_item_id,
					Substitution_item_id =
					NULL,
					Substitution_type_id =
					NULL ,
					transaction_quantity =
					NVL(transaction_quantity, x_transaction_qty)
					where Transaction_Interface_id =
					Substitute_Record.transaction_interface_id  ;

                                  CLOSE BackFlush_Cursor ;

			else
				CLOSE BackFlush_Cursor ;
				fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_REPLACE');
				fnd_message.set_token('ENTITY1',
					to_char(Substitute_Record.operation_seq_num));
				Raise Replacement_Exception ;

			end if;


		-- This is a deletion
	        elsif (Substitute_Record.substitution_type_id = 2 ) then

			/******************************************************
                 	-- Conditions for Deletion
                 	--      2. Delete
                 	--              a. If Op Seq and Item Exists
                 	--                      - Delete1 the Item
                 	--              b. Else
                 	--                 (Cases: Op. Seq doesn't exist,
                 	--                         Op. Seq Exists but item doesn't)
                 	--                      - Error it out
			******************************************************/

		      OPEN BackFlush_Cursor( interface_id,
					Substitute_Record.operation_seq_num,
					Substitute_Record.inventory_item_id,
					Substitute_Record.Organization_Id) ;

		      FETCH BackFlush_Cursor INTO Txn_Interface_Id, Op_Seq,
					Result_Item, x_transaction_qty;

         		 -- The Item exists at a particular Operation
			 -- Sequence Number
			 if(BackFlush_Cursor%FOUND) then
         			DELETE from mtl_transactions_interface
				        WHERE OPERATION_SEQ_NUM
					= Substitute_Record.operation_seq_num
					AND   INVENTORY_ITEM_ID
					= Substitute_Record.inventory_item_id
					AND   ORGANIZATION_ID
					= Substitute_Record.organization_id
					AND parent_id
					= interface_id
					AND Transaction_Interface_Id
					= Txn_Interface_Id
					AND Substitution_Type_Id is NULL;

				CLOSE BackFlush_Cursor ;

				if(Delete_Children(Txn_Interface_Id)=0) then
                                  fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_DELETE');
                                  fnd_message.set_token('ENTITY2',
                                          to_char(Substitute_Record.operation_seq_num));
				  Raise Deletion_Exception;
				end if;

         	  	else
				CLOSE BackFlush_Cursor ;
                                fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_DELETE');
                                fnd_message.set_token('ENTITY2',
                                        to_char(Substitute_Record.operation_seq_num));
         			Raise Deletion_Exception ;

       		        end if ;

		-- This is addition
		elsif(Substitute_Record.substitution_type_id = 3) then

			/******************************************************
                        -- In the case of addition we copy the Substitute to the
                        -- Source. The cases allowed are :
                        --      3. Addition:
                        --              a. If Op Seq Exists - Add the Item
                        --              b. If Op. Seq and Item Exists -
                        --                      Treat it like additional issue
                        --              c. If the Op. Seq doesn't Exist
                        --                      Don't Error it out, Issue it.
			-- Note : We didn't Merge the Additions into one
			-- Mtl Isssue as inorder to merge the transactions
			-- they have to be in the same UOM and we should not
			-- overwrite the transaction Information without the
			-- user's knowledge (so we decided to have it as 2
			-- separate transactions) dsoosai,jgu
                        ******************************************************/

                           	UPDATE 	mtl_transactions_interface
                           	SET 	SUBSTITUTION_TYPE_ID = NULL,
			       		INVENTORY_ITEM_ID =
					Substitute_Record.Substitution_Item_Id,
			       		SUBSTITUTION_ITEM_ID =
					NULL
                          	 where TRANSACTION_INTERFACE_ID =
                                 	Substitute_Record.Transaction_Interface_Id;

                -- This is Lot/Serial
                elsif(Substitute_Record.substitution_type_id = 4) then

                        /******************************************************
                        -- In the case of Lot/Serial we set the txn_interface_id
			-- of the Orignal to that of the original.
                        -- The cases allowed are :
                        --      4. Lot/Serial:
                        --              a. If Op Seq and Item Exists - Replace the
			--		   the Item Lot/Serial Association.
                        --              b. Else -
			--		   (If Op Seq. doesn't exist or the
			--		       Op Seq and Item does not exist
			--		       then we will fail it).
			--
			-- Note: we will error it out if the Substitution Lot
			-- serial information is in a UOM other than the Primary
			-- UOM (this willhappen only when the user enters info.
			-- through the interface).
                        ******************************************************/

		  if (Wip_Common.Is_Primary_UOM(
				p_item_id => Substitute_Record.inventory_item_id,
				p_org_id => Substitute_Record.Organization_Id,
				p_txn_uom => Substitute_Record.Transaction_Uom,
				p_pri_uom => x_pri_uom) = 1 ) then

                      OPEN BackFlush_Cursor( interface_id,
                                        Substitute_Record.operation_seq_num,
                                        Substitute_Record.inventory_item_id,
                                        Substitute_Record.Organization_Id) ;

                      FETCH BackFlush_Cursor INTO Txn_Interface_Id, Op_Seq,
                                        Result_Item, x_transaction_qty;

                        if(BackFlush_Cursor%FOUND) then
			     DELETE from mtl_transactions_interface
 			     WHERE  transaction_interface_id =
				   Substitute_Record.transaction_interface_id;

			     -- Fix bug#1054753, take the substitution subinventory
                             UPDATE mtl_transactions_interface
                             SET    transaction_interface_id =
				    Substitute_Record.transaction_interface_id,
				    subinventory_code =
				    Substitute_Record.subinventory_code
                             where  TRANSACTION_INTERFACE_ID =
                                    Txn_Interface_Id ;

			     CLOSE BackFlush_Cursor ;

		       else

                                CLOSE BackFlush_Cursor ;
                                fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_LOT_SERIAL');
                                fnd_message.set_token('ENTITY1',
                                        to_char(Substitute_Record.operation_seq_num));
                                Raise Lot_Serial_Exception ;
 		       end if;

		  else

                       fnd_message.set_name('WIP', 'WIP_ERROR_MERGE_LOT_UOM');
		       fnd_message.set_token('ENTITY1',
					to_char(Substitute_Record.inventory_item_id));
                       fnd_message.set_token('ENTITY2',
                                    Substitute_Record.Transaction_uom);
		       fnd_message.set_token('ENTITY3',
				    x_pri_uom);
                       Raise Lot_Serial_Exception ;

		  end if ;
		  -- Transaction UOM

                end If;
		-- For Substitute Type

         END LOOP ;


	-- do the deletion here
	if(Delete_Substitutes(Interface_Id) = 0) then
		return 0;
	end if ;

  	 return 1;


EXCEPTION

When Deletion_Exception then
	err_mesg := fnd_message.get ;
	return 0;

When Replacement_Exception then
	err_mesg := fnd_message.get ;
	return 0;

When Lot_Serial_Exception then
	err_mesg := fnd_message.get ;
	return 0;

When NO_DATA_FOUND then
	-- This is not an error
	return 1;
when others then
	err_mesg := 'SQL Error in Wip_Subs_Merge.Cmp_Merge_Subs: ';
	err_mesg := err_mesg || SUBSTR(SQLERRM,1,130);
	return 0;

end Cmp_Merge_Subs ;


end Wip_Subs_Merge;

/
