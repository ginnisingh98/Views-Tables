--------------------------------------------------------
--  DDL for Package Body GMP_RSRC_AVL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_RSRC_AVL_PKG" as
/* $Header: GMPAVLB.pls 120.2.12010000.3 2008/12/30 06:28:08 vpedarla ship $ */

G_PKG_NAME  varchar2(32);

TYPE cal_shift_typ is RECORD
( cal_date      DATE,
  shift_num     NUMBER,
  cal_from_date DATE,
  cal_to_date   DATE
);
calendar_record  cal_shift_typ;
TYPE cal_tab is table of cal_shift_typ index by BINARY_INTEGER;

cal_rec  cal_tab;

/*  New changes for Unavailable Resources - 12/14/00 */
TYPE unavail_rsrc_typ is RECORD
(
  resource_count NUMBER,
  u_from_date    DATE,
  u_to_date      DATE
);
unavail_resource_record  unavail_rsrc_typ;
TYPE unavail_rsrc_tab is table of unavail_rsrc_typ index by BINARY_INTEGER;

unavail_rec  unavail_rsrc_tab;
new_unavail_rec   unavail_rsrc_tab;

v_resource_id     NUMBER;
v_shift_num       NUMBER;
v_unavail_qty     NUMBER;
v_assigned_qty    NUMBER := 0;
v_calendar_date   DATE;
v_from_date       DATE;
v_to_date         DATE;
qty_null          EXCEPTION;
date_null         EXCEPTION;
v_from_time       DATE;
v_to_time         DATE;
l_organization_id NUMBER;
l_calendar_code   VARCHAR2(10) ;
c                 INTEGER := 0;
u                 INTEGER ;
u1                INTEGER := 1;
x                 INTEGER := 1;
i                 INTEGER := 1;
j                 INTEGER := 1;
tur               NUMBER := 0;
stmt_no           NUMBER := 0;
update_flag       VARCHAR2(1) := 'N';
NO_EXCP           VARCHAR2(1) := '';
NO_NO_EXCP        VARCHAR2(1) := '';
unavail_from_date DATE;
unavail_to_date   DATE;
temp_from_time    DATE;
temp_date         VARCHAR2(26) ;
v_cp_enabled      BOOLEAN := TRUE;

PROCEDURE log_message ( string IN VARCHAR2) IS
  loop_var INTEGER;
BEGIN
  IF v_cp_enabled THEN
    FND_FILE.PUT_LINE (FND_FILE.LOG, string);
  ELSE
    NULL;
  END IF;
END log_message;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    rsrc_avl                                                             |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Private                                                              |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This Procedure will find out the Available Time per Resource and     |
REM|    Calendar code assicatied  resource or organization level             |
REM| HISTROY                                                                 |
REM|    Rajesh Patangya created                                              |
REM|    B4999940 Use of BOM Calendar,Inventory Convergence                   |
REM+=========================================================================+
*/
PROCEDURE rsrc_avl(
                    p_api_version        IN NUMBER,
                    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
                    p_cal_code           IN VARCHAR2,   -- B4999940
                    p_resource_id        IN NUMBER,
                    p_from_date          IN DATE,
                    p_to_date            IN DATE,
                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2,
                    x_return_code        OUT NOCOPY VARCHAR2,
                    p_rec                IN OUT NOCOPY cal_tab2,
                    p_flag               IN OUT NOCOPY VARCHAR2
                    ) is
/* Local Variables for API */
gmp_api_name  varchar2(30) := 'rsrc_avl';
gmp_api_version    number := 1.0;


CURSOR cal_c1 IS
SELECT cdate,shift_no,
decode(sign(ftime - p_from_date),-1,p_from_date,ftime) from_time,
decode(sign(ttime - v_to_time),-1,ttime,v_to_time) to_time
FROM
(
       SELECT bsd.shift_date cdate,
       bsd.shift_num shift_no,
       (bsd.shift_date + (bst.from_time/86400)) ftime,
       (bsd.shift_date + (bst.to_time/86400)) ttime
       FROM   bom_calendars bc,
              bom_shift_dates bsd,
              bom_shift_times bst
       WHERE bsd.calendar_code = bc.calendar_code
         AND bst.calendar_code = bsd.calendar_code
         AND bsd.shift_num = bst.shift_num
         AND bsd.seq_num is not null
         AND bc.calendar_code = p_cal_code
)
WHERE 1= 1
  AND (
      (ftime between p_from_date and v_to_time)
      OR
      (ttime between p_from_date and v_to_time)
      )
ORDER BY cdate,from_time ;

CURSOR unavail_c2 IS
SELECT resource_units,
decode(sign(from_date - p_from_date),-1,p_from_date,from_date) from_time,
decode(sign(to_date - v_to_time),-1,to_date,v_to_time) to_time
FROM gmp_rsrc_unavail_dtl_v
WHERE resource_id = p_resource_id
AND
(
(from_date between p_from_date and v_to_time)
OR
(to_date between p_from_date and v_to_time)
)
ORDER BY from_time;

CURSOR qty_c3 IS
SELECT assigned_qty FROM cr_rsrc_dtl
WHERE resource_id = p_resource_id;

c                 INTEGER := 0;
u                 INTEGER ;
u1                INTEGER := 1;
x                 INTEGER := 1;
i                 INTEGER := 1;
j                 INTEGER := 1;
tur               NUMBER := 0;
stmt_no           NUMBER := 0;

BEGIN

/* New Lines Added for API Standards */
    IF NOT FND_API.compatible_api_call(gmp_api_version,
                                       p_api_version,
                                       gmp_api_name,
                                       G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;
--
    p_flag := 'Y' ;

    IF ((p_from_date is NULL) OR (p_to_date is NULL))
    THEN
        p_flag := 'N';
        raise date_null;
    END IF;
--
    SELECT to_char(p_to_date,'HH24:MI:SS')
    INTO temp_date
    FROM DUAL ;
--
    /* B2992029 - Fix for Gantt Chart query for Resource Availability */
    IF temp_date = '00:00:00' THEN
   /* 21-NOV-2003 B3267633 - RESOURCE AVAILABILITY SHOWING AS ZERO IN OPM
       SCHEDULER WORKBENCH */
       v_to_time :=
       to_date((substrb(to_char(p_to_date,'DD/MM/YYYY'),1,11)||' 23:59:59'),
                'DD/MM/YYYY HH24:MI:SS');
    ELSE
        v_to_time :=  p_to_date ;
    END IF ;
--
     OPEN qty_c3;
     FETCH qty_c3 INTO v_assigned_qty;
     if v_assigned_qty = 0
     then
         p_flag := 'N' ;
         raise qty_null;
     end if;
--
     CLOSE qty_c3;

     stmt_no := 10;
     /* If Pl/SQL Tbl cal_rec  has any residual rows,
        we Need to clean before populating the
        New Table  */

        if cal_rec.COUNT > 0
        then
           cal_rec.delete;
        end if;
--
      /* Delete the Unavailable PL/SQL table before start */
        if unavail_rec.COUNT > 0
        then
           unavail_rec.delete;
        end if;
--
      /* Delete the Out Cal Rec PL/SQL table before start */
        if p_rec.COUNT > 0
        then
           p_rec.delete;
        end if;

     /* Open the Calendar Cursor */
     stmt_no := 15;
     OPEN cal_c1;

     IF cal_c1%NOTFOUND THEN
        RAISE fnd_api.g_exc_error;
     END IF;

     loop
        FETCH cal_c1 INTO  calendar_record;
        EXIT WHEN cal_c1%NOTFOUND;

        cal_rec(i).cal_date := calendar_record.cal_date ;
        cal_rec(i).shift_num := calendar_record.shift_num ;
        cal_rec(i).cal_from_date := calendar_record.cal_from_date;
        cal_rec(i).cal_to_date := calendar_record.cal_to_date;

          -- Bug: 7556621 Vpedarla For shifts going over 12 AM , the to date from bom tables
          --      is showing the same date. So, Have to added a day to the date keeping the timestamp same
        IF ( cal_rec(i).cal_to_date < cal_rec(i).cal_from_date ) THEN
              cal_rec(i).cal_to_date :=  cal_rec(i).cal_to_date +1 ;
        END IF;
        i := i + 1;
     end loop;
     CLOSE cal_c1;

     /* OPEN Unavailable Cursor */
     OPEN unavail_c2;

     IF unavail_c2%NOTFOUND THEN
        RAISE fnd_api.g_exc_error;
     END IF;

     loop
          FETCH unavail_c2 INTO unavail_resource_record;
          EXIT WHEN unavail_c2%NOTFOUND;

	  unavail_rec(x).resource_count :=
                    unavail_resource_record.resource_count;
          unavail_rec(x).u_from_date :=
                    unavail_resource_record.u_from_date;
          unavail_rec(x).u_to_date :=
                    unavail_resource_record.u_to_date;
          x := x + 1;
     end loop;
     tur := unavail_rec.COUNT;
     CLOSE unavail_c2;
--
     if (tur = 0)
     then
         /* No exceptions , thus raise the flag so and code at the
            end of this package will do the necessary inserts */
         NO_NO_EXCP := 'Y' ;
     end if;
--
/* ===================================
   Brief Logic is as follows
     Loop through Calendars (cal_rec)
       For each calendar record
       Loop through unavailable_time_tbl
          Insert the resultant into Out Tbl Which is a PL/SQL table
       end loop;
     End Loop;

================================= */
  stmt_no := 20;

    FOR c in 1..cal_rec.COUNT
    LOOP
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       IF NO_NO_EXCP = 'Y' THEN
          EXIT ;
       END IF  ;
       NO_EXCP := 'N';

       FOR u in u1..unavail_rec.COUNT
        /* { Loop for unavailable */
       LOOP
          /* A flag is set if it find that the unavailable resource id
             is greater than the resource id coming from the resource
             rec that means this resource has no exception and it can
             skip all the calculations and gets directly inserted into
             the ST table - The assumption is that the resource ids
             will be coming in the same order in the Unvailable Cursor
             and the resources cursor - This is taken care in both the
             Cursors */

             /* {  ==A==
              Now check if the Cal date from time is less than Unavailable
              from time - Here the comparisons are made with both date
              and Time
             */
            IF (cal_rec(c).cal_from_date <= unavail_rec(u).u_from_date)
            THEN

              /* If the calendar from time is Yes, then check if the
                 Calendar end time is greater than unavailable from time
              */
              IF /* { Special 1 */
                 (cal_rec(c).cal_to_date > unavail_rec(u).u_from_date)
              THEN
                  /* {
                   Check if the Calendar to time is Less than Unavailable
                   to date
                  */
                IF /* == A 2 and A3 */
                   (cal_rec(c).cal_to_date <= unavail_rec(u).u_to_date)
                THEN
                    /* shorten the shift (remaining shift is consumed)
                       and insert the record */

                    stmt_no := 30;
                    p_rec(j).out_resource_count := v_assigned_qty;
                    p_rec(j).out_shift_num := cal_rec(c).shift_num;
                    p_rec(j).out_cal_date := cal_rec(c).cal_date;
                    p_rec(j).out_cal_from_date := cal_rec(c).cal_from_date;
                    p_rec(j).out_cal_to_date := unavail_rec(u).u_from_date;

                    -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursor
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
               --     p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                    j := j + 1;
--
                    stmt_no := 31;
                   IF (v_assigned_qty - unavail_rec(u).resource_count > 0 ) THEN
                    p_rec(j).out_resource_count :=
                         v_assigned_qty - unavail_rec(u).resource_count;
                    p_rec(j).out_shift_num := cal_rec(c).shift_num;
                    p_rec(j).out_cal_date := cal_rec(c).cal_date;
                    p_rec(j).out_cal_from_date := unavail_rec(u).u_from_date;
                    p_rec(j).out_cal_to_date := cal_rec(c).cal_to_date;

                 -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursor
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                --    p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                    j := j + 1;
                    END IF ;
--
                   /* Store the existing position of unavailable counter
                      This is helpful in looping from the same place where
                      we left from in the unavailable rec
                   */
                    u1 := u ;

                    EXIT; /* Exit the Unavailable rec loop and come with
                             the next cal date */

                ELSIF /* == A 1 , if the Cal date to time is greater
                        than Unavailable to time */
                     (cal_rec(c).cal_to_date > unavail_rec(u).u_to_date)
                THEN
                     /* Break the shift and insert firt record */
                     /* Assign new values to start and end times of
                        the cal_rec shift */
                     /* preserve the counter u into u1 */
                     /* As you continue to loop check resource_id */

                     /* Break the shift and insert first record */

                    stmt_no := 40;
                    p_rec(j).out_resource_count := v_assigned_qty;
                    p_rec(j).out_shift_num := cal_rec(c).shift_num;
                    p_rec(j).out_cal_date := cal_rec(c).cal_date;
                    p_rec(j).out_cal_from_date := cal_rec(c).cal_from_date;
                    p_rec(j).out_cal_to_date := unavail_rec(u).u_from_date;

                    -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursore
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                --    p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                    j := j + 1;
--
                    stmt_no := 41;
                   IF (v_assigned_qty - unavail_rec(u).resource_count > 0 ) THEN
                    p_rec(j).out_resource_count :=
                         v_assigned_qty - unavail_rec(u).resource_count;
                    p_rec(j).out_shift_num := cal_rec(c).shift_num;
                    p_rec(j).out_cal_date := cal_rec(c).cal_date;
                    p_rec(j).out_cal_from_date := unavail_rec(u).u_from_date;
                    p_rec(j).out_cal_to_date := unavail_rec(u).u_to_date;

                    -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursore
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                --    p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                    j := j + 1;
                    END IF ;
--
                     /* Assign New Values to the start time of cal_rec  */
                    /* !!!!!!!! WATCH THIS !!!!!!! */
                      /* Since we are updating one of the fields in
                         the calendar table, that is the calendar from
                         time, this piece of code is written to help
                         avoid writing the changed value of cal_rec.from_time
                         at all other places for different resource ids
                      */
                     IF update_flag = 'N' THEN
                        update_flag := 'Y' ;
         		temp_from_time := cal_rec(c).cal_from_date;
                     END IF ;
                     cal_rec(c).cal_from_date := unavail_rec(u).u_to_date;

                     /* preserve the counter u into u1 */
                        /* u1 := u + 1; */
                        u1 := u ;
                END IF ; /* } A2 and  A3  and A1 also */
              ELSE   /* Else for Special 1 */

                  stmt_no := 50;
                  /* Calendar time finishes before the Unavailable Period */
                  p_rec(j).out_resource_count := v_assigned_qty;
                  p_rec(j).out_shift_num := cal_rec(c).shift_num;
                  p_rec(j).out_cal_date := cal_rec(c).cal_date;
                  p_rec(j).out_cal_from_date := cal_rec(c).cal_from_date;
                  p_rec(j).out_cal_to_date := cal_rec(c).cal_to_date;

                  -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursore
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                --    p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                  j := j + 1;
--
--
                 /* Call the Insert Procedure */
                        u1 := u ;
                  EXIT ;
              END IF ; /* } For special 1, that is cal from time
                           is less than unavailable from time */

            /* ===== B ===== Special 2 , Cal from time
               is greater than Unavailable from time */

            ELSIF (unavail_rec(u).u_to_date > cal_rec(c).cal_from_date )
            THEN
                   /* ===== B1 =====
                   { Calendar End time is greater than Unavailable
                   End time */

               IF (cal_rec(c).cal_to_date > unavail_rec(u).u_to_date)
               THEN
                    /* Shorten the shift and loop through unavailable
                       records Do NOT write the record yet as there may be
                       another unavaialable record consuming into this
                       shift */
                    /* !!!!!!!! WATCH THIS !!!!!!! */
                      /* Since we are updating one of the fields in
                         the calendar table, that is the calendar from
                         time, this piece of code is written to help
                         avoid writing the changed value of cal_rec.from_time
                         at all other places for different resource ids
                      */
                     IF (v_assigned_qty - unavail_rec(u).resource_count ) > 0
                     THEN
                     p_rec(j).out_resource_count :=
                        v_assigned_qty - unavail_rec(u).resource_count;
                     p_rec(j).out_shift_num := cal_rec(c).shift_num;
                     p_rec(j).out_cal_date := cal_rec(c).cal_date;
                     p_rec(j).out_cal_from_date := cal_rec(c).cal_from_date;
                     p_rec(j).out_cal_to_date := unavail_rec(u).u_to_date;

                -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursore
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                --    p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                     j := j + 1;
                     END IF ;
--
                      IF update_flag = 'N' THEN
         	        update_flag := 'Y' ;
		        temp_from_time := cal_rec(c).cal_from_date ;
                      END IF ;
                      cal_rec(c).cal_from_date := unavail_rec(u).u_to_date;
--
                      /* continue looping in  unavailble loop */
               ELSIF
                     /* ===== B 2 and 3 ===== */
                    (cal_rec(c).cal_to_date <= unavail_rec(u).u_to_date)
               THEN
                   /* The shift is consumed , increase the counters for both
                                    the loops */
--                       p_flag := 'Y';
--                   log_message('Shift is Completely Consumed ');
--
                     IF (v_assigned_qty - unavail_rec(u).resource_count ) > 0
                     THEN
                     p_rec(j).out_resource_count :=
                        v_assigned_qty - unavail_rec(u).resource_count;
                     p_rec(j).out_shift_num := cal_rec(c).shift_num;
                     p_rec(j).out_cal_date := cal_rec(c).cal_date;
                     p_rec(j).out_cal_from_date := cal_rec(c).cal_from_date;
                     p_rec(j).out_cal_to_date := cal_rec(c).cal_to_date;

                     -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursore
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                --    p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                     j := j + 1;
                     END IF ;
--
                       IF (cal_rec(c).cal_to_date = unavail_rec(u).u_to_date)
                       THEN
		       --bug6489270 kbanddyo
                           cal_rec(c).cal_from_date := unavail_rec(u).u_to_date;
                           u1 := u + 1;
                       ELSE
                           u1 := u ;
                       END IF ;
                       EXIT ;
                       /* Exits out of the Unavailable loop and increases the
                               Calendar loop count */
               END IF ;  /* } */
            END IF  ;  /* } End If for Cal from time , Unavailable from date */

--          END IF ; /*  } resource id matching if */

          /* This is to Set the flag when the counter for Unavailable exceeds
             the Unavaible rec count
          */
          u1 := u ;
          IF u1 >= unavail_rec.COUNT THEN
             NO_EXCP := 'Y' ;
          END IF ;

       END LOOP ; /* } End loop for  unavail_rec */

       --bug6489270 kbanddyo added the following if condition
        IF u1 > unavail_rec.COUNT THEN
           NO_EXCP := 'Y' ;
       END IF ;

       IF NO_EXCP = 'Y'
       THEN
          /* Insert into PL/SQL TABLE while looping through the cal_rec
             from current position onwards */
          /* c := c + 1 ; */
          For i in c..cal_rec.COUNT
          LOOP
                    stmt_no := 60;
                 p_rec(j).out_resource_count := v_assigned_qty ;
                 p_rec(j).out_shift_num := cal_rec(i).shift_num;
                 p_rec(j).out_cal_date := cal_rec(i).cal_date;
                 p_rec(j).out_cal_from_date := cal_rec(i).cal_from_date;
                 p_rec(j).out_cal_to_date := cal_rec(i).cal_to_date;

                 -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursore
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                --    p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
--                    p_flag := 'N';
                 j := j + 1;
--
          END LOOP ;

	  IF update_flag = 'Y'
          THEN
	      cal_rec(c).cal_from_date := temp_from_time ;
	      update_flag := 'N';
	  END IF ;
          EXIT ; /* Exit calendar loop so as to go to next rsrc */
       END IF ; /* End if for EXCP Flag */

       /* Original value of  cal_rec.from time is written back here
          for other resources
       */
       IF update_flag = 'Y'
       THEN
          cal_rec(c).cal_from_date := temp_from_time ;
          update_flag := 'N';
       END IF ;
    END LOOP; /* End loop for cal_rec i.e. calendar records */

    IF NO_NO_EXCP = 'Y'
    THEN
       For i in 1..cal_rec.COUNT
       LOOP
                    stmt_no := 70;
                 p_rec(j).out_resource_count := v_assigned_qty ;
                 p_rec(j).out_shift_num := cal_rec(i).shift_num;
                 p_rec(j).out_cal_date := cal_rec(i).cal_date;
                 p_rec(j).out_cal_from_date := cal_rec(i).cal_from_date;
                 p_rec(j).out_cal_to_date := cal_rec(i).cal_to_date;

                 -- Bug: 7556621 Vpedarla made the below change in the cal_c1 cursore
		--IF to_char(p_rec(j).out_cal_to_date,'HH24:MI:SS') = '00:00:00' THEN
                 --   p_rec(j).out_cal_to_date := p_rec(j).out_cal_to_date + 1;
		--END IF ;
                 j := j + 1;
--
       END LOOP ;
       NO_NO_EXCP := 'N' ;
    END IF ;

    /*  standard call to get msge cnt, and if cnt is 1, get mesg info */
    FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);


  EXCEPTION
  WHEN  date_null
  THEN
        log_message('!!! Please Enter From and To Date :' );

  WHEN  qty_null
  THEN
        log_message('Qty is NULL :' );

   WHEN FND_API.G_EXC_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN OTHERS THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   /*
    WHEN  OTHERS
    THEN
        log_message('Error in Test rsrc Insert: '||stmt_no);
        log_message(sqlerrm);
   */

END rsrc_avl ; /* End of Procedure rsrc_avl */

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    rsrc_avl                                                             |
REM|                                                                         |
REM| TYPE                                                                    |
REM|    Public                                                               |
REM|                                                                         |
REM| DESCRIPTION                                                             |
REM|    This Procedure will find out the Available Time per Resource         |
REM| HISTROY                                                                 |
REM|    Rajesh Patangya created                                              |
REM|    B4999940 Use of BOM Calendar,Inventory Convergence                   |
REM+=========================================================================+
*/
PROCEDURE rsrc_avl(
                    p_api_version        IN NUMBER,
                    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
                    p_resource_id        IN NUMBER,
                    p_from_date          IN DATE,
                    p_to_date            IN DATE,
                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2,
                    x_return_code        OUT NOCOPY VARCHAR2,
                    p_rec                IN OUT NOCOPY cal_tab2,
                    p_flag               IN OUT NOCOPY VARCHAR2
                    ) IS

gmp_api_name          VARCHAR2(30) := 'rsrc_avl';
gmp_api_version       NUMBER := 1.0;
invalid_resource_id   EXCEPTION ;
undetermined_calendar EXCEPTION ;

CURSOR plant_cur is
SELECT organization_id, calendar_code
  FROM cr_rsrc_dtl
 WHERE resource_id = p_resource_id
   AND delete_mark = 0
   AND inactive_ind = 0 ;

CURSOR org_calendar_cur is
 SELECT calendar_code
   FROM mtl_parameters
 WHERE  organization_id = l_organization_id ;

BEGIN

    IF NOT FND_API.compatible_api_call(gmp_api_version,
                                       p_api_version,
                                       gmp_api_name,
                                       G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    OPEN plant_cur;
    FETCH plant_cur INTO l_organization_id, l_calendar_code;

     IF plant_cur%NOTFOUND THEN
        RAISE fnd_api.g_exc_error;
     END IF;

     IF plant_cur%ROWCOUNT <>1 THEN
         p_flag := 'N' ;
         raise invalid_resource_id ;
     END IF;

    CLOSE plant_cur;

    IF l_calendar_code IS NULL THEN
     OPEN org_calendar_cur ;
     FETCH org_calendar_cur INTO l_calendar_code ;

     IF org_calendar_cur%NOTFOUND THEN
        RAISE fnd_api.g_exc_error;
     END IF;

     IF org_calendar_cur%NOTFOUND  THEN
         p_flag := 'N' ;
         raise undetermined_calendar ;
     END IF;

     CLOSE org_calendar_cur ;
    END IF ;

     gmp_rsrc_avl_pkg.rsrc_avl( p_api_version,
                                p_init_msg_list,
                                l_calendar_code,
                                p_resource_id,
                                p_from_date,
                                p_to_date,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                x_return_code,
                                p_rec,p_flag);

    /*  standard call to get msge cnt, and if cnt is 1, get mesg info */
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);


EXCEPTION
   WHEN undetermined_calendar THEN
     X_return_code   := -100;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
     log_message('The Calendar is not assigned to resource and organizations ');

   WHEN invalid_resource_id  THEN
     X_return_code   := -101;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
     log_message('Invalid Resouce Id ');

   WHEN FND_API.G_EXC_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN OTHERS THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END rsrc_avl ; /* the proc without cal_id */

END gmp_rsrc_avl_pkg; /* End of package rsrc_avl_pkg */

/
