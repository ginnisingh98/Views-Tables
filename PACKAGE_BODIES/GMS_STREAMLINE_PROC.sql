--------------------------------------------------------
--  DDL for Package Body GMS_STREAMLINE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_STREAMLINE_PROC" as
/* $Header: gmsstrmb.pls 120.6.12010000.2 2009/06/22 04:43:51 abjacob ship $ */

-- function to return a delimited string from a stream.

function  PARSE_STREAM(stream_text      in varchar2,
                       stream_seperator in varchar2,
                       stream_position  in number)
          return varchar2 is

  l_process        varchar2(30);
  l_start_position number;
  l_end_position   number;

BEGIN
   If ((stream_text is NULL)       or
       (stream_seperator is NULL)  or
       (stream_position  is NULL))
    Then
      return NULL;
   End if;

   -- get start position

   If (stream_position = 1) then
      l_start_position := 1;
   Elsif (stream_position > 1) then
      l_start_position := instr(stream_text,stream_seperator,1,(stream_position - 1));
      If (l_start_position = 0) then
         return NULL;
      Else
         l_start_position := l_start_position + 1;
      End if;
   End if;
   -- get end position
   l_end_position := instr(stream_text,stream_seperator,1,stream_position);
   If (l_end_position = 0) then
       NULL;
   Else
       l_end_position := l_end_position - 1;
   End if;
   -- get the process
   If  (l_end_position = 0) then
       l_process := substr(stream_text, l_start_position);
   Else
       l_process := substr(stream_text, l_start_position,(l_end_position - l_start_position + 1));
   End if;

   return l_process;

END PARSE_STREAM;

-- Procedure for GMS streamline interface process

-- The datatype of variable through_date has been chaned to varchar2.
-- Refer Bug 2644176.
procedure  GMSISLPR(errbuf           out NOCOPY varchar2,
                    retcode          out NOCOPY varchar2,
                    process_stream   in  varchar2,
                    project_id       in  number    ,
                    through_date     in  varchar2  ,
                    reschedule_interval  in number ,
                    reschedule_time  in  date      ,
                    stop_date        in  date      ,
                    adjust_dates     in  varchar2  ,
                    debug_mode       in  varchar2
                    )  is

 l_process_label  varchar2(10);
 l_process        varchar2(10);
 l_application    varchar2(10);
 l_position       number := 1;
 ret_value        number;
 l_status         varchar2(30);
 dev_phase        varchar2(30);
 dev_status       varchar2(30);
 mesg             varchar2(30);
 phase            varchar2(30);
 loop_count       number := 0;
 stage            varchar2(10);

 user_id		varchar2(15); -- User id initiated the process
 debug_mode_flag	varchar2(1); -- stores the debug mode set for the application /* Bug 4367120 */
 l_org_id		number;
 l_sob_id		number;
 l_sys_link		varchar2(3);
 l_proc_Cat		varchar2(30);

BEGIN

  stage := '100';

  debug_mode_flag := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  user_id := NVL(FND_PROFILE.value('USER_ID'), -1); -- for bug 6673370

  SELECT set_of_books_id, org_id INTO l_sob_id, l_org_id from pa_implementations;

  stage := '110';

    WHILE (loop_count < 10) LOOP

       loop_count := loop_count +1;

       stage := '120';

       l_process_label :=  PARSE_STREAM(process_stream,'-',l_position);

       If (l_process_label is NULL) then
          exit;
       End if;

       stage := '130';

       if (l_process_label = 'DVC')  Then

         -- GMS: Distribute Supplier Invoice Adjustment Costs and Funds Check

	 -- Bug 2931481 : Added system_linkage_function('VI') parameter and added NULL parameters
	 -- Bug 4522760 : Added two more parameters in the call after project_id

         FND_REQUEST.set_org_id(l_org_id);

	 ret_value := fnd_request.submit_request( 'GMS','GMSFCIAR',NULL,NULL,FALSE,
                                                      project_id,NULL,NULL,through_date,NULL,NULL,NULL,NULL,'VI');

       stage := '140';

       Elsif (l_process_label = 'EXP')  Then

           -- fund check and costing of expense report

           -- Bug 2931481 : Added system_linkage_function('ER') parameter and added NULL parameters
	   -- Bug 4522760 : Added one NULL parameter in the call before 'ER'

	   FND_REQUEST.set_org_id(l_org_id);

           ret_value := fnd_request.submit_request( 'GMS','GMSFCERR',NULL,NULL,FALSE,NULL,
                                                       project_id,NULL, through_date,NULL,NULL,NULL,NULL,NULL,'ER');
       stage := '150';

       Elsif (l_process_label = 'LAB')  Then


           -- GMS: Costing and Funds Check on Straight Time Labor

            -- Bug 1656851: Added System Linkage Parameter 'ST'
	    -- Bug 4522760: Added two more parameters in the call before through_date

	    FND_REQUEST.set_org_id(l_org_id);

            ret_value := fnd_request.submit_request( 'GMS','GMSFCSTR',NULL,NULL,FALSE,NULL,
                                                     project_id,NULL,NULL,NULL, through_date,NULL,NULL,NULL,NULL,NULL,'ST');

       stage := '160';

       Elsif (l_process_label in ('DUSG', 'DPJ', 'DINV', 'DWIP', 'DBTC'))  Then






            -- GMS: Costing and Funds Check on Usages, Misc, Inv, Wip, Burden

            -- Bug 1656851: Added System Linkage Parameter 'US'
	    -- Bug 4502802; Added two more param

	    l_sys_link := ltrim(l_process_label,'D');

	    FND_REQUEST.set_org_id(l_org_id);

            ret_value := fnd_request.submit_request( 'GMS','GMSFCUSR',NULL,NULL,FALSE,NULL,
                                                       project_id,NULL,NULL,through_date, l_sys_link, NULL,NULL,NULL,NULL,'US');

	    stage := '170';

       Elsif l_process_label in ('DTBC') Then

	        -- PRC: Distribute Total Burdened Cost

		 FND_REQUEST.set_org_id(l_org_id);

	         ret_value := fnd_request.submit_request( 'PA','PACODTBC',NULL,NULL,FALSE,
                                                       NULL, project_id, through_date, NULL, NULL, NULL, NULL, debug_mode_flag);
		 stage := '175';



       Elsif (l_process_label in ('EUSG', 'EPJ', 'EINV', 'EWIP', 'EBTC','ETBC', 'ELAB', 'ESC')) THEN

            CASE l_process_label
	         WHEN 'EUSG' THEN l_proc_Cat := 'USAGE_COST';
		 WHEN 'EPJ'  THEN l_proc_Cat := 'MISCELLANEOUS_COST';
		 WHEN 'EINV' THEN l_proc_Cat := 'INVENTORY_COST';
		 WHEN 'EWIP' THEN l_proc_Cat := 'WIP_COST';
		 WHEN 'EBTC' THEN l_proc_Cat := 'BTC_COST';
		 WHEN 'ELAB' THEN l_proc_Cat := 'LABOR_COST';
		 WHEN 'ESC'  THEN l_proc_Cat := 'SUPPLIER_COST';
		 WHEN 'ETBC' THEN l_proc_Cat := 'TBC_COST';
	     END CASE;


	      -- PRC: Generate Cost Accounting Events

	      FND_REQUEST.set_org_id(l_org_id);

	      ret_value := fnd_request.submit_request( 'PA', 'PAGCAE', NULL, NULL, FALSE, l_proc_cat, through_date, NULL,
	                                               NULL, NULL, NULL, NULL);

       stage := '180';

	Elsif  (l_process_label in ('AUSG', 'APJ', 'AINV', 'AWIP', 'ABTC','ATBC', 'ALAB', 'ASC')) THEN

            CASE l_process_label
	         WHEN 'AUSG' THEN l_proc_Cat := 'USAGE_COST';
		 WHEN 'APJ'  THEN l_proc_Cat := 'MISCELLANEOUS_COST';
		 WHEN 'AINV' THEN l_proc_Cat := 'INVENTORY_COST';
		 WHEN 'AWIP' THEN l_proc_Cat := 'WIP_COST';
		 WHEN 'ABTC' THEN l_proc_Cat := 'BTC_COST';
		 WHEN 'ALAB' THEN l_proc_Cat := 'LABOR_COST';
		 WHEN 'ASC'  THEN l_proc_Cat := 'SUPPLIER_COST';
		 WHEN 'ATBC' THEN l_proc_Cat := 'TBC_COST';
	     END CASE;

	      -- PRC: Create Accounting

	      FND_REQUEST.set_org_id(l_org_id);

              ret_value := fnd_request.submit_request( 'PA', 'PAXACCPB', NULL, NULL, FALSE, 275, 275, 'Y', l_sob_id,
	                                               l_proc_cat, NVL(through_date,TO_CHAR(SYSDATE,'YYYY/MM/DD')), 'Y', 'Y', 'F', 'Y', 'N', 'S', 'Y', 'Y',
						       'N', NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL,
						       NULL, 'Final', NULL, NULL, NULL, NULL, NULL, NULL, l_org_id,
						       NULL, NULL, NULL, NULL, NULL, NULL, 'N', 'N',user_id); --added for bug 6673370

       stage := '190';


       Else
           L_process := NULL;
           ret_value := NULL;
       End if;

       stage := '200';

       If (ret_value is null) then
           RETCODE := 2;
           ERRBUF  := 'Error in GMS_STREAMLINE_PROC.GMSISLPR at stage '||stage||': No process submitted.';
           exit;
       stage := '210';
       Elsif (ret_value  = 0) then
           ROLLBACK;
           RETCODE := 2;
           ERRBUF  := 'Error in GMS_STREAMLINE_PROC.GMSISLPR at stage '||stage||' : Failed to spawn process' ;
           exit;
       stage := '220';
       Else
           commit;
             -- Wait for cuncurrent process to complete.
              If fnd_concurrent.wait_for_request (ret_value, 30, 0, phase, l_status,
                                                   dev_phase, dev_status, mesg) then
                Null;
              end if;
       End if;

       l_position := l_position + 1;

    END LOOP;
   EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       RETCODE := 2;
       ERRBUF  := 'Error in GMS_STREAMLINE_PROC.GMSISLPR at stage '||stage||' : '||sqlerrm;

END GMSISLPR;

end GMS_STREAMLINE_PROC;

/
