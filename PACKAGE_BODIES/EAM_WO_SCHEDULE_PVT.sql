--------------------------------------------------------
--  DDL for Package Body EAM_WO_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_SCHEDULE_PVT" AS
/* $Header: EAMVSCDB.pls 120.9.12010000.3 2010/01/19 05:42:56 vboddapa ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVSCDB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_SCHEDULE_PVT
--
--  NOTES
--
--  HISTORY
--
--  30-JUN-2002    Kenichi Nagumo     Initial Creation
***************************************************************************/

G_Pkg_Name      VARCHAR2(30) := 'EAM_WO_SCHEDULE_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;

PROCEDURE EAM_GET_SHIFT_WKDAYS
      ( p_curr_date        IN   DATE,
        p_calendar_code    IN   VARCHAR2,
        p_shift_num        IN   NUMBER,
        p_schedule_dir     IN   NUMBER,
        x_wkday_flag       OUT NOCOPY  NUMBER,
        x_error_message    OUT NOCOPY  VARCHAR2,
        x_return_status    OUT NOCOPY  VARCHAR2)
IS
        l_calendar_index   NUMBER;
        l_cal_rec_count    NUMBER;
        l_cal_first_date   DATE;
        l_cal_last_date    DATE;
	l_shift_first_index_date      DATE;
	l_shift_last_index_date      DATE;
        OUT_OF_CAL_EXC     EXCEPTION;

CURSOR  EAM_GET_FWD_SHIFT_DATES_CSR IS
   SELECT  SHIFT_NUM,
           SHIFT_DATE,
           SEQ_NUM,
	   CALENDAR_CODE
     FROM  BOM_SHIFT_DATES
    WHERE  CALENDAR_CODE = p_calendar_code
      AND  SHIFT_DATE >= trunc(p_curr_date)
      AND  SHIFT_DATE <= trunc(p_curr_date) + 50
      AND  EXCEPTION_SET_ID = -1
 ORDER BY  SHIFT_NUM, SHIFT_DATE;

CURSOR  EAM_GET_BKWD_SHIFT_DATES_CSR IS
   SELECT  SHIFT_NUM,
           SHIFT_DATE,
           SEQ_NUM,
	   CALENDAR_CODE
     FROM  BOM_SHIFT_DATES
    WHERE  CALENDAR_CODE = p_calendar_code
      AND  SHIFT_DATE >= trunc(p_curr_date) - 50
      AND  SHIFT_DATE <= trunc(p_curr_date)
      AND  EXCEPTION_SET_ID = -1
 ORDER BY  SHIFT_NUM DESC, SHIFT_DATE DESC;

BEGIN

    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Enters eam_get_shift_wkdays'||p_shift_num||'in'||p_curr_date||'for'||p_calendar_code) ; END IF ;

     l_cal_rec_count := shift_date_tbl.LAST;

     IF(l_cal_rec_count IS NOT NULL) THEN   --if shift table exists in memory
          l_shift_first_index_date := shift_date_tbl(shift_date_tbl.FIRST).SHIFT_DATE;     --the first date in the shift table
	  l_shift_last_index_date  :=  shift_date_tbl(l_cal_rec_count).SHIFT_DATE;         --the last date in the shift table
     END IF;

     IF p_schedule_dir = 1 THEN
     --fix for bug 4201713.execute the query to find the shifts only if the date passed is not already there in the shift table
       IF (l_cal_rec_count IS NULL)
           OR (l_cal_rec_count IS NOT NULL AND
	         ((p_calendar_code <> shift_date_tbl(l_cal_rec_count).calendar_code ) OR  --if calendar is different or
		 --if p_curr_date not exists between the shift dates in the table. Need to check 2 conditions as shift table can be organised in ascending/descending order for fwd/backward scheduling.
			 (NOT ((l_shift_first_index_date <= p_curr_date AND l_shift_last_index_date >= p_curr_date) OR (l_shift_first_index_date >= p_curr_date AND l_shift_last_index_date <= p_curr_date))))
		  ) THEN

	  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Shift query executed') ; END IF ;

         shift_date_tbl.delete;
         l_calendar_index := 0;

         FOR l_tab_shift_rec IN EAM_GET_FWD_SHIFT_DATES_CSR LOOP
             l_calendar_index := l_calendar_index + 1;
             shift_date_tbl(l_calendar_index).SHIFT_NUM := l_tab_shift_rec.shift_num;
             shift_date_tbl(l_calendar_index).SHIFT_DATE := l_tab_shift_rec.shift_date;
             shift_date_tbl(l_calendar_index).SEQ_NUM := l_tab_shift_rec.seq_num;
         END LOOP;

         IF l_calendar_index = 0 THEN
             RAISE OUT_OF_CAL_EXC;
         END IF;
      END IF; /* for populating shift_date_tbl */

     ELSE
      IF (l_cal_rec_count IS NULL)
           OR (l_cal_rec_count IS NOT NULL AND
                 ((p_calendar_code <> shift_date_tbl(l_cal_rec_count).calendar_code ) OR                   --if calendar is different or
		  --if p_curr_date not exists between the shift dates in the table. Need to check 2 conditions as shift table can be organised in ascending/descending order for fwd/backward scheduling.
		    (NOT ((l_shift_first_index_date <= p_curr_date AND l_shift_last_index_date >= p_curr_date) OR (l_shift_first_index_date >= p_curr_date AND l_shift_last_index_date <= p_curr_date))))
		  ) THEN

		  IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Shift query executed') ; END IF ;

         shift_date_tbl.delete;
         l_calendar_index := 0;

       FOR l_tab_shift_rec IN EAM_GET_BKWD_SHIFT_DATES_CSR LOOP

            l_calendar_index := l_calendar_index + 1;
            shift_date_tbl(l_calendar_index).SHIFT_NUM := l_tab_shift_rec.shift_num;
            shift_date_tbl(l_calendar_index).SHIFT_DATE := l_tab_shift_rec.shift_date;
            shift_date_tbl(l_calendar_index).SEQ_NUM := l_tab_shift_rec.seq_num;
       END LOOP;

         IF l_calendar_index = 0 THEN
            RAISE OUT_OF_CAL_EXC;
         END IF;
      END IF; /* for populating shift_date_tbl for Backward scheduling*/
     END IF;/* scheduling direction */

     l_calendar_index := shift_date_tbl.FIRST;
       WHILE l_calendar_index is not NULL LOOP
          IF (shift_date_tbl(l_calendar_index).SHIFT_NUM = p_shift_num AND
              shift_date_tbl(l_calendar_index).SHIFT_DATE = trunc(p_curr_date)) THEN
                IF shift_date_tbl(l_calendar_index).seq_num IS NOT NULL THEN
                    x_wkday_flag := 1;
                ELSE
                    x_wkday_flag := 2;
                END IF;

		 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Enters x_wkday_flag'||x_wkday_flag) ; END IF ;

              EXIT;
           END IF;
            l_calendar_index := shift_date_tbl.NEXT(l_calendar_index);
       END LOOP;

   EXCEPTION WHEN OUT_OF_CAL_EXC THEN
     x_return_status := fnd_api.g_ret_sts_error;
     x_error_message := 'DATE OUT OF CALENDAR';
    IF EAM_PROCESS_WO_PVT. Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Exception raised.No entry found for this date, calendar and exception_set_id combination'||p_shift_num||'in'||p_curr_date) ; END IF ;

END;






 PROCEDURE EAM_GET_SHIFT_NUM
    ( p_curr_time        IN OUT NOCOPY   NUMBER,
      p_schedule_dir     IN       NUMBER,
      l_res_sft_tbl      IN       l_res_sft_tab,
      p_curr_index       IN NUMBER ,
      x_shift_num        OUT NOCOPY      NUMBER,
      x_from_time        OUT NOCOPY      NUMBER,
      x_to_time          OUT NOCOPY      NUMBER,
      x_error_message    OUT NOCOPY      VARCHAR2,
      x_return_status     OUT NOCOPY     VARCHAR2,
      x_index_at                OUT NOCOPY NUMBER
    )
 IS
   l_next_shift_num   NUMBER := -1;
   l_next_start_time  NUMBER;
   l_res_sft_index    NUMBER;
   l_curr_time1       NUMBER := -1;
   temp               NUMBER;

 BEGIN

 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Starting EAM_GET_SHIFT_NUM') ; END IF ;

            l_next_start_time := p_curr_time;
            l_res_sft_index := p_curr_index ; /* Bug 4738273 : Changed code to set index to p_curr_index */

  WHILE l_res_sft_index is not NULL LOOP

    IF ((p_curr_time >= l_res_sft_tbl(l_res_sft_index).from_time
        AND p_curr_time < l_res_sft_tbl(l_res_sft_index).to_time)
        OR
         ((p_curr_time >= l_res_sft_tbl(l_res_sft_index).from_time
          OR p_curr_time < l_res_sft_tbl(l_res_sft_index).to_time)
           AND
           (l_res_sft_tbl(l_res_sft_index).to_time -
           l_res_sft_tbl(l_res_sft_index).from_time) <= 0))
           AND p_schedule_dir = 1
     OR
        ((p_curr_time > l_res_sft_tbl(l_res_sft_index).from_time
        AND p_curr_time <= l_res_sft_tbl(l_res_sft_index).to_time)
        OR
         ((p_curr_time > l_res_sft_tbl(l_res_sft_index).from_time
          OR p_curr_time <= l_res_sft_tbl(l_res_sft_index).to_time)
           AND
           (l_res_sft_tbl(l_res_sft_index).to_time -
           l_res_sft_tbl(l_res_sft_index).from_time) <= 0))
           AND p_schedule_dir = 2
           THEN
                x_shift_num := l_res_sft_tbl(l_res_sft_index).shift_num;
                x_from_time := l_res_sft_tbl(l_res_sft_index).from_time ;
                x_to_time   := l_res_sft_tbl(l_res_sft_index).to_time ;
                l_curr_time1 := p_curr_time ;
                x_index_at := l_res_sft_index ; /* Bug 4738273 : Added line  */
                EXIT;
     ELSIF  l_res_sft_tbl(l_res_sft_index).from_time > p_curr_time
            AND p_schedule_dir = 1 THEN

              IF l_next_start_time > l_res_sft_tbl(l_res_sft_index).from_time
                 OR l_next_start_time = p_curr_time THEN

                 l_next_shift_num  := l_res_sft_tbl(l_res_sft_index).shift_num;
                 x_shift_num       := l_next_shift_num;
                 x_from_time       := l_res_sft_tbl(l_res_sft_index).from_time;
                 x_to_time         := l_res_sft_tbl(l_res_sft_index).to_time;
                 l_next_start_time := l_res_sft_tbl(l_res_sft_index).from_time;
                 l_curr_time1       := l_res_sft_tbl(l_res_sft_index).from_time;
                 x_index_at := l_res_sft_index ;                /* Bug 4738273 : Added line  */
              END IF;
    ELSIF    l_res_sft_tbl(l_res_sft_index).to_time < p_curr_time
            AND p_schedule_dir = 2 THEN
            IF l_next_start_time < l_res_sft_tbl(l_res_sft_index).to_time
                 OR l_next_start_time = p_curr_time THEN

                 l_next_shift_num  := l_res_sft_tbl(l_res_sft_index).shift_num;
                 x_shift_num       := l_next_shift_num;
                 x_from_time       := l_res_sft_tbl(l_res_sft_index).from_time;
                 x_to_time         := l_res_sft_tbl(l_res_sft_index).to_time;
                 l_next_start_time := l_res_sft_tbl(l_res_sft_index).to_time;
                 l_curr_time1      := l_res_sft_tbl(l_res_sft_index).to_time;
                 x_index_at := l_res_sft_index ;                /* Bug 4738273 : Added line  */
            END IF;

     END IF; -- shift identifier
  l_res_sft_index := l_res_sft_tbl.NEXT(l_res_sft_index);
  END LOOP;

  IF l_curr_time1 <> -1 THEN
     p_curr_time := l_curr_time1;
  END IF;
END;   /* EAM_GET_SHIFT_NUM */







 PROCEDURE SCHEDULE_RESOURCES
    ( p_organization_id               IN      NUMBER,
      p_wip_entity_id        IN      NUMBER,
      p_op_seq_num           IN      NUMBER,
      p_schedule_dir         IN      NUMBER,
      p_calendar_code        IN      VARCHAR2,
      op_res_info_tbl        IN      op_res_info_tab,
      op_res_sft_tbl         IN      op_res_sft_tab,
      p_op_start_date        IN OUT NOCOPY  DATE,
      p_op_completion_date   IN OUT NOCOPY  DATE,
      p_res_usage_tbl        IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
      p_validation_level     IN      NUMBER,
      p_commit               IN      VARCHAR2,
      x_error_message        OUT NOCOPY     VARCHAR2,
      x_return_status        OUT NOCOPY     VARCHAR2
      )
 IS
   i                           NUMBER := 0;
   l_res_start_date            DATE   ;
   l_res_completion_date       DATE   ;
   l_next_res_start_date       DATE   ;
   l_next_res_completion_date  DATE   ;
   l_prior_res_completion_date DATE   ;
   l_res_lead_time             NUMBER ;
   l_res_seq_num               NUMBER ;
   l_curr_date                 DATE   ;
   l_curr_time                 NUMBER ;
   l_shift_num                 NUMBER ;
   l_curr_index                 NUMBER ; /* Bug 4738273 : Added l_curr_index, l_out_index */
   l_out_index                 NUMBER ;
   l_from_time                 NUMBER ;
   l_to_time                   NUMBER ;
   l_op_res_sft_index          NUMBER ;
   l_res_sft_index             NUMBER ;
   l_res_sft_count             NUMBER ;
   l_wkday_flag                NUMBER;
   l_sft_avail_time            NUMBER;
   l_stmt_num                  NUMBER := 200;
   NO_SFT_EXC                  EXCEPTION;

      l_min_rsc_start_date         DATE;
      l_max_rsc_end_date           DATE;
      l_rsc_index                  NUMBER;
      l_shift_index                NUMBER;

        t_start_date                  DATE;
        t_end_date                    DATE;
        l_eam_res_usage_rec           EAM_PROCESS_WO_PUB.eam_res_usage_rec_type;

BEGIN /*SCHEDULE_RESOURCES*/

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Starting EAM_CALC_OPERATION_TIME') ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Scheduling Direction '|| p_schedule_dir) ; END IF ;

  IF p_schedule_dir = 1 THEN
     i := op_res_info_tbl.FIRST;
  ELSE
     i := op_res_info_tbl.LAST;
  END IF;



IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Initializing date parameters') ; END IF ;


  l_res_start_date            := p_op_start_date;
  l_res_completion_date       := p_op_completion_date;
  l_next_res_start_date       := p_op_start_date ;
  l_next_res_completion_date  := p_op_completion_date;


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Entering Loop') ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Scheduling Operation '|| p_op_seq_num) ; END IF ;

 l_rsc_index := 1;    --initialise the resource index

   WHILE i is not NULL LOOP


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within Loop') ; END IF ;

    l_res_lead_time := 0;

    IF (op_res_info_tbl(i).op_seq_num = p_op_seq_num) /*fix3725352 and (NVL(op_res_info_tbl(i).op_completed, 'N') <> 'Y')*/ THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within op_seq_num and op_completed check') ; END IF ;

      IF op_res_info_tbl(i).scheduled_flag = 1 THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Within scheduled_flag check') ; END IF ;

         IF op_res_info_tbl(i).avail_24_hrs_flag = 1 THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Resource available 24 hr') ; END IF ;

            /* Calculating the leadtime in seconds */ /* mmaduska */
                l_res_lead_time := op_res_info_tbl(i).usage_rate/op_res_info_tbl(i).assigned_units;

               IF p_schedule_dir = 1 THEN /* forward schedule */

                  if (i > op_res_info_tbl.FIRST ) and (op_res_info_tbl(i).res_sch_num = op_res_info_tbl(op_res_info_tbl.PRIOR(i)).res_sch_num)
                  and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.PRIOR(i)).op_seq_num) then

                      l_res_completion_date := l_res_start_date + (l_res_lead_time/86400);

                      if l_res_completion_date > l_next_res_start_date then
                          l_next_res_start_date  := l_res_completion_date;
                      end if;

                  else

                      l_res_start_date := l_next_res_start_date;
                      l_res_completion_date := l_res_start_date + (l_res_lead_time/86400);
                      l_next_res_start_date  := l_res_completion_date;

                 end if;



               ELSE

          --     dbms_output.put_line ('i is ' || i);

                  if (i > op_res_info_tbl.LAST ) and (op_res_info_tbl(i).res_sch_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).res_sch_num)
                  and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).op_seq_num) then

                      l_res_start_date := l_res_completion_date - (l_res_lead_time/86400);

                      if l_res_start_date < l_next_res_completion_date then
                          l_next_res_completion_date := l_res_start_date;
                      end if;

                 else
                      l_res_completion_date := l_next_res_completion_date;
                      l_res_start_date := l_res_completion_date - (l_res_lead_time/86400);
                      l_next_res_completion_date := l_res_start_date;

                 end if;

            --     dbms_output.put_line ('l_res_start_date is ' || l_res_start_date);

               END IF;/* For forward and backward schedule */

                   l_eam_res_usage_rec.operation_seq_num:=        p_op_seq_num;
                   l_eam_res_usage_rec.resource_seq_num :=        op_res_info_tbl(i).res_seq_num;
                   l_eam_res_usage_rec.start_date       :=        l_res_start_date;
                   l_eam_res_usage_rec.completion_date  :=        l_res_completion_date;
                   l_eam_res_usage_rec.assigned_units   :=        op_res_info_tbl(i).assigned_units;

                   if p_res_usage_tbl.count > 0 then
                           p_res_usage_tbl(p_res_usage_tbl.count+1):=l_eam_res_usage_rec;
                   else
                           p_res_usage_tbl(1):=l_eam_res_usage_rec;
                   end if;

         ELSE
            -- Logic for shifts
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Reresource based on shift') ; END IF ;


             l_res_seq_num   := op_res_info_tbl(i).res_seq_num;
             /* mmaduska */
             l_res_lead_time := op_res_info_tbl(i).usage_rate/op_res_info_tbl(i).assigned_units;
             l_op_res_sft_index :=  op_res_sft_tbl.FIRST;
             l_res_sft_tbl.delete;
             l_res_sft_count := 0;
             l_res_sft_index := 0;

             WHILE l_op_res_sft_index is not NULL LOOP

                   IF  op_res_sft_tbl(l_op_res_sft_index).op_seq_num = p_op_seq_num AND
                       op_res_sft_tbl(l_op_res_sft_index).res_seq_num = l_res_seq_num THEN
                   --fix for bug 3355437.commented the following code so that pl/sql tables will be initialized always
                      /* l_res_sft_index := l_res_sft_tbl.LAST;

                       IF l_res_sft_index IS NULL THEN
                          l_res_sft_index := 0;
                       END IF;*/

                       l_res_sft_index := l_res_sft_index + 1;
                       l_res_sft_tbl(l_res_sft_index).shift_num := op_res_sft_tbl(l_op_res_sft_index).shift_num;
                       l_res_sft_tbl(l_res_sft_index).from_time := op_res_sft_tbl(l_op_res_sft_index).from_time;
                       l_res_sft_tbl(l_res_sft_index).to_time := op_res_sft_tbl(l_op_res_sft_index).to_time;
                       l_res_sft_count := l_res_sft_count + 1;

                   END IF;

                   l_op_res_sft_index :=  op_res_sft_tbl.NEXT(l_op_res_sft_index);

             END LOOP;

             IF l_res_sft_count = 0 THEN
                RAISE NO_SFT_EXC;
             END IF;

             IF p_schedule_dir = 1 THEN

                  if NOT ((i > op_res_info_tbl.FIRST ) and (op_res_info_tbl(i).res_sch_num = op_res_info_tbl(op_res_info_tbl.PRIOR(i)).res_sch_num)
                  and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.PRIOR(i)).op_seq_num)) then

                     l_res_start_date := l_next_res_start_date;

                  end if;

               l_curr_time := (l_res_start_date - trunc(l_res_start_date)) * 86400 ;
               l_curr_date := l_res_start_date;

                l_shift_index := 1;   --initialise shift index to 1
                l_curr_index := l_res_sft_tbl.FIRST ;

               WHILE l_res_lead_time > 0 LOOP

              IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Enters loop for lead time'||l_res_lead_time) ; END IF ;

                    eam_get_shift_num
                     ( l_curr_time,
                       p_schedule_dir,
                       l_res_sft_tbl,
                       l_curr_index,
                       l_shift_num,
                       l_from_time,
                       l_to_time,
                       x_error_message,
                       x_return_status,
                       l_out_index
                     );

                    IF l_shift_num  IS NULL THEN
                         l_curr_date := trunc(l_curr_date) + 1;
                         l_curr_time := 0;

                         eam_get_shift_num
                          ( l_curr_time,
                            p_schedule_dir,
                            l_res_sft_tbl,
                            l_curr_index,
                            l_shift_num,
                            l_from_time,
                            l_to_time,
                            x_error_message,
                            x_return_status,
                            l_out_index
                          );
                    ELSE
                               IF ( l_out_index IS NOT NULL ) THEN
                                        l_curr_index := l_res_sft_tbl.NEXT( l_out_index ) ;
                              END IF ;
                    END IF;

                    eam_get_shift_wkdays
                     ( l_curr_date,
                       p_calendar_code,
                       l_shift_num,
                       p_schedule_dir,
                       l_wkday_flag,
                       x_error_message,
                       x_return_status
                     );

                     IF(x_return_status <>'S') THEN
                          RETURN;
                     END IF;

                    IF l_wkday_flag = 1 THEN

                       IF (l_shift_index = 1) THEN                      --store the value of first valid shift
                           l_res_start_date := trunc(l_curr_date) + l_curr_time/86400 ;
                       END IF;

                     l_shift_index := l_shift_index + 1;


                      IF   ( (l_to_time - l_from_time) <= 0 AND  l_curr_time >= l_from_time) THEN
                             l_sft_avail_time :=   86400 - l_curr_time;
                      ELSE
                          l_sft_avail_time :=  l_to_time - l_curr_time;
                      END IF;/* avail time */

                      IF l_sft_avail_time >= l_res_lead_time THEN

                      l_res_completion_date := trunc(l_curr_date) + (l_curr_time + l_res_lead_time)/86400;

                          t_start_date :=trunc(l_curr_date) + (l_curr_time)/86400;

                          l_eam_res_usage_rec.operation_seq_num:=        p_op_seq_num;
                          l_eam_res_usage_rec.resource_seq_num :=        op_res_info_tbl(i).res_seq_num;
                          l_eam_res_usage_rec.start_date       :=        t_start_date;
                          l_eam_res_usage_rec.completion_date  :=        l_res_completion_date;
                          l_eam_res_usage_rec.assigned_units   :=        op_res_info_tbl(i).assigned_units;

                            if p_res_usage_tbl.count > 0 then
                                   p_res_usage_tbl(p_res_usage_tbl.count+1):=l_eam_res_usage_rec;
                            else
                                   p_res_usage_tbl(1):=l_eam_res_usage_rec;
                            end if;

                      if (i > op_res_info_tbl.FIRST ) and (op_res_info_tbl(i).res_sch_num = op_res_info_tbl(op_res_info_tbl.PRIOR(i)).res_sch_num)
                      and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.PRIOR(i)).op_seq_num) then

                          if l_res_completion_date > l_next_res_start_date then
                             l_next_res_start_date := l_res_completion_date;
                          end if;

                      else
                             l_next_res_start_date := l_res_completion_date;
                      end if;

                         l_res_lead_time := 0;
                      ELSE
                         l_res_lead_time := l_res_lead_time - l_sft_avail_time;
                         l_curr_time     := l_curr_time + l_sft_avail_time;
                         IF l_curr_time >= 86400 THEN
                            l_curr_time := l_curr_time - 86400;
                            l_curr_date := trunc(l_curr_date) + 1;
                         END IF;

                             t_end_date   := trunc(l_curr_date) + (l_curr_time/86400);
                             t_start_date := t_end_date - (l_sft_avail_time/86400);

                             l_eam_res_usage_rec.operation_seq_num:=        p_op_seq_num;
                             l_eam_res_usage_rec.resource_seq_num :=        op_res_info_tbl(i).res_seq_num;
                             l_eam_res_usage_rec.start_date       :=        t_start_date;
                             l_eam_res_usage_rec.completion_date  :=        t_end_date;
                             l_eam_res_usage_rec.assigned_units   :=        op_res_info_tbl(i).assigned_units;

                             if p_res_usage_tbl.count > 0 then
                                   p_res_usage_tbl(p_res_usage_tbl.count+1):=l_eam_res_usage_rec;
                             else
                                   p_res_usage_tbl(1):=l_eam_res_usage_rec;
                             end if;

                      END IF;/* avail time */
                         l_curr_index := l_res_sft_tbl.FIRST ;

                    ELSE
                         IF ( l_out_index IS NOT NULL AND l_res_sft_tbl.NEXT(l_out_index) IS NULL ) THEN
			     IF l_to_time <= l_from_time THEN
				l_curr_date := trunc(l_curr_date) + 1;
				l_curr_time := 0 ;
			     ELSE
				l_curr_time := l_to_time + 1;
			     END IF;
                             l_curr_index := l_res_sft_tbl.FIRST ;

                         END IF ;
                    END IF; /*wkdays flag */

                 END LOOP;

            ELSE

                  if NOT ((i > op_res_info_tbl.LAST ) and (op_res_info_tbl(i).res_sch_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).res_sch_num)
                  and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).op_seq_num)) then

                      l_res_completion_date := l_next_res_completion_date;

                  end if;

               l_curr_time := (l_res_completion_date - trunc(l_res_completion_date)) * 86400 ;
               l_curr_date := l_res_completion_date;

                l_shift_index := 1;   --initialise shift index to 1
                l_curr_index := l_res_sft_tbl.FIRST ;

                WHILE l_res_lead_time > 0 LOOP

                    eam_get_shift_num    ( l_curr_time        ,
                                           p_schedule_dir     ,
                                           l_res_sft_tbl      ,
                                           l_curr_index ,
                                           l_shift_num        ,
                                           l_from_time        ,
                                           l_to_time          ,
                                           x_error_message    ,
                                           x_return_status  ,
                                           l_out_index );


                    IF l_shift_num  IS NULL THEN
                         l_curr_date := trunc(l_curr_date) - 1;
                         l_curr_time := 86400;

                         eam_get_shift_num ( l_curr_time        ,
                                           p_schedule_dir     ,
                                           l_res_sft_tbl      ,
					   l_curr_index	      ,
                                           l_shift_num        ,
                                           l_from_time        ,
                                           l_to_time          ,
                                           x_error_message    ,
                            x_return_status,
                            l_out_index
                          );

                   ELSE
                       IF ( l_out_index IS NOT NULL ) THEN
                                l_curr_index := l_res_sft_tbl.NEXT( l_out_index ) ;
                      END IF ;
                    END IF;

                    eam_get_shift_wkdays
                             (l_curr_date,
                              p_calendar_code,
                              l_shift_num,
                              p_schedule_dir,
                              l_wkday_flag ,
                              x_error_message ,
                              x_return_status  );

                     IF(x_return_status <>'S') THEN
                          RETURN;
                     END IF;

                    IF l_wkday_flag = 1 THEN

                       IF (l_shift_index = 1) THEN    --copy the last valid shift time to resource completion date

		            --start for 7264665
			 if  (op_res_info_tbl.LAST >i  ) and (op_res_info_tbl(i).res_sch_num =	op_res_info_tbl(op_res_info_tbl.NEXT(i)).res_sch_num)
			      and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).op_seq_num) then
                                l_res_completion_date := trunc(l_curr_date) +(l_curr_time+l_res_lead_time)/86400 ;
			    else
                                l_res_completion_date := trunc(l_curr_date) + l_curr_time/86400 ;
			 end if;
			    --end for 7264665

                       END IF;     --end of if for shift_index=1
                       l_shift_index := l_shift_index+1;

                      IF   ( (l_to_time - l_from_time) <= 0
                          AND  l_curr_time <= l_to_time) THEN
                       l_sft_avail_time :=   l_curr_time - 0 ;
                      ELSE
                        l_sft_avail_time :=   l_curr_time - l_from_time;
                      END IF;/* avail time */

                      IF l_sft_avail_time >= l_res_lead_time THEN

		      --start for 7264665

			if  (op_res_info_tbl.LAST >i  ) and (op_res_info_tbl(i).res_sch_num =	op_res_info_tbl(op_res_info_tbl.NEXT(i)).res_sch_num)
			     and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).op_seq_num) then
	                      l_res_start_date := trunc(l_curr_date) + (l_curr_time)/86400;
			   else
		              l_res_start_date := trunc(l_curr_date) + (l_curr_time - l_res_lead_time)/86400;
			end if;

		        --end for 7264665


                      if (i > op_res_info_tbl.LAST ) and (op_res_info_tbl(i).res_sch_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).res_sch_num)
                      and (op_res_info_tbl(i).op_seq_num = op_res_info_tbl(op_res_info_tbl.NEXT(i)).op_seq_num) then

                          if l_res_start_date < l_next_res_completion_date then
                              l_next_res_completion_date := l_res_start_date;
                          end if;

                      else
                          l_next_res_completion_date := l_res_start_date;
                      end if;

                         l_res_lead_time := 0;
                           t_end_date := trunc(l_curr_date) + (l_curr_time/86400);

                            l_eam_res_usage_rec.operation_seq_num:=        p_op_seq_num;
                            l_eam_res_usage_rec.resource_seq_num :=        op_res_info_tbl(i).res_seq_num;
                            l_eam_res_usage_rec.start_date       :=        l_res_start_date;
                            l_eam_res_usage_rec.completion_date  :=        t_end_date;
                            l_eam_res_usage_rec.assigned_units   :=        op_res_info_tbl(i).assigned_units;

                            if p_res_usage_tbl.count > 0 then
                                   p_res_usage_tbl(p_res_usage_tbl.count+1):=l_eam_res_usage_rec;
                            else
                                   p_res_usage_tbl(1):=l_eam_res_usage_rec;
                            end if;

                      ELSE
                         l_res_lead_time := l_res_lead_time - l_sft_avail_time;
                         l_curr_time     := l_curr_time - l_sft_avail_time;
                         IF l_curr_time <= 0 THEN
                            l_curr_time :=  86400 + l_curr_time;
                            l_curr_date := trunc(l_curr_date) - 1;
                         END IF;
                          t_end_date   := trunc(l_curr_date) + ((l_curr_time+l_sft_avail_time) /86400);
                           t_start_date   := t_end_date - (l_sft_avail_time/86400);

                           l_eam_res_usage_rec.operation_seq_num:=        p_op_seq_num;
                           l_eam_res_usage_rec.resource_seq_num :=        op_res_info_tbl(i).res_seq_num;
                           l_eam_res_usage_rec.start_date       :=        t_start_date;
                           l_eam_res_usage_rec.completion_date  :=        t_end_date;
                           l_eam_res_usage_rec.assigned_units   :=        op_res_info_tbl(i).assigned_units;

                           if p_res_usage_tbl.count > 0 then
                                   p_res_usage_tbl(p_res_usage_tbl.count+1):=l_eam_res_usage_rec;
                            else
                                   p_res_usage_tbl(1):=l_eam_res_usage_rec;
                            end if;

                      END IF;/* avail time */

                         l_curr_index := l_res_sft_tbl.FIRST ;

                    ELSE
                        IF ( l_out_index IS NOT NULL AND l_res_sft_tbl.NEXT(l_out_index) IS NULL ) THEN
			     IF l_to_time <= l_from_time THEN
				l_curr_date := trunc(l_curr_date) - 1;
				l_curr_time := 86400;
			     ELSE
				 l_curr_time := l_from_time - 1;
                             END IF;
                             l_curr_index := l_res_sft_tbl.FIRST ;
			END IF;
                    END IF; /*wkdays flag */
                 END LOOP;
             END IF; /* Schedule direction */
              -- NULL;
          END IF; /* end for shift and 24hrs flag based scheduling */


      ELSE

-- for non-scheduled resources
         IF p_schedule_dir = 1 THEN /* forward schedule */
                l_res_start_date := l_next_res_start_date;
                l_res_completion_date := l_res_start_date;
                l_next_res_start_date  := l_res_completion_date;
         ELSE
                l_res_completion_date := l_next_res_completion_date;
                l_res_start_date := l_res_completion_date;
                l_next_res_completion_date := l_res_start_date;
         END IF;

      END IF;  /* End for scheduled_flag */



        begin
                -- bug no 3444091
                if l_res_start_date > l_res_completion_date then
                        x_return_status := fnd_api.g_ret_sts_error;
                        fnd_message.set_name('EAM','EAM_WO_RES_DT_ERR');
                        fnd_message.set_token('RESNO', op_res_info_tbl(i).res_seq_num);
                        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Negative resource duration') ; END IF ;
                        return;
                end if;

                 UPDATE WIP_OPERATION_RESOURCES
                 SET    START_DATE        = l_res_start_date,
                        COMPLETION_DATE   = l_res_completion_date
                 WHERE  WIP_ENTITY_ID     = p_wip_entity_id
                 AND    OPERATION_SEQ_NUM = p_op_seq_num
                 AND    RESOURCE_SEQ_NUM  = op_res_info_tbl(i).res_seq_num;

                UPDATE WIP_OP_RESOURCE_INSTANCES
                 set start_date = l_res_start_date
                 , completion_date = l_res_completion_date
                     WHERE  WIP_ENTITY_ID     = p_wip_entity_id
                 AND    OPERATION_SEQ_NUM = p_op_seq_num
                 AND    RESOURCE_SEQ_NUM  = op_res_info_tbl(i).res_seq_num;
        exception
                when others then
                        null;
        end;

       if  (p_schedule_dir = 1) AND ( (l_rsc_index = 1) OR (l_min_rsc_start_date > l_res_start_date ) ) THEN
           l_min_rsc_start_date := l_res_start_date;      --find the minimum resource start date
       END IF;

       if  (p_schedule_dir = 2) AND ( (l_rsc_index = 1) OR (l_max_rsc_end_date < l_res_completion_date ) ) THEN
           l_max_rsc_end_date := l_res_completion_date;        -- find the max resource end date
       END IF;
       l_rsc_index := l_rsc_index + 1;


 --start of fix for 3574991
   IF p_schedule_dir = 1 THEN
     if (l_res_completion_date > p_op_completion_date) then
        p_op_completion_date := l_res_completion_date;
     end if;

  ELSE
     if (l_res_start_date < p_op_start_date) then
        p_op_start_date := l_res_start_date;
     end if;

  END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('entering if'||p_op_seq_num||'...'||op_res_info_tbl(i).res_seq_num) ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('l_res_start_date= '|| l_res_start_date) ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('l_res_completion_date= '|| l_res_completion_date) ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('l_next_res_start_date= '|| l_next_res_start_date) ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('l_next_res_completion_date= '|| l_next_res_completion_date) ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Start Date'|| p_op_start_date) ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Op Completion Date'|| p_op_completion_date) ; END IF ;


    END IF; /* End of identification of op_seq_num */


             IF p_schedule_dir = 1 THEN
                       i := op_res_info_tbl.NEXT(i);
              ELSE
                     i := op_res_info_tbl.PRIOR(i);
             END IF;
         --end of fix for 3574991

  END LOOP;

    IF p_schedule_dir = 1 THEN     --copy the min resource start date to operation's start date
           p_op_start_date := l_min_rsc_start_date;
    ELSE                          --copy max resource end date to operation's end date
           p_op_completion_date := l_max_rsc_end_date;
    END IF; --end of check for scheduling direction


EXCEPTION
    WHEN NO_SFT_EXC THEN
    x_return_status := fnd_api.g_ret_sts_error;
    x_error_message := 'NO SHIFT ASSOCIATED TO A RESOURCE';
    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('No shift found for the resource') ; END IF ;

END; /*SCHEDULE_RESOURCES */








PROCEDURE SCHEDULE_OPERATIONS
      ( p_organization_id           IN   NUMBER,
        p_wip_entity_id    IN   NUMBER,
        p_start_date       IN OUT NOCOPY  DATE,
        p_completion_date  IN OUT NOCOPY  DATE,
        p_hour_conv        IN   NUMBER,
        p_calendar_code    IN   VARCHAR2,
        p_excetion_set_id  IN   NUMBER,
        p_validation_level IN   NUMBER,
        p_res_usage_tbl    IN OUT NOCOPY EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type,
        p_commit           IN   VARCHAR2,
        x_error_message    OUT NOCOPY  VARCHAR2,
        x_return_status    OUT NOCOPY  VARCHAR2) IS

        l_calender_code         VARCHAR2(10);
        l_exception_set_id      NUMBER;
        l_res_rec_count         NUMBER;
        l_op_scd_seq_count      NUMBER;
        l_schedule_dir          NUMBER;
        l_op_index              NUMBER;
        l_res_index             NUMBER;
        l_op_seq_num            NUMBER;
        l_res_count             NUMBER;
        l_op_start_date         DATE;
        l_op_completion_date    DATE;
        l_min_start_date        DATE;
        l_max_completion_date   DATE;
        l_res_sft_rec_count     NUMBER;
        l_stmt_num              NUMBER := 100;
        l_op_last_level         NUMBER;
	l_sched_start_wo_dt        DATE;
	l_sched_completion_wo_dt   DATE;



   /* Cursor definition to store resource information*/

    CURSOR  EAM_RSC_CSR IS
        SELECT WO.OPERATION_SEQ_NUM              OP_SEQ_NUM,
               WO.OPERATION_SEQUENCE_ID          OP_SEQ_ID,
               WO.FIRST_UNIT_START_DATE          OP_START_DATE,
               WO.LAST_UNIT_COMPLETION_DATE      OP_COMPLETION_DATE,
               WO.OPERATION_COMPLETED            OP_COMPLETED,
               WOR.RESOURCE_SEQ_NUM              RES_SEQ_NUM,
               NVL(WOR.SCHEDULE_SEQ_NUM, WOR.RESOURCE_SEQ_NUM)              RES_SCH_NUM,
               WOR.RESOURCE_ID                   RES_ID,
               WOR.START_DATE                    RES_START_DATE,
               WOR.COMPLETION_DATE               RES_COMPLETION_DATE,
               NVL(WOR.ASSIGNED_UNITS, 0)        ASSIGNED_UNITS,
               DR2.CAPACITY_UNITS                CAPACITY_UNITS,
               ROUND(WOR.USAGE_RATE_OR_AMOUNT * (1/p_hour_conv )* DECODE (CON.CONVERSION_RATE, '', 0, '0', 0, CON.CONVERSION_RATE) *
                DECODE (WOR.BASIS_TYPE, 1, 1, 2, 1, 1) * 3600)  USAGE_RATE,
               DECODE(WOR.SCHEDULED_FLAG, 1, DECODE(WOR.USAGE_RATE_OR_AMOUNT, 0, 2, 1),
                 WOR.SCHEDULED_FLAG) SCHEDULED_FLAG,
               DR2.AVAILABLE_24_HOURS_FLAG       AVAIL_24_HRS_FLAG
          FROM WIP_OPERATIONS WO,
               BOM_DEPARTMENT_RESOURCES DR1,
               BOM_DEPARTMENT_RESOURCES DR2,
               WIP_OPERATION_RESOURCES WOR,
               BOM_RESOURCES RES,
               MTL_UOM_CONVERSIONS CON
         WHERE
               WO.WIP_ENTITY_ID = p_wip_entity_id
           AND WO.ORGANIZATION_ID = p_organization_id
           AND WO.WIP_ENTITY_ID = WOR.WIP_ENTITY_ID
           AND WO.OPERATION_SEQ_NUM = WOR.OPERATION_SEQ_NUM
           AND WO.DEPARTMENT_ID = DR1.DEPARTMENT_ID
           AND WOR.RESOURCE_ID = DR1.RESOURCE_ID
           AND NVL(DR1.SHARE_FROM_DEPT_ID, DR1.DEPARTMENT_ID) = DR2.DEPARTMENT_ID
           AND WOR.RESOURCE_ID = DR2.RESOURCE_ID
           AND WOR.RESOURCE_ID = RES.RESOURCE_ID
           AND CON.UOM_CODE (+) = RES.UNIT_OF_MEASURE
           AND CON.INVENTORY_ITEM_ID (+) = 0
      ORDER BY WO.OPERATION_SEQ_NUM,
--               WOR.RESOURCE_SEQ_NUM;
               WOR.SCHEDULE_SEQ_NUM;
     /* Cursor to identify the operation scheduling sequence considering the dependency */

   CURSOR OP_FWD_SCD_SEQ_CSR IS
       SELECT -1 "LEVEL", operation_seq_num "OP_SEQ_NUM"
         FROM wip_operations
        WHERE wip_entity_id = p_wip_entity_id
          AND operation_seq_num not in( SELECT prior_operation
                                          FROM WIP_OPERATION_NETWORKS
                                         WHERE wip_entity_id = p_wip_entity_id
                                         UNION
                                        SELECT next_operation
                                          FROM WIP_OPERATION_NETWORKS
                                         WHERE wip_entity_id = p_wip_entity_id)
         UNION

        SELECT 0 "LEVEL", prior_operation "OP_SEQ_NUM"
          FROM wip_operation_networks
         WHERE prior_operation NOT IN
                (SELECT next_operation
                   FROM wip_operation_networks
                  WHERE wip_entity_id = p_wip_entity_id )
                    AND wip_entity_id=p_wip_entity_id
         UNION
        SELECT max(level) "LEVEL", next_operation "OP_SEQ_NUM"
          FROM (SELECT * FROM wip_operation_networks
         WHERE wip_entity_id=p_wip_entity_id)
    START WITH prior_operation IN
                   (SELECT prior_operation
                      FROM wip_operation_networks
                     WHERE prior_operation NOT IN
                           (SELECT next_operation
                              FROM wip_operation_networks
                             WHERE wip_entity_id=p_wip_entity_id )
                               AND wip_entity_id=p_wip_entity_id)
                  CONNECT BY PRIOR next_operation = prior_operation
                               AND wip_entity_id = p_wip_entity_id
      GROUP BY next_operation
      ORDER BY 1;


    CURSOR OP_BWD_SCD_SEQ_CSR IS
       SELECT -1 "LEVEL", operation_seq_num "OP_SEQ_NUM"
         FROM wip_operations
        WHERE wip_entity_id = p_wip_entity_id
          AND operation_seq_num not in( SELECT prior_operation
                                          FROM WIP_OPERATION_NETWORKS
                                         WHERE wip_entity_id = p_wip_entity_id
                                         UNION
                                        SELECT next_operation
                                          FROM WIP_OPERATION_NETWORKS
                                         WHERE wip_entity_id = p_wip_entity_id)
         UNION
        SELECT 0 "LEVEL", next_operation "OP_SEQ_NUM"
          FROM wip_operation_networks
         WHERE next_operation NOT IN
                (SELECT prior_operation
                   FROM wip_operation_networks
                  WHERE wip_entity_id = p_wip_entity_id )
                    AND wip_entity_id=p_wip_entity_id
         UNION
        SELECT max(level) "LEVEL", prior_operation "OP_SEQ_NUM"
          FROM (SELECT * FROM wip_operation_networks
         WHERE wip_entity_id=p_wip_entity_id)
    START WITH next_operation IN
                   (SELECT next_operation
                      FROM wip_operation_networks
                     WHERE next_operation NOT IN
                           (SELECT prior_operation
                              FROM wip_operation_networks
                             WHERE wip_entity_id=p_wip_entity_id )
                               AND wip_entity_id=p_wip_entity_id)
                  CONNECT BY PRIOR prior_operation = next_operation
                               AND wip_entity_id = p_wip_entity_id
      GROUP BY prior_operation
      ORDER BY 1;

/*  Bug 5144273. Split cursor OP_RES_SFT_CSR into two cursors OP_RES_SFT_CSR_FWD and OP_RES_SFT_CSR_BWD .
    OP_RES_SFT_CSR_FWD is used for Forward scheduling and OP_RES_SFT_CSR_BWD for backward scheduling
    */
       CURSOR OP_RES_SFT_CSR_FWD IS
       SELECT   WO.OPERATION_SEQ_NUM  OP_SEQ_NUM,
                WOR.RESOURCE_SEQ_NUM  RES_SEQ_NUM,
                SHF.SHIFT_NUM         SHIFT_NUM,
                SHF.FROM_TIME         FROM_TIME,
                SHF.TO_TIME           TO_TIME
         FROM   BOM_SHIFT_TIMES SHF,
                BOM_RESOURCE_SHIFTS RSH,
                BOM_DEPARTMENT_RESOURCES BDR,
                WIP_OPERATION_RESOURCES WOR,
                WIP_OPERATIONS WO
         WHERE  WO.WIP_ENTITY_ID = p_wip_entity_id
           AND  WO.ORGANIZATION_ID = p_organization_id
           AND  WO.WIP_ENTITY_ID = WOR.WIP_ENTITY_ID
           AND  WO.OPERATION_SEQ_NUM = WOR.OPERATION_SEQ_NUM
           AND  WOR.SCHEDULED_FLAG IS NOT NULL
           AND  WO.DEPARTMENT_ID = BDR.DEPARTMENT_ID
           AND  WOR.RESOURCE_ID = BDR.RESOURCE_ID
           AND  NVL(BDR.SHARE_FROM_DEPT_ID, BDR.DEPARTMENT_ID) = RSH.DEPARTMENT_ID
           AND  RSH.RESOURCE_ID = WOR.RESOURCE_ID
           AND  RSH.SHIFT_NUM = SHF.SHIFT_NUM
           AND  SHF.CALENDAR_CODE = p_calendar_code
           ORDER BY FROM_TIME, TO_TIME ;


    CURSOR OP_RES_SFT_CSR_BWD IS
    SELECT   WO.OPERATION_SEQ_NUM  OP_SEQ_NUM,
             WOR.RESOURCE_SEQ_NUM  RES_SEQ_NUM,
             SHF.SHIFT_NUM         SHIFT_NUM,
             SHF.FROM_TIME         FROM_TIME,
             SHF.TO_TIME           TO_TIME
      FROM   BOM_SHIFT_TIMES SHF,
             BOM_RESOURCE_SHIFTS RSH,
             BOM_DEPARTMENT_RESOURCES BDR,
             WIP_OPERATION_RESOURCES WOR,
             WIP_OPERATIONS WO
      WHERE  WO.WIP_ENTITY_ID = p_wip_entity_id
        AND  WO.ORGANIZATION_ID = p_organization_id
        AND  WO.WIP_ENTITY_ID = WOR.WIP_ENTITY_ID
        AND  WO.OPERATION_SEQ_NUM = WOR.OPERATION_SEQ_NUM
        AND  WOR.SCHEDULED_FLAG IS NOT NULL
        AND  WO.DEPARTMENT_ID = BDR.DEPARTMENT_ID
        AND  WOR.RESOURCE_ID = BDR.RESOURCE_ID
        AND  NVL(BDR.SHARE_FROM_DEPT_ID, BDR.DEPARTMENT_ID) = RSH.DEPARTMENT_ID
        AND  RSH.RESOURCE_ID = WOR.RESOURCE_ID
        AND  RSH.SHIFT_NUM = SHF.SHIFT_NUM
        AND  SHF.CALENDAR_CODE = p_calendar_code
	ORDER BY TO_TIME DESC, FROM_TIME DESC;


  BEGIN /*SCHEDULE_OPERATIONS*/

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Starting SCHEDULE_OPERATIONS') ; END IF ;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Scheduling '|| p_wip_entity_id) ; END IF ;

    l_res_rec_count:=0;
    op_res_info_tbl.delete;

     FOR l_op_res_info_rec IN EAM_RSC_CSR LOOP
--fix for bug 3355437.commented the following code so that pl/sql tables will be initialized always
      /* l_res_rec_count :=  op_res_info_tbl.last;

       IF l_res_rec_count is NULL THEN
         l_res_rec_count:=0;
       END IF;*/

       l_res_rec_count := l_res_rec_count + 1;

       op_res_info_tbl(l_res_rec_count).op_seq_num := l_op_res_info_rec.OP_SEQ_NUM;
       op_res_info_tbl(l_res_rec_count).op_seq_id := l_op_res_info_rec.OP_SEQ_id;
       op_res_info_tbl(l_res_rec_count).op_start_date := l_op_res_info_rec.op_start_date;
       op_res_info_tbl(l_res_rec_count).op_completion_date := l_op_res_info_rec.op_completion_date;
       op_res_info_tbl(l_res_rec_count).op_completed := l_op_res_info_rec.op_completed;
       op_res_info_tbl(l_res_rec_count).res_seq_num := l_op_res_info_rec.res_seq_num;
       op_res_info_tbl(l_res_rec_count).res_sch_num := l_op_res_info_rec.res_sch_num;
       op_res_info_tbl(l_res_rec_count).res_id := l_op_res_info_rec.res_id;
       op_res_info_tbl(l_res_rec_count).res_start_date := l_op_res_info_rec.res_start_date;
       op_res_info_tbl(l_res_rec_count).res_completion_date := l_op_res_info_rec.res_completion_date;
       op_res_info_tbl(l_res_rec_count).assigned_units := l_op_res_info_rec.ASSIGNED_UNITS;
       op_res_info_tbl(l_res_rec_count).capacity_units := l_op_res_info_rec.CAPACITY_UNITS;
       op_res_info_tbl(l_res_rec_count).usage_rate := l_op_res_info_rec.USAGE_RATE;
       op_res_info_tbl(l_res_rec_count).scheduled_flag := l_op_res_info_rec.SCHEDULED_FLAG;
       op_res_info_tbl(l_res_rec_count).avail_24_hrs_flag := l_op_res_info_rec.AVAIL_24_HRS_FLAG;

     END LOOP;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Resource Count for Scheduling '||op_res_info_tbl.count) ; END IF ;

   l_res_sft_rec_count := 0;
   op_res_sft_tbl.delete;

					IF  p_start_date IS NOT NULL THEN -- fwd scheduling .added for bug 5144273

													    FOR l_op_rsc_sft_rec IN OP_RES_SFT_CSR_FWD LOOP

													       l_res_sft_rec_count := l_res_sft_rec_count + 1;

													       op_res_sft_tbl(l_res_sft_rec_count).op_seq_num := l_op_rsc_sft_rec.op_seq_num;
													       op_res_sft_tbl(l_res_sft_rec_count).res_seq_num := l_op_rsc_sft_rec.res_seq_num;
													       op_res_sft_tbl(l_res_sft_rec_count).shift_num := l_op_rsc_sft_rec.shift_num;
													       op_res_sft_tbl(l_res_sft_rec_count).from_time := l_op_rsc_sft_rec.from_time;
													       op_res_sft_tbl(l_res_sft_rec_count).to_time := l_op_rsc_sft_rec.to_time;
													    END LOOP;
					ELSE -- bwd scheduling . added for bug 5144273
														       FOR l_op_rsc_sft_rec IN OP_RES_SFT_CSR_BWD LOOP

															  l_res_sft_rec_count := l_res_sft_rec_count + 1;

															  op_res_sft_tbl(l_res_sft_rec_count).op_seq_num := l_op_rsc_sft_rec.op_seq_num;
															  op_res_sft_tbl(l_res_sft_rec_count).res_seq_num := l_op_rsc_sft_rec.res_seq_num;
															  op_res_sft_tbl(l_res_sft_rec_count).shift_num := l_op_rsc_sft_rec.shift_num;
															  op_res_sft_tbl(l_res_sft_rec_count).from_time := l_op_rsc_sft_rec.from_time;
															  op_res_sft_tbl(l_res_sft_rec_count).to_time := l_op_rsc_sft_rec.to_time;
														       END LOOP;
					   END IF ;


  IF p_start_date IS NOT NULL THEN

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Forward Scheduling') ; END IF ;

     l_schedule_dir := 1;

    l_op_scd_seq_count:=0;
    op_scd_seq_tbl.delete;

    FOR l_op_scd_seq_rec IN OP_FWD_SCD_SEQ_CSR LOOP
--fix for bug 3355437.commented the following code so that pl/sql tables will be initialized always
       /*l_op_scd_seq_count :=  op_scd_seq_tbl.last;

       IF l_op_scd_seq_count is NULL THEN
         l_op_scd_seq_count:=0;
       END IF;*/

       l_op_scd_seq_count := l_op_scd_seq_count + 1;

       op_scd_seq_tbl(l_op_scd_seq_count).level := l_op_scd_seq_rec.LEVEL;
       op_scd_seq_tbl(l_op_scd_seq_count).op_seq_num := l_op_scd_seq_rec.OP_SEQ_NUM;
       op_scd_seq_tbl(l_op_scd_seq_count).op_start_date := NULL;
       op_scd_seq_tbl(l_op_scd_seq_count).op_completion_date := NULL;

     END LOOP;

     l_op_index := op_scd_seq_tbl.FIRST;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Count for Scheduling '||op_scd_seq_tbl.count) ; END IF ;

     WHILE l_op_index is not NULL LOOP

        l_op_seq_num := op_scd_seq_tbl(l_op_index).op_seq_num;
        l_res_count := 0;

        IF op_scd_seq_tbl(l_op_index).level = 0 OR op_scd_seq_tbl(l_op_index).level = -1 THEN

            l_op_start_date := p_start_date;
        ELSE

           dep_op_seq_num_tbl.delete;

            SELECT prior_operation
            BULK COLLECT INTO  dep_op_seq_num_tbl
            FROM   wip_operation_networks
            WHERE  wip_entity_id = p_wip_entity_id
            AND    next_operation = l_op_seq_num;


            DECLARE
              l_dep_index    NUMBER;
              l_op_tab_index NUMBER;
            BEGIN

              l_op_start_date := p_start_date;
              l_dep_index := dep_op_seq_num_tbl.FIRST;

              WHILE l_dep_index is not NULL LOOP

                   l_op_tab_index := op_scd_seq_tbl.FIRST;

                   WHILE l_op_tab_index is not NULL LOOP

                       IF dep_op_seq_num_tbl(l_dep_index) = op_scd_seq_tbl(l_op_tab_index).op_seq_num THEN

                           IF l_op_start_date <= op_scd_seq_tbl(l_op_tab_index).op_completion_date THEN

                               l_op_start_date :=  op_scd_seq_tbl(l_op_tab_index).op_completion_date;

                           ELSE
                               NULL;
                           END IF;

                           EXIT;

                       END IF;

                       l_op_tab_index := op_scd_seq_tbl.NEXT(l_op_tab_index);

                    END LOOP; /* idenfication of completion time of prior op*/

                    l_dep_index := dep_op_seq_num_tbl.NEXT(l_dep_index);

                END LOOP; /* Comparing all prior op completion time */

           END;


        END IF;/* Identification of start time for intermediate operation ends*/

          l_res_index := op_res_info_tbl.FIRST;

          WHILE l_res_index is not NULL LOOP

            IF  op_scd_seq_tbl(l_op_index).op_seq_num = op_res_info_tbl(l_res_index).op_seq_num THEN

                l_res_count := l_res_count + 1;

            END IF;

            l_res_index := op_res_info_tbl.NEXT(l_res_index);

          END LOOP;

          IF l_res_count = 0 THEN
                l_op_completion_date := l_op_start_date;
          ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_CALC_OPERATION_TIME') ; END IF ;
           --fix for 3574991
             l_op_completion_date :=l_op_start_date;

             SCHEDULE_RESOURCES
               (p_organization_id,
                p_wip_entity_id,
                l_op_seq_num,
                l_schedule_dir,
                p_calendar_code,
                op_res_info_tbl,
                op_res_sft_tbl,
                l_op_start_date,
                l_op_completion_date,
		p_res_usage_tbl,
                p_validation_level,
                p_commit,
                x_error_message,
                x_return_status  );

		IF(x_return_status <> 'S') THEN
		      RETURN;
		END IF;

          END IF;

          op_scd_seq_tbl(l_op_index).op_start_date := l_op_start_date;
          op_scd_seq_tbl(l_op_index).op_completion_date := l_op_completion_date;

       l_op_index := op_scd_seq_tbl.NEXT(l_op_index);

     END LOOP;

 ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Backward Scheduling') ; END IF ;


     l_schedule_dir := 2;

     l_op_scd_seq_count:=0;
     op_scd_seq_tbl.delete;

    FOR l_op_scd_seq_rec IN OP_BWD_SCD_SEQ_CSR LOOP
--fix for bug 3355437.commented the following code so that pl/sql tables will be initialized always
     /*  l_op_scd_seq_count :=  op_scd_seq_tbl.last;

       IF l_op_scd_seq_count is NULL THEN

         l_op_scd_seq_count:=0;

       END IF;*/

       l_op_scd_seq_count := l_op_scd_seq_count + 1;

       op_scd_seq_tbl(l_op_scd_seq_count).level := l_op_scd_seq_rec.LEVEL;
       op_scd_seq_tbl(l_op_scd_seq_count).op_seq_num := l_op_scd_seq_rec.OP_SEQ_NUM;
       op_scd_seq_tbl(l_op_scd_seq_count).op_start_date := NULL;
       op_scd_seq_tbl(l_op_scd_seq_count).op_completion_date := NULL;

     END LOOP;

     l_op_index     := op_scd_seq_tbl.FIRST;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Operation Count for Scheduling'||op_scd_seq_tbl.count) ; END IF ;

     WHILE l_op_index is not NULL LOOP

        l_op_seq_num := op_scd_seq_tbl(l_op_index).op_seq_num;
        l_res_count := 0;

        IF op_scd_seq_tbl(l_op_index).level = 0 OR
           op_scd_seq_tbl(l_op_index).level = -1 THEN

            l_op_completion_date := p_completion_date;

        ELSE

          dep_op_seq_num_tbl.delete;

            SELECT next_operation
      BULK COLLECT INTO dep_op_seq_num_tbl
              FROM wip_operation_networks
             WHERE wip_entity_id = p_wip_entity_id
               AND prior_operation = l_op_seq_num;

            DECLARE

              l_dep_index    NUMBER;
              l_op_tab_index NUMBER;

            BEGIN

              l_op_completion_date := p_completion_date;
              l_dep_index := dep_op_seq_num_tbl.FIRST;

              WHILE l_dep_index is not NULL LOOP

                   l_op_tab_index := op_scd_seq_tbl.FIRST;

                   WHILE l_op_tab_index is not NULL LOOP

                       IF dep_op_seq_num_tbl(l_dep_index) = op_scd_seq_tbl(l_op_tab_index).op_seq_num THEN

                           IF l_op_completion_date >= op_scd_seq_tbl(l_op_tab_index).op_start_date THEN

                               l_op_completion_date := op_scd_seq_tbl(l_op_tab_index).op_start_date;

                           ELSE

                               NULL;

                           END IF;

                           EXIT;

                       END IF;

                       l_op_tab_index := op_scd_seq_tbl.NEXT(l_op_tab_index);

                    END LOOP; /* idenfication of start time of next op*/

                    l_dep_index := dep_op_seq_num_tbl.NEXT(l_dep_index);

                END LOOP; /* Comparing all NEXT op start time */

              END;

        END IF;/* Identification of start time for intermediate operation ends*/

          l_res_index := op_res_info_tbl.FIRST;

          WHILE l_res_index is not NULL LOOP

            IF  op_scd_seq_tbl(l_op_index).op_seq_num = op_res_info_tbl(l_res_index).op_seq_num THEN

                l_res_count := l_res_count + 1;

            END IF;

            l_res_index := op_res_info_tbl.NEXT(l_res_index);

          END LOOP;

          IF l_res_count = 0 THEN
                l_op_start_date := l_op_completion_date;
          ELSE

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling EAM_CALC_OPERATION_TIME') ; END IF ;
             --fix for 3574991
              l_op_start_date   := l_op_completion_date;

               SCHEDULE_RESOURCES
               (p_organization_id,
                p_wip_entity_id,
                l_op_seq_num,
                l_schedule_dir,
                p_calendar_code,
                op_res_info_tbl,
                op_res_sft_tbl,
                l_op_start_date,
                l_op_completion_date,
		p_res_usage_tbl,
                p_validation_level,
                p_commit,
                x_error_message,
                x_return_status  );

		IF(x_return_status <> 'S') THEN
		      RETURN;
		END IF;

          END IF;

         --  dbms_output.put_line ('Start Date *' || l_op_start_date);
	--  dbms_output.put_line ('Completion Date *' || l_op_completion_date);


          op_scd_seq_tbl(l_op_index).op_start_date := l_op_start_date;
          op_scd_seq_tbl(l_op_index).op_completion_date := l_op_completion_date;

       l_op_index := op_scd_seq_tbl.NEXT(l_op_index);

     END LOOP;

  END IF; /* Decision for Forward or backward scheduling */


  l_op_index := op_scd_seq_tbl.FIRST;

l_max_completion_date      :=     NULL;
l_min_start_date                   :=     NULL;


  WHILE l_op_index is not NULL LOOP

      l_op_start_date :=  op_scd_seq_tbl(l_op_index).op_start_date;
      l_op_completion_date := op_scd_seq_tbl(l_op_index).op_completion_date;
      l_op_seq_num :=  op_scd_seq_tbl(l_op_index).op_seq_num;

      	-- bug no 3444091
	if l_op_start_date > l_op_completion_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_OP_DT_TK_ERR');
		fnd_message.set_token('OPNO', l_op_seq_num);
		 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Negative operation duration') ; END IF ;
                return;
	end if;


      UPDATE WIP_OPERATIONS
         SET FIRST_UNIT_START_DATE      = l_op_start_date,
             FIRST_UNIT_COMPLETION_DATE = l_op_completion_date,
             LAST_UNIT_START_DATE       = l_op_start_date,
             LAST_UNIT_COMPLETION_DATE  = l_op_completion_date
       WHERE WIP_ENTITY_ID = p_wip_entity_id
         AND OPERATION_SEQ_NUM = l_op_seq_num;

  --irrespective of the scheduling direciton.find the minimum and maximum of operation dates
  IF((l_max_completion_date IS NULL) OR (l_max_completion_date < l_op_completion_date)) THEN
           l_max_completion_date := l_op_completion_date;
  END IF;

  IF((l_min_start_date IS NULL)  OR (l_min_start_date > l_op_start_date)) THEN
          l_min_start_date := l_op_start_date;
  END IF;


      l_op_index := op_scd_seq_tbl.NEXT(l_op_index);

  END LOOP;

   --workorder dates will be the minimum start date and maximum end date of operations.
   p_start_date := NVL(l_min_start_date,NVL(p_start_date,p_completion_date));  --will be Null when there are no operations
   p_completion_date   :=    NVL(l_max_completion_date, p_start_date);

        if p_start_date > p_completion_date then
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_message.set_name('EAM','EAM_WO_DT_TK_ERR');
                fnd_message.set_token('WONO', p_wip_entity_id);
		IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Negative workorder duration') ; END IF ;
                return;
        end if;

	update wip_discrete_jobs
	set scheduled_start_date = p_start_date,
		scheduled_completion_date = p_completion_date
	where wip_entity_id = p_wip_entity_id
	and   organization_id = p_organization_id;


END;/* SCHEDULE_OPERATIONS */





/* Procedure EAM_RTG_GET_INFO for calling procedures to load activity
  routing data to wip tables AND to schedule the operations */

 PROCEDURE SCHEDULE_WO
    ( p_organization_id            IN    NUMBER,
      p_wip_entity_id     IN    NUMBER,
      p_start_date        IN OUT NOCOPY DATE,
      p_completion_date   IN OUT NOCOPY DATE,
      p_validation_level  IN    NUMBER,
      p_commit            IN    VARCHAR2 := FND_API.G_FALSE,
      x_error_message     OUT NOCOPY   VARCHAR2,
      x_return_status     OUT NOCOPY   VARCHAR2
    )
 IS
      l_calendar_code  VARCHAR2(10);
      l_exception_set_id NUMBER;
      l_uom_conv       NUMBER;
      l_stmt_num       NUMBER := 0;
      l_error_msg      VARCHAR2(8000);
      l_stmt_msg       VARCHAR2(200);
      l_hour_uom       VARCHAR2(10);
      l_scd_req        NUMBER := 1;
      INVALID_PARAM_EXC EXCEPTION;

      TYPE l_relationship_records IS REF CURSOR RETURN WIP_SCHED_RELATIONSHIPS%ROWTYPE;
      l_constrained_children      l_relationship_records;
      l_relationship_record       WIP_SCHED_RELATIONSHIPS%ROWTYPE;

      l_min_date  DATE := null;
      l_max_date  DATE := null;
      l_date      DATE := null;

      l_wo_start_date DATE := null;
      l_wo_end_date   DATE := null;
      l_start_date  DATE := null;
      l_compl_date  DATE := null;
      l_status_type NUMBER;
      l_date_completed DATE;

	l_request_id              NUMBER;
	l_program_application_id  NUMBER;
	l_program_id              NUMBER;
	l_program_update_date     DATE;

	p_res_usage_tbl  EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;

	TYPE wip_operations_tbl_type     is TABLE OF number INDEX BY BINARY_INTEGER;
	TYPE wip_op_resource_tbl_type    is TABLE OF number INDEX BY BINARY_INTEGER;
	TYPE wip_op_res_inst_tbl_type    is TABLE OF number INDEX BY BINARY_INTEGER;
	TYPE wip_op_r_inst_st_tbl_type   is TABLE OF DATE INDEX BY BINARY_INTEGER;
	TYPE wip_op_r_inst_end_tbl_type  is TABLE OF DATE INDEX BY BINARY_INTEGER;

	l_WipOperation_tbl	     wip_operations_tbl_type;
	l_WipOperResource_tbl	     wip_op_resource_tbl_type;
	l_WipOperResInst_tbl	     wip_op_res_inst_tbl_type;
	l_WipOperResInstSt_tbl       wip_op_r_inst_st_tbl_type;
	l_WipOperResInstEnd_tbl      wip_op_r_inst_end_tbl_type;

	 l_mesg_token_tbl          EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
         l_out_mesg_token_tbl      EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
         l_token_tbl               EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type ;

	-- Added for bug 5175006
	l_count  NUMBER ;
	CURSOR	c_zero_res_req_hours IS
	SELECT	operation_seq_num,
			resource_seq_num,
			start_date,
			completion_date,
			assigned_units
	 FROM	wip_operation_resources
       WHERE	wip_entity_id = p_wip_entity_id
	    AND	organization_id = p_organization_id
	    AND	usage_rate_or_amount = 0 ;

	l_res_rec	c_zero_res_req_hours%ROWTYPE ;

 BEGIN

   SAVEPOINT SCHEDULE_WO;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_stmt_num := 10;

   /* For identifying Hour UOM for resource scheduling */
    l_hour_uom := fnd_profile.value('BOM:HOUR_UOM_CODE');

    IF l_hour_uom IS NULL THEN
           IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Value of Profile BOM: Hour UOM is null') ; END IF ;
           x_return_status := FND_API.G_RET_STS_ERROR;
           l_token_tbl.DELETE;
           l_token_tbl(1).token_name  := 'PROFILE';
           l_token_tbl(1).token_value := 'BOM: Hour UOM';
           l_out_mesg_token_tbl  := l_mesg_token_tbl;

           EAM_ERROR_MESSAGE_PVT.Add_Error_Token
           (  x_Mesg_token_tbl => l_out_Mesg_Token_Tbl
           , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
           , p_message_name   => 'EAM_NULL_PROFILE'
           , p_token_tbl      => l_token_tbl
           );

           l_mesg_token_tbl      := l_out_mesg_token_tbl;

            EAM_ERROR_MESSAGE_PVT.Translate_And_Insert_Messages
           (  p_mesg_token_tbl    => l_mesg_token_tbl
            , p_error_level       => EAM_ERROR_MESSAGE_PVT.G_WO_LEVEL
            , p_entity_index      => 1
            );

           RETURN;
       END IF;


       l_stmt_num := 60;

       SELECT CON.CONVERSION_RATE
         INTO l_uom_conv
         FROM MTL_UOM_CONVERSIONS CON
        WHERE CON.UOM_CODE = l_hour_uom
          AND NVL(DISABLE_DATE, SYSDATE + 1) > SYSDATE
          AND CON.INVENTORY_ITEM_ID = 0;

       l_stmt_num := 70;

       SELECT CALENDAR_CODE,
              CALENDAR_EXCEPTION_SET_ID
         INTO l_calendar_code,
              l_exception_set_id
         FROM MTL_PARAMETERS
        WHERE ORGANIZATION_ID = p_organization_id;


     l_stmt_num := 80;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling CALC_SCHEDULE from SCHEDULE_WO') ; END IF ;

	DELETE FROM wip_operation_resource_usage
	 WHERE wip_entity_id   = p_wip_entity_id
	   AND organization_id = p_organization_id;


	   SCHEDULE_OPERATIONS
	    ( p_organization_id,
	      p_wip_entity_id,
	      p_start_date,
	      p_completion_date,
	      l_uom_conv,
	      l_calendar_code,
	      l_exception_set_id,
	      p_validation_level,
	      p_res_usage_tbl,
	      p_commit,
	      x_error_message,
	      x_return_status
	      );

	      IF(x_return_status <> 'S' ) THEN
	            ROLLBACK TO SCHEDULE_WO;
		     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Return status from Schedule_operations is :'||x_return_status) ; END IF ;
		     RETURN;
	      END IF;

	      -- Added for bug 5175006
	      l_count :=  p_res_usage_tbl.count ;

	      OPEN c_zero_res_req_hours ;
	      LOOP
			FETCH c_zero_res_req_hours INTO l_res_rec ;
			EXIT WHEN c_zero_res_req_hours%NOTFOUND ;

			l_count :=  l_count +1 ;
			p_res_usage_tbl( l_count ).operation_seq_num := l_res_rec.operation_seq_num ;
			p_res_usage_tbl( l_count ).resource_seq_num := l_res_rec.resource_seq_num ;
			p_res_usage_tbl( l_count ).start_date := l_res_rec.start_date ;
			p_res_usage_tbl( l_count ).completion_date := l_res_rec.completion_date ;
			p_res_usage_tbl( l_count ).assigned_units := l_res_rec.assigned_units ;

	      END LOOP;
	      CLOSE c_zero_res_req_hours ;
		-- end of fix for bug 5175006

	IF p_res_usage_tbl.count > 0 THEN

           SELECT request_id,program_application_id,program_id,program_update_date
             INTO l_request_id,l_program_application_id,l_program_id,l_program_update_date
             FROM wip_discrete_jobs
            WHERE wip_entity_id = p_wip_entity_id
              AND organization_id = p_organization_id;

           FOR cnt IN p_res_usage_tbl.FIRST..p_res_usage_tbl.LAST LOOP

                   INSERT INTO WIP_OPERATION_RESOURCE_USAGE
                        (   wip_entity_id
                          , operation_seq_num
                          , resource_seq_num
                          , organization_id
                          , start_date
                          , completion_date
                          , assigned_units
                          , last_update_date
                          , last_updated_by
                          , creation_date
                          , created_by
                          , last_update_login
                          , request_id
                          , program_application_id
                          , program_id
                          , program_update_date )
                   VALUES
                         (  p_wip_entity_id
                          , p_res_usage_tbl(cnt).operation_seq_num
                          , p_res_usage_tbl(cnt).resource_seq_num
                          , p_organization_id
                          , p_res_usage_tbl(cnt).start_date
                          , p_res_usage_tbl(cnt).completion_date
                          , p_res_usage_tbl(cnt).assigned_units
                          , SYSDATE
                          , FND_GLOBAL.user_id
                          , SYSDATE
                          , FND_GLOBAL.user_id
                          , FND_GLOBAL.login_id
                          , l_request_id
                          , l_program_application_id
                          , l_program_id
                          , l_program_update_date );
           END LOOP;

         END IF;

	 SELECT operation_seq_num ,
		resource_seq_num ,
		instance_id ,
		start_date ,
		completion_date
	 BULK COLLECT INTO
		l_WipOperation_tbl,
		l_WipOperResource_tbl,
		l_WipOperResInst_tbl,
		l_WipOperResInstSt_tbl,
		l_WipOperResInstEnd_tbl
	 FROM   WIP_OP_RESOURCE_INSTANCES
	 WHERE  wip_entity_id = p_wip_entity_id
           AND  organization_id = p_organization_id;

	      IF l_WipOperResInst_tbl.COUNT > 0 THEN
		FOR mm in l_WipOperResInst_tbl.FIRST..l_WipOperResInst_tbl.LAST LOOP

			INSERT INTO WIP_OPERATION_RESOURCE_USAGE
                        (   wip_entity_id
                          , operation_seq_num
                          , resource_seq_num
                          , organization_id
                          , start_date
                          , completion_date
                          , assigned_units
			  , instance_id
                          , last_update_date
                          , last_updated_by
                          , creation_date
                          , created_by
                          , last_update_login
                          , request_id
                          , program_application_id
                          , program_id
                          , program_update_date )
                   SELECT
                           wip_entity_id
                          , operation_seq_num
                          , resource_seq_num
                          , organization_id
                          , start_date
                          , completion_date
                          , assigned_units
			  , l_WipOperResInst_tbl(mm)
                          , last_update_date
                          , last_updated_by
                          , creation_date
                          , created_by
                          , last_update_login
                          , request_id
                          , program_application_id
                          , program_id
                          , program_update_date
		    FROM  WIP_OPERATION_RESOURCE_USAGE
		   WHERE  wip_entity_id			= p_wip_entity_id
		     AND  organization_id		= p_organization_id
		     AND  operation_seq_num		= l_WipOperation_tbl(mm)
		     AND  resource_seq_num		= l_WipOperResource_tbl(mm)
		     AND  instance_id IS NULL;

		END LOOP;
	      END IF;


      -- Find the min start date and max end date of all
      -- constrained children for this parent

     -- find the list of constrained children
     IF NOT l_constrained_children%ISOPEN THEN
       OPEN l_constrained_children FOR
         select * from
         wip_sched_relationships
         where relationship_type = 1
         and parent_object_id = p_wip_entity_id
         and parent_object_type_id = 1;
     END IF;

      LOOP FETCH l_constrained_children into
		l_relationship_record;
		IF l_relationship_record.parent_object_id is not null then

			 select scheduled_start_date,scheduled_completion_date,status_type,date_completed
			  into l_start_date,l_compl_date,l_status_type,l_date_completed
			  from wip_discrete_jobs
			  where wip_entity_id = l_relationship_record.child_object_id
			  and organization_id = p_organization_id;

	--do not consider child workorders which are cancelled or [closed and date_completed is null](closed from cancelled status)
			       IF NOT(
			               l_status_type = 7
				       OR ((l_status_type IN (12,14,15)) AND (l_date_completed IS NULL))
				       ) THEN
						IF l_min_date is null OR
						l_min_date > l_start_date THEN
						  l_min_date := l_start_date;
						END IF;


						IF l_max_date is null OR
						l_max_date < l_compl_date THEN
						  l_max_date := l_compl_date;
						END IF;
				END IF;

		 END IF;

		 EXIT WHEN l_constrained_children%NOTFOUND;
      END LOOP;

      CLOSE l_constrained_children;


      select scheduled_start_date, scheduled_completion_date
        into l_wo_start_date, l_wo_end_date
        from wip_discrete_jobs
        where wip_entity_id = p_wip_entity_id
	and organization_id = p_organization_id;


      if l_wo_start_date > nvl(l_min_date,l_wo_start_date+1) then
          update wip_discrete_jobs set
          scheduled_start_date = l_min_date
          where wip_entity_id = p_wip_entity_id
          and organization_id = p_organization_id;
      end if;
      if l_wo_end_date < nvl(l_max_date,l_wo_end_date -1) then
        update wip_discrete_jobs set
          scheduled_completion_date = l_max_date
          where wip_entity_id = p_wip_entity_id
          and organization_id = p_organization_id;

      end if;

-- bug no 3444091
      select scheduled_start_date, scheduled_completion_date
        into l_wo_start_date, l_wo_end_date
        from wip_discrete_jobs
        where wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id;

	if l_wo_start_date > l_wo_end_date then
		x_return_status := fnd_api.g_ret_sts_error;
		fnd_message.set_name('EAM','EAM_WO_DT_ERR');
		fnd_message.set_token('RESNO', p_wip_entity_id);
		   IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Negative workorder duration') ; END IF ;
                return;
	end if;

--dbms_output.put_line('Inside Schedule WO, At the end');

--########## Commented out


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
    WHEN INVALID_PARAM_EXC THEN
       ROLLBACK TO SCHEDULE_WO;
       x_return_status := fnd_api.g_ret_sts_error;
       x_error_message := ' EAM_RTG_GET_INFO : Statement - '||l_stmt_num||' Invalid parameter - '||l_error_msg;
        IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Invalid parameter exception') ; END IF ;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO SCHEDULE_WO;
        x_return_status := fnd_api.g_ret_sts_error;
        x_error_message := ' EAM_RTG_GET_INFO : Statement - '||l_stmt_num||'No Calendar associated in Org parameters';
	 IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('No calendar associated in Org parameters') ; END IF ;
    WHEN OTHERS THEN
     ROLLBACK TO SCHEDULE_WO;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    x_error_message := ' EAM_RTG_GET_INFO : Statement - '||l_stmt_num||' Error Message - '||SQLERRM;
     IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Enters when others exception') ; END IF ;
  END;



END EAM_WO_SCHEDULE_PVT;

/
