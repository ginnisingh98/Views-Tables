--------------------------------------------------------
--  DDL for Package Body INVKBCGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVKBCGN" as
/* $Header: INVKBCGB.pls 120.3 2005/10/13 19:04:57 dherring noship $ */

--  Global constant holding the package name
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'INVKBCGN';

-- Global var holding the Current Error code for the error encountered
Current_Error_Code   Varchar2(20) := NULL;


/*
  Commented as part of bug fix 2493917.
  Procedure put_line is used now to write the
  logs.

/*

procedure  :	Set_Log_File
This procedure dynamically set the log and out file directories
*/
/*
Procedure Set_Log_File IS

   v_db_name VARCHAR2(100);
   v_log_name VARCHAR2(100);
   v_db_name VARCHAR2(100);
   v_st_position number(3);
   v_end_position number(3);
   v_w_position number(3);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 Begin
   select INSTR(value,',',1,2),INSTR(value,',',1,3)
   into v_st_position,v_end_position
   from  v$parameter
   where upper(name) = 'UTL_FILE_DIR';

   v_w_position := v_end_position - v_st_position - 1;

   select substr(value,v_st_position+1,v_w_position)
   into v_log_name
   from v$parameter
   where upper(name) = 'UTL_FILE_DIR';
   v_log_name := ltrim(v_log_name);
   FND_FILE.PUT_NAMES(v_log_name,v_log_name,v_log_name);

End Set_Log_File;
*/

/*
  This method is added as part of bug fix 2493917.
  This method will write log messages to log file
  for both modes, concurrent as well as standalone.
  Internally it uses INV_LOG_UTIL.TRACE for writting
  log messages to the log file.
*/
PROCEDURE put_line(msg VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	IF (l_debug = 1) THEN
   	INV_LOG_UTIL.TRACE(msg,g_pkg_name);
	END IF;
END put_line;


/*  Main procedure for kanban card creation */


PROCEDURE Create_Kanban_Cards(
                             ERRBUF               OUT NOCOPY VARCHAR2,
                             RETCODE              OUT NOCOPY NUMBER,
                             X_ORG_ID             IN  NUMBER,
                             X_ITEM_LO            IN  VARCHAR2,
                             X_ITEM_HI            IN  VARCHAR2,
                             X_SUBINV             IN  VARCHAR2,
                             X_LOCATOR_LO         IN  VARCHAR2,
                             X_LOCATOR_HI         IN  VARCHAR2,
                             X_SOURCE_TYPE        IN  NUMBER,
                             X_SUPPLIER_ID        IN  NUMBER,
                             X_SUPPLIER_SITE_ID   IN  NUMBER,
                             X_SOURCING_ORG_ID    IN  NUMBER,
                             X_SOURCING_SUBINV    IN  VARCHAR2,
                             X_SOURCING_LOC_ID    IN  NUMBER,
                             X_WIP_LINE_ID        IN  NUMBER,
                             X_STATUS             IN  NUMBER,
                             X_PULL_SEQ_ID        IN  NUMBER,
                             X_PRINT_KANBAN_CARD  IN  NUMBER,
		             X_REPORT_ID          IN  NUMBER  ) IS
        v_Retcode Number;
        CONC_STATUS BOOLEAN;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN

-- This statement will help running this program in standalone mode
-- For bug 2464024 : Commenting out set_log_file and fnd_file.put_line
-- statements since its giving unhandled exception when generating kanban cards.
 /*  Set_Log_File;  */

-- FND_FILE.PUT_NAMES('/sqlcom/log/kb.log', '/sqlcom/log/kb.out', '/sqlcom/log' );

  PUT_LINE('P_ORG_ID='||to_char(X_ORG_ID));
  PUT_LINE('P_ITEM_LO='''||X_ITEM_LO || '''');
  PUT_LINE('P_ITEM_HI='''||X_ITEM_HI || '''');
  PUT_LINE('P_SUBINV='''||X_SUBINV || '''');
  PUT_LINE('P_LOCATOR_LO='''||X_LOCATOR_LO || '''');
  PUT_LINE('P_LOCATOR_HI='''||X_LOCATOR_HI || '''');
  PUT_LINE('P_SOURCE_TYPE='||to_char(X_SOURCE_TYPE));
  PUT_LINE('P_SUPPLIER_ID='||to_char(X_SUPPLIER_ID));
  PUT_LINE('P_SUPPLIER_SITE_ID='||to_char(X_SUPPLIER_SITE_ID ));
  PUT_LINE('P_SOURCING_ORG_ID='||to_char(X_SOURCING_ORG_ID ));
  PUT_LINE('P_SOURCING_SUBINV='''||X_SOURCING_SUBINV || '''');
  PUT_LINE('P_SOURCING_LOC_ID='||to_char(X_SOURCING_LOC_ID));
  PUT_LINE('P_WIP_LINE_ID='||to_char(X_WIP_LINE_ID));
  PUT_LINE('P_STATUS='||to_char(X_STATUS));
  PUT_LINE('P_PULL_SEQ_ID='||to_char(X_PULL_SEQ_ID));
  PUT_LINE('P_PRINT_CARD='||to_char(X_PRINT_KANBAN_CARD));
  PUT_LINE('P_REPORT_ID='||to_char(X_REPORT_ID));
  PUT_LINE(' ');



 if ( X_pull_seq_id IS NOT NULL ) OR (X_REPORT_ID IS NOT NULL )then
   v_Retcode := resolve_pullseq_with_pull( X_STATUS,
                                           X_PULL_SEQ_ID,
                                           X_PRINT_KANBAN_CARD,
					   X_REPORT_ID );
 elsif (  (X_item_lo IS NULL)           AND
          (X_item_hi IS NULL)           AND
          (X_subinv IS NULL)            AND
          (X_locator_lo IS NULL)        AND
          (X_locator_hi IS NULL)        AND
          (X_source_type IS NULL)       AND
          (X_supplier_id IS NULL)       AND
          (X_supplier_site_id IS NULL)  AND
          (X_sourcing_org_id IS NULL)   AND
          (X_sourcing_subinv IS NULL)   AND
          (X_sourcing_loc_id IS NULL)   AND
          (X_wip_line_id IS NULL) )     then
    v_Retcode := resolve_pullseq_all_null( X_ORG_ID,
                                           X_ITEM_LO,
                                           X_ITEM_HI,
                                           X_SUBINV,
                                           X_LOCATOR_LO,
                                           X_LOCATOR_HI,
                                           X_SOURCE_TYPE,
                                           X_SUPPLIER_ID,
                                           X_SUPPLIER_SITE_ID,
                                           X_SOURCING_ORG_ID,
                                           X_SOURCING_SUBINV,
                                           X_SOURCING_LOC_ID,
                                           X_WIP_LINE_ID,
                                           X_STATUS,
                                           X_PRINT_KANBAN_CARD );
 elsif ( (X_locator_lo  IS NOT NULL)   OR
         (X_locator_hi  IS NOT NULL) ) then
   v_Retcode := resolve_pullseq_with_loc( X_ORG_ID,
                                          X_ITEM_LO,
                                          X_ITEM_HI,
                                          X_SUBINV,
                                          X_LOCATOR_LO,
                                          X_LOCATOR_HI,
                                          X_SOURCE_TYPE,
                                          X_SUPPLIER_ID,
                                          X_SUPPLIER_SITE_ID,
                                          X_SOURCING_ORG_ID,
                                          X_SOURCING_SUBINV,
                                          X_SOURCING_LOC_ID,
                                          X_WIP_LINE_ID,
                                          X_STATUS,
                                          X_PRINT_KANBAN_CARD );
 else
   v_Retcode := resolve_pullseq_no_loc( X_ORG_ID,
                                        X_ITEM_LO,
                                        X_ITEM_HI,
                                        X_SUBINV,
                                        X_LOCATOR_LO,
                                        X_LOCATOR_HI,
                                        X_SOURCE_TYPE,
                                        X_SUPPLIER_ID,
                                        X_SUPPLIER_SITE_ID,
                                        X_SOURCING_ORG_ID,
                                        X_SOURCING_SUBINV,
                                        X_SOURCING_LOC_ID,
                                        X_WIP_LINE_ID,
                                        X_STATUS,
                                        X_PRINT_KANBAN_CARD );
 end if; /** if ( X_pull_seq_id IS NOT NULL ) then **/


 if v_Retcode = 1 then
   RETCODE := v_Retcode;
   CONC_STATUS :=
     FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);
 elsif v_Retcode = 3 then
   RETCODE := v_Retcode;
   CONC_STATUS :=
     FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);
 else
   RETCODE := v_Retcode;
   CONC_STATUS :=
     FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
 end if;

Exception
    when others then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'Create_Kanban_Cards');
	  print_error;
        END IF;
     current_error_code := to_char(SQLCODE);
     RETCODE := 2;
     CONC_STATUS :=
           FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
END Create_Kanban_Cards;


FUNCTION  resolve_pullseq_all_null(
                          X_ORG_ID             IN  NUMBER,
                          X_ITEM_LO            IN  VARCHAR2,
                          X_ITEM_HI            IN  VARCHAR2,
                          X_SUBINV             IN  VARCHAR2,
                          X_LOCATOR_LO         IN  VARCHAR2,
                          X_LOCATOR_HI         IN  VARCHAR2,
                          X_SOURCE_TYPE        IN  NUMBER,
                          X_SUPPLIER_ID        IN  NUMBER,
                          X_SUPPLIER_SITE_ID   IN  NUMBER,
                          X_SOURCING_ORG_ID    IN  NUMBER,
                          X_SOURCING_SUBINV    IN  VARCHAR2,
                          X_SOURCING_LOC_ID    IN  NUMBER,
                          X_WIP_LINE_ID        IN  NUMBER,
                          X_STATUS             IN  NUMBER,
			  X_PRINT_KANBAN_CARD  IN  NUMBER  ) return Number IS

  cursor MKPSC is
       select
          pull_sequence_id , organization_id , inventory_item_id ,
          subinventory_name , locator_id , source_type , supplier_id,
          supplier_site_id, source_organization_id, source_subinventory,
	 source_locator_id, wip_line_id, kanban_size, number_of_cards,
	 release_kanban_flag
       from
          MTL_KANBAN_PULL_SEQUENCES
       where
          kanban_plan_id = -1 AND
          source_type in (1,2,3,4) AND
	  --release_kanban_flag = 1 AND
          organization_id = X_org_id
       for update of organization_id NOWAIT;

    KBCC           MKPSC%ROWTYPE;
    Rec            BOOLEAN := FALSE;
    v_success      Number := 1;
    v_report_id    Number := NULL;
    v_org_code     VARCHAR2(3);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
    For KBCC in MKPSC LOOP
      REC := TRUE;
      card_check_and_create( KBCC.PULL_SEQUENCE_ID,
                             KBCC.ORGANIZATION_ID,
                             KBCC.INVENTORY_ITEM_ID,
                             KBCC.SUBINVENTORY_NAME,
              	             KBCC.LOCATOR_ID,
                             KBCC.SOURCE_TYPE,
              	             KBCC.KANBAN_SIZE,
                             KBCC.NUMBER_OF_CARDS,
                             KBCC.SUPPLIER_ID,
                             KBCC.SUPPLIER_SITE_ID,
                             KBCC.SOURCE_ORGANIZATION_ID,
                             KBCC.SOURCE_SUBINVENTORY,
                             KBCC.SOURCE_LOCATOR_ID,
                             KBCC.WIP_LINE_ID,
                             X_STATUS,
                             X_PRINT_KANBAN_CARD,
			     kbcc.release_kanban_flag,
                             V_REPORT_ID );
    END LOOP;
    current_error_code := to_char(SQLCODE);

    if NOT REC  then
         FND_MESSAGE.set_name('INV', 'INV_NO_PULLSEQ_SELECTED');
         PUT_LINE( fnd_message.get );
         current_error_code := to_char(SQLCODE);
    end if;  /* if NOT REC then */

-- call to report conc pgm report
    if  (X_PRINT_KANBAN_CARD = 1 AND V_REPORT_ID IS NOT NULL ) then
      print_kanban_report( v_report_id );
    end if;
    Commit;
    return  v_success;

Exception
    when others then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_all_null');
	  print_error;
        END IF;
     v_success := 2;
     current_error_code := to_char(SQLCODE);
     return v_success;
END resolve_pullseq_all_null;



FUNCTION  resolve_pullseq_with_pull(
                          X_STATUS             IN  NUMBER,
                          X_PULL_SEQ_ID        IN  NUMBER,
                          X_PRINT_KANBAN_CARD  IN  NUMBER,
		 	  X_REPORT_ID          IN  NUMBER  ) return Number IS

  cursor MKPSC is
       select
          pull_sequence_id , organization_id , inventory_item_id ,
          subinventory_name , locator_id , source_type , supplier_id,
          supplier_site_id, source_organization_id, source_subinventory,
	 source_locator_id, wip_line_id, kanban_size, number_of_cards,
	 release_kanban_flag
       from
          MTL_KANBAN_PULL_SEQUENCES
       where
          pull_sequence_id = X_pull_seq_id AND
          source_type in (1,2,3,4) AND
	  --release_kanban_flag = 1 AND
	  x_report_id IS NULL
          OR (source_type in (1,2,3,4) AND
	  --release_kanban_flag = 1 AND
	  x_report_id IS NOT NULL and
	  pull_sequence_id in (select pull_sequence_id
	                       from mtl_kanban_card_print_temp
		               where x_report_id = report_id))
          for update of organization_id NOWAIT;

    KBCC    MKPSC%ROWTYPE;
    Rec     BOOLEAN := FALSE;
    v_success           Number := 1;
    v_report_id         Number := NULL;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
    v_report_id := x_report_id;
    For KBCC  in  MKPSC
    LOOP
         REC := TRUE;

         card_check_and_create( KBCC.PULL_SEQUENCE_ID, KBCC.ORGANIZATION_ID,
                                KBCC.INVENTORY_ITEM_ID, KBCC.SUBINVENTORY_NAME,
                 	        KBCC.LOCATOR_ID, KBCC.SOURCE_TYPE,
                 	        KBCC.KANBAN_SIZE, KBCC.NUMBER_OF_CARDS,
                                KBCC.SUPPLIER_ID, KBCC.SUPPLIER_SITE_ID,
                                KBCC.SOURCE_ORGANIZATION_ID,
                                KBCC.SOURCE_SUBINVENTORY,
                                KBCC.SOURCE_LOCATOR_ID, KBCC.WIP_LINE_ID,

				X_STATUS, X_PRINT_KANBAN_CARD,
				kbcc.release_kanban_flag,
				V_REPORT_ID );

    END LOOP;
        current_error_code := to_char(SQLCODE);
    if  NOT REC  then
              FND_MESSAGE.set_name('INV', 'INV_NO_PULLSEQ_SELECTED');
              PUT_LINE( fnd_message.get );
              current_error_code := to_char(SQLCODE);
    end if;

-- call to report conc pgm report
 if  (X_PRINT_KANBAN_CARD = 1 AND V_REPORT_ID IS NOT NULL ) then
   print_kanban_report( v_report_id );
 end if;
 Commit;
 return  v_success;

Exception
   when others then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_with_pull');
	  print_error;
        END IF;
        v_success := 2;
        current_error_code := to_char(SQLCODE);
        return v_success;
END resolve_pullseq_with_pull;


FUNCTION  resolve_pullseq_with_loc(
                          X_ORG_ID             IN  NUMBER,
                          X_ITEM_LO            IN  VARCHAR2,
                          X_ITEM_HI            IN  VARCHAR2,
                          X_SUBINV             IN  VARCHAR2,
                          X_LOCATOR_LO         IN  VARCHAR2,
                          X_LOCATOR_HI         IN  VARCHAR2,
                          X_SOURCE_TYPE        IN  NUMBER,
                          X_SUPPLIER_ID        IN  NUMBER,
                          X_SUPPLIER_SITE_ID   IN  NUMBER,
                          X_SOURCING_ORG_ID    IN  NUMBER,
                          X_SOURCING_SUBINV    IN  VARCHAR2,
                          X_SOURCING_LOC_ID    IN  NUMBER,
                          X_WIP_LINE_ID        IN  NUMBER,
                          X_STATUS             IN  NUMBER,
                          X_PRINT_KANBAN_CARD  IN  NUMBER  ) return Number IS

    Rec                         BOOLEAN := FALSE;
    d_sql_p   			integer := NULL;
    d_sql_rows_processed  	integer := NULL;
    d_sql_stmt                  varchar2(6000) := NULL;
    d_sql_stmt1                 varchar2(4000) := NULL;
    d_sql_stmt2                 varchar2(6000) := NULL;
    p_where_itm                 varchar2(2000) := NULL;
    p_where_loc                 varchar2(2000) := NULL;
    d_pull_seq_id               NUMBER;
    d_org_id                    NUMBER;
    d_inv_itm_id                NUMBER;
    d_subinv                    varchar2(10);
    d_loc_id                    NUMBER;
    d_src_type                  NUMBER;
    d_supp_id                   NUMBER;
    d_supp_site_id              NUMBER;
    d_src_org_id                NUMBER;
    d_src_subinv                varchar2(10);
    d_src_loc_id                NUMBER;
    d_wip_line_id               NUMBER;
    d_kanban_size               NUMBER;
    d_no_cards                  NUMBER;
    d_release_kanban_flag       NUMBER;
    v_success                   Number := 1;
    v_report_id                 Number := NULL;
    v_org_code                  VARCHAR2(3);
    v_item_name               mtl_system_items_kfv.concatenated_segments%TYPE;
    v_loc_name                mtl_item_locations_kfv.concatenated_segments%TYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

 if ( (X_ITEM_LO  IS NULL) AND (X_ITEM_HI  IS NULL) )    then

 Begin
   query_range_loc( X_org_id, X_locator_lo, X_locator_hi, p_where_loc);
   if ( p_where_loc  IS NOT NULL ) then
     d_sql_p := dbms_sql.open_cursor;

     d_sql_stmt :=
     'select pull_sequence_id ,organization_id ,inventory_item_id ,' ||
     ' subinventory_name , locator_id , source_type , supplier_id,' ||
     ' supplier_site_id, source_organization_id, source_subinventory,' ||
     ' source_locator_id, wip_line_id, kanban_size, number_of_cards, ' ||
     ' release_kanban_flag, from MTL_KANBAN_PULL_SEQUENCES  where '||
     ' organization_id   = :org_id AND source_type in (1,2,3,4) AND ' ||
     ' nvl(subinventory_name,''9999'') = ' ||
     ' nvl(:subinv, nvl(subinventory_name,''9999'')) AND ' ||
     ' nvl(source_type,-9999) = nvl(:source_type,nvl(source_type,-9999)) AND '||
     ' nvl(supplier_id,-9999) = nvl(:supplier_id,nvl(supplier_id,-9999)) AND '||
     ' nvl(supplier_site_id,-9999) = ' ||
     ' nvl(:supplier_site_id,nvl(supplier_site_id,-9999)) AND ' ||
     ' nvl(source_organization_id,-9999) = ' ||
     ' nvl(:sourcing_org_id, nvl(source_organization_id,-9999))  AND ' ||
     ' nvl(source_subinventory, ''9999'') = ' ||
     ' nvl(:sourcing_subinv, nvl(source_subinventory,''9999''))  AND ' ||
     ' nvl(source_locator_id, -9999) = '||
     ' nvl(:sourcing_loc_id,nvl(source_locator_id,-9999)) AND ' ||
     ' nvl(wip_line_id, -9999) = '||
     ' nvl(:line_id,nvl(wip_line_id,-9999)) AND ' ||
     ' kanban_plan_id = -1 AND ' ||
     --' release_kanban_flag = 1 AND ' ||
     ' locator_id in ( select inventory_location_id from mtl_item_locations ' ||
     ' where ' || p_where_loc ||
     ' and organization_id = :org_id) '||
     ' for update of organization_id NOWAIT ';


  PUT_LINE(' p_where ='||p_where_loc );
  PUT_LINE(' d_sql_stmt ='||substr(d_sql_stmt,1,75) );
  PUT_LINE('Before parsing');

     dbms_sql.parse( d_sql_p, d_sql_stmt , dbms_sql.native );

  PUT_LINE('Parsed The statement in loc');

      dbms_sql.define_column(d_sql_p,1,d_pull_seq_id);
      dbms_sql.define_column(d_sql_p,2,d_org_id );
      dbms_sql.define_column(d_sql_p,3,d_inv_itm_id);
      dbms_sql.define_column(d_sql_p,4,d_subinv,10 );
      dbms_sql.define_column(d_sql_p,5,d_loc_id);
      dbms_sql.define_column(d_sql_p,6,d_src_type);
      dbms_sql.define_column(d_sql_p,7,d_supp_id );
      dbms_sql.define_column(d_sql_p,8,d_supp_site_id );
      dbms_sql.define_column(d_sql_p,9,d_src_org_id );
      dbms_sql.define_column(d_sql_p,10,d_src_subinv,10 );
      dbms_sql.define_column(d_sql_p,11,d_src_loc_id );
      dbms_sql.define_column(d_sql_p,12,d_wip_line_id );
      dbms_sql.define_column(d_sql_p,13,d_kanban_size);
      dbms_sql.define_column(d_sql_p,14,d_no_cards);
      dbms_sql.define_column(d_sql_p,15,d_release_kanban_flag);

  PUT_LINE('Defined the cols in locs');

     dbms_sql.bind_variable(d_sql_p,'org_id', X_ORG_ID);
     dbms_sql.bind_variable(d_sql_p,'subinv', X_subinv);
     dbms_sql.bind_variable(d_sql_p,'source_type', X_source_type);
     dbms_sql.bind_variable(d_sql_p,'supplier_id', X_supplier_id);
     dbms_sql.bind_variable(d_sql_p,'supplier_site_id', X_supplier_site_id);
     dbms_sql.bind_variable(d_sql_p,'sourcing_org_id', X_sourcing_org_id);
     dbms_sql.bind_variable(d_sql_p,'sourcing_subinv', X_sourcing_subinv);
     dbms_sql.bind_variable(d_sql_p,'sourcing_loc_id', X_sourcing_loc_id);
     dbms_sql.bind_variable(d_sql_p,'line_id', X_wip_line_id);

  PUT_LINE('Bind the vars');

      d_sql_rows_processed := dbms_sql.execute(d_sql_p);

  PUT_LINE('No Rows ='||to_char(d_sql_rows_processed));

     Loop
         if ( dbms_sql.fetch_rows(d_sql_p) > 0 ) then
            Rec := TRUE;
            dbms_sql.column_value(d_sql_p,1, d_pull_seq_id);
            dbms_sql.column_value(d_sql_p,2, d_org_id);
            dbms_sql.column_value(d_sql_p,3, d_inv_itm_id);
            dbms_sql.column_value(d_sql_p,4, d_subinv);
            dbms_sql.column_value(d_sql_p,5, d_loc_id);
            dbms_sql.column_value(d_sql_p,6, d_src_type);
            dbms_sql.column_value(d_sql_p,7, d_supp_id);
            dbms_sql.column_value(d_sql_p,8, d_supp_site_id);
            dbms_sql.column_value(d_sql_p,9, d_src_org_id);
            dbms_sql.column_value(d_sql_p,10, d_src_subinv);
            dbms_sql.column_value(d_sql_p,11, d_src_loc_id);
            dbms_sql.column_value(d_sql_p,12, d_wip_line_id);
            dbms_sql.column_value(d_sql_p,13, d_kanban_size);
            dbms_sql.column_value(d_sql_p,14, d_no_cards);
	    dbms_sql.column_value(d_sql_p,15,d_release_kanban_flag);

            card_check_and_create( d_pull_seq_id,
                          	d_org_id, d_inv_itm_id, d_subinv,
                 	        d_loc_id, d_src_type,
                 	        d_kanban_size, d_no_cards,
                                d_supp_id, d_supp_site_id,
                                d_src_org_id, d_src_subinv,
                                d_src_loc_id, d_wip_line_id, X_STATUS,
				   X_PRINT_KANBAN_CARD,
				   d_release_kanban_flag,
				   V_REPORT_ID );
         else
           -- No more rows in cursor
             dbms_sql.close_cursor(d_sql_p);
             Exit;
        end if;
       End loop;
       current_error_code := to_char(SQLCODE);

      if  NOT Rec  then
            FND_MESSAGE.set_name('INV', 'INV_NO_PULLSEQ_SELECTED');
            PUT_LINE( fnd_message.get );
           current_error_code := to_char(SQLCODE);
      end if;
      if dbms_sql.is_open(d_sql_p) then
          dbms_sql.close_cursor(d_sql_p);
      end if;
   end if;
   Exception
       when others then
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_with_loc');
	    print_error;
          END IF;
          if dbms_sql.is_open(d_sql_p) then
              dbms_sql.close_cursor(d_sql_p);
          end if;
          v_success := 2;
          current_error_code := to_char(SQLCODE);
   end;

 Else

  Begin

   query_range_itm( X_item_lo, X_item_hi, p_where_itm);
   query_range_loc( X_org_id, X_locator_lo, X_locator_hi, p_where_loc);

  if (( p_where_itm  IS NOT NULL ) AND ( p_where_loc IS NOT NULL))  then
     d_sql_p := dbms_sql.open_cursor;
     d_sql_stmt :=
     'select pull_sequence_id ,organization_id ,inventory_item_id ,' ||
     ' subinventory_name , locator_id , source_type , supplier_id,' ||
     ' supplier_site_id, source_organization_id, source_subinventory,' ||
     ' source_locator_id, wip_line_id, kanban_size, number_of_cards, ' ||
     ' release_kanban_flag from MTL_KANBAN_PULL_SEQUENCES  where '||
     ' organization_id  = :org_id AND source_type in (1,2,3,4) AND ' ||
     'nvl(subinventory_name,''9999'') = ' ||
     'nvl(:subinv, nvl(subinventory_name,''9999'')) AND ' ||
     'nvl(source_type,-9999) = nvl(:source_type, nvl(source_type,-9999)) AND '||
     'nvl(supplier_id,-9999) = nvl(:supplier_id,nvl(supplier_id, -9999)) AND '||
     'nvl(supplier_site_id,-9999) = ' ||
     'nvl(:supplier_site_id,nvl(supplier_site_id,-9999)) AND ' ||
     'nvl(source_organization_id,-9999) = ' ||
     'nvl(:sourcing_org_id, nvl(source_organization_id,-9999))  AND ' ||
     'nvl(source_subinventory, ''9999'') = ' ||
     'nvl(:sourcing_subinv, nvl(source_subinventory,''9999''))  AND ' ||
     'nvl(source_locator_id, -9999) = '||
     'nvl(:sourcing_loc_id,nvl(source_locator_id,-9999)) AND ' ||
     'nvl(wip_line_id, -9999) = '||
     'nvl(:line_id,nvl(wip_line_id,-9999)) AND ' ||
     'locator_id in ( select inventory_location_id from mtl_item_locations ' ||
     'where ' || p_where_loc ||
     ' and organization_id = :org_id) AND ' ||
       'kanban_plan_id = -1';
      --  and  || 'release_kanban_flag = 1 '


     d_sql_stmt1 :=  ' AND ' ||
     'inventory_item_id in ( select inventory_item_id from mtl_system_items ' ||
     'where ' || p_where_itm || ' and organization_id = :org_id) ' ||
     ' for update of organization_id NOWAIT ';

  PUT_LINE(' len stmt ='||to_char(length(d_sql_stmt)) );
  PUT_LINE(' len stmt1 ='||to_char(length(d_sql_stmt1)));

    d_sql_stmt2 := d_sql_stmt || d_sql_stmt1;

  PUT_LINE(' p_where_itm ='||p_where_itm );
  PUT_LINE(' p_where_loc ='||p_where_loc );
  PUT_LINE(' d_sql_stmt ='||d_sql_stmt );
  PUT_LINE(' d_sql_stmt1 ='||d_sql_stmt1 );

    dbms_sql.parse( d_sql_p, d_sql_stmt2, dbms_sql.native );

  PUT_LINE('Parsed The statement in loc-itm');

      dbms_sql.define_column(d_sql_p,1,d_pull_seq_id);
      dbms_sql.define_column(d_sql_p,2,d_org_id );
      dbms_sql.define_column(d_sql_p,3,d_inv_itm_id);
      dbms_sql.define_column(d_sql_p,4,d_subinv,10 );
      dbms_sql.define_column(d_sql_p,5,d_loc_id);
      dbms_sql.define_column(d_sql_p,6,d_src_type);
      dbms_sql.define_column(d_sql_p,7,d_supp_id );
      dbms_sql.define_column(d_sql_p,8,d_supp_site_id );
      dbms_sql.define_column(d_sql_p,9,d_src_org_id );
      dbms_sql.define_column(d_sql_p,10,d_src_subinv,10 );
      dbms_sql.define_column(d_sql_p,11,d_src_loc_id );
      dbms_sql.define_column(d_sql_p,12,d_wip_line_id );
      dbms_sql.define_column(d_sql_p,13,d_kanban_size);
      dbms_sql.define_column(d_sql_p,14,d_no_cards);
      dbms_sql.define_column(d_sql_p,15,d_release_kanban_flag);
  PUT_LINE('Defined the cols in loc-itm');

     dbms_sql.bind_variable(d_sql_p,'org_id', X_ORG_ID);
     dbms_sql.bind_variable(d_sql_p,'subinv', X_subinv);
     dbms_sql.bind_variable(d_sql_p,'source_type', X_source_type);
     dbms_sql.bind_variable(d_sql_p,'supplier_id', X_supplier_id);
     dbms_sql.bind_variable(d_sql_p,'supplier_site_id', X_supplier_site_id);
     dbms_sql.bind_variable(d_sql_p,'sourcing_org_id', X_sourcing_org_id);
     dbms_sql.bind_variable(d_sql_p,'sourcing_subinv', X_sourcing_subinv);
     dbms_sql.bind_variable(d_sql_p,'sourcing_loc_id', X_sourcing_loc_id);
     dbms_sql.bind_variable(d_sql_p,'line_id', X_wip_line_id);

  PUT_LINE('Bind the vars ');

      d_sql_rows_processed := dbms_sql.execute(d_sql_p);

  PUT_LINE('No ofRows='||to_char(d_sql_rows_processed));

     Loop
         if ( dbms_sql.fetch_rows(d_sql_p) > 0 ) then
            Rec := TRUE;
            dbms_sql.column_value(d_sql_p,1, d_pull_seq_id);
            dbms_sql.column_value(d_sql_p,2, d_org_id);
            dbms_sql.column_value(d_sql_p,3, d_inv_itm_id);
            dbms_sql.column_value(d_sql_p,4, d_subinv);
            dbms_sql.column_value(d_sql_p,5, d_loc_id);
            dbms_sql.column_value(d_sql_p,6, d_src_type);
            dbms_sql.column_value(d_sql_p,7, d_supp_id);
            dbms_sql.column_value(d_sql_p,8, d_supp_site_id);
            dbms_sql.column_value(d_sql_p,9, d_src_org_id);
            dbms_sql.column_value(d_sql_p,10, d_src_subinv);
	    dbms_sql.column_value(d_sql_p,11, d_src_loc_id);
	    dbms_sql.column_value(d_sql_p,12, d_wip_line_id);
	    dbms_sql.column_value(d_sql_p,13, d_kanban_size);
	    dbms_sql.column_value(d_sql_p,14, d_no_cards);
	    dbms_sql.column_value(d_sql_p,15,d_release_kanban_flag);

            card_check_and_create( d_pull_seq_id,
                          	d_org_id, d_inv_itm_id, d_subinv,
                 	        d_loc_id, d_src_type,
                 	        d_kanban_size, d_no_cards,
                                d_supp_id, d_supp_site_id,
                                d_src_org_id, d_src_subinv,
                                d_src_loc_id, d_wip_line_id, X_STATUS,
				   X_PRINT_KANBAN_CARD,
				   d_release_kanban_flag,
				   V_REPORT_ID );
         else
           -- No more rows in cursor
             dbms_sql.close_cursor(d_sql_p);
             Exit;
         end if;
      End loop;
       current_error_code := to_char(SQLCODE);

       if  NOT Rec  then
               FND_MESSAGE.set_name('INV', 'INV_NO_PULLSEQ_SELECTED');
               PUT_LINE( fnd_message.get );
              current_error_code := to_char(SQLCODE);
       end if;
       if dbms_sql.is_open(d_sql_p) then
           dbms_sql.close_cursor(d_sql_p);
       end if;
    end if;
    Exception
       when others then
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_with_loc');
	   print_error;
         END IF;
         if dbms_sql.is_open(d_sql_p) then
             dbms_sql.close_cursor(d_sql_p);
         end if;
         v_success := 2;
         current_error_code := to_char(SQLCODE);
   end;

 end if;

-- call to report conc pgm report
   if  (X_PRINT_KANBAN_CARD = 1 AND V_REPORT_ID IS NOT NULL ) then
       print_kanban_report( v_report_id );
   end if;
 Commit;
return v_success;

Exception
   when others then
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_with_loc');
	  print_error;
          v_success := 2;
          current_error_code := to_char(SQLCODE);
          return v_success;
END resolve_pullseq_with_loc;


FUNCTION  resolve_pullseq_no_loc(
                          X_ORG_ID             IN  NUMBER,
                          X_ITEM_LO            IN  VARCHAR2,
                          X_ITEM_HI            IN  VARCHAR2,
                          X_SUBINV             IN  VARCHAR2,
                          X_LOCATOR_LO         IN  VARCHAR2,
                          X_LOCATOR_HI         IN  VARCHAR2,
                          X_SOURCE_TYPE        IN  NUMBER,
                          X_SUPPLIER_ID        IN  NUMBER,
                          X_SUPPLIER_SITE_ID   IN  NUMBER,
                          X_SOURCING_ORG_ID    IN  NUMBER,
                          X_SOURCING_SUBINV    IN  VARCHAR2,
                          X_SOURCING_LOC_ID    IN  NUMBER,
                          X_WIP_LINE_ID        IN  NUMBER,
                          X_STATUS             IN  NUMBER,
                          X_PRINT_KANBAN_CARD  IN  NUMBER  ) return Number IS

  cursor MKPSC is
    select
          pull_sequence_id , organization_id , inventory_item_id ,
          subinventory_name , locator_id , source_type , supplier_id,
          supplier_site_id, source_organization_id, source_subinventory,
      source_locator_id, wip_line_id, kanban_size, number_of_cards ,
      release_kanban_flag
    from
          MTL_KANBAN_PULL_SEQUENCES
    where
    organization_id   = X_org_id AND
    nvl(subinventory_name,'9999') =
                               nvl(X_subinv, nvl(subinventory_name,'9999')) AND
    nvl(source_type,-9999) = nvl(X_source_type, nvl(source_type,-9999))     AND
    nvl(supplier_id,-9999) = nvl(X_supplier_id,nvl(supplier_id, -9999))     AND
    nvl(supplier_site_id,-9999) =
                        nvl(X_supplier_site_id,nvl(supplier_site_id,-9999)) AND
    nvl(source_organization_id,-9999) =
                 nvl(X_sourcing_org_id, nvl(source_organization_id,-9999))  AND
    nvl(source_subinventory, '9999') =
                   nvl(X_sourcing_subinv, nvl(source_subinventory,'9999'))  AND
    nvl(source_locator_id, -9999) =
                        nvl(X_sourcing_loc_id,nvl(source_locator_id,-9999)) AND
    nvl(wip_line_id, -9999) =
                        nvl(X_wip_line_id,nvl(wip_line_id,-9999)) AND
    kanban_plan_id = -1 AND
      source_type in (1,2,3,4)
      --AND release_kanban_flag = 1
    for update of organization_id NOWAIT;

    KBCC                        MKPSC%ROWTYPE;
    Rec                         BOOLEAN := FALSE;
    d_sql_p   			integer := NULL;
    d_sql_rows_processed  	integer := NULL;
    d_sql_stmt                  varchar2(4000) := NULL;
    p_where                     varchar2(2000) := NULL;
    d_pull_seq_id               NUMBER;
    d_org_id                    NUMBER;
    d_inv_itm_id                NUMBER;
    d_subinv                    varchar2(10);
    d_loc_id                    NUMBER;
    d_src_type                  NUMBER;
    d_supp_id                   NUMBER;
    d_supp_site_id              NUMBER;
    d_src_org_id                NUMBER;
    d_src_subinv                varchar2(10);
    d_src_loc_id                NUMBER;
    d_wip_line_id               NUMBER;
    d_kanban_size               NUMBER;
    d_no_cards                  NUMBER;
    d_release_kanban_flag       NUMBER;
    v_success                   Number := 1;
    v_report_id                 Number := NULL;
    v_org_code                  VARCHAR2(3);
    v_item_name              mtl_system_items_kfv.concatenated_segments%TYPE;
    v_loc_name               mtl_item_locations_kfv.concatenated_segments%TYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  Begin
      if ( (X_ITEM_LO  IS NULL) AND (X_ITEM_HI  IS NULL) )    then
    Begin
      For KBCC  in  MKPSC   LOOP
         REC := TRUE;
         card_check_and_create( KBCC.PULL_SEQUENCE_ID, KBCC.ORGANIZATION_ID,
                                KBCC.INVENTORY_ITEM_ID, KBCC.SUBINVENTORY_NAME,
                 	        KBCC.LOCATOR_ID, KBCC.SOURCE_TYPE,
                 	        KBCC.KANBAN_SIZE, KBCC.NUMBER_OF_CARDS,
                                KBCC.SUPPLIER_ID, KBCC.SUPPLIER_SITE_ID,
                                KBCC.SOURCE_ORGANIZATION_ID,
                                KBCC.SOURCE_SUBINVENTORY,
                                KBCC.SOURCE_LOCATOR_ID,
                                KBCC.WIP_LINE_ID, X_STATUS,
                                X_PRINT_KANBAN_CARD,
				kbcc.release_kanban_flag,V_REPORT_ID );
      END LOOP;
      current_error_code := to_char(SQLCODE);
      if  NOT REC  then
                FND_MESSAGE.set_name('INV', 'INV_NO_PULLSEQ_SELECTED');
                PUT_LINE( fnd_message.get );
      end if;
      current_error_code := to_char(SQLCODE);
      Exception
         when others then
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_no_loc');
	     print_error;
           END IF;
        v_success := 2;
        current_error_code := to_char(SQLCODE);
   end;

 Else

  Begin

   query_range_itm( X_item_lo, X_item_hi, p_where);
    if ( p_where  IS NOT NULL ) then
      d_sql_p := dbms_sql.open_cursor;
      d_sql_stmt :=
      'select pull_sequence_id ,organization_id ,inventory_item_id ,' ||
      ' subinventory_name , locator_id , source_type , supplier_id,' ||
      ' supplier_site_id, source_organization_id, source_subinventory,' ||
      ' source_locator_id, wip_line_id, kanban_size, number_of_cards, ' ||
      ' release_kanban_flag from MTL_KANBAN_PULL_SEQUENCES  where '||
      ' organization_id   = :org_id AND source_type in (1,2,3,4) AND ' ||
      ' nvl(subinventory_name,''9999'') = ' ||
      ' nvl(:subinv, nvl(subinventory_name,''9999'')) AND ' ||
     ' nvl(source_type,-9999) = nvl(:source_type,nvl(source_type,-9999)) AND '||
     ' nvl(supplier_id,-9999) = nvl(:supplier_id,nvl(supplier_id,-9999)) AND '||
      ' nvl(supplier_site_id,-9999) = ' ||
      ' nvl(:supplier_site_id,nvl(supplier_site_id,-9999)) AND ' ||
      ' nvl(source_organization_id,-9999) = ' ||
      ' nvl(:sourcing_org_id, nvl(source_organization_id,-9999))  AND ' ||
      ' nvl(source_subinventory, ''9999'') = ' ||
      ' nvl(:sourcing_subinv, nvl(source_subinventory,''9999''))  AND ' ||
      ' nvl(source_locator_id, -9999) = '||
      ' nvl(:sourcing_loc_id,nvl(source_locator_id,-9999)) AND ' ||
      'nvl(wip_line_id, -9999) = '||
      'nvl(:line_id,nvl(wip_line_id,-9999)) AND ' ||
      ' kanban_plan_id = -1 AND ' ||
      --' release_kanban_flag = 1 AND ' ||
     ' inventory_item_id in ( select inventory_item_id from mtl_system_items '||
      ' where ' || p_where || ' and organization_id = :org_id) ' ||
     ' for update of organization_id NOWAIT ';


  PUT_LINE(' p_where ='||p_where );
  PUT_LINE(' d_sql_stmt ='||d_sql_stmt );

     dbms_sql.parse( d_sql_p, d_sql_stmt , dbms_sql.native );

  PUT_LINE('Parsed The statement in no_loc');

      dbms_sql.define_column(d_sql_p,1,d_pull_seq_id);
      dbms_sql.define_column(d_sql_p,2,d_org_id );
      dbms_sql.define_column(d_sql_p,3,d_inv_itm_id);
      dbms_sql.define_column(d_sql_p,4,d_subinv,10 );
      dbms_sql.define_column(d_sql_p,5,d_loc_id);
      dbms_sql.define_column(d_sql_p,6,d_src_type);
      dbms_sql.define_column(d_sql_p,7,d_supp_id );
      dbms_sql.define_column(d_sql_p,8,d_supp_site_id );
      dbms_sql.define_column(d_sql_p,9,d_src_org_id );
      dbms_sql.define_column(d_sql_p,10,d_src_subinv,10 );
      dbms_sql.define_column(d_sql_p,11,d_src_loc_id );
      dbms_sql.define_column(d_sql_p,12,d_wip_line_id );
      dbms_sql.define_column(d_sql_p,13,d_kanban_size);
      dbms_sql.define_column(d_sql_p,14,d_no_cards);
      dbms_sql.define_column(d_sql_p,15,d_release_kanban_flag);

  PUT_LINE('Defined the cols in no_locs');

     dbms_sql.bind_variable(d_sql_p,'org_id', X_ORG_ID);
     dbms_sql.bind_variable(d_sql_p,'subinv', X_subinv);
     dbms_sql.bind_variable(d_sql_p,'source_type', X_source_type);
     dbms_sql.bind_variable(d_sql_p,'supplier_id', X_supplier_id);
     dbms_sql.bind_variable(d_sql_p,'supplier_site_id', X_supplier_site_id);
     dbms_sql.bind_variable(d_sql_p,'sourcing_org_id', X_sourcing_org_id);
     dbms_sql.bind_variable(d_sql_p,'sourcing_subinv', X_sourcing_subinv);
     dbms_sql.bind_variable(d_sql_p,'sourcing_loc_id', X_sourcing_loc_id);
     dbms_sql.bind_variable(d_sql_p,'line_id', X_wip_line_id);

  PUT_LINE('Bind the vars in  no_locs');

      d_sql_rows_processed := dbms_sql.execute(d_sql_p);

  PUT_LINE('No ofRows ='||to_char(d_sql_rows_processed));

     Loop
         if ( dbms_sql.fetch_rows(d_sql_p) > 0 ) then
            Rec := TRUE;
            dbms_sql.column_value(d_sql_p,1, d_pull_seq_id);
            dbms_sql.column_value(d_sql_p,2, d_org_id);
            dbms_sql.column_value(d_sql_p,3, d_inv_itm_id);
            dbms_sql.column_value(d_sql_p,4, d_subinv);
            dbms_sql.column_value(d_sql_p,5, d_loc_id);
            dbms_sql.column_value(d_sql_p,6, d_src_type);
            dbms_sql.column_value(d_sql_p,7, d_supp_id);
            dbms_sql.column_value(d_sql_p,8, d_supp_site_id);
            dbms_sql.column_value(d_sql_p,9, d_src_org_id);
            dbms_sql.column_value(d_sql_p,10, d_src_subinv);
            dbms_sql.column_value(d_sql_p,11, d_src_loc_id);
	    dbms_sql.column_value(d_sql_p,12, d_wip_line_id);
	    dbms_sql.column_value(d_sql_p,13, d_kanban_size);
	    dbms_sql.column_value(d_sql_p,14, d_no_cards);
	    dbms_sql.column_value(d_sql_p,15, d_release_kanban_flag);

            card_check_and_create( d_pull_seq_id,
                          	d_org_id, d_inv_itm_id, d_subinv,
                 	        d_loc_id, d_src_type,
                 	        d_kanban_size, d_no_cards,
                                d_supp_id, d_supp_site_id,
                                d_src_org_id, d_src_subinv,
                                d_src_loc_id, d_wip_line_id, X_STATUS,
				   X_PRINT_KANBAN_CARD,
				   d_release_kanban_flag,
				   V_REPORT_ID );
         else
           -- No more rows in cursor
             dbms_sql.close_cursor(d_sql_p);
             Exit;
         end if;
      End loop;
       current_error_code := to_char(SQLCODE);
      if  NOT Rec  then
                FND_MESSAGE.set_name('INV', 'INV_NO_PULLSEQ_SELECTED');
                PUT_LINE( fnd_message.get );
     end if;
     current_error_code := to_char(SQLCODE);
     if dbms_sql.is_open(d_sql_p) then
           dbms_sql.close_cursor(d_sql_p);
     end if;
   end if;
     Exception
        when others then
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_no_loc');
	     print_error;
           END IF;
          if dbms_sql.is_open(d_sql_p) then
             dbms_sql.close_cursor(d_sql_p);
          end if;
          v_success := 2;
          current_error_code := to_char(SQLCODE);
         return v_success;
   end;
 end if;

-- call to report conc pgm report
 if  (X_PRINT_KANBAN_CARD = 1 AND V_REPORT_ID IS NOT NULL ) then
      print_kanban_report( v_report_id );
 end if;
 Commit;
 return v_success;

Exception
   when others then
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'resolve_pullseq_no_loc');
          print_error;
     v_success := 2;
     current_error_code := to_char(SQLCODE);
     return v_success;
END resolve_pullseq_no_loc;


PROCEDURE  card_check_and_create(
			  X_PULL_SEQUENCE_ID     IN  NUMBER,
                          X_ORG_ID               IN  NUMBER,
                 	  X_ITEM_ID              IN  NUMBER,
                          X_SUBINV               IN  VARCHAR2,
                 	  X_LOC_ID               IN  NUMBER,
                          X_SOURCE_TYPE          IN  NUMBER,
                 	  X_KANBAN_SIZE          IN  NUMBER,
                          X_NO_OF_CARDS          IN  NUMBER,
                          X_SUPPLIER_ID          IN  NUMBER,
                          X_SUPPLIER_SITE_ID     IN  NUMBER,
                          X_SOURCING_ORG_ID      IN  NUMBER,
                          X_SOURCING_SUBINV      IN  VARCHAR2,
                          X_SOURCING_LOC_ID      IN  NUMBER,
                          X_WIP_LINE_ID          IN  NUMBER,
                          X_STATUS               IN  NUMBER,
				  X_PRINT_KANBAN_CARD    IN  NUMBER,
				  p_release_kanban_flag IN NUMBER,
                          X_REPORT_ID            IN OUT NOCOPY NUMBER   ) IS

l_kanban_card_ids    INV_Kanban_PVT.kanban_card_id_tbl_type;
l_pull_seq_rec       INV_Kanban_PVT.pull_sequence_rec_type;
l_return_status      varchar2(1) := FND_API.G_RET_STS_SUCCESS;
l_report_id          number;
l_org_code           VARCHAR2(3) := Null;
l_item_name          MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE := Null;
l_loc_name           MTL_ITEM_LOCATIONS_KFV.CONCATENATED_SEGMENTS%TYPE := Null;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
   l_pull_seq_rec.pull_sequence_id          := X_pull_sequence_id;
   l_pull_seq_rec.organization_id           := X_org_id ;
   l_pull_seq_rec.inventory_item_id         := X_item_id ;
   l_pull_seq_rec.subinventory_name         := X_subinv;
   l_pull_seq_rec.locator_id                := X_loc_id;
   l_pull_seq_rec.source_type               := X_source_type ;
   l_pull_seq_rec.Kanban_size               := X_kanban_size ;
   l_pull_seq_rec.number_of_cards           := X_no_of_cards ;
   l_pull_seq_rec.supplier_id               := X_supplier_id ;
   l_pull_seq_rec.supplier_site_id          := X_supplier_site_id ;
   l_pull_seq_rec.source_organization_id    := X_sourcing_org_id ;
   l_pull_seq_rec.source_subinventory       := X_sourcing_subinv ;
   l_pull_seq_rec.source_locator_id         := X_sourcing_loc_id ;
   l_pull_seq_rec.wip_line_id       	    := X_wip_line_id ;
   l_pull_seq_rec.release_kanban_flag       := p_release_kanban_flag;

     if  INV_kanban_PVT.Ok_To_Create_Kanban_Cards(X_Pull_sequence_id )  then
         INV_kanban_PVT.create_kanban_cards( l_return_status,
                                              l_kanban_card_ids,
                                              l_pull_seq_rec,
                                              X_STATUS );

         if  l_return_status = FND_API.G_RET_STS_ERROR  then
              Raise FND_API.G_EXC_ERROR;
	 end if;

         if l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              Raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         if X_PRINT_KANBAN_CARD = 1  then
               	if  X_REPORT_ID  IS NULL  then
               	  select  MTL_KANBAN_CARD_PRINT_TEMP_S.nextval
               	  into  l_report_id  from  DUAL;
               	  X_REPORT_ID := l_report_id;
               	end if;
		for l_card_count in 1..l_kanban_card_Ids.count
                 LOOP
                  insert into MTL_KANBAN_CARD_PRINT_TEMP
                  (REPORT_ID,KANBAN_CARD_ID)
                  values ( x_report_id, l_kanban_card_Ids(l_card_count) );
                 END LOOP;
	 end if;

     if  X_loc_id is not NULL  then

        kb_get_conc_segments(X_org_id, X_loc_id, l_loc_name);
/*
       	Select concatenated_segments
       	into l_loc_name
       	from mtl_item_locations_kfv
       	where inventory_location_id = X_loc_id and
               	    organization_id = X_org_id;
*/
     end if;

     if X_item_id is not NULL then
         Select concatenated_segments
         into l_item_name
         from mtl_system_items_kfv
         where inventory_item_id = X_item_id and
                 organization_id = X_org_id;
     end if;

         Select organization_code
         into l_org_code
         from mtl_parameters
         where ORGANIZATION_ID = X_org_id;

         FND_MESSAGE.set_name('INV','INV_KANBAN_CARDS_CREATED');
         FND_MESSAGE.SET_TOKEN('ORG_CODE',l_org_code);
         FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
         FND_MESSAGE.SET_TOKEN('SUB_CODE',X_subinv);
         FND_MESSAGE.SET_TOKEN('LOCATOR_NAME',l_loc_name);
         PUT_LINE( fnd_message.get );
     else
        PUT_LINE( fnd_message.get );
     end if;
Exception
     when  FND_API.G_EXC_ERROR   then
	print_error;
     when  FND_API.G_EXC_UNEXPECTED_ERROR   then
	print_error;
     when others  then
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'card_check_and_create');
	  print_error;
END card_check_and_create;


PROCEDURE query_range_loc( X_org_id     IN Number,
                           X_locator_lo IN VARCHAR2,
                           X_locator_hi IN VARCHAR2,
                           X_where      OUT NOCOPY VARCHAR2 )  IS
v_num  		       NUMBER;
v_delim  	       varchar2(1);
v_append               varchar2(1000) := NULL;
v_where                varchar2(2000) := NULL;
v_cnt                  Number := 0;
v_ctr                  Number;
v_flex_num             Number := Null;
v_proj_ref_enabled     Number := Null;
Rec                    Boolean := FALSE;
comma                  varchar2(1) := '''';

seg_low  fnd_flex_ext.SegmentArray;
seg_high fnd_flex_ext.SegmentArray;

Cursor CUR1(v_struct_num Number) is
      select a.application_column_name, b.format_type
      from FND_ID_FLEX_SEGMENTS_VL a, FND_FLEX_VALUE_SETS b
      where  a.application_id = 401         and
             a.id_flex_code   = 'MTLL'      and
             a.id_flex_num    = v_struct_num  and
             a.enabled_flag   = 'Y'         and
             a.display_flag   = 'Y'         and
             a.flex_value_set_id = b.flex_value_set_id
      order by  a.segment_num;


--CUR2  CUR1%ROWTYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

 Select id_flex_num into v_flex_num
 from fnd_id_flex_structures
 where id_flex_code = 'MTLL';

 Select project_reference_enabled into v_proj_ref_enabled
 from  MTL_PARAMETERS
 where organization_id = X_org_id;

  v_delim := fnd_flex_ext.get_delimiter('INV','MTLL', v_flex_num);

  v_num := fnd_flex_ext.breakup_segments( X_locator_lo, v_delim, seg_low);
  v_num := fnd_flex_ext.breakup_segments( X_locator_hi, v_delim, seg_high);


  -- bug 4662395 set the profile mfg_organization_id so
  -- the call to MTL_PROJECT_V will return data.

  FND_PROFILE.put('MFG_ORGANIZATION_ID',X_org_id);

-- Building the where clause

 for CUR2 in CUR1(v_flex_num)  Loop
   Rec := TRUE;
   v_cnt := v_cnt + 1;
   if ( (seg_low(v_cnt) IS NOT NULL)  OR (seg_high(v_cnt) IS NOT NULL) )  then
       if v_where is not null   then
     		     v_append := v_where||' and ';
       else
                     v_append := NULL;
       end if;

     if  v_proj_ref_enabled = 1  AND
         ( CUR2.APPLICATION_COLUMN_NAME =  'SEGMENT19'  OR
           CUR2.APPLICATION_COLUMN_NAME =  'SEGMENT20')    then
        if  CUR2.APPLICATION_COLUMN_NAME = 'SEGMENT19' then
          v_where := v_append ||' to_number(SEGMENT19) in '||
          '(select project_id from mtl_project_v where '||
          'project_name >= nvl('||comma||seg_low(v_cnt)||comma||
          ', project_name) '|| 'and project_name <= nvl('||
          comma||seg_high(v_cnt)||comma||', project_name))';
        elsif  CUR2.APPLICATION_COLUMN_NAME = 'SEGMENT20' then
          v_where := v_append ||' to_number(SEGMENT20) in '||
          '(select task_id from mtl_task_v where '||
          'project_id = nvl(to_number(SEGMENT19),project_id) and '||
          'project_name >= nvl('||comma||seg_low(v_cnt)||comma||
          ', project_name) '||
          'and project_name <= nvl('||comma||seg_high(v_cnt)||comma||
          ',project_name))';
        end if;
     else

          if seg_low(v_cnt) is not null  then
            if  CUR2.FORMAT_TYPE = 'N'   then
             v_where := v_append||' to_number('||CUR2.APPLICATION_COLUMN_NAME||
                        ')'||' >= '||seg_low(v_cnt);
            else
              v_where := v_append||' '||CUR2.APPLICATION_COLUMN_NAME||
                        ' >= '||comma||seg_low(v_cnt)||comma;
            end if;
          end if;
          if v_where is not null then
             v_append := v_where||' and ';
          else
             v_append := null;
          end if;
          if seg_high(v_cnt) is not null then
            if  CUR2.FORMAT_TYPE = 'N'   then
              v_where := v_append||' to_number('||CUR2.APPLICATION_COLUMN_NAME||
                         ')'||' <= '||seg_high(v_cnt);
            else
               v_where := v_append||' '||CUR2.APPLICATION_COLUMN_NAME||
                          ' <= '||comma||seg_high(v_cnt)||comma;
           end if;
        end if;
      end if;
    end if;
 end Loop;
 X_where := v_where;

 if  NOT Rec  then
    FND_MESSAGE.set_name('INV','INV_NO_LOCATOR_SEGMENTS_FOUND');
    PUT_LINE( fnd_message.get );
    current_error_code := to_char(SQLCODE);
 end if;
Exception
 when others then
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'query_range_loc');
	print_error;
end query_range_loc;



PROCEDURE query_range_itm( X_item_lo IN VARCHAR2,
                           X_item_hi IN VARCHAR2,
                           X_where   OUT NOCOPY VARCHAR2 )  IS
v_num             NUMBER;
v_delim           varchar2(1);
v_append          varchar2(1000) := NULL;
v_where           varchar2(2000) := NULL;
v_cnt             Number := 0;
v_ctr             Number;
v_flex_num        Number := Null;
Rec               Boolean := FALSE;
comma             varchar2(1) := '''';

seg_low           fnd_flex_ext.SegmentArray;
seg_high          fnd_flex_ext.SegmentArray;



Cursor CUR1(v_struct_num Number) is
      select a.application_column_name, b.format_type
      from FND_ID_FLEX_SEGMENTS_VL a, FND_FLEX_VALUE_SETS b
      where  a.application_id = 401         and
             a.id_flex_code   = 'MSTK'      and
             a.id_flex_num    = v_struct_num  and
             a.enabled_flag   = 'Y'         and
             a.display_flag   = 'Y'         and
             a.flex_value_set_id = b.flex_value_set_id
      order by  a.segment_num;

--  CUR2  CUR1%ROWTYPE;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN

 Select id_flex_num into v_flex_num
 from fnd_id_flex_structures
 where id_flex_code = 'MSTK';

  v_delim := fnd_flex_ext.get_delimiter('INV','MSTK',v_flex_num);
  v_num := fnd_flex_ext.breakup_segments( X_item_lo, v_delim, seg_low);
  v_num := fnd_flex_ext.breakup_segments( X_item_hi, v_delim, seg_high);

-- Building the where clause

  for CUR2 in CUR1(v_flex_num)  Loop
    Rec := TRUE;
    v_cnt := v_cnt + 1;
    if ( (seg_low(v_cnt) IS NOT NULL)  OR (seg_high(v_cnt) IS NOT NULL) )  then
       if v_where is not null then
             v_append := v_where||' and ';
       else
             v_append := NULL;
       end if;
      if seg_low(v_cnt) is not null  then
        if  CUR2.FORMAT_TYPE = 'N'   then
            v_where := v_append||' to_number('||CUR2.APPLICATION_COLUMN_NAME||
                        ')'||' >= '||seg_low(v_cnt);
        else
            v_where := v_append||' '||CUR2.APPLICATION_COLUMN_NAME||
                       ' >= '||comma||seg_low(v_cnt)||comma;
        end if;
      end if;
      if v_where is not null then
                v_append := v_where||' and ';
      else
                v_append := null;
      end if;
      if seg_high(v_cnt) is not null then
        if  CUR2.FORMAT_TYPE = 'N'   then
             v_where := v_append||' to_number('||CUR2.APPLICATION_COLUMN_NAME||
                        ')'||' <= '||seg_high(v_cnt);
        else
            v_where := v_append||' '||CUR2.APPLICATION_COLUMN_NAME||
                   ' <= '||comma||seg_high(v_cnt)||comma;
        end if;
      end if;
   end if;
  end Loop;
X_where := v_where;

 if  NOT Rec  then
       FND_MESSAGE.set_name('INV','INV_NO_ITEM_SEGMENTS_FOUND');
       PUT_LINE( fnd_message.get );
       current_error_code := to_char(SQLCODE);
 end if;
Exception
 when others then
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , 'query_range_itm');
	print_error;
end query_range_itm;


 PROCEDURE print_kanban_report( X_REPORT_ID  IN  NUMBER )  IS
 v_req_id       NUMBER;
 v_sort_by      NUMBER := 3;
 v_call_from    NUMBER := 2;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
 BEGIN
  v_req_id := fnd_request.submit_request( 'INV',
                                          'INVKBCPR',
                                           NULL,
                                           NULL,
                                           FALSE,
                                           NULL, /* p_org_id */
                                           NULL, /* p_date_created_low */
                                           NULL, /* p_date_created_high */
                                           NULL, /* p_kanban_card_number_low */
                                           NULL, /* p_kanban_card_number_high */
                                           NULL, /* p_item_low */
                                           NULL, /* p_item_high */
                                           NULL, /* p_subinv */
                                           NULL, /* p_locator_low */
                                           NULL, /* p_locator_high */
                                           NULL, /* p_source_type */
                                           NULL, /* p_kanban_card_type */
                                           NULL, /* p_supplier */
                                           NULL, /* p_supplier_site */
                                           NULL, /* p_source_org_id */
                                           NULL, /* p_source_subinv */
                                           NULL, /* p_source_loc_id */
                                           v_sort_by,   /* p_sort_by */
                                           v_call_from, /* p_call_from */
                                           NULL,        /* p_kanban_card_id */
                                           X_REPORT_ID  /* p_report_id */
                                        );

   PUT_LINE( fnd_message.get );
   if v_req_id = 0 then
         delete from MTL_KANBAN_CARD_PRINT_TEMP
         where
         report_id = X_REPORT_ID;
   end if;
END print_kanban_report;


Procedure Print_Error IS
l_count     number;
l_msg       varchar2(2000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
	Fnd_msg_pub.Count_And_get(p_count    => l_count,
                          	  p_data     => l_msg,
                                  p_encoded  => 'F');
	if l_count = 0
	then
		null;
	elsif l_count = 1
	then
         	PUT_LINE( l_msg);
	else
		For I in 1..l_count
		loop
	 		l_msg := fnd_msg_pub.get(I,'F');
         		PUT_LINE( l_msg);
		end loop;
                       PUT_LINE(' ');
	end if;
        FND_MSG_PUB.initialize;
Exception
 when others then
       PUT_LINE( SQLERRM );
End Print_Error;


Procedure  kb_get_conc_segments( X_org_id         IN  Number,
                                 X_loc_id         IN  Number,
                                 X_conc_segs      OUT NOCOPY varchar2 ) is
v_loc_str    varchar2(2000)   := null;
v_proj_name  varchar2(50)     := null;
v_task_name  varchar2(50)     := null;
v_append     varchar2(1000)   := null;
v_parse_str  varchar2(3000)   := null;
v_num  		       NUMBER;
v_cnt                  NUMBER       := 0;
v_proj_ref_enabled     Number       := Null;
v_flex_code            varchar2(5)  := 'MTLL';
v_flex_num             Number;
v_seg19_f              Boolean      := False;
v_seg20_f              Boolean      := False;
v_delim                varchar2(1)  := Null;
dsql_cur               Number;
rows_processed         Number;
str1                  varchar2(15) := NULL;
d_data_str   varchar2(1000)   := null;

Cursor CUR1(flex_code  varchar2) is
      select a.application_column_name
      from FND_ID_FLEX_SEGMENTS_VL a
      where  a.application_id = 401                                 and
             a.id_flex_code   = flex_code                           and
             a.id_flex_num    = (select id_flex_num
                                 from fnd_id_flex_structures
                                 where id_flex_code = flex_code)    and
             a.enabled_flag   = 'Y'                                 and
             a.display_flag   = 'Y'
      order by  a.segment_num;


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

 Select id_flex_num into v_flex_num
 from fnd_id_flex_structures
 where id_flex_code = 'MTLL';

 Select project_reference_enabled into v_proj_ref_enabled
 from  MTL_PARAMETERS
 where organization_id = X_org_id;

 -- bug 4662395 set the profile mfg_organization_id so
 -- the call to MTL_PROJECT_V will return data.

 FND_PROFILE.put('MFG_ORGANIZATION_ID',X_org_id);

 v_delim := fnd_flex_ext.get_delimiter('INV',v_flex_code, v_flex_num);

 str1 := '||'''||v_delim||'''||';

 for CUR2 in CUR1(v_flex_code)   Loop
    if  v_proj_ref_enabled = 1  AND
         ( CUR2.APPLICATION_COLUMN_NAME =  'SEGMENT19'  OR
                       CUR2.APPLICATION_COLUMN_NAME =  'SEGMENT20')    then
        if  CUR2.APPLICATION_COLUMN_NAME = 'SEGMENT19' then
           begin
             v_seg19_f := True;
             select distinct project_name into v_proj_name
             from mtl_project_v where
             project_id = ( select nvl(to_number(SEGMENT19), 0)
                            from mtl_item_locations
                            where inventory_location_id = X_loc_id and
                                  organization_id       = X_org_id      );
           exception
                when others then
                  v_proj_name := null;
           end;
        elsif  CUR2.APPLICATION_COLUMN_NAME = 'SEGMENT20' then
          begin
             v_seg20_f := True;
             select distinct A.task_name into v_task_name
             from mtl_task_v A where
             A.task_id = (select nvl(to_number(SEGMENT20), 0)
                          from mtl_item_locations
                          where inventory_location_id = X_loc_id and
                                organization_id       = X_org_id      )     AND
             A.project_id = (select nvl(to_number(SEGMENT19), A.project_id)
                             from mtl_item_locations
                             where inventory_location_id = X_loc_id and
                                   organization_id       = X_org_id      );
           exception
                when others then
                  v_task_name := null;
           end;
        end if;
    end if;
 end Loop;

for CUR2 in CUR1(v_flex_code)   Loop
       if v_loc_str is not null   then
     		     v_append := v_loc_str||str1;
       else
                     v_append := NULL;
       end if;
       if  ( CUR2.APPLICATION_COLUMN_NAME <>  'SEGMENT19'  AND
                       CUR2.APPLICATION_COLUMN_NAME <>  'SEGMENT20')    then
             v_loc_str  := v_append||CUR2.APPLICATION_COLUMN_NAME;
       end if;
 end Loop;

  if v_loc_str is not null   then
      v_parse_str := 'select '||v_loc_str||
           ' from mtl_item_locations where inventory_location_id = :loc_id '||
           ' and organization_id = :org_id';

      dsql_cur := dbms_sql.open_cursor;
      dbms_sql.parse(dsql_cur,v_parse_str,dbms_sql.native);
      dbms_sql.define_column(dsql_cur,1,d_data_str,800);

      dbms_sql.bind_variable(dsql_cur,'loc_id',X_loc_id);
      dbms_sql.bind_variable(dsql_cur,'org_id',X_org_id);
      rows_processed :=  dbms_sql.execute(dsql_cur);

       Loop
           if ( dbms_sql.fetch_rows(dsql_cur) > 0 ) then
               dbms_sql.column_value(dsql_cur,1,d_data_str);
           else
             -- No more rows in cursor
               dbms_sql.close_cursor(dsql_cur);
               Exit;
          end if;
       End loop;
     if dbms_sql.is_open(dsql_cur) then
           dbms_sql.close_cursor(dsql_cur);
     end if;
  end if;

 if  v_seg19_f  and  v_seg20_f  then
    X_conc_segs := d_data_str||v_delim||v_proj_name||v_delim||v_task_name;
 elsif  v_seg19_f  then
    X_conc_segs := d_data_str||v_delim||v_proj_name;
 elsif  v_seg20_f  then
    X_conc_segs := d_data_str||v_delim||v_task_name;
 else
    X_conc_segs := d_data_str;
 end if;
Exception
 when others then
         X_conc_segs := NULL;
END kb_get_conc_segments;


END INVKBCGN;

/
