--------------------------------------------------------
--  DDL for Package Body BOMDELEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMDELEX" AS
/* $Header: BOMDEXPB.pls 120.1 2005/06/21 04:44:18 appldev ship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMDELEB.pls                                               |
| DESCRIPTION  : This file is a packaged body for deleting
|                records from bom_explosions table where the rexplode flag
|                is set to 1
| Parameters:   1 - top bill sequence id , 2-explosion type
|               error_code      error code
|               error_msg       error message
|History :
|23-JUN-03      Sangeetha       CREATED
+==========================================================================*/
PROCEDURE DELETE_BOM_EXPLOSIONS(
	ERRBUF                  IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	RETCODE                 IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	top_bill_seq_id		IN	Number	,
	expl_type		IN	Varchar2
	) IS
	conc_status		BOOLEAN ;
	Current_Error_Code   Varchar2(20) := NULL;
	INVALID_ARGUMENT_LIST	Exception;
	Cursor Get_Delete_Rows IS
		Select top_bill_sequence_id, bill_sequence_id,
		       explosion_type, sort_order
		From   bom_explosions
		where  top_bill_sequence_id = top_bill_seq_id
                and    explosion_type = expl_type
		and    rexplode_flag = 1 ;

BEGIN
	/* Print the list of parameters */
        FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;
	FND_FILE.PUT_LINE( FND_FILE.LOG,'Top_Bill_sequence_id='||to_char(top_bill_seq_id));
	FND_FILE.PUT_LINE( FND_FILE.LOG,'Explosion Type='||expl_type);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'******************************************') ;

	/* Make sure the right set of parameter are passed */
        IF (top_bill_seq_id is NULL) Or (expl_type IS NULL) THEN
		raise invalid_argument_list ;
	END IF ;


	For Delete_Rows in Get_Delete_Rows
	Loop
		Loop
		Delete from bom_explosions BE
		Where
		      BE.top_bill_sequence_id = DELETE_ROWS.top_bill_sequence_id
                And   BE.EXPLOSION_TYPE =
			DELETE_ROWS.explosion_type
                AND   (BE.SORT_ORDER like DELETE_ROWS.sort_order||'%'
                       AND   BE.SORT_ORDER <> DELETE_ROWS.sort_order)
                AND ROWNUM < 1000 ;
                	EXIT WHEN (SQL%ROWCOUNT = 0) ;
                    COMMIT;
		End Loop;
        END LOOP ;

       UPDATE BOM_EXPLOSIONS
       SET    REQUEST_ID = NULL
       WHERE TOP_BILL_SEQUENCE_ID = top_bill_seq_id
       AND   EXPLOSION_TYPE = expl_type
       AND   SORT_ORDER = Bom_Common_Definitions.G_Bom_Init_SortCode;

       Commit ;

       RETCODE := 0 ;
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);

EXCEPTION
 WHEN invalid_argument_list THEN
    UPDATE BOM_EXPLOSIONS
    SET    REQUEST_ID = NULL
    WHERE TOP_BILL_SEQUENCE_ID = top_bill_seq_id
    AND   EXPLOSION_TYPE = expl_type
    AND   SORT_ORDER = Bom_Common_Definitions.G_Bom_Init_SortCode;
    commit;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Either Top assembly Item Id or Explosion type  is not specified') ;
    RETCODE := 2;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);
 When Others Then
    Rollback;
    UPDATE BOM_EXPLOSIONS
    SET    REQUEST_ID = NULL
    WHERE TOP_BILL_SEQUENCE_ID = top_bill_seq_id
    AND   EXPLOSION_TYPE = expl_type
    AND   SORT_ORDER = Bom_Common_Definitions.G_Bom_Init_SortCode;
    commit;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'The concurrent request did not complete
			successfully');
    FND_FILE.PUT_LINE(fnd_file.log,'Others exception raised');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Others : '||SQLCODE || ':'||SQLERRM) ;
    RETCODE := 2;
    conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

END DELETE_BOM_EXPLOSIONS;

PROCEDURE GET_TOP_BILL(Item_Id			IN	Number,
		       Org_Id  			IN	Number,
		       Alt_Bom_Desg 		IN	VARCHAR2,
		       Return_Status	 IN OUT NOCOPY /* file.sql.39 change */     Varchar2 ,
		       Err_Buf		 IN OUT NOCOPY /* file.sql.39 change */ Varchar2) IS

Cursor get_top(Bill_Seq_Id	Number)
IS
Select top_bill_sequence_id, explosion_type, sort_order
from   bom_explosions BE
where  BE.COMP_COMMON_BILL_SEQ_ID = Bill_Seq_Id
and    BE.rexplode_flag = 1
and    BE.explosion_type in ('INCLUDED','OPTIONAL','ALL');

Cursor bom_expl(top_bill_id   Number, expl_type	  VARCHAR2)
IS
SELECT Request_id
FROM   Bom_explosions
WHERE  top_bill_sequence_id = top_bill_id
AND    explosion_type  = expl_type
AND    sort_order = Bom_Common_Definitions.G_Bom_Init_SortCode;

X_Req_Id		Number := 0;
Req_Id			Number := 0;
Bill_Id			Number := 0;
l_delete_bom_expl 	Number := 2;
expl_row_cnt		Number := 0;

Begin

	l_delete_bom_expl := fnd_profile.value('BOM:DELETE_BOM_EXPLOSIONS');

	If l_delete_bom_expl = 1 then
	   SELECT bill_sequence_id
           INTO   Bill_Id
           FROM   bom_bill_of_materials
           WHERE  Assembly_Item_Id = Item_Id
           AND    nvl(Alternate_Bom_Designator,'NONE')=nvl(Alt_Bom_Desg,'NONE')
           AND    Organization_Id  = Org_Id;

	   For C1 in get_top(Bill_Id)
           Loop
	      expl_row_cnt  := 0;
	      Begin
		SELECT count(*)
		into   expl_row_cnt
		FROM   bom_explosions
		WHERE  top_bill_sequence_id = C1.top_bill_sequence_id
		AND    explosion_type = C1.explosion_type
		AND    sort_order like C1.sort_order||'%'
                AND    sort_order <> C1.sort_order;
	      END;
	      If (expl_row_cnt > 0) then
		For cr in  bom_expl(C1.top_bill_sequence_id,C1.explosion_type)
		Loop
		  If (cr.Request_Id IS NULL ) then
                 	  X_req_id := fnd_request.submit_request(
                       		       application   => 'BOM',
                               	       program       => 'BOMDELEX',
                                       description   => NULL,
                                       start_time    => NULL,
                                       sub_request   => FALSE,
                                       argument1     => C1.top_bill_sequence_id,
                                       argument2     => C1.explosion_type);
                   	  If (X_req_id <> 0) then
                  		Update bom_explosions
                  		set REQUEST_ID = X_req_id
                  		where top_bill_sequence_id = 								C1.top_bill_sequence_id
                  		and explosion_type = C1.explosion_type
                  		and SORT_ORDER = Bom_Common_Definitions.G_Bom_Init_SortCode;
		  		Commit;
		  		Return_Status := 'S';
		   	  Else
		  		Return_Status := 'E';
                   	  End if;
		  End If;
		End Loop;
		X_req_Id := 0;
	      End If;
	  End Loop;
	End if;
Exception
	WHEN NO_DATA_FOUND THEN
		Err_Buf	:= SQLERRM;
		Return_Status := 'E';
	WHEN OTHERS THEN
		Err_buf := SQLERRM;
		Return_Status := 'E';
End GET_TOP_BILL;

END BOMDELEX ;

/
