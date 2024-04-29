--------------------------------------------------------
--  DDL for Package Body BOM_DELETE_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_DELETE_GROUPS_API" AS
/* $Header: BOMPDELB.pls 120.9 2007/07/09 11:07:51 bbpatel ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMPDELB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Delete_Groups_Api
--
--  NOTES
--
--  HISTORY
--
--  02-SEP-02   Vani Hymavathi    Initial Creation
***************************************************************************/
 /*****************************************************************
  * FUNCTION : invoke_events
  * Parameters IN :  action_type ,org_id,inv_id ,alternate,st type id,
  *                   bill_id ,comp_id,delete_type
  * Parameters OUT: err_text
  * return        : 0 -success , other - SQL Exception
  * Purpose : This function will invokde different Business Events
  *     depending on the parameters passed.
  ******************************************************************/
FUNCTION invoke_events(p_action_type IN NUMBER,
                       p_org_id IN NUMBER,
                       p_assembly_id IN NUMBER,
                       p_alternate VARCHAR2,
                       p_item_name VARCHAR2,
                       p_description VARCHAR2,
                       p_bill_id IN NUMBER,
                       p_comp_id IN NUMBER,
                       p_delete_type IN NUMBER,
                       err_text OUT NOCOPY VARCHAR2)  return NUMBER;
 /*****************************************************************
  * FUNCTION : write_log
  * Parameters IN :   alt_desg ,org_id,item_name ,comp_name ,
  *                   eff_date,op_seq,delete_type.
  * Parameters OUT: err_text
  * return        : 0 -success , other - SQL Exception
  * Purpose : This function will write to conc-log
  ******************************************************************/
FUNCTION write_log(alt_desg IN VARCHAR2,
               org_name IN VARCHAR2,
               item_name IN VARCHAR2,
               comp_name IN VARCHAR2,
               eff_date IN VARCHAR2,
               op_seq IN NUMBER,
                   delete_type IN NUMBER,
                   err_text OUT NOCOPY VARCHAR2) RETURN NUMBER;

 /*****************************************************************
  * FUNCTION :  substitute_tokens
  * Parameters IN :   token_list -TOKEN_RECORD, stmt -LONG
  * Parameters OUT:  stmt - LONG bind_list -BIND_TABLE, err_text
  * return        : 0 -success , other - SQL Exception
  * Purpose : This function will replace '&' with ':'.
  *        and capture all the bind parameters used in the statement.
  ******************************************************************/

FUNCTION substitute_tokens (token_list IN TOKEN_RECORD,
          stmt IN OUT NOCOPY long,
                            bind_list OUT NOCOPY BIND_TABLE,
          err_text  OUT NOCOPY varchar2) return NUMBER;

 /*****************************************************************
  * FUNCTION :  config_item_consolidate
  * Parameters IN :   inventory_item_id,organization_id,delete_entity_type
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose :  Configuration Item Purge - Consolidate Item
  ******************************************************************/

FUNCTION config_item_consolidate( p_inventory_item_id IN NUMBER,
                                  p_organization_id IN NUMBER,
                                p_delete_entity_type IN NUMBER,
                                err_text  OUT NOCOPY VARCHAR2) return NUMBER;

 /*****************************************************************
  * FUNCTION :  constraint_checker
  * Parameters IN :token_list-TOKEN_RECORD, delete_seq_id, delete_entity_type
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose :  This function checks all the constraints from
  *           bom_delete_sql_statements table that are valid for given
  *           delete entity type
  ******************************************************************/

FUNCTION constraint_checker( token_list IN TOKEN_RECORD,
                 delete_seq_id IN NUMBER,
                 delete_entity_type IN NUMBER,
                 err_text  OUT NOCOPY varchar2) return NUMBER;

 /*****************************************************************
  * FUNCTION :  extract_table_name
  * Parameters IN :stmt-LONG
  * return        : Table name present in the statement
  ******************************************************************/
FUNCTION extract_table_name ( stmt IN LONG, err_text  OUT NOCOPY varchar2) return LONG;

 /*****************************************************************
  * FUNCTION :  extract_table_name
  * Parameters IN :stmt-LONG
  * return        : where clause of the statement
  ******************************************************************/
FUNCTION extract_where (stmt IN LONG, err_text  OUT NOCOPY varchar2) return LONG;

 /*****************************************************************
  * FUNCTION :  archive_data
  * Parameters IN :token_list-TOKEN_RECORD, archive table name,
  *                product table name , where clause.
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose : archive the data from product table.
  ******************************************************************/

FUNCTION archive_data(token_list IN Token_Record,
              insert_table IN VARCHAR2,
            table_name IN VARCHAR2,
                where_clause IN VARCHAR2,
                            bind_list IN BIND_TABLE,
                      err_text  OUT NOCOPY VARCHAR2 ) return NUMBER ;
 /*****************************************************************
  * FUNCTION :  update_op_sequences
  * Parameters IN :tdelete_entity_type ,routing_seq_id
  * Parameters OUT:  err_text
  * return        : 0 -success , other - SQL Exception
  * Purpose : updates op sequences to 1 in BOM_INVENTORY_COMPONENTS
  ******************************************************************/

FUNCTION update_op_sequences(delete_entity_type IN NUMBER,
                       routing_seq_id IN NUMBER,
           op_seq_id IN NUMBER,
           err_text  OUT NOCOPY VARCHAR2 ) return NUMBER;


 /*****************************************************************
  * FUNCTION :  execute_delete
  * Parameters IN :token_list-TOKEN_RECORD, delete_entity_type
  *                 archive_flag
  * Parameters OUT:  err_text, action_status(4-delete,3-error)
  * return        : 0 -success , other - SQL Exception
  * Purpose :  This function executes the delete statements from
  *           bom_delete_sql_statements table that are valid for given
  *           delete entity type
  ******************************************************************/

FUNCTION execute_delete(delete_entity_type IN NUMBER,
           token_list IN Token_Record,
           archive_flag IN NUMBER,
           action_status OUT NOCOPY NUMBER,
             err_text  OUT NOCOPY VARCHAR2) return NUMBER;

 -- bug:5726408 Added support for executing UPDATE statement.
 /*****************************************************************
  * FUNCTION : execute_update
  * Parameters IN : delete_entity_type Type of delete entity
  *                 token_list Records of tokens to be substituted
  * Parameters OUT: action_status 4-delete, 3-error
  *                 err_text Error message in case of exception
  * return : 0 -success , other - SQL Exception
  * Purpose : This function executes the update statements from
  *           bom_delete_sql_statements table that are valid for given
  *           delete entity type
  ******************************************************************/

FUNCTION execute_update (
                          delete_entity_type  IN NUMBER,
                          token_list          IN Token_Record,
                          action_status       OUT NOCOPY NUMBER,
                          err_text            OUT NOCOPY VARCHAR2) RETURN NUMBER;


 /*****************************************************************
  * FUNCTION :  do_delete
  * Parameters IN :delete group id ,delete type
  *                 action_type (check or delete),archive_flag
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose :  This function checks all the constraints,
  *           arvhives the data based on the archive_flag option
  *           deletes the data based on action_type.
  ******************************************************************/

FUNCTION do_delete(group_id IN NUMBER,
      delete_type IN NUMBER,
      action_type IN NUMBER,
      archive_flag IN NUMBER,
      err_text  OUT NOCOPY VARCHAR2,
      process_errored_rows IN VARCHAR2) return NUMBER;


ENTITY CONSTANT NUMBER  :=1;
SUB_ENTITY CONSTANT NUMBER  :=2;
ACT_DELETE CONSTANT NUMBER  := 2;
ACT_CHECK CONSTANT NUMBER  :=1;
FATAL_ERROR CONSTANT NUMBER  :=-1000;
p_debug    VARCHAR2(1);
user_id NUMBER := -1;
resp_id NUMBER := -1;
resp_appl_id NUMBER := -1;
req_id NUMBER := -1;
prog_id NUMBER := -1;
prog_appl_id NUMBER := -1;


 /*****************************************************************
  * Procedure : delete groups
  * Parameters IN :
  *    delete_group_id,action_type,delete_type,archive
  * Parameters OUT: ERRBUF, RETCODE
  * Purpose : Main procedure for checking and deleting a delete group
  ******************************************************************/

PROCEDURE delete_groups
(ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
  delete_group_id  IN NUMBER:= '0',
  action_type IN NUMBER:= '1',
  delete_type IN NUMBER:= '1',
  archive IN NUMBER:='1',
  process_errored_rows IN VARCHAR2
  ) is

CONC_FAILURE EXCEPTION;
stmt_num NUMBER;

CURSOR delete_errors ( c_delete_group_id NUMBER )
IS
  SELECT 1
  FROM
    BOM_DELETE_ENTITIES bdent,
    BOM_DELETE_SUB_ENTITIES bdsubent
  WHERE
        bdent.DELETE_ENTITY_SEQUENCE_ID = bdsubent.DELETE_ENTITY_SEQUENCE_ID(+)
  AND   ( ( bdent.DELETE_STATUS_TYPE = 3 ) OR ( bdsubent.DELETE_STATUS_TYPE = 3 ) )
  AND   bdent.DELETE_GROUP_SEQUENCE_ID = c_delete_group_id;

BEGIN

stmt_num := 0;
   IF FND_PROFILE.VALUE('MRP_DEBUG') = 'Y' then
     p_debug := 'Y';
   else
     p_debug :='N';
   end if;

stmt_num := 1;
             user_id     := nvl(FND_PROFILE.Value('USER_ID'),-1);
             resp_id      :=nvl(FND_PROFILE.value('RESP_ID'),-1);
             resp_appl_id := nvl(FND_PROFILE.Value('RESP_APPL_ID'),-1);
			 req_id       := FND_GLOBAL.CONC_REQUEST_ID;
			 prog_id      := FND_GLOBAL.CONC_PROGRAM_ID;
			 prog_appl_id := FND_GLOBAL.PROG_APPL_ID;



stmt_num :=2;

  /*
   Added a call to Package BOM_DELETE_ENTITY.insert_common_bills
   This inserts the common Bill entities for the current org, or all Orgs
   or Org Hierarchy depending on the option chosen on the Delete Groups
   Form
  */
    bom_delete_entity.insert_common_bills(delete_group_id,delete_type);



stmt_num :=3;

    if (do_delete(delete_group_id, delete_type, action_type,
    archive,  ERRBUF, process_errored_rows) <> 0) then
  /*
  ** if delete returned failure, write error message to log file
  ** rollback and return CONC_FAILURE
  */
  raise CONC_FAILURE;
    end if;

stmt_num :=4;

   /*
   Added a call to Package BOM_DELETE_ENTITY.insert_original_bills
   This inserts original Bill entities for the all Orgs
   or Org Hierarchy depending on the option chosen on the Delete Groups   Form

   */
       bom_delete_entity.insert_original_bills(delete_group_id,delete_type);


stmt_num :=5;

    if (do_delete(delete_group_id, delete_type, action_type,
    archive , ERRBUF, process_errored_rows) <> 0) then

  /*
  ** if delete returned failure, write error message to log file
  ** rollback and return CONC_FAILURE
  */
  raise CONC_FAILURE;
    end if;

COMMIT;

  --bug:5235742 Change the concurrent program completion status. Set warning, if
  --some of the entities errored out during delete.
  FOR l_del_errors_rec IN delete_errors(delete_group_id)
  LOOP
    RETCODE := '1';
    EXIT;
  END LOOP;

  IF ( RETCODE = '1' ) THEN
    Fnd_Message.Set_Name('BOM','BOM_CONC_REQ_WARNING');
    ERRBUF := Fnd_Message.Get;
  ELSE
    RETCODE := '0';
    Fnd_Message.Set_Name('INV','INV_STATUS_SUCCESS');
    ERRBUF := Fnd_Message.Get;
    fnd_file.put_line( which => fnd_file.output, buff => ERRBUF);
  END IF; -- end if ( RETCODE = '1' )

EXCEPTION
   when CONC_FAILURE then
      ROLLBACK;
                       fnd_file.put_line( which => fnd_file.output,
                                buff => ERRBUF);
      RETCODE := '2';
   WHEN others THEN
      ERRBUF := ERRBUF||'Bom_Delete_Groups_Api '||stmt_num||' '||substrb(SQLERRM,1,500);
                       fnd_file.put_line( which => fnd_file.output,
                                buff => ERRBUF);
      RETCODE := '2';

end;

 /*****************************************************************
  * FUNCTION :  do_delete
  * Parameters IN :delete group id ,delete type
  *                 action_type (check or delete),archive_flag
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose :  This function checks all the constraints,
  *           arvhives the data based on the archive_flag option
  *           deletes the data based on action_type.
  ******************************************************************/

FUNCTION do_delete(group_id IN NUMBER,
                  delete_type IN NUMBER,
                  action_type IN NUMBER,
                  archive_flag IN NUMBER,
                  err_text  OUT NOCOPY varchar2,
                  process_errored_rows IN VARCHAR2) return NUMBER  is


CURSOR entity_cursor (p_group_id NUMBER )is
    SELECT /*+ ORDERED */ BDE.INVENTORY_ITEM_ID inventory_item_id,
     BDE.ORGANIZATION_ID organization_id,
           ALTERNATE_DESIGNATOR alternate_designator,
     DELETE_ENTITY_TYPE delete_entity_type,
     nvl(BILL_SEQUENCE_ID, -1) bill_seq_id,
     nvl(ROUTING_SEQUENCE_ID, -1) routing_seq_id,
                 -1 component_seq_id,
                 -1 operation_seq_id,
     DELETE_ENTITY_SEQUENCE_ID delete_entity_seq_id,
     MP.ORGANIZATION_CODE organization_code,
     BDE.ITEM_CONCAT_SEGMENTS item_name, --bug:6193035 Removed substrb
                 BDE.ITEM_DESCRIPTION description
    FROM BOM_DELETE_ENTITIES BDE, MTL_PARAMETERS MP
    WHERE DELETE_GROUP_SEQUENCE_ID = p_group_id
    AND   DELETE_STATUS_TYPE in (1,2, decode(process_errored_rows, 'Y', 3, 1))
    AND   BDE.ORGANIZATION_ID = MP.ORGANIZATION_ID
    ORDER BY decode(MP.MASTER_ORGANIZATION_ID,
        BDE.ORGANIZATION_ID, 2, 1),
       decode(BDE.DELETE_ENTITY_TYPE,2,9999,BDE.DELETE_ENTITY_TYPE) DESC,
       BDE.ALTERNATE_DESIGNATOR
    FOR UPDATE OF ALTERNATE_DESIGNATOR;

CURSOR sub_entity_cursor(p_group_id NUMBER) is
    SELECT /*+ ORDERED */ A.INVENTORY_ITEM_ID inventory_item_id,
     A.ORGANIZATION_ID organization_id,
     A.ALTERNATE_DESIGNATOR alternate_designator,
     nvl(BILL_SEQUENCE_ID, -1) bill_seq_id,
     nvl(ROUTING_SEQUENCE_ID, -1) routing_seq_id,
     nvl(B.COMPONENT_SEQUENCE_ID, -1) component_seq_id,
     nvl(B.OPERATION_SEQUENCE_ID, -1) operation_seq_id,
     B.DELETE_ENTITY_SEQUENCE_ID delete_entity_seq_id,
                 B.component_item_id component_item_id,
     MP.ORGANIZATION_CODE organization_code,
     B.OPERATION_SEQ_NUM op_seq_num,
     to_char(B.EFFECTIVITY_DATE, 'YYYY/MM/DD HH24:MI') effectivity_date,
     A.ITEM_CONCAT_SEGMENTS item_name,
     B.COMPONENT_CONCAT_SEGMENTS comp_name,
                 B.description description
    FROM BOM_DELETE_ENTITIES A, BOM_DELETE_SUB_ENTITIES B,
      MTL_PARAMETERS MP
    WHERE A.DELETE_GROUP_SEQUENCE_ID = p_group_id
    AND   B.DELETE_STATUS_TYPE in (1,2,3)
    AND   A.DELETE_ENTITY_SEQUENCE_ID =
        B.DELETE_ENTITY_SEQUENCE_ID
    AND   MP.ORGANIZATION_ID = A.ORGANIZATION_ID
    FOR UPDATE OF B.OPERATION_SEQUENCE_ID;

        cursor_type NUMBER;
      curr_del_entity_type NUMBER;
      current_seq_id NUMBER;
      curr_comp_seq_id NUMBER;
      curr_op_seq_id NUMBER;
        chk_ret NUMBER;
        action_status NUMBER;
        token_list Token_Record;
        delete_success NUMBER := 0;
        stmt_num NUMBER :=0;

BEGIN

stmt_num := 1;
/*
** retrieve all rows from DELETE_ENTITIES or DELETE_SUB_ENTITIES table
** depending on delete
*/
    if (delete_type =1 OR delete_type=2 OR delete_type=3 OR delete_type=6 OR delete_type=7 ) THEN
      cursor_type := ENTITY;
    else
      cursor_type := SUB_ENTITY;
    end if;

stmt_num := 2;
    if (cursor_type = ENTITY) THEN

          FOR entity_record in entity_cursor(group_id) LOOP
        SAVEPOINT start_process;

        current_seq_id  := entity_record.delete_entity_seq_id;
                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => 'delete_entity_Seq_id =  '|| to_char(current_seq_id));
                    end if;
                    curr_del_entity_type:= entity_record.delete_entity_type;
                    token_list.inventory_item_id := entity_record.inventory_item_id;
                    token_list.organization_id := entity_record.organization_id;
                    token_list.bill_sequence_id := entity_record.bill_seq_id;
                    token_list.routing_sequence_id := entity_record.routing_seq_id;
        token_list.component_sequence_id := entity_record.component_seq_id;
                    token_list.operation_sequence_id := entity_record.operation_seq_id;
                    token_list.del_group_seq_id := group_id;
stmt_num := 3;
              /*
         delete all errors if any for this entity row since we are going to
         rerun the delete on it
        */

        IF (curr_del_entity_type=1 OR curr_del_entity_type=2 OR curr_del_entity_type=3  )THEN
              DELETE FROM BOM_DELETE_ERRORS
        WHERE DELETE_ENTITY_SEQUENCE_ID = current_seq_id;
        END IF;

stmt_num := 5;
    chk_ret := constraint_checker(token_list, current_seq_id,
                              curr_del_entity_type, err_text );
stmt_num := 6;
    if (chk_ret = 0) THEN

      /*
      ** perform delete here if action_type is delete
      */
     if (action_type = ACT_DELETE) then
      stmt_num := 7;

      if (execute_delete(entity_record.delete_entity_type,
          token_list, archive_flag, action_status,
           err_text ) <> 0 ) then

           ROLLBACK TO SAVEPOINT start_process;
           delete_success := 1;
      else
        if (action_status = 4) then
           /*
            ** write to log file for every lntity deleted
            */
          if (    write_log(
            entity_record.alternate_designator,
            entity_record.organization_code,
            entity_record.item_name,
            null,
            null,
            null,
            entity_record.delete_entity_type,
            err_text )<>0) then
            return 2;
          end if;
          /*
          ** invoke business events
          */
          if (invoke_events(
                  action_status,
                  entity_record.organization_id,
                  entity_record.inventory_item_id,
                  entity_record.alternate_designator,
                  entity_record.item_name,
                  entity_record.description,
                  null,
                  null,
                  entity_record.delete_entity_type,
                  err_text) <> 0) then
                  return 2;
          end if;
       end if;
      end if;
     else
          action_status := 2; /* check ok */
     end if;
    elsif (chk_ret = 1) then
      action_status   := 3; /* error */
      /*
      ** invoke business events
      */
      if (invoke_events(
            action_status,
            entity_record.organization_id,
            entity_record.inventory_item_id,
            entity_record.alternate_designator,
            entity_record.item_name,
            entity_record.description,
            null,
            null,
            entity_record.delete_entity_type,
            err_text) <>0) then
         return 2;
       end if;
    else
     ROLLBACK TO SAVEPOINT start_process;
     return 2;
    end if;
      /*
      ** set the status
                        */
     UPDATE BOM_DELETE_ENTITIES
        SET DELETE_STATUS_TYPE = action_status,
            DELETE_DATE = decode(action_status, 4,
                                        sysdate, NULL),
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY  = user_id,
            REQUEST_ID       = req_id,
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROGRAM_ID = prog_id,
            PROGRAM_APPLICATION_ID = prog_appl_id
      WHERE DELETE_ENTITY_SEQUENCE_ID = current_seq_id;

      END LOOP; /* for */

   else
               for sub_entity_record in sub_entity_cursor(group_id) LOOP
        SAVEPOINT start_process;

        current_seq_id     := sub_entity_record.DELETE_ENTITY_SEQ_ID;
                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => 'delete_entity_Seq_id =  '|| to_char(current_seq_id));
                    end if;
                    curr_del_entity_type:= delete_type;
                    token_list.inventory_item_id := sub_entity_record.inventory_item_id;
                    token_list.organization_id := sub_entity_record.organization_id;
                    token_list.bill_sequence_id := sub_entity_record.bill_seq_id;
                    token_list.routing_sequence_id := sub_entity_record.routing_seq_id;
        token_list.component_sequence_id := sub_entity_record.component_seq_id;
                    token_list.operation_sequence_id := sub_entity_record.operation_seq_id;
                    token_list.del_group_seq_id := group_id;
                    token_list.component_item_id := sub_entity_record.component_item_id; -- added for bug:5726408

         /*
         ** delete all errors if any for this entity row since we are going to
         ** rerun the delete on it
         */
                    if (curr_del_entity_type=4 ) then
                curr_comp_seq_id := sub_entity_record.component_seq_id;
         DELETE FROM BOM_DELETE_ERRORS
        WHERE DELETE_ENTITY_SEQUENCE_ID = current_seq_id
        AND   COMPONENT_SEQUENCE_ID = curr_comp_seq_id;
                    elsif ( curr_del_entity_type= 5) then
           curr_op_seq_id := sub_entity_record.operation_seq_id;
           DELETE FROM BOM_DELETE_ERRORS
        WHERE DELETE_ENTITY_SEQUENCE_ID = current_seq_id
        AND   OPERATION_SEQUENCE_ID = curr_op_seq_id;
                    end if;

                chk_ret := constraint_checker(token_list, current_seq_id,
         curr_del_entity_type, err_text );

        if (chk_ret = 0) then
      /*
      ** perform delete here if action_type is delete
      */
      if (action_type = ACT_DELETE) then
          if (execute_delete(curr_del_entity_type,
        token_list, archive_flag, action_status,
        err_text ) <>0) THEN
         ROLLBACK TO SAVEPOINT start_process;
         delete_success := 1;
          else
        if (action_status = 4) then
        /*
        ** write to log file for every entity deleted
        */
                              if(write_log(
              sub_entity_record.alternate_designator,
              sub_entity_record.organization_code,
              sub_entity_record.item_name,
              sub_entity_record.comp_name,
              sub_entity_record.effectivity_date,
                                      sub_entity_record.op_seq_num,
              delete_type,err_text)<>0)then
                                     return 2;
                                    end if;

                                 /*
                                 ** invoke business events
                                 */
                              if(invoke_events(
              action_status,
              sub_entity_record.organization_id,
              null,
                                      null,
                                      sub_entity_record.comp_name,
                                      sub_entity_record.description,
              sub_entity_record.bill_seq_id,
              sub_entity_record.component_item_id,
              delete_type, err_text)<>0)then
                                     return 2;
                                    end if;

        end if;
          end if;

        /* bug:5726408 Execute UPDATE statement for entity */
        IF (  execute_update( curr_del_entity_type,
                              token_list,
                              action_status,
                              err_text ) <> 0 )
        THEN

          ROLLBACK TO SAVEPOINT start_process;
          delete_success := 1;

        END IF;

      else
          action_status := 2; /* check ok */
                        end if;
        elsif (chk_ret = 1) then
      action_status   := 3; /* error */
                                 /*
                                 ** invoke business events
                                 */
                              if(invoke_events(
              action_status,
              sub_entity_record.organization_id,
              null,
                                      null,
                                      sub_entity_record.comp_name,
                                      sub_entity_record.description,
              sub_entity_record.bill_seq_id,
              sub_entity_record.component_item_id,
              delete_type,err_text)<>0)then
                                     return 2;
                                    end if;

                    else
      ROLLBACK TO SAVEPOINT start_process;
                        return 2;
                    end if;

      /*
      ** set the status
                        */

       UPDATE BOM_DELETE_SUB_ENTITIES
          SET DELETE_STATUS_TYPE = action_status,
              DELETE_DATE = decode(action_status, 4,
                         sysdate, NULL),
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATED_BY = user_id,
              REQUEST_ID       = req_id,
              PROGRAM_UPDATE_DATE = SYSDATE,
              PROGRAM_ID = prog_id,
              PROGRAM_APPLICATION_ID = prog_appl_id
        WHERE DELETE_ENTITY_SEQUENCE_ID = current_seq_id
        AND   ((delete_type = 4
          AND COMPONENT_SEQUENCE_ID =
        curr_comp_seq_id)
       OR
       (curr_del_entity_type = 5
      AND OPERATION_SEQUENCE_ID =
        curr_op_seq_id));
           END LOOP;
     end if;

 if (delete_success = 1) then
  return 2;
 end if;
if (entity_cursor % ISOPEN) then
  close entity_cursor;
  end if;
if (sub_entity_cursor %ISOPEN) then
 close sub_entity_cursor;
 end if;

 return 0;

EXCEPTION
   WHEN others THEN
      err_text := err_text||'do_delete '||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;


END;


 /*****************************************************************
  * FUNCTION :  constraint_checker
  * Parameters IN :token_list-TOKEN_RECORD, delete_seq_id, delete_entity_type
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose :  This function checks all the constraints from
  *           bom_delete_sql_statements table that are valid for given
  *           delete entity type
  ******************************************************************/

FUNCTION constraint_checker( token_list IN Token_Record,
                     delete_seq_id IN  NUMBER,
                     delete_entity_type IN NUMBER,
                     err_text OUT NOCOPY varchar2) return NUMBER  is

     CURSOR constraint_cursor(p_delete_entity_type NUMBER) IS
        SELECT SQL_STATEMENT_NAME stmt_name,
               DELETE_ON_SUCCESS_FLAG delete_on_success_flag,
               MESSAGE_NAME,
               SQL_STATEMENT
        FROM BOM_DELETE_SQL_STATEMENTS
        WHERE SQL_STATEMENT_TYPE = 1
          AND ACTIVE_FLAG = 1
          AND DELETE_ENTITY_TYPE = p_delete_entity_type;

      cur_rec constraint_cursor%ROWTYPE;
        INVENTORY_ITEM_ID NUMBER;
        ORGANIZATION_ID NUMBER;
        COMPONENT_SEQUENCE_ID NUMBER;
        OPERATION_SEQUENCE_ID NUMBER;
        BILL_SEQUENCE_ID NUMBER;
       ROUTING_SEQUENCE_ID NUMBER;
        constraint_stmt LONG ;
        first_time NUMBER := 0;
        bind_list BIND_TABLE;
        cnt NUMBER;
        error_sequence_number NUMBER :=0;
        stmt_num NUMBER := 0;
        ret_code NUMBER :=0;
  cursor_name INTEGER;
  rows_processed INTEGER;

BEGIN


    INVENTORY_ITEM_ID := token_list.inventory_item_id;
    ORGANIZATION_ID :=  token_list.organization_id;
    BILL_SEQUENCE_ID :=  token_list.bill_sequence_id;
    ROUTING_SEQUENCE_ID :=  token_list.routing_sequence_id;
    COMPONENT_SEQUENCE_ID := token_list.component_sequence_id;
    OPERATION_SEQUENCE_ID := token_list.operation_sequence_id;

stmt_num :=1;
    OPEN constraint_cursor(delete_entity_type);

    LOOP
          FETCH constraint_cursor INTO cur_rec ;
          EXIT WHEN constraint_cursor%NOTFOUND;

stmt_num := 2;
  /*
  ** do the consolidation here for items and bill.  Set a savepoint here
  ** so that when constraint failure, then rollback consolidation
  */
      if ((delete_entity_type = 1 OR delete_entity_type = 2 OR
      delete_entity_type = 3) AND first_time = 0)THEN

stmt_num := 3;
    SAVEPOINT consolidate;
    first_time := 1;

    if (config_item_consolidate( inventory_item_id,organization_id,
      delete_entity_type, err_text) <> 0 )THEN

                   return (FATAL_ERROR);
          end if; /* if */
      END IF; /* if */
/*
** check to see if sql stmt was truncated, if so then allocate and
** retrieve again
*/
stmt_num := 4;
             SELECT SQL_STATEMENT
              INTO constraint_stmt
              FROM BOM_DELETE_SQL_STATEMENTS
                WHERE SQL_STATEMENT_NAME = cur_rec.stmt_name;

                    constraint_stmt := UPPER(constraint_stmt);
                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => constraint_stmt);
                    end if;

/*
** check to see if the first word in the statement is other than
** select.  In which case, this constraint should not be executed
*/
stmt_num := 5;
      if ( instr(constraint_stmt,'SELECT') =0) THEN
      return(FATAL_ERROR);
      end if;


stmt_num := 6;
           if (substitute_tokens(token_list, constraint_stmt,  bind_list ,err_text)<> 0) THEN
               return 2;
           else

                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => constraint_stmt);
                    end if;
stmt_num := 7;
             begin
          cursor_name := dbms_sql.open_cursor;
    DBMS_SQL.PARSE(cursor_name, constraint_stmt,dbms_sql.native);
                dbms_sql.define_column(cursor_name, 1, cnt);
    for i in 1..bind_list.COUNT loop

      DBMS_SQL.BIND_VARIABLE(cursor_name, bind_list(i).bind_name, bind_list(i).bind_value);

    end loop;
    rows_processed := dbms_sql.execute_and_fetch(cursor_name);
                dbms_sql.column_value(cursor_name, 1, cnt);
    dbms_sql.close_cursor(cursor_name);
             exception
               when no_data_found then
               cnt := 0;
    dbms_sql.close_cursor(cursor_name);
         when others then
          if(p_debug = 'Y')then
            fnd_file.put_line ( Which => FND_FILE.LOG,
                                buff => SUBSTRB(SQLERRM,1,500) );
          end if;
    DBMS_SQL.close_cursor(cursor_name);
             end;

                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => ' No of Rows = '||to_char(cnt));
                    end if;
              if (cnt =0 AND cur_rec.delete_on_success_flag = 1) OR
     (cnt <> 0 and cur_rec.delete_on_success_flag =2) then
               error_sequence_number := error_sequence_number +1;
               INSERT INTO BOM_DELETE_ERRORS (
                            DELETE_ENTITY_SEQUENCE_ID,
                            COMPONENT_SEQUENCE_ID,
                            OPERATION_SEQUENCE_ID,
                            ERROR_SEQUENCE_NUMBER,
                            SQL_STATEMENT_NAME,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY)
                            VALUES (
                                delete_seq_id,
                                component_sequence_id,
                                operation_sequence_id,
                                error_sequence_number,
                                cur_rec.stmt_name,
                                SYSDATE,
                                user_id,
                                SYSDATE,
                                user_id);
                ret_code := 1;
          end if;
          end if;
      END LOOP;
if constraint_cursor%ISOPEN then
close constraint_cursor;
end if;

return ret_code;

EXCEPTION
   WHEN others THEN
      err_text := err_text||'const_checker '||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;

END;



 /*****************************************************************
  * FUNCTION :  substitute_tokens
  * Parameters IN :   token_list -TOKEN_RECORD, stmt -LONG
  * Parameters OUT:  stmt - LONG bind_list -BIND_TABLE, err_text
  * return        : 0 -success , other - SQL Exception
  * Purpose : This function will replace '&' with ':'.
  *        and capture all the bind parameters used in the statement.
  ******************************************************************/
FUNCTION substitute_tokens ( token_list IN TOKEN_RECORD,
                 stmt IN OUT NOCOPY LONG,
                             bind_list OUT NOCOPY BIND_TABLE,
                 err_text OUT NOCOPY varchar2) return NUMBER is

i NUMBER :=1;
stmt_num NUMBER := 0;
BEGIN
stmt_num :=1;
   stmt := UPPER(stmt);

stmt_num := 2;
      stmt := replace(stmt,'&',':');

stmt_num := 3;
        if( INSTR (stmt,':BILL_SEQUENCE_ID',1,1) <>0 ) then
           bind_list(i).bind_name := 'BILL_SEQUENCE_ID';
           bind_list(i).bind_value := token_list.bill_sequence_id;
           i := i+1;
        end if;
stmt_num := 4;
        if (INSTR (stmt,':ROUTING_SEQUENCE_ID',1,1) <>0  ) then
           bind_list(i).bind_name := 'ROUTING_SEQUENCE_ID';
           bind_list(i).bind_value := token_list.routing_sequence_id;
           i := i+1;
  end if;
stmt_num := 5;
        if (INSTR (stmt,':ITEM_ID',1,1) <>0)  then
           bind_list(i).bind_name := 'ITEM_ID';
           bind_list(i).bind_value := token_list.inventory_item_id;
           i := i+1;
  end if;
stmt_num := 4;
        if (INSTR (stmt,':COMPONENT_SEQUENCE_ID',1,1) <>0) then
           bind_list(i).bind_name := 'COMPONENT_SEQUENCE_ID';
           bind_list(i).bind_value := token_list.component_sequence_id;
           i := i+1;
  end if;
stmt_num := 5;
        if (INSTR (stmt,':OPERATION_SEQUENCE_ID',1,1) <>0) then
           bind_list(i).bind_name := 'OPERATION_SEQUENCE_ID';
           bind_list(i).bind_value := token_list.operation_sequence_id;
           i := i+1;
        end if;
stmt_num := 6;
        if (INSTR (stmt,':ORGANIZATION_ID',1,1) <>0) then
           bind_list(i).bind_name := 'ORGANIZATION_ID';
           bind_list(i).bind_value := token_list.organization_id;
           i := i+1;
        end if;

stmt_num := 7;
        --bug:5546629 Added support for token DEL_GROUP_SEQ_ID
        if (INSTR (stmt,':DEL_GROUP_SEQ_ID',1,1) <>0) then
           bind_list(i).bind_name := 'DEL_GROUP_SEQ_ID';
           bind_list(i).bind_value := token_list.del_group_seq_id;
           i := i+1;
        end if;

stmt_num := 8;
        --bug:5546629 Added support for token COMP_ITEM_ID
        if (INSTR (stmt,':COMPONENT_ITEM_ID',1,1) <>0) then
           bind_list(i).bind_name := 'COMPONENT_ITEM_ID';
           bind_list(i).bind_value := token_list.component_item_id;
           i := i+1;
        end if;

return 0;

EXCEPTION
   WHEN others THEN
      err_text := err_text||'sub_token '||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;

END;




 /*****************************************************************
  * FUNCTION :  config_item_consolidate
  * Parameters IN :   inventory_item_id,organization_id,delete_entity_type
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose :  Configuration Item Purge - Consolidate Item
  ******************************************************************/
FUNCTION config_item_consolidate( p_inventory_item_id IN NUMBER,
                            p_organization_id IN NUMBER,
            p_delete_entity_type IN NUMBER,
          err_text OUT NOCOPY VARCHAR2) return NUMBER is

config_flag      VARCHAR2(1)   := ' ';
delete_status    VARCHAR2(10)  := ' ';
item_status      VARCHAR2(10)  := ' ';
base_id          NUMBER    := 0;
job_count        NUMBER    := 0;
stmt_num NUMBER :=0;

BEGIN
stmt_num := 1;
                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                         buff => 'inventory_item_id:'||to_char(p_inventory_item_id));
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => 'organization_id:'||to_char(p_organization_id));

                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => 'delete_entity_type:'||to_char(p_delete_entity_type));
                    end if;

    select MSI.AUTO_CREATED_CONFIG_FLAG,
            MSI.INVENTORY_ITEM_STATUS_CODE,
            MSI.BASE_ITEM_ID
     into   config_flag,
            item_status,
            base_id
     from   MTL_SYSTEM_ITEMS MSI
     where  MSI.ORGANIZATION_ID = p_organization_id
     and    MSI.INVENTORY_ITEM_ID = p_inventory_item_id;

stmt_num := 2;
     IF config_flag = 'Y' THEN
     BEGIN
        select BP.BOM_DELETE_STATUS_CODE
        into   delete_status
        from   BOM_PARAMETERS BP
        where  BP.ORGANIZATION_ID = p_organization_id;
stmt_num := 3;

        IF item_status = delete_status THEN
        BEGIN
           IF base_id <> p_inventory_item_id and base_id IS NOT NULL THEN
           BEGIN
              job_count := 0;
              IF p_delete_entity_type in (2,3) THEN  /* bill or routing */
              BEGIN
stmt_num := 4;
                 select count(*)
                 into   job_count
                 from   WIP_DISCRETE_JOBS WDJ
                 where  WDJ.ORGANIZATION_ID = p_organization_id
                 and    WDJ.PRIMARY_ITEM_ID = p_inventory_item_id
                 and    WDJ.STATUS_TYPE <> 12 /*Closed-no charges allowed*/
                 and    rownum = 1;  /* get just the first one that */
                                     /* isn't closed  */
                 IF job_count = 0 then  /* all were closed */
                 BEGIN
stmt_num := 5;
                    update WIP_ENTITIES WE
                    set    WE.PRIMARY_ITEM_ID = base_id
                    where  WE.ORGANIZATION_ID =p_organization_id
                    and    WE.PRIMARY_ITEM_ID = p_inventory_item_id;

stmt_num := 6;
                    update WIP_DISCRETE_JOBS WDJ
                    set    WDJ.PRIMARY_ITEM_ID = base_id,
                           WDJ.ALTERNATE_BOM_DESIGNATOR = NULL,
                           WDJ.ALTERNATE_ROUTING_DESIGNATOR = NULL
                    where  WDJ.ORGANIZATION_ID = p_organization_id
                    and    WDJ.PRIMARY_ITEM_ID = p_inventory_item_id;

stmt_num := 7;
                    update WIP_MOVE_TRANSACTIONS WMT
                    set    WMT.PRIMARY_ITEM_ID = base_id
                    where  WMT.ORGANIZATION_ID = p_organization_id
                    and    WMT.PRIMARY_ITEM_ID = p_inventory_item_id;

stmt_num := 8;
                    update WIP_MOVE_TXN_INTERFACE WMTI
                    set    WMTI.PRIMARY_ITEM_ID = base_id
                    where  WMTI.ORGANIZATION_ID = p_organization_id
                    and    WMTI.PRIMARY_ITEM_ID = p_inventory_item_id;

stmt_num := 9;
                    update WIP_REQUIREMENT_OPERATIONS WRO
                    set    WRO.INVENTORY_ITEM_ID = base_id
                    where  WRO.ORGANIZATION_ID = p_organization_id
                    and    WRO.INVENTORY_ITEM_ID = p_inventory_item_id;

stmt_num := 10;
                    update WIP_COST_TXN_INTERFACE WCTI
                    set    WCTI.PRIMARY_ITEM_ID = base_id
                    where  WCTI.ORGANIZATION_ID = p_organization_id
                    and    WCTI.PRIMARY_ITEM_ID = p_inventory_item_id;

stmt_num := 11;
                    update WIP_TRANSACTIONS WT
                    set    WT.PRIMARY_ITEM_ID = base_id
                    where  WT.ORGANIZATION_ID = p_organization_id
                    and    WT.PRIMARY_ITEM_ID = p_inventory_item_id;

                 END;
                END IF; /* if job status is closed */
              END;
              END IF; /* if bill or routing type */
              IF p_delete_entity_type = 1 THEN   /* item */
              BEGIN
stmt_num := 12;
                 update MTL_MATERIAL_TRANSACTIONS MT
                 set    MT.INVENTORY_ITEM_ID = base_id
                 where  MT.ORGANIZATION_ID = p_organization_id
                 and    MT.INVENTORY_ITEM_ID = p_inventory_item_id;

stmt_num := 13;
                 update MTL_TRANSACTION_LOT_NUMBERS MTLN
                 set    MTLN.INVENTORY_ITEM_ID = base_id
                 where  MTLN.ORGANIZATION_ID = p_organization_id
                 and    MTLN.INVENTORY_ITEM_ID = p_inventory_item_id;

stmt_num := 14;
                 update MTL_UNIT_TRANSACTIONS MUT
                 set    MUT.INVENTORY_ITEM_ID = base_id
                 where  MUT.ORGANIZATION_ID = p_organization_id
                 and    MUT.INVENTORY_ITEM_ID = p_inventory_item_id;
stmt_num := 15;

                 update MTL_TRANSACTION_ACCOUNTS MTA
                 set    MTA.INVENTORY_ITEM_ID = base_id
                 where  MTA.ORGANIZATION_ID = p_organization_id
                 and    MTA.INVENTORY_ITEM_ID = p_inventory_item_id;
              END;
              END IF; /* if item type */

           END;
           END IF;  /* if base_id <> item_id */
        END;
        END IF;  /* if status matches */
     END;
     END IF;  /* If config item */
     return(0);    /* Set status to OK */

  EXCEPTION
     WHEN NO_DATA_FOUND THEN /* Don't try to consolidate, return true status */
    return (0);
     WHEN OTHERS THEN
       err_text := err_text||'config_item_consolidate'||stmt_num||' '||substrb(SQLERRM,1,500);
       RETURN SQLCODE;
END;

 /*****************************************************************
  * FUNCTION :  execute_delete
  * Parameters IN :token_list-TOKEN_RECORD, delete_entity_type
  *                 archive_flag
  * Parameters OUT:  err_text, action_status(4-delete,3-error)
  * return        : 0 -success , other - SQL Exception
  * Purpose :  This function executes the delete statements from
  *           bom_delete_sql_statements table that are valid for given
  *           delete entity type
  ******************************************************************/
FUNCTION execute_delete(delete_entity_type IN NUMBER,
                       token_list IN Token_Record,
                       archive_flag IN NUMBER,
                       action_status OUT NOCOPY NUMBER,
                       err_text  OUT NOCOPY VARCHAR2) return NUMBER is

CURSOR delete_cursor(p_delete_entity_type NUMBER) IS
  SELECT sql_statement stmt, ARCHIVE_TABLE_NAME,
         length(ARCHIVE_TABLE_NAME) archive_table_length,
   SQL_STATEMENT_NAME stmt_name
  FROM BOM_DELETE_SQL_STATEMENTS
  WHERE SQL_STATEMENT_TYPE = 2
  AND ACTIVE_FLAG = 1
  AND DELETE_ENTITY_TYPE = p_delete_entity_type
  ORDER BY SEQUENCE_NUMBER;

 table_name VARCHAR2(80);
 where_stmt LONG;
 delete_stmt LONG;
 bind_list BIND_TABLE;
 stmt_num NUMBER :=0;
  cursor_name INTEGER;
  rows_processed INTEGER;
BEGIN
action_status := 3; -- initially set to Error.
stmt_num := 1;
       for cur_rec in delete_cursor(delete_entity_type) LOOP

stmt_num := 2;
    SAVEPOINT consolidate;

/*
** check to see if sql stmt was truncated, if so then allocate and
** retrieve again
*/

stmt_num := 3;

    delete_stmt := upper(cur_rec.stmt);

                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => delete_stmt);
                    end if;
/*
** check to see if the first word in the statement is other than
** select.  In which case, this constraint should not be executed
*/
stmt_num := 4;
           if ( instr(delete_stmt,'DELETE') =0) THEN
      return(FATAL_ERROR);

           end if;

stmt_num := 5;

           if (substitute_tokens(  token_list,delete_stmt,bind_list,err_text)<>0) THEN
               return 2;
           else
                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => delete_stmt);
                    end if;
       if (cur_rec.archive_table_length > 0 AND archive_flag = 1) THEN
stmt_num := 6;
          table_name  := extract_table_name(delete_stmt,err_text);
stmt_num := 7;
          where_stmt  := extract_where(delete_stmt,err_text);
stmt_num := 8;
          if (archive_data(token_list,cur_rec.archive_table_name,
    table_name, where_stmt,bind_list, err_text) <> 0) THEN
stmt_num := 9;
            ROLLBACK TO SAVEPOINT start_process;
        return 1;
         end if;
stmt_num := 1;
             end if;
           end if;


          cursor_name := dbms_sql.open_cursor;
    DBMS_SQL.PARSE(cursor_name, delete_stmt,dbms_sql.native);
    for i in 1..bind_list.COUNT loop


      DBMS_SQL.BIND_VARIABLE(cursor_name, bind_list(i).bind_name, bind_list(i).bind_value);

    end loop;
               rows_processed:= DBMS_SQL.execute(cursor_name);
    dbms_sql.close_cursor(cursor_name);
       END LOOP;
action_status := 4; -- deleted successfully
return 0;

EXCEPTION
   WHEN others THEN
      err_text := err_text||'exec_delete '||stmt_num||' '||substrb(SQLERRM,1,500);
      ROLLBACK TO SAVEPOINT start_process;
      RETURN SQLCODE;


end;

 -- bug:5726408 Added support for executing UPDATE statement.
 /*****************************************************************
  * FUNCTION : execute_update
  * Parameters IN : delete_entity_type Type of delete entity
  *                 token_list Records of tokens to be substituted
  * Parameters OUT: action_status 4-delete, 3-error
  *                 err_text Error message in case of exception
  * return : 0 -success , other - SQL Exception
  * Purpose : This function executes the update statements from
  *           bom_delete_sql_statements table that are valid for given
  *           delete entity type
  ******************************************************************/

FUNCTION execute_update (
                          delete_entity_type  IN NUMBER,
                          token_list          IN Token_Record,
                          action_status       OUT NOCOPY NUMBER,
                          err_text            OUT NOCOPY VARCHAR2) RETURN NUMBER
IS

  CURSOR delete_cursor(p_delete_entity_type NUMBER)
  IS
    SELECT
        SQL_STATEMENT stmt,
        SQL_STATEMENT_NAME stmt_name
    FROM BOM_DELETE_SQL_STATEMENTS
    WHERE
        SQL_STATEMENT_TYPE = 3
    AND ACTIVE_FLAG = 1
    AND DELETE_ENTITY_TYPE = p_delete_entity_type
    ORDER BY SEQUENCE_NUMBER;

  delete_stmt     LONG;
  bind_list       BIND_TABLE;
  stmt_num        NUMBER := 0;
  cursor_name     INTEGER;
  rows_processed  INTEGER;

BEGIN
  action_status := 3; -- initially set to Error.

  stmt_num := 1;
  FOR cur_rec IN delete_cursor ( delete_entity_type )
  LOOP

    /* check to see if sql stmt was truncated, if so then allocate and
     * retrieve again */

    stmt_num := 2;
    delete_stmt := UPPER(cur_rec.stmt);

    IF ( p_debug = 'Y' )
    THEN
      FND_FILE.put_line ( Which => FND_FILE.LOG,
                          buff => delete_stmt);
    END IF;

    /* check to see if the first word in the statement is UPDATE. */
    stmt_num := 3;
    IF ( INSTR( delete_stmt, 'UPDATE' ) = 0 )
    THEN
      RETURN( FATAL_ERROR );
    END IF;

    stmt_num := 4;
    IF ( substitute_tokens( token_list, delete_stmt, bind_list, err_text ) <> 0 )
    THEN
      RETURN 2;
    ELSE
      IF ( p_debug = 'Y' )
      THEN
        fnd_file.put_line ( Which => FND_FILE.LOG,
                            buff => delete_stmt );
      END IF;
    END IF ;

    cursor_name := DBMS_SQL.OPEN_CURSOR;

    DBMS_SQL.PARSE( cursor_name, delete_stmt, DBMS_SQL.NATIVE );

    FOR i IN 1 .. bind_list.COUNT
    LOOP
      DBMS_SQL.BIND_VARIABLE( cursor_name, bind_list(i).bind_name, bind_list(i).bind_value );
    END LOOP;

    rows_processed:= DBMS_SQL.EXECUTE(cursor_name);

    DBMS_SQL.CLOSE_CURSOR( cursor_name );

  END LOOP; -- end FOR cur_rec IN delete_cursor

  action_status := 4; -- deleted successfully
  RETURN 0;

EXCEPTION
   WHEN OTHERS THEN
      err_text := err_text||'exec_update '||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;

END execute_update;


 /*****************************************************************
  * FUNCTION :  update_op_sequences
  * Parameters IN :tdelete_entity_type ,routing_seq_id
  * Parameters OUT:  err_text
  * return        : 0 -success , other - SQL Exception
  * Purpose : updates op sequences to 1 in BOM_INVENTORY_COMPONENTS
  ******************************************************************/

FUNCTION update_op_sequences(delete_entity_type IN  NUMBER,
                                     routing_seq_id IN NUMBER,
                                     op_seq_id IN  NUMBER,
        err_text OUT NOCOPY varchar2) return NUMBER is
stmt_num NUMBER := 0;

BEGIN
    if (delete_entity_type = 3) THEN/* routing delete */
stmt_num := 1;
  UPDATE BOM_INVENTORY_COMPONENTS
      SET OPERATION_SEQ_NUM = 1
      WHERE BILL_SEQUENCE_ID = (SELECT BILL_SEQUENCE_ID
    FROM BOM_BILL_OF_MATERIALS BOM,
        BOM_OPERATIONAL_ROUTINGS BOR
    WHERE BOR.ROUTING_SEQUENCE_ID = routing_seq_id
    AND   BOR.ORGANIZATION_ID = BOM.ORGANIZATION_ID
    AND   BOR.ASSEMBLY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
    AND   nvl(BOR.ALTERNATE_ROUTING_DESIGNATOR, 'NONE') =
      nvl(BOM.ALTERNATE_BOM_DESIGNATOR, 'NONE'));
    else  /* operation delete */
stmt_num := 2;
  UPDATE BOM_INVENTORY_COMPONENTS BIC
      SET OPERATION_SEQ_NUM = 1
      WHERE BILL_SEQUENCE_ID = (SELECT BILL_SEQUENCE_ID
    FROM BOM_BILL_OF_MATERIALS BOM,
        BOM_OPERATIONAL_ROUTINGS BOR
    WHERE BOR.ROUTING_SEQUENCE_ID = routing_seq_id
    AND   BOR.ORGANIZATION_ID = BOM.ORGANIZATION_ID
    AND   BOR.ASSEMBLY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
    AND   nvl(BOR.ALTERNATE_ROUTING_DESIGNATOR, 'NONE') =
      nvl(BOM.ALTERNATE_BOM_DESIGNATOR, 'NONE'))
    AND OPERATION_SEQ_NUM = (SELECT OPERATION_SEQ_NUM
    FROM BOM_OPERATION_SEQUENCES
    WHERE OPERATION_SEQUENCE_ID = op_seq_id);
    end if;

return 0;
EXCEPTION
   WHEN others THEN
      err_text := err_text||'update_op_sequences'||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;

END;

 /*****************************************************************
  * FUNCTION :  archive_data
  * Parameters IN :token_list-TOKEN_RECORD, archive table name,
  *                product table name , where clause.
  * Parameters OUT:  err_text
  * return        : 0 -success ,2-error, other - SQL Exception
  * Purpose : archive the data from product table.
  ******************************************************************/

FUNCTION archive_data( token_list IN Token_Record,
           insert_table IN varchar2,
                       table_name IN varchar2,
                       where_clause IN varchar2,
                            bind_list IN BIND_TABLE,
                       err_text OUT NOCOPY varchar2) return NUMBER  is

   l_schema VARCHAR2(30);
   l_status     VARCHAR2(1);
   l_industry      VARCHAR2(1);
   l_oracleUser    VARCHAR2(30);

   CURSOR col_list_cursor( prod_table VARCHAR2,
                           schema_name VARCHAR2,
                           oracle_user VARCHAR2) IS
    SELECT distinct ATC.COLUMN_NAME COLUMN_NAME
    FROM  ALL_TAB_COLUMNS ATC,
          ALL_OBJECTS AO
    WHERE TABLE_NAME = trim(prod_table)
    AND     ( ( AO.OBJECT_TYPE = 'TABLE' AND ATC.OWNER = schema_name )
         OR   ( AO.OBJECT_TYPE = 'VIEW'  AND ATC.OWNER = oracle_user ) )
    AND AO.OBJECT_NAME = trim(prod_table)
        AND AO.OWNER = ATC.OWNER
    ORDER BY COLUMN_NAME;
insert_stmt LONG;
update_stmt LONG;
archive_table varchar2(80);
prod_table varchar2(80);
column_name VARCHAR2 (80);
dummy NUMBER :=0;
req_id NUMBER  :=-1;
prog_id NUMBER :=-1;
stmt_num NUMBER:=0;
cursor_name INTEGER;
rows_processed INTEGER;
l_app_short_name VARCHAR2(10);

BEGIN
/*
** update the standard who columns before archiving the data.  Need to
** do it this way, since if I try to update after archiving, then I don't
** know which rows were updated.  If for some reason there is a failure
** then it rollsback the updates anyways
*/


stmt_num := 0;
             req_id := nvl(FND_PROFILE.value('CONC_REQUEST_ID'),-1);
             prog_id := nvl(FND_PROFILE.value('CONC_PROGRAM_ID'),-1);
             resp_appl_id := nvl(FND_PROFILE.value('RESP_APPL_ID'),-1);

stmt_num := 1;
   update_stmt:=  'UPDATE' || table_name || ' SET REQUEST_ID = ' || req_id
    ||', PROGRAM_ID = ' || prog_id ||', PROGRAM_APPLICATION_ID =' || resp_appl_id
            ||', PROGRAM_UPDATE_DATE = sysdate ';

                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => update_stmt);
                    end if;
update_stmt := update_stmt ||' WHERE '||where_clause;
stmt_num := 2;
 cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, update_stmt,dbms_sql.native);
                for i in 1..bind_list.COUNT loop
                  DBMS_SQL.BIND_VARIABLE(cursor_name, bind_list(i).bind_name, bind_list(i).bind_value);
                end loop;
               rows_processed:= DBMS_SQL.execute(cursor_name);
                dbms_sql.close_cursor(cursor_name);
stmt_num := 3;
    archive_table := insert_table;
    prod_table := table_name;
/*
 Begin
          SELECT 1
       INTO dummy
       FROM DUAL
         WHERE EXISTS (
     SELECT NULL
     FROM ALL_TAB_COLUMNS COL1
     WHERE TABLE_NAME = trim(prod_table)
     AND NOT EXISTS (
       SELECT NULL
       FROM ALL_TAB_COLUMNS COL2
       WHERE TABLE_NAME = trim(archive_table)
       AND COL2.COLUMN_NAME = COL1.COLUMN_NAME));
exception
 when no_data_found then
  dummy :=0;
 when others then
  dummy :=2;
end;
stmt_num := 4;
    if (dummy <> 0) then
    -- archive table structure does not match production table structure
        fnd_message.set_name('BOM', 'BOM_ARCHIVE_TOO_OLD');
        err_text := fnd_message.get;
        return(2);
    end if;
*/
    SELECT
      ORACLE_USERNAME INTO l_oracleUser
    FROM
      FND_ORACLE_USERID
    WHERE
      READ_ONLY_FLAG = 'U';

    --Bug No: 4248530. When the prod table is in some schema other than BOM then we need
    -- to get the schema name Ex: MTL_RTG_ITEM_REVISIONS.
    l_app_short_name := 'BOM';
    IF(INSTR(trim(prod_table), 'MTL',1,1) = 1) THEN
        l_app_short_name := 'INV';
    END IF;

    IF NOT FND_INSTALLATION.GET_APP_INFO(l_app_short_name, l_status, l_industry, l_schema)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_schema IS NULL OR l_oracleUser IS NULL)
    THEN
      stmt_num := 4;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

stmt_num := 5;
    insert_stmt := insert_stmt  || ' INSERT INTO  '||insert_table || '( ';

    IF (p_debug = 'Y') THEN
        fnd_file.put_line (Which => FND_FILE.LOG, buff => ('Schema Name:' || l_schema));
        fnd_file.put_line (Which => FND_FILE.LOG, buff => ('Oracle User:' || l_oracleUser));
        fnd_file.put_line (Which => FND_FILE.LOG, buff => ('Prod Table:' || prod_table));
     END IF;

    for col_list in col_list_cursor(prod_table, l_schema, l_oracleUser) loop
         insert_stmt := insert_stmt || col_list.column_name || ' , ';
    END LOOP;

stmt_num := 6;
     insert_stmt:= trim (insert_stmt);
    insert_stmt := substr(insert_stmt,1,length(insert_stmt)-1 );
    insert_stmt := insert_stmt || ' )  SELECT ';

    for col_list in col_list_cursor(prod_table, l_schema, l_oracleUser) loop
          insert_stmt := insert_stmt || col_list.column_name || ' , ';
    END LOOP;

     insert_stmt := trim (insert_stmt);
    insert_stmt := substr(insert_stmt,1,length(insert_stmt)-1 );
stmt_num := 7;
    insert_stmt := insert_stmt || ' FROM '|| prod_table || ' WHERE ' ||where_clause;

stmt_num := 8;
                    if(p_debug = 'Y')then
                 fnd_file.put_line (Which => FND_FILE.LOG,
                                          buff => insert_stmt);
                    end if;
  cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, insert_stmt,dbms_sql.native);
                for i in 1..bind_list.COUNT loop

                        DBMS_SQL.BIND_VARIABLE(cursor_name, bind_list(i).bind_name, bind_list(i).bind_value);

                end loop;
               rows_processed:= DBMS_SQL.execute(cursor_name);
    dbms_sql.close_cursor(cursor_name);
return 0;

   EXCEPTION
   WHEN others THEN
      err_text := err_text||'archive_data'||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;

END;

 /*****************************************************************
  * FUNCTION :  extract_table_name
  * Parameters IN :stmt-LONG
  * return        : Table name present in the statement
  ******************************************************************/

FUNCTION extract_table_name ( stmt IN LONG, err_text OUT NOCOPY VARCHAR2) return LONG is
position1 NUMBER;
position2 NUMBER;
ret_value LONG;
stmt_num NUMBER;
BEGIN
stmt_num :=1;
position1 := instr (stmt, 'DELETE',1) +6;
stmt_num := 2;
position2 := instr(stmt,' WHERE',1);
stmt_num :=3;
ret_value := substr( stmt, position1, position2-position1);
stmt_num :=4;
ret_value := replace(ret_value,'FROM',' ');
stmt_num := 5;
return ret_value;
EXCEPTION
   WHEN others THEN
      err_text := err_text||'extract_table_name'||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;
END;
 /*****************************************************************
  * FUNCTION :  extract_table_name
  * Parameters IN :stmt-LONG
  * return        : where clause of the statement
  ******************************************************************/
FUNCTION extract_where (stmt IN LONG, err_text OUT NOCOPY VARCHAR2) return LONG is
position1 NUMBER;
stmt_num NUMBER;

BEGIN
stmt_num :=1;
position1 := instr(stmt,' WHERE',1);
stmt_num :=2;
return substr( stmt, position1+6);
EXCEPTION
   WHEN others THEN
      err_text := err_text||'extract_where '||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;
END;
 /*****************************************************************
  * FUNCTION : write_log
  * Parameters IN :   alt_desg ,org_id,item_name ,comp_name ,
  *                   eff_date,op_seq,delete_type.
  * Parameters OUT: err_text
  * return        : 0 -success , other - SQL Exception
  * Purpose : This function will write to conc-log
  ******************************************************************/
FUNCTION write_log(alt_desg IN VARCHAR2,
                   org_name IN VARCHAR2,
                   item_name IN VARCHAR2,
                   comp_name IN VARCHAR2,
                   eff_date IN VARCHAR2,
                   op_seq IN NUMBER,
                   delete_type IN NUMBER,
                   err_text OUT NOCOPY VARCHAR2)  return NUMBER is
err_text1 varchar2(2000);
err_text2 varchar2(2000);
stmt_num NUMBER;

begin
stmt_num := 1;
    if(delete_type = 1)then
         /* item delete */
          Fnd_Message.set_name('BOM', 'BOM_ITEM_DELETED');
      Fnd_Message.set_token('ORG', org_name);
          Fnd_Message.set_token('ITEM', item_name);
          err_text1 := Fnd_Message.get;
   elsif(delete_type =2 )then

      /* bill delete */
          Fnd_Message.set_name('BOM', 'BOM_BILL_DELETED');
      Fnd_Message.set_token('ORG', org_name);
          Fnd_Message.set_token('ITEM', item_name);
          Fnd_Message.set_token('ALTERNATE', alt_desg);
          err_text1 := Fnd_Message.get;
   elsif(delete_type =3 )then
   /* routing delete */
          Fnd_Message.set_name('BOM', 'BOM_ROUTING_DELETED');
      Fnd_Message.set_token('ORG', org_name);
          Fnd_Message.set_token('ITEM', item_name);
          Fnd_Message.set_token('ALTERNATE', alt_desg);
   elsif(delete_type =4 )then
  /* component delete */
          Fnd_Message.set_name('BOM', 'BOM_COMPONENT_DELETED1');
      Fnd_Message.set_token('ORG', org_name);
          Fnd_Message.set_token('ITEM', item_name);
          Fnd_Message.set_token('ALTERNATE', alt_desg);
          err_text1 := Fnd_Message.get;
          Fnd_Message.set_name('BOM', 'BOM_COMPONENT_DELETED2');
      Fnd_Message.set_token('COMPONENT', comp_name);
          Fnd_Message.set_token('OP', op_seq);
          Fnd_Message.set_token('EFFDATE', eff_date);
          err_text2 := Fnd_Message.get;
   elsif(delete_type =5 )then
  /* operation delete */
          Fnd_Message.set_name('BOM', 'BOM_OPERATION_DELETED1');
      Fnd_Message.set_token('ORG', org_name);
          Fnd_Message.set_token('ITEM', item_name);
          Fnd_Message.set_token('ALTERNATE', alt_desg);
          err_text1 := Fnd_Message.get;
          Fnd_Message.set_name('BOM', 'BOM_OPERATION_DELETED2');
      Fnd_Message.set_token('COMPONENT', comp_name);
          Fnd_Message.set_token('OP', op_seq);
          Fnd_Message.set_token('EFFDATE', eff_date);
          err_text2 := Fnd_Message.get;
   end if;
 if err_text1 IS NOT NULL THEN
    fnd_file.put_line (Which => FND_FILE.LOG,
                     buff => err_text1);
 else

   if err_text2 is not null then
    fnd_file.put_line (Which => FND_FILE.LOG,
                     buff => err_text2);

   end if;
 end if;
  return 0;
EXCEPTION
   WHEN others THEN
      err_text := err_text||'write_log'||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;

 end;

  /*****************************************************************
  * FUNCTION : invoke_events
  * Parameters IN :   ction_type ,org_id,inv_id ,alternate,structure type
  *                   bill_id, comp_id,delete_type
  * Parameters OUT: err_text
  * return        : 0 -success ,other - SQL Exception
  * Purpose : This function will invokde different Business Events
  *     depending on the parameters passed.
  ******************************************************************/
FUNCTION invoke_events(     p_action_type IN NUMBER,
                            p_org_id IN NUMBER,
                            p_assembly_id IN  NUMBER,
                            p_alternate IN VARCHAR2,
                            p_item_name VARCHAR2,
                            p_description VARCHAR2,
                            p_bill_id IN NUMBER,
                            p_comp_id IN  NUMBER,
                            p_delete_type IN NUMBER,
                            err_text OUT NOCOPY VARCHAR2)  return NUMBER is
l_ret_status  varchar2(1);
l_org_code varchar2(30);
l_master_org_flag varchar2(1);
stmt_num  NUMBER:=1;
begin

     if (p_action_type =4) then

       if (p_delete_type = 1) then

         /* Call IP api */ -- bug 4323967

         IF (BOM_VALIDATE.Object_Exists(
			                                  p_object_type  => 'PACKAGE',
			                                  p_object_name  => 'ICX_CAT_POPULATE_MI_GRP') = 'Y') THEN

           SELECT DECODE(master_organization_id, p_org_id, 'Y', 'N'), organization_code
				     INTO l_master_org_flag, l_org_code
    			 	 FROM MTL_PARAMETERS
    				WHERE organization_id = p_org_id;

           stmt_num := 2;

           EXECUTE IMMEDIATE
               			 ' BEGIN                                                '||
               			 '  ICX_CAT_POPULATE_MI_GRP.populateItemChange    (     '||
               			 '   P_API_VERSION        => 1.0              		'||
		                 '  ,P_COMMIT             => FND_API.G_FALSE		'||
               			 '  ,P_INIT_MSG_LIST      => FND_API.G_FALSE		'||
		                 '  ,P_VALIDATION_LEVEL   => FND_API.G_VALID_LEVEL_FULL '||
                     '  ,P_DML_TYPE           => ''DELETE''			'||
                     '  , P_INVENTORY_ITEM_ID   =>:p_assembly_id            '||
                     '  , P_ITEM_NUMBER         =>:p_item_name        	'||
                     '  , P_ORGANIZATION_ID     =>:p_org_id 		'||
                     '  , P_ORGANIZATION_CODE   =>:l_org_code		'||
                     '  , P_MASTER_ORG_FLAG     =>:l_master_org_flag	'||
                     '  , P_ITEM_DESCRIPTION    =>:p_description            '||
               			 '  ,X_RETURN_STATUS      => :l_ret_status );           '||
               			 ' END;'
           USING  IN p_assembly_id, IN p_item_name, IN p_org_id, IN l_org_code,  IN l_master_org_flag , IN p_description ,OUT l_ret_status;

         END IF; --BOM_VALIDATE.Object_Exists for ICX_CAT_POPULATE_MI_GRP

         --Now calling EGO code that will cancel any NIRs that exist for the deleted item.
         --Bug 5526375
         IF (BOM_VALIDATE.Object_Exists(
			                                  p_object_type  => 'PACKAGE',
			                                  p_object_name  => 'EGO_COMMON_PVT') = 'Y') THEN

           IF (BOM_VALIDATE.Object_Exists(
                                          p_object_type  => 'PACKAGE',
                                          p_object_name  => 'ENG_NIR_UTIL_PKG') = 'Y') THEN

             stmt_num := 3;

             EXECUTE IMMEDIATE
                       ' BEGIN                                       '||
                       '  EGO_COMMON_PVT.CANCEL_NIR_FOR_DELETE_ITEM( '||
                       '    P_INVENTORY_ITEM_ID   =>:p_assembly_id   '||
                       '  , P_ORGANIZATION_ID     =>:p_org_id   	   '||
                       '  , P_ITEM_NUMBER         =>:p_item_name );  '||
                       ' END;'
             USING IN p_assembly_id, IN p_org_id, IN p_item_name;

           END IF; --BOM_VALIDATE.Object_Exists for ENG_NIR_UTIL_PKG

         END IF; --BOM_VALIDATE.Object_Exists for EGO_COMMON_PVT


         Bom_Business_Event_PKG.Raise_Item_Event
           ( p_Inventory_Item_Id   => p_assembly_id
            ,p_Organization_Id     => p_org_id
            ,p_item_name           => p_item_name
            ,p_item_description    => p_description
            ,p_Event_Name          => Bom_Business_Event_PKG.G_ITEM_DEL_SUCCESS_EVENT);

       elsif (p_delete_type =2 ) then
         Bom_Business_Event_PKG.Raise_Bill_Event
           ( p_pk1_value =>to_char( p_assembly_id)
            ,p_pk2_value => to_char(p_org_id)
            ,p_obj_name => null
            ,p_structure_name => p_alternate
            ,p_structure_comment => null
            ,p_organization_id => p_org_id
            ,p_Event_Name          =>  Bom_Business_Event_PKG.G_STRUCTURE_DEL_SUCCESS_EVENT);
       elsif (p_delete_type =4) then
         Bom_Business_Event_PKG.Raise_Component_Event
           ( p_bill_sequence_id => p_bill_id
            ,p_pk1_value => to_char(p_comp_id)
            ,p_pk2_value => to_char(p_org_id)
            ,p_obj_name => null
            ,p_organization_id => p_org_id
            ,p_comp_item_name       => p_item_name
            ,p_comp_description => p_description
            ,p_Event_Name          =>  Bom_Business_Event_PKG.G_COMPONENT_DEL_SUCCESS_EVENT);
       end if;  --if (p_delete_type = 1) then

     elsif (p_action_type = 3) then

       if (p_delete_type = 1) then
         Bom_Business_Event_PKG.Raise_Item_Event
           ( p_Inventory_Item_Id   => p_assembly_id
            ,p_Organization_Id     => p_org_id
            ,p_item_name           => p_item_name
            ,p_item_description    => p_description
            ,p_Event_Name          => Bom_Business_Event_PKG.G_ITEM_DEL_ERROR_EVENT);
       elsif (p_delete_type =2 ) then
         Bom_Business_Event_PKG.Raise_Bill_Event
           ( p_pk1_value => to_char(p_assembly_id)
            ,p_pk2_value => to_char(p_org_id)
            ,p_obj_name => null
            ,p_structure_name => p_alternate
            ,p_structure_comment => null
            ,p_organization_id => p_org_id
            ,p_Event_Name          =>  Bom_Business_Event_PKG.G_STRUCTURE_DEL_ERROR_EVENT);
       elsif (p_delete_type =4) then
         Bom_Business_Event_PKG.Raise_Component_Event
           ( p_bill_sequence_id => p_bill_id
            ,p_pk1_value => to_char(p_comp_id)
            ,p_pk2_value => to_char(p_org_id)
            ,p_obj_name => null
            ,p_organization_id => p_org_id
            ,p_comp_item_name       => p_item_name
            ,p_comp_description => p_description
            ,p_Event_Name          =>  Bom_Business_Event_PKG.G_COMPONENT_DEL_ERROR_EVENT);
       end if; --if (p_delete_type = 1) then

     end if; --if (p_action_type =4) then

  return 0;

EXCEPTION
   WHEN others THEN
      err_text := err_text||'invoke_events'||stmt_num||' '||substrb(SQLERRM,1,500);
      RETURN SQLCODE;

   end;

PROCEDURE delete_groups
(ERRBUF OUT NOCOPY VARCHAR2,
RETCODE OUT NOCOPY VARCHAR2,
  delete_group_id  IN NUMBER:= '0',
  action_type IN NUMBER:= '1',
  delete_type IN NUMBER:= '1',
  archive IN NUMBER:='1'
  )
  is
  begin
    delete_groups(
      ERRBUF => ERRBUF,
      RETCODE => RETCODE,
      delete_group_id => delete_group_id ,
      action_type => action_type,
      delete_type => delete_type,
      archive => archive,
      process_errored_rows => 'Y');
  end;


end Bom_Delete_Groups_Api;

/
