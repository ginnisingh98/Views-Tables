--------------------------------------------------------
--  DDL for Package Body OTA_CRT_FINANCE_SEGMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CRT_FINANCE_SEGMENT" as
/* $Header: otcrtfhr.pkb 120.1.12010000.2 2009/02/27 08:53:46 pekasi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------<create_segment>------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package is used for self service application to create finance header
--   data when user enroll in the class.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   Finanece Header infrmation will be created.
--
-- Post Failure:
--   Status will be passed to the caller and the caller will raise a notification.
--
-- Developer Implementation Notes:
--   The attrbute in parameters should be modified as to the business process
--   requirements.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure create_segment
  (p_assignment_id                        in     number
  ,p_business_group_id_from               in     number
  ,p_business_group_id_to                 in     number
  ,p_organization_id				in     number
  ,p_sponsor_organization_id              in     number
  ,p_event_id 					in 	 number
  ,p_person_id					in     number
  ,p_currency_code				in     varchar2
  ,p_cost_allocation_keyflex_id           in     number
  ,p_user_id                              in     number
  ,p_finance_header_id			 out nocopy    number
  ,p_object_version_number		 out nocopy    number
  ,p_result                     	 out nocopy    varchar2
  ,p_from_result                          out nocopy    varchar2
  ,p_to_result                            out nocopy    varchar2
  ) IS

TYPE from_rec_type IS RECORD
   (colname    varchar2(30),
    destcolname  varchar2(30),
    colvalue   varchar2(200));

TYPE from_arr_type IS TABLE OF from_rec_type INDEX BY BINARY_INTEGER;


TYPE to_rec_type IS RECORD
   (colname    varchar2(30),
    destcolname  varchar2(30),
    colvalue   varchar2(200));

TYPE to_arr_type IS TABLE OF to_rec_type INDEX BY BINARY_INTEGER;


l_organization_id  number(15);
l_cost_allocation_keyflex_id number(9);
l_user_id        number ;


source_cursor           INTEGER;
ret                     INTEGER;
l_segment               varchar2(200);
l_paying_cost_center    varchar2(2000);
l_receiving_cost_center varchar2(2000);
l_chart_of_accounts_id  number(15);
l_set_of_books_id       number(15);
l_from_set_of_books_id  number(15);
l_to_set_of_books_id    number(15);
l_receivable_type       ota_finance_headers.receivable_type%type;
l_sequence 			number(3);
l_delimiter   		varchar2(1);
l_length      		number(3);
l_dynamicSqlString  	varchar2(2000);
i          			number;
--cc_arr     		cc_arr_type;
j          			number;
k          			number;
g_from_arr   		from_arr_type;
g_to_arr   			to_arr_type;
l_from_cc_id  		number;
l_to_cc_id  		number;
l_map                   varchar2(1);
l_error                 varchar(2000);
l_authorizer_person_id  ota_finance_headers.authorizer_person_id%type;
l_auto_transfer         varchar2(1) := FND_PROFILE.VALUE('OTA_SSHR_AUTO_GL_TRANSFER');
l_transfer_status       ota_finance_headers.transfer_status%type;
l_administrator         ota_finance_headers.administrator%type;
l_date_format varchar2(200);
l_hr_cost_segment       ota_hr_gl_flex_maps.hr_cost_segment%type;

l_offering_id   		ota_events.offering_id%type;

CURSOR THG_FROM(p_business_group_id in number)
IS
Select
      tcc.gl_set_of_books_id,
	thg.SEGMENT
	,thg.SEGMENT_NUM
	,thg.HR_DATA_SOURCE
	,thg.CONSTANT
	,thg.HR_COST_SEGMENT
FROM  OTA_HR_GL_FLEX_MAPS THG
      ,OTA_CROSS_CHARGES TCC
WHERE THG.Cross_charge_id = TCC.Cross_charge_id and
      TCC.Business_group_id = p_business_group_id and
      TCC.Type = 'E' and
      TCC.FROM_TO = 'F' and
      Trunc(sysdate) between tcc.start_date_active and nvl(tcc.end_date_active,sysdate)
ORDER BY thg.segment_num;


CURSOR THG_TO(p_business_group_id in number)
IS
Select
      tcc.gl_set_of_books_id,
	thg.SEGMENT
	,thg.SEGMENT_NUM
	,thg.HR_DATA_SOURCE
	,thg.CONSTANT
	,thg.HR_COST_SEGMENT
FROM  OTA_HR_GL_FLEX_MAPS THG
      ,OTA_CROSS_CHARGES TCC
WHERE THG.Cross_charge_id = TCC.Cross_charge_id and
      TCC.Business_group_id = p_business_group_id_to and
      TCC.Type = 'E' and
      TCC.FROM_TO = 'T' and
      Trunc(sysdate) between tcc.start_date_active and nvl(tcc.end_date_active,sysdate)
ORDER BY thg.segment_num;



CURSOR ORG
IS
SELECT
  COST_ALLOCATION_KEYFLEX_ID
FROM HR_ALL_ORGANIZATION_UNITS
WHERE ORGANIZATION_ID = l_organization_id;

CURSOR SOB(p_set_of_books_id in number)
 IS
SELECT CHART_OF_ACCOUNTS_ID
FROM GL_SETS_OF_BOOKS
WHERE SET_OF_BOOKS_ID = p_set_of_books_id;

CURSOR OFA IS
SELECT hr.COST_ALLOCATION_KEYFLEX_ID
FROM   HR_ALL_ORGANIZATION_UNITS hr ,
       PER_ALL_ASSIGNMENTS_F asg
WHERE hr.organization_id = asg.organization_id and
      asg.organization_id = p_organization_id and
      asg.assignment_id = p_assignment_id and
      trunc(sysdate) between asg.effective_start_date and
                             asg.effective_end_date;

CURSOR SPO IS
SELECT hr.COST_ALLOCATION_KEYFLEX_ID
FROM   HR_ALL_ORGANIZATION_UNITS hr ,
       OTA_EVENTS EVT
WHERE  hr.organization_id = evt.organization_id and
       evt.event_id = p_event_id;

/* For Ilearning */
CURSOR csr_event
IS
SELECT offering_id
FROM ota_events
where event_id= p_event_id;

Begin
  p_result := 'S';
  l_sequence := 1;
  j := 1;



  /*-----------------------------------------------------------
  | For Transfer from logic                                    |
  |                                                           |
  ------------------------------------------------------------*/
  for from_rec  in thg_from(p_business_group_id_from)
  LOOP
     if l_sequence = 1 then

         OPEN sob(from_rec.gl_set_of_books_id);
           FETCH sob into l_chart_of_accounts_id;

         CLOSE sob;
           l_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL', 'GL#', l_chart_of_accounts_id);

           l_from_set_of_books_id := from_rec.gl_set_of_books_id;

     for  i in 1..30
     loop
		 g_from_arr(i).colname := 'SEGMENT'||to_char(i);
 	  	 g_from_arr(i).destcolname := 'FROM_SEGMENT'||to_char(i);
		 g_from_arr(i).colvalue := null;
     end loop;

     end if;

     l_sequence := 2;

     l_segment := null;
     l_cost_allocation_keyflex_id := null;
     l_hr_cost_segment:=from_rec.hr_cost_segment;

     IF from_rec.hr_data_source = 'BGP' THEN
        IF from_rec.HR_COST_SEGMENT is not null THEN
           BEGIN

             SELECT COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
             FROM   HR_ALL_ORGANIZATION_UNITS WHERE organization_id = p_business_group_id_from;


            l_dynamicSqlString := 'SELECT '|| l_hr_cost_segment ||' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
             BEGIN
  	   		 execute immediate l_dynamicSqlString
          		 into l_segment
         		 using l_cost_allocation_keyflex_id;
          		 EXCEPTION WHEN NO_DATA_FOUND Then
                   null;
       	 END;

             EXCEPTION WHEN NO_DATA_FOUND Then
              null;
           END;

         ELSE
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            else
               p_result := 'E';
               p_from_result  := 'B';
            end if;
         END IF;

         IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'B';
               p_result := 'E';
            END IF;
         END IF;

     ELSIF  from_rec.hr_data_source = 'ASG' THEN

      IF from_rec.HR_COST_SEGMENT is not null THEN
         l_dynamicSqlString := 'SELECT '|| l_hr_cost_segment || ' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	     execute immediate l_dynamicSqlString
           into l_segment
           using p_cost_allocation_keyflex_id;
           EXCEPTION WHEN NO_DATA_FOUND Then
              null;
         END;
      ELSE
        IF from_rec.constant is not null then
            l_segment := from_rec.constant;
        ELSE
           p_from_result  := 'A';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'A';
               p_result := 'E';
            END IF;
         END IF;
     ELSIF from_rec.hr_data_source = 'OFA' THEN
      IF from_rec.HR_COST_SEGMENT is not null THEN
         BEGIN
          OPEN OFA;
          FETCH OFA INTO l_cost_allocation_keyflex_id ;
          CLOSE OFA;
       /*   SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 PER_ALL_ASSIGNMENTS_F asg
          WHERE hr.organization_id = asg.organization_id and
                asg.organization_id = p_organization_id and
                asg.assignment_id = p_assignment_id ; */

 	    l_dynamicSqlString := 'SELECT '||l_hr_cost_segment || ' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	    execute immediate l_dynamicSqlString
          into l_segment
          using l_cost_allocation_keyflex_id;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
         END;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
        END;
       ELSE
        IF from_rec.constant is not null then
            l_segment := from_rec.constant;
        ELSE
           p_from_result  := 'O';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'O';
               p_result := 'E';
            END IF;
         END IF;

     ELSIF  from_rec.hr_data_source = 'SPO' THEN
      IF from_rec.HR_COST_SEGMENT is not null THEN
        BEGIN
          OPEN SPO;
          FETCH SPO INTO l_cost_allocation_keyflex_id ;
          CLOSE SPO;

         /* SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 OTA_EVENTS EVT
          WHERE hr.organization_id = evt.organization_id and
                evt.event_id = p_event_id; */
          l_dynamicSqlString := 'SELECT '||l_hr_cost_segment || ' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;

 	    BEGIN
  	       execute immediate l_dynamicSqlString
             into l_segment
             using l_cost_allocation_keyflex_id;
             EXCEPTION WHEN NO_DATA_FOUND Then
             null;
          END;
         EXCEPTION WHEN NO_DATA_FOUND Then
             null;
        END;
       ELSE
         IF from_rec.constant is not null then
            l_segment := from_rec.constant;
         ELSE
           p_from_result  := 'S';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF from_rec.constant is not null then
               l_segment := from_rec.constant;
            ELSE
               p_from_result  := 'S';
               p_result := 'E';
            END IF;
         END IF;

     --  END;
     ELSE
       IF from_rec.constant is null then
          p_from_result  := 'S';
          p_result := 'E';
       ELSE
          l_segment := from_rec.constant;
       END IF;
     END IF;

     /*if l_segment is null then
        l_segment := from_rec.constant;
     end if;*/

     if l_paying_cost_center is null then
        l_paying_cost_center := l_segment;
     else
        l_paying_cost_center := l_paying_cost_center ||l_delimiter||l_segment;
     end if;

      j := to_number(substr(from_rec.SEGMENT,8,2));
      if ( g_from_arr(j).colname = from_rec.SEGMENT  ) THEN
    	    g_from_arr(j).colvalue := l_segment;

         -- j:= j +1 ;
      end if;


  /* IF p_result = 'E' then
      RETURN;
   END IF; */

  END LOOP;
  if p_result = 'S' then
     if l_paying_cost_center is not null then
      l_length := length (l_paying_cost_center);
      l_from_cc_id :=FND_FLEX_EXT.GET_CCID('SQLGL', 'GL#', l_chart_of_accounts_id, fnd_date.date_to_canonical(sysdate),
                             l_paying_cost_center);

      if l_from_cc_id =0 then
         p_from_result  := 'C';
         p_result := 'E';
      end if;
     else
         p_from_result  := 'N';
         p_result := 'E';
    end if;
  end if;



if p_result = 'S' then

  l_sequence := 1;
  k := 1;
  /*-----------------------------------------------------------
  | For Transfer to logic                                     |
  |                                                           |
  ------------------------------------------------------------*/
  for to_rec  in thg_to(p_business_group_id_to)
  LOOP
     if l_sequence = 1 then

        OPEN sob(to_rec.gl_set_of_books_id);
         FETCH sob into l_chart_of_accounts_id;
        CLOSE sob;
        l_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL', 'GL#', l_chart_of_accounts_id);

        l_to_set_of_books_id := to_rec.gl_set_of_books_id;
     for  l in 1..30
     loop
		 g_to_arr(l).colname := 'SEGMENT'||to_char(l);
 	  	 g_to_arr(l).destcolname := 'TO_SEGMENT'||to_char(l);
		 g_to_arr(l).colvalue := null;
     end loop;


     end if;

     l_sequence := 2;

     l_segment := null;
     l_cost_allocation_keyflex_id := null;
     l_hr_cost_segment :=to_rec.hr_cost_segment;

     IF to_rec.hr_data_source = 'BGP' THEN
        IF to_rec.HR_COST_SEGMENT is not null THEN
           BEGIN
             SELECT COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
             FROM   HR_ALL_ORGANIZATION_UNITS WHERE organization_id = p_business_group_id_to;


            l_dynamicSqlString := 'SELECT '||l_hr_cost_segment || ' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
             BEGIN
  	   		 execute immediate l_dynamicSqlString
          		 into l_segment
         		 using l_cost_allocation_keyflex_id;
          		 EXCEPTION WHEN NO_DATA_FOUND Then
                   null;
         	 END;

             EXCEPTION WHEN NO_DATA_FOUND Then
             null;
           END;
        ELSE
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            else
               p_result := 'E';
               p_to_result  := 'B';
            end if;
         END IF;

         IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'B';
               p_result := 'E';
            END IF;
         END IF;

     ELSIF  to_rec.hr_data_source = 'ASG' THEN
      IF to_rec.HR_COST_SEGMENT is not null THEN
         l_dynamicSqlString := 'SELECT '||l_hr_cost_segment || ' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	    execute immediate l_dynamicSqlString
          into l_segment
          using p_cost_allocation_keyflex_id;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
         END;


      ELSE
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            else
               p_result := 'E';
               p_to_result  := 'A';
            end if;
      END IF;

         IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'A';
               p_result := 'E';
            END IF;
         END IF;


     ELSIF to_rec.hr_data_source = 'OFA' THEN
      IF to_rec.HR_COST_SEGMENT is not null THEN
         BEGIN
          OPEN OFA;
          FETCH OFA INTO l_cost_allocation_keyflex_id ;
          CLOSE OFA;
         /* SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 PER_ALL_ASSIGNMENTS_F asg
          WHERE hr.organization_id = asg.organization_id and
                asg.organization_id = p_organization_id and
                asg.assignment_id = p_assignment_id  ; */

 	    l_dynamicSqlString := 'SELECT '||l_hr_cost_segment || ' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;
         BEGIN
  	    execute immediate l_dynamicSqlString
          into l_segment
          using l_cost_allocation_keyflex_id;
          EXCEPTION WHEN NO_DATA_FOUND Then
             null;
         END;

        END;
       ELSE
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            else
               p_result := 'E';
               p_to_result  := 'O';
            end if;
      END IF;

         IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'O';
               p_result := 'E';
            END IF;
         END IF;
     ELSIF  to_rec.hr_data_source = 'SPO' THEN
       IF to_rec.HR_COST_SEGMENT is not null THEN
        BEGIN
           OPEN SPO;
          FETCH SPO INTO l_cost_allocation_keyflex_id ;
          CLOSE SPO;

        /*  SELECT hr.COST_ALLOCATION_KEYFLEX_ID INTO l_cost_allocation_keyflex_id
          FROM   HR_ALL_ORGANIZATION_UNITS hr ,
                 OTA_EVENTS EVT
          WHERE hr.organization_id = evt.organization_id and
                evt.event_id = p_event_id; */
        l_dynamicSqlString := 'SELECT '||l_hr_cost_segment || ' FROM PAY_COST_ALLOCATION_KEYFLEX
                       WHERE COST_ALLOCATION_KEYFLEX_ID = :txn '  ;

 	    BEGIN
  	       execute immediate l_dynamicSqlString
             into l_segment
             using l_cost_allocation_keyflex_id;
             EXCEPTION WHEN NO_DATA_FOUND Then
             null;
          END;
         EXCEPTION WHEN NO_DATA_FOUND Then
             null;
        END;
       ELSE
         IF to_rec.constant is not null then
            l_segment := to_rec.constant;
        ELSE
           p_from_result  := 'S';
           p_result := 'E';
        END IF;
      END IF;
       IF l_segment is null then
            IF to_rec.constant is not null then
               l_segment := to_rec.constant;
            ELSE
               p_to_result  := 'S';
               p_result := 'E';
            END IF;
         END IF;

     --  END;
     ELSE

      IF to_rec.constant is null then
          p_to_result  := 'S';
          p_result := 'E';
       ELSE
          l_segment := to_rec.constant;
       END IF;


     END IF;

    /* if l_segment is null then
        l_segment := to_rec.constant;
     end if; */

     if l_receiving_cost_center is null then
        l_receiving_cost_center := l_segment;
     else
        l_receiving_cost_center := l_receiving_cost_center ||l_delimiter||l_segment;
     end if;

     k := to_number(substr(to_rec.SEGMENT,8,2));

     if ( to_rec.SEGMENT = g_to_arr(k).colname) THEN
        g_to_arr(k).colvalue := l_segment;
        --k:= k +1 ;
     end if;

 --  IF p_result = 'E' then
 --     RETURN;
  -- END IF;

  END LOOP;
   if p_result = 'S' then
       if l_receiving_cost_center is not null then
         l_length := length (l_receiving_cost_center);
          l_to_cc_id :=FND_FLEX_EXT.GET_CCID('SQLGL', 'GL#', l_chart_of_accounts_id, fnd_date.date_to_canonical(sysdate),
                             l_receiving_cost_center);

         if l_to_cc_id = 0 then
            p_result := 'E';
            p_to_result  := 'C';
         end if;
    else
         p_to_result  := 'N';
         p_result := 'E';
    end if;
  end if;
end if;

IF p_result = 'S' THEN
   /* For Ilearning */
   OPEN csr_event;
   FETCH csr_event into l_offering_id;
   CLOSE csr_event;

   l_administrator  :=p_user_id;
   if l_auto_transfer = 'Y' then
      if l_offering_id is null then
         l_authorizer_person_id := p_user_id;
         l_transfer_status := 'AT';
      else
         l_authorizer_person_id := null;
         l_transfer_status := 'NT';
      end if;
   else
      l_authorizer_person_id := null;
      l_transfer_status := 'NT';
   end if;

      ota_tfh_api_ins.ins
       (
        p_finance_header_id         =>  p_finance_header_id
       ,p_object_version_number     =>  p_object_version_number
       ,p_organization_id           =>  p_organization_id
       ,p_administrator             =>  l_administrator
       ,p_cancelled_flag            =>  'N'
       ,p_currency_code             =>  p_currency_code
       ,p_date_raised               =>  sysdate
       ,p_payment_status_flag       =>  'N'
       ,p_transfer_status           =>  l_transfer_status
       ,P_type                      =>  'CT'
       ,p_authorizer_person_id      =>  l_authorizer_person_id
       ,p_receivable_type	      =>  l_receivable_type
       ,P_paying_cost_center        =>  l_paying_cost_center
       ,P_receiving_cost_center     =>  l_receiving_cost_center
       ,p_transfer_from_set_of_book_id => l_from_set_of_books_id
       ,p_transfer_to_set_of_book_id => l_to_set_of_books_id
       ,p_from_segment1             =>  g_from_arr(1).colvalue
       ,p_from_segment2             =>  g_from_arr(2).colvalue
       ,p_from_segment3             =>  g_from_arr(3).colvalue
       ,p_from_segment4             =>  g_from_arr(4).colvalue
       ,p_from_segment5             =>  g_from_arr(5).colvalue
       ,p_from_segment6             =>  g_from_arr(6).colvalue
       ,p_from_segment7             =>  g_from_arr(7).colvalue
       ,p_from_segment8             =>  g_from_arr(8).colvalue
       ,p_from_segment9             =>  g_from_arr(9).colvalue
       ,p_from_segment10            =>  g_from_arr(10).colvalue
       ,p_from_segment11            =>  g_from_arr(11).colvalue
       ,p_from_segment12            =>  g_from_arr(12).colvalue
       ,p_from_segment13            =>  g_from_arr(13).colvalue
       ,p_from_segment14            =>  g_from_arr(14).colvalue
       ,p_from_segment15            =>  g_from_arr(15).colvalue
       ,p_from_segment16            =>  g_from_arr(16).colvalue
       ,p_from_segment17            =>  g_from_arr(17).colvalue
       ,p_from_segment18            =>  g_from_arr(18).colvalue
       ,p_from_segment19            =>  g_from_arr(19).colvalue
       ,p_from_segment20            =>  g_from_arr(20).colvalue
       ,p_from_segment21            =>  g_from_arr(21).colvalue
       ,p_from_segment22            =>  g_from_arr(22).colvalue
       ,p_from_segment23            =>  g_from_arr(23).colvalue
       ,p_from_segment24            =>  g_from_arr(24).colvalue
       ,p_from_segment25            =>  g_from_arr(25).colvalue
       ,p_from_segment26            =>  g_from_arr(26).colvalue
       ,p_from_segment27            =>  g_from_arr(27).colvalue
       ,p_from_segment28            =>  g_from_arr(28).colvalue
       ,p_from_segment29            =>  g_from_arr(29).colvalue
       ,p_from_segment30            =>  g_from_arr(30).colvalue
       ,p_to_segment1               =>  g_to_arr(1).colvalue
       ,p_to_segment2               =>  g_to_arr(2).colvalue
       ,p_to_segment3               =>  g_to_arr(3).colvalue
       ,p_to_segment4               =>  g_to_arr(4).colvalue
       ,p_to_segment5               =>  g_to_arr(5).colvalue
       ,p_to_segment6               =>  g_to_arr(6).colvalue
       ,p_to_segment7               =>  g_to_arr(7).colvalue
       ,p_to_segment8               =>  g_to_arr(8).colvalue
       ,p_to_segment9               =>  g_to_arr(9).colvalue
       ,p_to_segment10              =>  g_to_arr(10).colvalue
       ,p_to_segment11              =>  g_to_arr(11).colvalue
       ,p_to_segment12              =>  g_to_arr(12).colvalue
       ,p_to_segment13              =>  g_to_arr(13).colvalue
       ,p_to_segment14              =>  g_to_arr(14).colvalue
       ,p_to_segment15              =>  g_to_arr(15).colvalue
       ,p_to_segment16              =>  g_to_arr(16).colvalue
       ,p_to_segment17              =>  g_to_arr(17).colvalue
       ,p_to_segment18              =>  g_to_arr(18).colvalue
       ,p_to_segment19              =>  g_to_arr(19).colvalue
       ,p_to_segment20              =>  g_to_arr(20).colvalue
       ,p_to_segment21              =>  g_to_arr(21).colvalue
       ,p_to_segment22              =>  g_to_arr(22).colvalue
       ,p_to_segment23              =>  g_to_arr(23).colvalue
       ,p_to_segment24              =>  g_to_arr(24).colvalue
       ,p_to_segment25              =>  g_to_arr(25).colvalue
       ,p_to_segment26              =>  g_to_arr(26).colvalue
       ,p_to_segment27              =>  g_to_arr(27).colvalue
       ,p_to_segment28              =>  g_to_arr(28).colvalue
       ,p_to_segment29              =>  g_to_arr(29).colvalue
       ,p_to_segment30              =>  g_to_arr(30).colvalue
       ,p_transfer_from_cc_id       =>  l_from_cc_id
       ,p_transfer_to_cc_id         =>  l_to_cc_id
       ,P_validate                  =>  false
       ,P_transaction_type          =>  'INSERT');
END IF;

end create_segment;
--
end ota_crt_finance_segment;

/
