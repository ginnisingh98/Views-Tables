--------------------------------------------------------
--  DDL for Package Body ZPB_WFMNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_WFMNT" AS
/* $Header: zpbwkfmnt.plb 120.0.12010.2 2006/08/03 18:48:48 appldev noship $ */

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'ZPB_WFMNT';

-- Wrapper to call DeleteWorkflow and clean zpb_excp* tables for a BAID
Procedure PurgeWF_BusinessArea (p_business_area_id in number)
  is

   l_thisInst number;
   l_thisACID number;
   retcode  varchar2(2);
   errbuf   varchar2(100);

  CURSOR c_instances is
   select instance_ac_id
   from zpb_analysis_cycle_instances
   where analysis_cycle_id = l_thisACID;

   v_instance c_instances%ROWTYPE;

  CURSOR c_acids is
   select ANALYSIS_CYCLE_ID
     from ZPB_ANALYSIS_CYCLES
     where BUSINESS_AREA_ID = p_business_area_id;

   v_acid c_acids%ROWTYPE;


 BEGIN

  -- for each ACID within each BA abort and delete the EPBCYCLE and ZPBSCHED workflows
  for v_acid in c_acids loop

    l_thisACID :=  v_acid.ANALYSIS_CYCLE_ID;
    ZPB_WFMNT.purge_Workflows (errbuf, retcode, l_thisACID, 'A');

     -- Delete task rows from zpb_excp_results, zpb_exp_explanations by instance
     for v_instance in c_instances loop
         l_thisInst :=  v_instance.instance_ac_id;
         delete from zpb_excp_results re
          where re.task_id in (select pd.task_id from zpb_process_details_v pd
          where analysis_cycle_id = l_thisInst);
         delete from zpb_excp_explanations ex
          where ex.task_id in (select pd.task_id from zpb_process_details_v pd
          where analysis_cycle_id = l_thisInst);
     end loop;

  end loop;



  -- The default date setting for exec wf_purge.adhocdirectory is sysdate.
  -- This will purge out any ad hoc roles or users zpb generated based on the expiration_date
  -- whcih were set by wf_directory.CreateAdHocRole.  This is a standard WF API.
  wf_purge.adhocdirectory;


 return;

 exception

   when others then
       raise;
    -- RAISE_APPLICATION_ERROR(-20100, 'Error in ZPB_WF.CallDelWF');
end PurgeWF_BusinessArea;


procedure purge_Workflows (errbuf out nocopy varchar2,
                          retcode out nocopy varchar2,
                          p_inACID in Number,
                          ACIDType in varchar2)
   IS
    AttrName   varchar2(30);
    CurrStatus varchar2(20);
    result     varchar2(100);

    CURSOR c_ItemKeys is
        select item_type, item_key
           from WF_ITEM_ATTRIBUTE_VALUES
           where (item_type = 'ZPBSCHED' OR item_type = 'EPBCYCLE')
           and   name = AttrName
           and   number_value = p_inACID;

    v_ItemKey c_ItemKeys%ROWTYPE;


  CURSOR c_dc_objects is
   select w.item_key
    from ZPB_DC_OBJECTS d,
    WF_ITEM_ATTRIBUTE_VALUES w
    where analysis_cycle_id = p_inACID
    and (w.item_type = 'EPBDC')
    and  w.name = 'DC_OBJECT_ID'
    and  w.number_value = d.object_id;

   v_dc_object c_dc_objects%ROWTYPE;


BEGIN

    retcode := '0';

    if ACIDType = 'I' then
      AttrName := 'INSTANCEID';
    else
      AttrName := 'ACID';
    end if;

    for  v_ItemKey in c_ItemKeys loop
        wf_engine.ItemStatus(v_ItemKey.item_type, v_ItemKey.item_key, currStatus, result);

        if  UPPER(RTRIM(currStatus)) = 'COMPLETE' then
            WF_PURGE.Total(v_ItemKey.item_Type, v_ItemKey.item_key);
        else
            WF_ENGINE.AbortProcess(v_ItemKey.item_Type, v_ItemKey.item_key);
            WF_PURGE.Total(v_ItemKey.item_Type, v_ItemKey.item_key);
        end if;

    end loop;

    -- To PURGE out the EPBDC objects too!
    for v_dc_object in c_dc_objects loop

        wf_engine.ItemStatus('EPBDC', v_dc_object.item_key, currStatus, result);

        if  UPPER(RTRIM(currStatus)) = 'COMPLETE' then
            WF_PURGE.Total('EPBDC', v_dc_object.item_key);
        else
            WF_ENGINE.AbortProcess('EPBDC', v_dc_object.item_key);
            WF_PURGE.Total('EPBDC', v_dc_object.item_key);
        end if;

    end loop;


   return;

  exception

   when NO_DATA_FOUND then
     retcode :='0';

   when others then
    retcode :='2';
    errbuf:=substr(sqlerrm, 1, 255);

end purge_Workflows;



end ZPB_WFMNT;


/
