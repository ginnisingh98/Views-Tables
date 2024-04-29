--------------------------------------------------------
--  DDL for Package Body GMD_QA_RCV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QA_RCV_PUB" AS
/* $Header: GMDPRECB.pls 120.1.12010000.4 2008/11/07 23:07:00 plowe ship $ */

FUNCTION get_disposition
( p_po_num IN VARCHAR2,
  p_po_line_num IN VARCHAR2,
  p_shipment_num IN VARCHAR2,
  p_receipt_num IN VARCHAR2,
  p_shipment_line_id IN NUMBER default null -- 7447810
) RETURN VARCHAR2 IS

CURSOR cur_get_disposition IS -- 7447810 optimized query for shipment_line_id
select disposition
from
--po_headers_all poh,
--po_lines_all pol,
--po_line_locations_all poll,
rcv_transactions rcv ,
gmd_sampling_events se,
rcv_shipment_lines rsl,
rcv_shipment_headers rsh
where
-- segment1 = p_po_num
--and poh.po_header_id = pol.po_header_id
--and rsl.line_num = p_po_line_num
--and pol.line_num = p_po_line_num
--and poh.po_header_id = rsl.po_header_id
--and poll.shipment_num = p_shipment_num
--and poll.po_line_id = pol.po_line_id
--and poll.line_location_id = rcv.po_line_location_id
rcv.shipment_header_id = rsh.shipment_header_id
and se.receipt_id = rsh.shipment_header_id
and se.receipt_line_id = rsl.shipment_line_id
and rsl.shipment_header_id = rsh.shipment_header_id
and rcv.shipment_line_ID = p_shipment_line_id
--and rsh.RECEIPT_NUM = p_receipt_num
order by rcv.creation_date desc;



l_disposition VARCHAR2(3);
l_progress  	   	VARCHAR2(3);

  BEGIN
  	gmd_debug.log_initialize('OPM Receiving Inspection');
  	gmd_debug.put_line('entering get_disposition ');
		gmd_debug.put_line('p_po_num : '|| p_po_num );
	  gmd_debug.put_line('p_po_line_num : '|| p_po_line_num );
	  gmd_debug.put_line('p_shipment_num : '|| p_shipment_num );
		gmd_debug.put_line('p_receipt_num  : '|| p_receipt_num  );
		gmd_debug.put_line('p_shipment_line_id : '|| p_shipment_line_id );


    IF (p_po_num IS NOT NULL) THEN
      OPEN cur_get_disposition;
       l_progress := '010';
      FETCH cur_get_disposition INTO l_disposition;
       l_progress := '020';
      IF (cur_get_disposition%FOUND) THEN
        IF cur_get_disposition%ISOPEN THEN
         CLOSE cur_get_disposition;
        END IF;
         l_progress := '030';
        gmd_debug.put_line('progress  = ', l_progress);
        RETURN l_disposition;
      ELSE
         l_progress := '040';
        IF cur_get_disposition%ISOPEN THEN
         CLOSE cur_get_disposition;
       	END IF;
       	 gmd_debug.put_line('progress  = ', l_progress);
        RETURN NULL;
      END IF;
    ELSE
      l_progress := '050';
      gmd_debug.put_line('progress  = ', l_progress);
    	RETURN NULL;
    END IF;
exception
	when others then
			 IF cur_get_disposition%ISOPEN THEN
         CLOSE cur_get_disposition;
       END IF;

	     gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_QA_RCV_PUB.GET_DISPOSITION','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
	     return(l_progress);
	     --return (sqlerrm);


  END get_disposition;

FUNCTION get_quantity
( p_po_num IN VARCHAR2,
  p_po_line_num IN VARCHAR2,
  p_shipment_num IN VARCHAR2,
  p_receipt_num IN VARCHAR2,
  p_shipment_line_id IN NUMBER default null -- 7447810
) RETURN NUMBER IS

CURSOR cur_get_quantity IS  -- 7447810 optimized query for shipment_line_id
select rcv.quantity
from
--po_headers_all poh,
--po_lines_all pol,
--po_line_locations_all poll,
rcv_transactions rcv ,
gmd_sampling_events se,
rcv_shipment_lines rsl,
rcv_shipment_headers rsh
where
-- segment1 = p_po_num
--and poh.po_header_id = pol.po_header_id
--and rsl.line_num = p_po_line_num
--and pol.line_num = p_po_line_num
--and poh.po_header_id = rsl.po_header_id
--and poll.shipment_num = p_shipment_num
--and poll.po_line_id = pol.po_line_id
--and poll.line_location_id = rcv.po_line_location_id
rcv.shipment_header_id = rsh.shipment_header_id
and se.receipt_id = rsh.shipment_header_id
and se.receipt_line_id = rsl.shipment_line_id
and rsl.shipment_header_id = rsh.shipment_header_id
and rcv.shipment_line_ID = p_shipment_line_id
--and rsh.RECEIPT_NUM = p_receipt_num
order by rcv.creation_date desc;

l_quantity NUMBER;
l_progress  	   	VARCHAR2(3);

  BEGIN

    gmd_debug.put_line('entering get_quantity');
    gmd_debug.put_line('p_po_num : '|| p_po_num );
	  gmd_debug.put_line('p_po_line_num : '|| p_po_line_num );
	  gmd_debug.put_line('p_shipment_num : '|| p_shipment_num );
		gmd_debug.put_line('p_receipt_num  : '|| p_receipt_num  );
		gmd_debug.put_line('p_shipment_line_id : '|| p_shipment_line_id );


    IF (p_po_num IS NOT NULL) THEN
      OPEN cur_get_quantity;
       l_progress := '010';
      FETCH cur_get_quantity INTO l_quantity;
       l_progress := '020';
      IF (cur_get_quantity%FOUND) THEN
        IF cur_get_quantity%ISOPEN THEN
         CLOSE cur_get_quantity;
        END IF;
         l_progress := '030';
        gmd_debug.put_line('progress  = ', l_progress);
        RETURN l_quantity;
      ELSE
        IF cur_get_quantity%ISOPEN THEN
         CLOSE cur_get_quantity;
        END IF;
         l_progress := '040';
        gmd_debug.put_line('progress  = ', l_progress);
        RETURN 0;
      END IF;
    ELSE
       l_progress := '050';
      gmd_debug.put_line('progress  = ', l_progress);
    	RETURN 0;
    END IF;
exception
	when others then
			 IF cur_get_quantity%ISOPEN THEN
         CLOSE cur_get_quantity;
       END IF;

	     gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_QA_RCV_PUB.GET_QUANTITY','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
	     return(l_progress);
	     --return (sqlerrm);

END get_quantity;

FUNCTION get_inspection_result -- 7447810
( p_po_num IN VARCHAR2,
  p_po_line_num IN VARCHAR2,
  p_shipment_num IN VARCHAR2,
  p_receipt_num IN VARCHAR2,
  p_shipment_line_id IN NUMBER default null -- 7447810
) RETURN VARCHAR2 IS

CURSOR cur_get_inspection_result IS  -- 7447810 optimized query for shipment_line_id
select disposition
from
--po_headers_all poh,
--po_lines_all pol,
--po_line_locations_all poll,
rcv_transactions rcv ,
gmd_sampling_events se,
rcv_shipment_lines rsl,
rcv_shipment_headers rsh
where
-- segment1 = p_po_num
--and poh.po_header_id = pol.po_header_id
--and rsl.line_num = p_po_line_num
--and pol.line_num = p_po_line_num
--and poh.po_header_id = rsl.po_header_id
--and poll.shipment_num = p_shipment_num
--and poll.po_line_id = pol.po_line_id
--and poll.line_location_id = rcv.po_line_location_id
rcv.shipment_header_id = rsh.shipment_header_id
and se.receipt_id = rsh.shipment_header_id
and se.receipt_line_id = rsl.shipment_line_id
and rsl.shipment_header_id = rsh.shipment_header_id
and rcv.shipment_line_ID = p_shipment_line_id
--and rsh.RECEIPT_NUM = p_receipt_num
order by rcv.creation_date desc;

/* need to translate accept or reject into the language that is used
by this trick below */

l_lkup varchar2(30);

CURSOR cur_lkup IS
--SELECT displayed_field
SELECT substr(rtrim(displayed_field),1,10)
FROM po_lookup_codes
WHERE lookup_type = 'ERT RESULTS ACTION'
and lookup_code = l_lkup;       /* 'ACCEPT' or 'REJECT' */

l_inspection_result VARCHAR2(80);
l_temp_res VARCHAR2(3);
l_progress  	   	VARCHAR2(3);

  BEGIN

    gmd_debug.put_line('entering get_inspection_result');
    gmd_debug.put_line('p_po_num : '|| p_po_num );
	  gmd_debug.put_line('p_po_line_num : '|| p_po_line_num );
	  gmd_debug.put_line('p_shipment_num : '|| p_shipment_num );
		gmd_debug.put_line('p_receipt_num  : '|| p_receipt_num  );
		gmd_debug.put_line('p_shipment_line_id : '|| p_shipment_line_id );


    IF (p_po_num IS NOT NULL) THEN

      OPEN cur_get_inspection_result;
      l_progress := '010';
      FETCH cur_get_inspection_result INTO l_temp_res;
      l_progress := '020';
      IF (cur_get_inspection_result%FOUND) THEN
        IF cur_get_inspection_result%ISOPEN THEN
         CLOSE cur_get_inspection_result;
        END IF;

        IF l_temp_res = '4A'
        or l_temp_res = '5AV'   -- 5018575
        then
           l_lkup := 'ACCEPT';
        else
           l_lkup := 'REJECT';
        end if;
        l_progress := '030';
        -- determine accept or reject based on disposition
        OPEN cur_lkup;
        l_progress := '040';
        FETCH cur_lkup INTO l_inspection_result;
        l_progress := '050';
        IF (cur_lkup%FOUND) THEN
          IF cur_lkup%ISOPEN THEN
         		CLOSE cur_lkup;
       		END IF;

          l_progress := '060';
          gmd_debug.put_line('progress  = ', l_progress);
          RETURN l_inspection_result;
        ELSE
          IF cur_lkup%ISOPEN THEN
         		CLOSE cur_lkup;
       		END IF;

          l_progress := '070';
          gmd_debug.put_line('progress  = ', l_progress);
          RETURN null;
        END IF;
     ELSE
        IF cur_get_inspection_result%ISOPEN THEN
         CLOSE cur_get_inspection_result;
        END IF;
        l_progress := '080';
        gmd_debug.put_line('progress  = ', l_progress);
    	  RETURN null;
     END IF; -- IF (cur_get_inspection_result%FOUND) THEN
   ELSE
   		l_progress := '090';
   	  gmd_debug.put_line('progress  = ', l_progress);
   	  RETURN null;
   END IF; -- IF (p_po_num IS NOT NULL) THEN
exception
	when others then
			 IF cur_get_inspection_result%ISOPEN THEN
         CLOSE cur_get_inspection_result;
       END IF;
			 IF cur_lkup%ISOPEN THEN
         CLOSE cur_lkup;
       END IF;

	     gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_QA_RCV_PUB.GET_INSPECTION_RESULT','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
	     return(l_progress);
	     --return (sqlerrm);

END get_inspection_result;


PROCEDURE store_collection_details(
						p_po_num IN VARCHAR2,
  					p_po_line_num IN VARCHAR2,
  					p_shipment_num IN VARCHAR2,
  					p_receipt_num IN VARCHAR2,
  					p_plan_name IN VARCHAR2, -- actually plan number - need to derive id
  					p_collection_id IN NUMBER,
  					p_occurrence IN NUMBER) is

PRAGMA AUTONOMOUS_TRANSACTION;


CURSOR cur_get_id IS
select sampling_event_id
from
po_headers_all poh,
po_lines_all pol,
po_line_locations_all poll,
rcv_transactions rcv ,
gmd_sampling_events se,
rcv_shipment_lines rsl,
rcv_shipment_headers rsh
where segment1 = p_po_num
and   poh.po_header_id = pol.po_header_id
and   rsl.line_num   = p_po_line_num
and   pol.line_num =  p_po_line_num
and   poh.po_header_id = rsl.po_header_id
and   poll.shipment_num  =  p_shipment_num
and   poll.po_line_id =  pol.po_line_id
and   poll.line_location_id = rcv.po_line_location_id
and   rcv.shipment_header_id = rsh.shipment_header_id
and   se.receipt_id  =  rsh.shipment_header_id
and   se.receipt_line_id = rsl.shipment_line_id
and   rsl.shipment_header_id  = rsh.shipment_header_id
and   rsh.RECEIPT_NUM = p_receipt_num
order by rcv.creation_date desc;

cursor cur_get_plan_id is
select plan_id from qa_plans where name = p_plan_name;



l_progress  	   	VARCHAR2(3);
l_id           NUMBER;
l_plan_id      NUMBER;


BEGIN
		gmd_debug.log_initialize('PLOWE');
		gmd_debug.put_line('entering store_collection_details ');
		--gmd_api_pub.log_message('GMD 1','entering store_collection_details ');
		--gmd_api_pub.log_message('GMD 1','PO_NUM = ',p_po_num,'ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);

    IF (p_po_num IS NOT NULL) THEN
      OPEN cur_get_id;
      l_progress := '010';
      FETCH cur_get_id INTO l_id;
      l_progress := '020';
      IF (cur_get_id%NOTFOUND) THEN
        IF cur_get_id%ISOPEN THEN
        	l_id := 0;
         	CLOSE cur_get_id;
        END IF;
      l_progress := '030';
      ELSE
        l_progress := '040';
        IF cur_get_id%ISOPEN THEN
        	  CLOSE cur_get_id;
       	END IF;
      END IF;   -- IF (cur_get_id%FOUND) THEN
    ELSE
      l_progress := '050';
    	l_id := 0;
    END IF;  -- IF (p_po_num IS NOT NULL) THEN

		IF (p_plan_name IS NOT NULL) THEN
      OPEN cur_get_plan_id;
      l_progress := '060';
      FETCH cur_get_plan_id INTO l_plan_id;
      l_progress := '070';
      IF (cur_get_plan_id%NOTFOUND) THEN
        IF cur_get_plan_id%ISOPEN THEN
      	  	l_plan_id := 0;
        	 	CLOSE cur_get_plan_id;
        END IF;
        l_progress := '080';

      ELSE
        l_progress := '090';
        IF cur_get_plan_id%ISOPEN THEN
         	CLOSE cur_get_plan_id;
       	END IF;

      END IF;  -- IF (cur_get_plan_id%NOTFOUND) THEN
    ELSE
      l_progress := '100';
    	l_plan_id := 0;
    END IF; -- IF (p_plan_name IS NOT NULL) THEN

		If l_id <> 0 then
			update gmd_sampling_events
            set
            plan_id = l_plan_id,
            occurrence = p_occurrence,
            collection_id = p_collection_id,
            LAST_UPDATE_DATE = sysdate,
            LAST_UPDATED_BY = fnd_global.user_id,
            LAST_UPDATE_LOGIN = fnd_global.login_id
            where sampling_event_id = l_id;
      l_progress := '110';
      COMMIT;
      l_progress := '120';
		end if;
		gmd_api_pub.log_message('GMD 11','exiting store_collection_details ');
exception
	when others then
			 IF cur_get_plan_id%ISOPEN THEN
         CLOSE cur_get_plan_id;
       END IF;
       IF cur_get_id%ISOPEN THEN
         CLOSE cur_get_id;
       END IF;
       gmd_debug.put_line('progress  = ', l_progress);
	     gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_QA_RCV_PUB.STORE_COLLECTION_DETAILS','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
       rollback;

END store_collection_details ;



END GMD_QA_RCV_PUB;

/
