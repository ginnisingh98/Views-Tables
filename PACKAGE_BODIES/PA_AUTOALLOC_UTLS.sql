--------------------------------------------------------
--  DDL for Package Body PA_AUTOALLOC_UTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AUTOALLOC_UTLS" AS
/*  $Header: PAXAAUTB.pls 115.2 99/07/16 15:15:53 porting ship  $  */

------------------------------------------------------------------------------
FUNCTION USED_IN_AUTOALLOCWF (  p_allocation_run_id     Number )
RETURN VARCHAR2
IS

v_request_id Number  ;

Cursor SetCur IS
	SELECT BATCH.Request_Id
	FROM	PA_Alloc_Runs_All PA,
		GL_Auto_Alloc_Batch_History Batch
	WHERE	PA.Run_ID = p_allocation_run_id
	AND	Batch.Request_ID > 0
	AND	Batch.Batch_ID = PA.Rule_ID
	AND	Batch.Batch_Type_Code = 'P'
	AND 	Batch.PA_Allocation_Run_ID = p_allocation_run_id;

BEGIN

    Open SetCur;
    Fetch SetCur into v_request_id;

    If SetCur%NOTFOUND then
	Close SetCur;
	/* Run ID does not belong to AutoAloc Set */
	RETURN null;
    End If;

    Close SetCur;

    RETURN to_char(v_request_id);

END USED_IN_AUTOALLOCWF;

------------------------------------------------------------------------------
FUNCTION IN_ACTIVE_AUTOALLOCWF (  p_allocation_run_id     Number )
RETURN VARCHAR2
IS


v_end_date Date ;
v_item_key Varchar2(15);

Cursor SetCur IS
        SELECT WF.End_Date
        FROM    WF_Items_V WF
        WHERE   WF.Item_Type = 'GLALLOC'
        AND     WF.Item_Key = v_item_key
	AND	WF.root_activity = 'GL_SD_ALLOCATION_PROCESS';

BEGIN


 /* Find out if the run is used in an Autoallocation set that uses Work-Flow */

    v_item_key := USED_IN_AUTOALLOCWF (p_allocation_run_id);

    If v_item_key is null Then
       Return 'N';

    Else

    /*If the run belongs to an autoallocation set that has started a workflow
     then find the end date recorded in wf_items_v for the item_type,item_key
	 and root_activity.If it's complete then end_date will be not null*/

       Open SetCur;
       Fetch SetCur into v_end_date;

       If SetCur%NOTFOUND then
          Close SetCur;
	/* No process recorded in the WF view */
          RETURN 'N';
       End If;

    End If;

    Close SetCur;

        If v_end_date is null then
           /** Run ID belongs to active AutoAlloc Set  **/
           RETURN 'Y';
	Else
            /** Run ID belongs to a completed AUtoAlloc Set **/
           RETURN 'N';
	End If;


END IN_ACTIVE_AUTOALLOCWF;

------------------------------------------------------------------------------

END;

/
