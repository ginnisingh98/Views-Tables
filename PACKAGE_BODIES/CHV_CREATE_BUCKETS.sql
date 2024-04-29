--------------------------------------------------------
--  DDL for Package Body CHV_CREATE_BUCKETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_CREATE_BUCKETS" as
/* $Header: CHVCBKTB.pls 120.1.12010000.6 2013/08/20 11:00:14 shikapoo ship $*/
/*========================== CHV_CREATE_BUCKETS ==============================*/
/*=============================================================================

  PROCEDURE NAME:     create_bucket_template()

=============================================================================*/

PROCEDURE create_bucket_template(
			  p_horizon_start_date          IN      DATE,
			  p_include_future_release_flag IN      VARCHAR2,
                          p_bucket_pattern_id           IN      NUMBER,
			  p_horizon_end_date            OUT NOCOPY     DATE,
                          x_bucket_descriptor_table   IN  OUT NOCOPY     BKTTABLE,
                          x_bucket_start_date_table   IN  OUT NOCOPY     BKTTABLE,
			  x_bucket_end_date_table     IN  OUT NOCOPY     BKTTABLE) IS

  /*  Declare Program Variables */

  x_progress                        varchar2(3)  := NULL            ;
  x_week_start_day                  varchar2(25) ;
  x_day_count                       number  := 0 ;
  x_week_count                      number  := 0 ;
  x_month_count                     number  := 0 ;
  x_quarter_count                   number  := 0 ;

  x_bucket_start_date		    date    := p_horizon_start_date ;
  x_bucket_end_date 	  	    date    := p_horizon_start_date ;
  x_horizon_end_date                date         ;
  x_bucket_count                    number  := 1 ;

begin

  x_progress := '010' ;

  /* Select the bucket pattern from chv_bucket_patterns based on
  ** incoming parameter bucket_pattern_id including the week
  ** start day.
  ** We have to hardcode the date due to nls issue when using the next_day function. We have to use
  ** a known date to get the correct 3 char day in the current language.
  */

  SELECT decode(cbp.week_start_day,'1_MONDAY'    , to_char(to_date('31/01/2000','DD/MM/YYYY'),'DY'),
                                   '2_TUESDAY'   , to_char(to_date('01/02/2000','DD/MM/YYYY'),'DY'),
                                   '3_WEDNESDAY' , to_char(to_date('02/02/2000','DD/MM/YYYY'),'DY'),
                                   '4_THURSDAY'  , to_char(to_date('03/02/2000','DD/MM/YYYY'),'DY'),
                                   '5_FRIDAY'    , to_char(to_date('04/02/2000','DD/MM/YYYY'),'DY'),
                                   '6_SATURDAY'  , to_char(to_date('05/02/2000','DD/MM/YYYY'),'DY'),
                                   '7_SUNDAY'    , to_char(to_date('06/02/2000','DD/MM/YYYY'),'DY'),
                                                   to_char(to_date('31/01/2000','DD/MM/YYYY'),'DY')
               ),
         cbp.number_daily_buckets,
         cbp.number_weekly_buckets,
         cbp.number_monthly_buckets,
         cbp.number_quarterly_buckets
  INTO   x_week_start_day,
         x_day_count,
         x_week_count,
         x_month_count,
         x_quarter_count
  FROM   chv_bucket_patterns cbp
  WHERE  cbp.bucket_pattern_id = p_bucket_pattern_id;

  /* Creating a Past Due bucket with just the end date
  ** which is the day before the horizon start date.
  */

 x_bucket_descriptor_table(x_bucket_count)  := 'PAST_DUE'               ;
 x_bucket_start_date_table(x_bucket_count)  := null                     ;
 x_bucket_end_date_table(x_bucket_count)    := to_char(x_bucket_start_date - 1,'YYYY/MM/DD') ;
 x_bucket_count	      		            := x_bucket_count + 1       ;

 /* Create daily buckets only if the input parameter x_day_count is
 ** greater than 0.
 */

 if x_day_count > 0 then

    for i in 1..x_day_count loop

     x_bucket_descriptor_table(x_bucket_count)  := 'DAY'                   ;
     x_bucket_start_date_table(x_bucket_count)  := to_char(x_bucket_start_date,'YYYY/MM/DD') ;
     x_bucket_end_date_table(x_bucket_count)    := to_char(x_bucket_start_date,'YYYY/MM/DD') ;
     x_bucket_count                             := x_bucket_count + 1      ;
     x_bucket_end_date                          := x_bucket_start_date     ;
     x_bucket_start_date		        := x_bucket_start_date + 1 ;

    end loop ;

 end if ;

 /* Create the week bucket.  If the bucket being created does not start on the
 ** week_start_day specified for the organization schedule being created
 ** create a buffer bucket to fill the gap.
 */

 if x_week_count > 0 then

    if next_day(x_bucket_start_date,x_week_start_day)<>
               (x_bucket_start_date + 7)  then

    x_bucket_descriptor_table(x_bucket_count)   := 'BUFFER'                    ;
    x_bucket_start_date_table(x_bucket_count)   := to_char(x_bucket_start_date,'YYYY/MM/DD') ;
    x_bucket_end_date_table(x_bucket_count)     := to_char(next_day(x_bucket_start_date,x_week_start_day) - 1,'YYYY/MM/DD') ;
    x_bucket_start_date                         := next_day(x_bucket_start_date,x_week_start_day) ;
    x_bucket_end_date                           := next_day(x_bucket_start_date,x_week_start_day) ;
    x_bucket_count			        := x_bucket_count + 1          ;

  end if ;

    for i in 1..x_week_count loop

     x_bucket_descriptor_table(x_bucket_count)  := 'WEEK' ;
     x_bucket_start_date_table(x_bucket_count)  := to_char((x_bucket_start_date),'YYYY/MM/DD');
     x_bucket_end_date_table(x_bucket_count)    := to_char((x_bucket_start_date + 6),'YYYY/MM/DD');
     x_bucket_start_date                        := x_bucket_start_date + 7 ;
     x_bucket_end_date                          := x_bucket_start_date - 1 ;
     x_bucket_count			        := x_bucket_count + 1 ;

    end loop ;

  end if ;

 /* Create Month buckets.  If the previous bucket does not end on the last
 ** day of the month create a buffer bucket to fill the gap so that the
 ** month starts on the first of the calender month.
 */

 if x_month_count > 0 then

  if last_day(x_bucket_start_date - 1) - (x_bucket_start_date - 1)  <> 0 then

   x_bucket_descriptor_table(x_bucket_count)  := 'BUFFER'  ;
   x_bucket_start_date_table(x_bucket_count)  := to_char((x_bucket_start_date),'YYYY/MM/DD');
   x_bucket_end_date_table(x_bucket_count)    := to_char(last_day(x_bucket_start_date),'YYYY/MM/DD') ;
   x_bucket_start_date                        := last_day(x_bucket_start_date) + 1;
   x_bucket_end_date                          := last_day(x_bucket_start_date)  ;
   x_bucket_count			      := x_bucket_count + 1  ;

  end if ;

  for i in 1..x_month_count loop

   x_bucket_descriptor_table(x_bucket_count) := 'MONTH'  ;
   x_bucket_start_date_table(x_bucket_count) := to_char((x_bucket_start_date),'YYYY/MM/DD') ;
   x_bucket_end_date_table(x_bucket_count)   := to_char(last_day(x_bucket_start_date),'YYYY/MM/DD') ;
   x_bucket_start_date                       := last_day(x_bucket_start_date) + 1 ;
   x_bucket_end_date                         := x_bucket_start_date - 1 ;
   x_bucket_count			     := x_bucket_count + 1 ;

  end loop ;

 end if ;

 /* Create Quarter buckets.  If the previous bucket does not end on the last
 ** day of the month create a buffer bucket to fill the gap so that the
 ** quarter starts on the first of the calender month.
 */

 if x_quarter_count > 0 then

  if last_day(x_bucket_start_date-1) - (x_bucket_start_date-1)  <> 0 then

   x_bucket_descriptor_table(x_bucket_count) := 'BUFFER'                      ;
   x_bucket_start_date_table(x_bucket_count) := to_char((x_bucket_start_date),'YYYY/MM/DD') ;
   x_bucket_end_date_table(x_bucket_count)   := to_char(last_day(x_bucket_start_date),'YYYY/MM/DD') ;
   x_bucket_start_date			     := last_day(x_bucket_start_date) + 1 ;
   x_bucket_end_date			     := x_bucket_start_date - 1 ;
   x_bucket_count			     := x_bucket_count + 1            ;

  end if ;

  for i in 1..x_quarter_count loop

   x_bucket_descriptor_table(x_bucket_count) := 'QUARTER'                      ;
   x_bucket_start_date_table(x_bucket_count) := to_char(x_bucket_start_date,'YYYY/MM/DD') ;
   x_bucket_end_date_table(x_bucket_count)   := to_char(add_months((x_bucket_start_date-1),3),'YYYY/MM/DD') ;
   x_bucket_start_date			     := add_months(x_bucket_start_date,3) ;
   x_bucket_end_date                         := x_bucket_start_date - 1        ;
   x_bucket_count			     := x_bucket_count + 1             ;

  end loop ;

 end if ;

  /* Initializing the horizon end date to passed later to the calling
  ** program
  */

  /* Assign out parameters to pass to the calling program */

  p_horizon_end_date        := x_bucket_end_date ;

  /* Creating future release bucket if future release flag is Yes. */

 If p_include_future_release_flag = 'Y' then

  x_bucket_descriptor_table(x_bucket_count)   :=  'FUTURE' ;
  x_bucket_start_date_table(x_bucket_count)   :=  to_char((x_bucket_end_date + 1),'YYYY/MM/DD') ;
  x_bucket_end_date_table(x_bucket_count)     :=  null ;
  x_bucket_count                              :=  x_bucket_count + 1 ;

 end if ;

 /* Initializing the rest of the 110 buckets to null.
 ** This has to be done because the insert_buckets program will fail
 ** since the PL/SQL tables are transposed into a record and a hard code
 ** insert is done.
 */

 for i in x_bucket_count..60 loop

     x_bucket_descriptor_table(x_bucket_count)   := null ;
     x_bucket_start_date_table(x_bucket_count)   := null ;
     x_bucket_end_date_table(x_bucket_count)     := null ;
     x_bucket_count                              := x_bucket_count + 1 ;

 end loop ;


exception
  when others then
       po_message_s.sql_error('Insert_Row', X_progress, sqlcode);
       raise;

END create_bucket_template ;

/*=============================================================================

  PROCEDURE NAME:     load_horizontal_schedules()

=============================================================================*/

PROCEDURE load_horizontal_schedules(
                         p_schedule_id             IN      NUMBER,
                         p_schedule_item_id        IN      NUMBER,
                         p_row_select_order        IN      NUMBER,
    		         p_row_type                IN      VARCHAR2,
		         p_bucket_table            IN      BKTTABLE) IS

  x_progress             varchar2(3)  := NULL ;
  x_last_updated_by      NUMBER ;
  x_login_id             NUMBER ;

begin

     x_login_id        :=  fnd_global.login_id ;
     x_last_updated_by := fnd_global.user_id ;

     x_progress := '010' ;

    /* Insert the record type into the table */

    insert into chv_horizontal_schedules
                     (SCHEDULE_ID,
                      SCHEDULE_ITEM_ID,
                      ROW_SELECT_ORDER,
                      ROW_TYPE,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      COLUMN1,
                      COLUMN2,
                      COLUMN3,
                      COLUMN4,
                      COLUMN5,
                      COLUMN6,
                      COLUMN7,
                      COLUMN8,
                      COLUMN9,
                      COLUMN10,
                      COLUMN11,
                      COLUMN12,
                      COLUMN13,
                      COLUMN14,
                      COLUMN15,
                      COLUMN16,
                      COLUMN17,
                      COLUMN18,
                      COLUMN19,
                      COLUMN20,
                      COLUMN21,
                      COLUMN22,
                      COLUMN23,
                      COLUMN24,
                      COLUMN25,
                      COLUMN26,
                      COLUMN27,
                      COLUMN28,
                      COLUMN29,
                      COLUMN30,
                      COLUMN31,
                      COLUMN32,
                      COLUMN33,
                      COLUMN34,
                      COLUMN35,
                      COLUMN36,
                      COLUMN37,
                      COLUMN38,
                      COLUMN39,
                      COLUMN40,
                      COLUMN41,
                      COLUMN42,
                      COLUMN43,
                      COLUMN44,
                      COLUMN45,
                      COLUMN46,
                      COLUMN47,
                      COLUMN48,
                      COLUMN49,
                      COLUMN50,
                      COLUMN51,
                      COLUMN52,
                      COLUMN53,
                      COLUMN54,
                      COLUMN55,
                      COLUMN56,
                      COLUMN57,
                      COLUMN58,
                      COLUMN59,
                      COLUMN60,
                      LAST_UPDATE_LOGIN,
                      REQUEST_ID,
                      PROGRAM_APPLICATION_ID,
                      PROGRAM_ID,
                      PROGRAM_UPDATE_DATE)
               VALUES(p_schedule_id,
					  p_schedule_item_id,
					  p_row_select_order,
					  p_row_type,
					  sysdate,
					  x_last_updated_by,
					  sysdate,
					  x_last_updated_by,
					  p_bucket_table(1),
					  p_bucket_table(2),
					  p_bucket_table(3),
					  p_bucket_table(4),
					  p_bucket_table(5),
					  p_bucket_table(6),
					  p_bucket_table(7),
					  p_bucket_table(8),
					  p_bucket_table(9),
					  p_bucket_table(10),
					  p_bucket_table(11),
					  p_bucket_table(12),
					  p_bucket_table(13),
					  p_bucket_table(14),
					  p_bucket_table(15),
					  p_bucket_table(16),
					  p_bucket_table(17),
					  p_bucket_table(18),
					  p_bucket_table(19),
					  p_bucket_table(20),
					  p_bucket_table(21),
					  p_bucket_table(22),
					  p_bucket_table(23),
					  p_bucket_table(24),
					  p_bucket_table(25),
					  p_bucket_table(26),
					  p_bucket_table(27),
					  p_bucket_table(28),
					  p_bucket_table(29),
					  p_bucket_table(30),
					  p_bucket_table(31),
					  p_bucket_table(32),
					  p_bucket_table(33),
					  p_bucket_table(34),
					  p_bucket_table(35),
					  p_bucket_table(36),
					  p_bucket_table(37),
					  p_bucket_table(38),
					  p_bucket_table(39),
					  p_bucket_table(40),
					  p_bucket_table(41),
					  p_bucket_table(42),
					  p_bucket_table(43),
					  p_bucket_table(44),
					  p_bucket_table(45),
					  p_bucket_table(46),
					  p_bucket_table(47),
					  p_bucket_table(48),
					  p_bucket_table(49),
					  p_bucket_table(50),
					  p_bucket_table(51),
					  p_bucket_table(52),
					  p_bucket_table(53),
					  p_bucket_table(54),
					  p_bucket_table(55),
					  p_bucket_table(56),
					  p_bucket_table(57),
					  p_bucket_table(58),
					  p_bucket_table(59),
					  p_bucket_table(60),
					  x_login_id,
					  null,
					  null,
					  null,
					  null ) ;
exception
  when others then
       po_message_s.sql_error('Insert_Row', X_progress, sqlcode);
       raise;

END load_horizontal_schedules ;
/*=============================================================================

  PROCEDURE NAME:     calculate_bucket_qty()

=============================================================================*/
PROCEDURE calculate_buckets(p_schedule_id               IN     NUMBER,
			    p_schedule_item_id	        IN     NUMBER,
			    p_horizon_start_date        IN     DATE,
			    p_horizon_end_date          IN     DATE,
                            p_schedule_type             IN     VARCHAR2,
			    p_cum_enable_flag           IN     VARCHAR2,
			    p_cum_quantity_received     IN     NUMBER,
                            p_bucket_descriptor_table   IN     BKTTABLE,
			    p_bucket_start_date_table   IN     BKTTABLE,
                            p_bucket_end_date_table     IN     BKTTABLE,
                            p_past_due_qty              OUT NOCOPY    NUMBER,
			    p_past_due_qty_primary      OUT NOCOPY    NUMBER
                           ) IS

  /* Declaring Program Variables */

  x_release_quantity_table    bkttable       ;
  x_forecast_quantity_table   bkttable       ;
  x_cum_quantity_table        bkttable       ;
  x_total_quantity_table      bkttable       ;

  x_bucket_count              number    := 0 ;
  x_forecast_quantity         number    := 0 ;
  x_total_forecast_qty        number    := 0 ;
  x_release_quantity          number    := 0 ;
  x_total_release_qty         number    := 0 ;
  x_release_quantity_primary  number    := 0 ;

  x_row_select_order          number         ;
  x_row_type                  varchar2(25)   ;
  x_progress                  varchar2(25)   ;

BEGIN

  x_progress := '010' ;

  for i in 1..60 loop

    x_bucket_count       := x_bucket_count + 1 ;
    x_forecast_quantity  := 0 ;
    x_release_quantity   := 0 ;

    if p_bucket_descriptor_table(x_bucket_count) = 'PAST_DUE' then

      /* Calculate Past Due Bucket Quantity by selecting
      ** total ORDER_QUANTITY from CHV_ITEM_ORDERS
      ** based on the due_date.
      */

      begin

        x_progress := '020'  ;

        select nvl(sum(round(cio.order_quantity,5)),0),
	       nvl(sum(round(cio.order_quantity_primary,5)),0)
        into   x_release_quantity,
               x_release_quantity_primary
        from   chv_item_orders cio
        where  cio.schedule_id      = p_schedule_id
        and    cio.schedule_item_id = p_schedule_item_id
        and    cio.supply_document_type = 'RELEASE'
        and    trunc(cio.due_date) <= to_date(p_bucket_end_date_table(x_bucket_count),'YYYY/MM/DD') ;

      exception when no_data_found then null ;
      end ;

      x_release_quantity_table(x_bucket_count)  := x_release_quantity ;
      x_forecast_quantity_table(x_bucket_count) := 0 ;
      x_total_quantity_table(x_bucket_count)    := x_release_quantity ;
      x_total_release_qty                       := x_release_quantity ;
      p_past_due_qty                            := x_release_quantity ;
      p_past_due_qty_primary                    := x_release_quantity_primary ;

    elsif p_bucket_descriptor_table(x_bucket_count) in ('DAY','BUFFER','WEEK','MONTH',
					   'QUARTER') then

      /* Calculate Bucket Firm and Forecast Quantity by selecting
      ** total ORDER_QUANTITY from CHV_ITEM_ORDERS
      ** based on the due_date.
      */

      begin

        x_progress := '030'  ;

        /* Selecting forecast quantities from chv_item_orders
        ** for the scheduled_item.
        */

        select nvl(sum(round(cio.order_quantity,5)),0)
        into   x_forecast_quantity
        from   chv_item_orders cio
        where  cio.schedule_id      = p_schedule_id
        and    cio.schedule_item_id = p_schedule_item_id
        and   ((p_schedule_type = 'FORECAST_ALL_DOCUMENTS'
                and cio.supply_document_type in ('RELEASE','PLANNED_ORDER','REQUISITION')
                and trunc(cio.due_date) between to_date(p_bucket_start_date_table(x_bucket_count),'YYYY/MM/DD')
                                     and to_date(p_bucket_end_date_table(x_bucket_count),'YYYY/MM/DD') )
                OR
               (p_schedule_type in ('FORECAST_ONLY','MATERIAL_RELEASE','RELEASE_WITH_FORECAST')
                and cio.supply_document_type in ('PLANNED_ORDER','REQUISITION')
                and trunc(cio.due_date) between to_date(p_bucket_start_date_table(x_bucket_count),'YYYY/MM/DD')
                                     and to_date(p_bucket_end_date_table(x_bucket_count),'YYYY/MM/DD') )
              ) ;

      exception when no_data_found then null ;
      end ;

      x_forecast_quantity_table(x_bucket_count) := x_forecast_quantity ;
      x_total_forecast_qty                      := x_total_forecast_qty + x_forecast_quantity ;

      begin

        x_progress := '040'  ;

        /* Selecting release quantities from chv_item_orders
        ** for the scheduled_item.
        */

        select nvl(sum(round(cio.order_quantity,5)),0)
        into   x_release_quantity
        from   chv_item_orders cio
        where  cio.schedule_id      = p_schedule_id
        and    cio.schedule_item_id = p_schedule_item_id
        and  p_schedule_type in ('RELEASE_ONLY','MATERIAL_RELEASE','RELEASE_WITH_FORECAST')
             and cio.supply_document_type = 'RELEASE'
             and trunc(cio.due_date) between to_date(p_bucket_start_date_table(x_bucket_count),'YYYY/MM/DD')
                                  and to_date(p_bucket_end_date_table(x_bucket_count),'YYYY/MM/DD') ;

      exception when no_data_found then null ;
      end ;

      x_release_quantity_table(x_bucket_count) := x_release_quantity ;
      x_total_release_qty                      := x_total_release_qty + x_release_quantity ;
      x_total_quantity_table(x_bucket_count)   := x_release_quantity + x_forecast_quantity ;

     elsif p_bucket_descriptor_table(x_bucket_count) = 'FUTURE' then

       /* Select all future releases from CHV_ITEM_ORDERS for the future
       ** release bucket.
       */

       begin

         x_progress := '050'  ;

         select nvl(sum(round(cio.order_quantity,5)),0)
         into   x_release_quantity
         from   chv_item_orders cio
         where  cio.schedule_id      = p_schedule_id
         and    cio.schedule_item_id = p_schedule_item_id
         and    cio.supply_document_type = 'RELEASE'
         and    trunc(cio.due_date) > to_date(p_bucket_start_date_table(x_bucket_count),'YYYY/MM/DD') ;

       exception when no_data_found then null ;
       end ;

       x_release_quantity_table(x_bucket_count)  := x_release_quantity ;
       x_forecast_quantity_table(x_bucket_count) := 0 ;
       x_total_release_qty                      := x_total_release_qty + x_release_quantity ;
       x_total_quantity_table(x_bucket_count)   := x_release_quantity ;

    else

       /* No value in the bucket descriptor initialize to null */

       x_release_quantity_table(x_bucket_count)  := null ;
       x_forecast_quantity_table(x_bucket_count) := null ;
       x_total_quantity_table(x_bucket_count)    := null ;

    end if ;

     /* Initialize CUM quantity Bucket. */
/*Bug2028705
  Rounding the cumulative quantity to 5 similar to (standards for rounding)
  the ones in the rest of the supplier scheduling code for quantity.
*/
     if  p_bucket_descriptor_table(x_bucket_count) is not null then

        x_cum_quantity_table(x_bucket_count) := to_char(round(nvl(x_total_release_qty,0) +
						        nvl(x_total_forecast_qty,0) +
                                                        nvl(p_cum_quantity_received,0)
						       ,5)) ;
     else

        x_cum_quantity_table(x_bucket_count) := null ;

     end if ;

   end loop ;

   /* Initialize row_select_order and row_type and call stored
   ** procedure insert_buckets by passing the appropriate PL/SQL table
   ** to insert the record into CHV_HORIZONTAL_SCHEDULES
   */

   x_row_select_order := 1 ;
   x_row_type         := 'BUCKET_DESCRIPTOR' ;
   chv_create_buckets.load_horizontal_schedules(p_schedule_id             ,
			                        p_schedule_item_id        ,
			                        x_row_select_order        ,
			                        x_row_type                ,
			                        p_bucket_descriptor_table ) ;

   x_row_select_order := 2 ;
   x_row_type         := 'BUCKET_START_DATE' ;
   chv_create_buckets.load_horizontal_schedules(p_schedule_id             ,
			                        p_schedule_item_id        ,
			                        x_row_select_order        ,
			                        x_row_type                ,
			                        p_bucket_start_date_table ) ;

   x_row_select_order := 3 ;
   x_row_type         := 'RELEASE_QUANTITY' ;
   chv_create_buckets.load_horizontal_schedules(p_schedule_id             ,
			                        p_schedule_item_id        ,
			                        x_row_select_order        ,
			                        x_row_type                ,
			                        x_release_quantity_table  ) ;

   x_row_select_order := 4 ;
   x_row_type         := 'FORECAST_QUANTITY' ;
   chv_create_buckets.load_horizontal_schedules(p_schedule_id             ,
			                        p_schedule_item_id        ,
			                        x_row_select_order        ,
			                        x_row_type                ,
			                        x_forecast_quantity_table ) ;
   x_row_select_order := 5 ;
   x_row_type         := 'TOTAL_QUANTITY' ;
   chv_create_buckets.load_horizontal_schedules(p_schedule_id             ,
			                        p_schedule_item_id        ,
			                        x_row_select_order        ,
			                        x_row_type                ,
			                        x_total_quantity_table    ) ;

      x_row_select_order := 6 ;
      x_row_type         := 'CUM_QUANTITY' ;
      chv_create_buckets.load_horizontal_schedules(p_schedule_id          ,
    			                           p_schedule_item_id     ,
			                           x_row_select_order     ,
			                           x_row_type             ,
			                           x_cum_quantity_table   ) ;

   x_row_select_order := 7 ;
   x_row_type         := 'BUCKET_END_DATE' ;
   chv_create_buckets.load_horizontal_schedules(p_schedule_id             ,
			                        p_schedule_item_id        ,
			                        x_row_select_order        ,
			                        x_row_type                ,
			                        p_bucket_end_date_table   ) ;
exception
  when others then
       po_message_s.sql_error('calculate_bucket_qty', X_progress, sqlcode);
       raise;

END calculate_buckets ;

END CHV_CREATE_BUCKETS  ;

/
