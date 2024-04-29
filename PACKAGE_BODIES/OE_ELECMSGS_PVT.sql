--------------------------------------------------------
--  DDL for Package Body OE_ELECMSGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ELECMSGS_PVT" AS
/* $Header: OEXVELMB.pls 120.5 2005/12/09 05:09:21 kmuruges ship $ */

PROCEDURE do_query(p_elec_msgs_tbl	   IN OUT NOCOPY /* file.sql.39 change */ Elec_Msgs_Summary_Tbl,
                   p_order_source_id       IN     NUMBER,
                   p_orig_sys_document_ref IN     VARCHAR2,
                   p_sold_to_org_id        IN     NUMBER,
                   p_transaction_type      IN     VARCHAR2,
                   p_start_date_from       IN     DATE,
                   p_start_date_to         IN     DATE,
                   p_update_date_from      IN     DATE,
                   p_update_date_to        IN     DATE,
                   p_message_status_code   IN     VARCHAR2
)
IS
    l_place_holder_table Elec_Msgs_Summary_Tbl;
    l_start_date_from      DATE;
    l_start_date_to        DATE;
    l_update_date_from     DATE;
    l_update_date_to       DATE;
    DT_mask VARCHAR2(25) := fnd_date.canonical_DT_mask;
    l_min_order_source_id  NUMBER;
    l_max_order_source_id  NUMBER;

   cursor results_cursor_1 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id = p_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and x.sold_to_org_id = p_sold_to_org_id
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

   cursor results_cursor_2 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id = p_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and (x.sold_to_org_id = p_sold_to_org_id or p_sold_to_org_id IS NULL)
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

   cursor results_cursor_3 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id between l_min_order_source_id and l_max_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and x.sold_to_org_id = p_sold_to_org_id
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

   cursor results_cursor_4 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id between l_min_order_source_id and l_max_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and (x.sold_to_org_id = p_sold_to_org_id or p_sold_to_org_id IS NULL)
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

   cursor results_cursor_5 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id = p_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and x.sold_to_org_id = p_sold_to_org_id
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
           and exists (select 1 from oe_processing_msgs msg
                       where msg.order_source_id = x.order_source_id
                         and msg.original_sys_document_ref = x.orig_sys_document_ref
                         and  ((msg.entity_code like 'ELECMSG%' and msg.entity_id = to_number(x.item_key)) or x.em_conc_request_id = msg.request_id)
                         and msg.message_status_code = p_message_status_code)

         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

   cursor results_cursor_6 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id = p_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and (x.sold_to_org_id = p_sold_to_org_id or p_sold_to_org_id IS NULL)
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
           and exists (select 1 from oe_processing_msgs msg
                       where msg.order_source_id = x.order_source_id
                         and msg.original_sys_document_ref = x.orig_sys_document_ref
                         and  ((msg.entity_code like 'ELECMSG%' and msg.entity_id = to_number(x.item_key)) or x.em_conc_request_id = msg.request_id)
                         and msg.message_status_code = p_message_status_code)
         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

   cursor results_cursor_7 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id between l_min_order_source_id and l_max_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and x.sold_to_org_id = p_sold_to_org_id
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
           and exists (select 1 from oe_processing_msgs msg
                       where msg.order_source_id = x.order_source_id
                         and msg.original_sys_document_ref = x.orig_sys_document_ref
                         and  ((msg.entity_code like 'ELECMSG%' and msg.entity_id = to_number(x.item_key)) or x.em_conc_request_id = msg.request_id)
                         and msg.message_status_code = p_message_status_code)
         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

   cursor results_cursor_8 is
       select x.order_source_id,
	      x.orig_sys_document_ref,
	      x.sold_to_org_id,
	      decode(nvl(max(x.order_number), 0), 0, NULL, max(x.order_number)),
              max(order_type_id),
              count(*),
              min(x.creation_date),
	      max(x.last_update_date),
              'x',
              x.org_id
         from oe_em_information x
         where x.order_source_id between l_min_order_source_id and l_max_order_source_id
           and (x.orig_sys_document_ref = p_orig_sys_document_ref or p_orig_sys_document_ref IS NULL)
           and (x.sold_to_org_id = p_sold_to_org_id or p_sold_to_org_id IS NULL)
           and (x.em_transaction_type_code = p_transaction_type or p_transaction_type IS NULL)
           and exists (select 1 from oe_processing_msgs msg
                       where msg.order_source_id = x.order_source_id
                         and msg.original_sys_document_ref = x.orig_sys_document_ref
                         and ((msg.entity_code like 'ELECMSG%' and msg.entity_id = to_number(x.item_key)) or x.em_conc_request_id = msg.request_id)
                         and msg.message_status_code = p_message_status_code)
         group by x.order_source_id, x.orig_sys_document_ref, x.sold_to_org_id, x.org_id
          having  min(x.creation_date) between nvl(l_start_date_from, min(x.creation_date)) and nvl(l_start_date_to, min(x.creation_date))
             and  max(x.last_update_date) between nvl(l_update_date_from, max(x.last_update_date)) and nvl(l_update_date_to, max(x.last_update_date))
          order by x.org_id, x.order_source_id, x.sold_to_org_id;

    idx   number := 1;
    j number := 1;
    n number := 1;

    l_results_rec          Elec_Msgs_Summary_Type;
    cursor results_Cursor2 is
      SELECT em_transaction_type_code, message_text, document_status
         FROM oe_em_information
       WHERE order_source_id = p_elec_msgs_tbl(j).order_source_id
         AND orig_sys_document_ref = p_elec_msgs_tbl(j).orig_sys_document_ref
         AND sold_to_org_id = p_elec_msgs_tbl(j).sold_to_org_id
         AND org_id = p_elec_msgs_tbl(j).org_id
    ORDER BY creation_date desc;
BEGIN

  -- do the following date conversion in order so that if the user inputs '1-JAN-03'
  -- we search between '1-JAN-03 00:00:00' and '1-JAN-03 23:59:59'

  l_start_date_from := to_date(to_char(trunc(p_start_date_from), DT_mask),DT_mask);
  l_start_date_to := to_date(to_char(p_start_date_to+(1-1/(24*60*60)), DT_mask),DT_mask);
  l_update_date_from := to_date(to_char(trunc(p_update_date_from), DT_mask),DT_mask);
  l_update_date_to := to_date(to_char(p_update_date_to+(1-1/(24*60*60)), DT_mask),DT_mask);

  IF p_order_source_id IS NULL THEN
     SELECT max(order_source_id), min(order_source_id)
       INTO l_max_order_source_id, l_min_order_source_id
       FROM OE_Order_Sources;
  END IF;

  IF p_order_source_id IS NOT NULL
     AND p_sold_to_org_id IS NOT NULL THEN

    IF p_message_status_code IS NULL THEN

    OPEN results_cursor_1;
    LOOP
      FETCH results_cursor_1  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_1%NOTFOUND;
        p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;
    END LOOP;
   CLOSE results_cursor_1;

   ELSE

    OPEN results_cursor_5;
    LOOP
      FETCH results_cursor_5  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_5%NOTFOUND;
        p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;
    END LOOP;
   CLOSE results_cursor_5;
   END IF;
  ELSIF p_order_source_id IS NOT NULL THEN
    IF p_message_status_code IS NULL THEN
    OPEN results_cursor_2;
    LOOP
      FETCH results_cursor_2  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_2%NOTFOUND;

         p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;
    END LOOP;
   CLOSE results_cursor_2;

   ELSE
    OPEN results_cursor_6;
    LOOP
      FETCH results_cursor_6  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_6%NOTFOUND;

         p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;

    END LOOP;
   CLOSE results_cursor_6;
   END IF;

   ELSIF p_sold_to_org_id IS NOT NULL THEN
    IF p_message_status_code IS NULL THEN

    OPEN results_cursor_3;
    LOOP
      FETCH results_cursor_3  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_3%NOTFOUND;
        p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;
    END LOOP;
   CLOSE results_cursor_3;

   ELSE

   OPEN results_cursor_7;
    LOOP
      FETCH results_cursor_7  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_7%NOTFOUND;
        p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;
    END LOOP;
   CLOSE results_cursor_7;
   END IF;
   ELSE
    IF p_message_status_code IS NULL THEN

    OPEN results_cursor_4;
    LOOP
      FETCH results_cursor_4  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_4%NOTFOUND;
        p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;
    END LOOP;
   CLOSE results_cursor_4;

   ELSE
     OPEN results_cursor_8;
    LOOP
      FETCH results_cursor_8  INTO
        l_results_rec.order_source_id,
        l_results_rec.orig_sys_document_ref,
        l_results_rec.sold_to_org_id,
        l_results_rec.order_number,
        l_results_rec.order_type_id,
        l_results_rec.num_msgs,
        l_results_rec.creation_date,
        l_results_rec.last_update_date,
        l_results_rec.last_transaction_type,
        l_results_rec.org_id;
        EXIT WHEN results_cursor_8%NOTFOUND;
        p_elec_msgs_tbl(idx) := l_results_rec;
        idx := idx + 1;
    END LOOP;
   CLOSE results_cursor_8;
   END IF;
   END IF;
     --oe_debug_pub.add('434'||idx||' fsdf' || results_cursor%ROWCOUNT);

  IF p_elec_msgs_tbl.count > 0 then


  /* summaries need to recomputed if transaction type is passed in*/
  IF p_transaction_type IS NOT NULL THEN
  LOOP
      EXIT WHEN n = idx;
      SELECT decode(nvl(max(order_number), 0), 0, NULL, max(order_number)),max (order_type_id), count(*), min(creation_Date), max(last_update_Date)
        INTO p_elec_msgs_tbl(n).order_number,p_elec_msgs_tbl(n).order_type_id, p_elec_msgs_tbl(n).num_msgs, p_elec_msgs_tbl(n).creation_date, p_elec_msgs_tbl(n).last_update_date
        FROM oe_em_information
       WHERE order_source_id = p_elec_msgs_tbl(n).order_source_id
         AND orig_sys_document_ref = p_elec_msgs_tbl(n).orig_sys_document_ref
         AND sold_to_org_id = p_elec_msgs_tbl(n).sold_to_org_id
         AND org_id = p_elec_msgs_tbl(n).org_id;
      n := n+1;
  END LOOP;
  END IF;

    LOOP
    OPEN results_cursor2;
      EXIT WHEN j = idx;
      FETCH results_cursor2 INTO
            p_elec_msgs_tbl(j).last_transaction_type,
            p_elec_msgs_tbl(j).last_transaction_message,
            p_elec_msgs_tbl(j).last_transaction_status;
           j := j + 1;

    CLOSE results_cursor2;
  END LOOP;
  END IF;

  IF p_elec_msgs_tbl.count = 0 then
     p_elec_msgs_tbl := l_place_holder_table;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     --oe_debug_pub.add('others'||SQLERRM);
     IF p_elec_msgs_tbl.count = 0 then
        p_elec_msgs_tbl := l_place_holder_table;
     END IF;
End do_query;


PROCEDURE Create_History_Entry (
          p_order_source_id	IN	NUMBER,
          p_sold_to_org_id	IN	NUMBER,
          p_orig_sys_document_ref   IN	VARCHAR2,
          p_transaction_type	IN	VARCHAR2,
          p_document_id 	IN	NUMBER,
          p_parent_document_id 	IN	NUMBER,
          p_org_id		IN	NUMBER,
          p_change_sequence	IN	VARCHAR2,
          p_itemtype    	IN	VARCHAR2,
          p_itemkey		IN	VARCHAR2,
          p_order_number	IN	NUMBER,
          p_order_type_id	IN	NUMBER,
          p_status		IN	VARCHAR2,
          p_message_text	IN	VARCHAR2,
          p_request_id          IN      NUMBER,
          p_header_id           IN      NUMBER,
          p_document_disposition IN     VARCHAR2,
          p_last_update_itemkey IN     VARCHAR2,
          x_return_status       OUT NOCOPY VARCHAR2)
IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
    /* Validation to ensure that none of the primary key elements is NULL */
    IF (p_order_source_id IS NULL OR p_sold_to_org_id IS NULL
        OR p_orig_sys_document_ref IS NULL OR p_transaction_type IS NULL OR p_document_id IS NULL) THEN
        --oe_debug_pub.add('Insufficient key params to insert,returning');
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
    END IF;
--oe_debug_pub.add('before insert');

    /* Insertion -- what should the behaviour be if org_id is null */
    INSERT INTO Oe_Em_Information (
        order_source_id,
        orig_sys_document_ref,
        sold_to_org_id,
        em_transaction_type_code,
        document_id,
        parent_document_id,
        org_id,
        change_sequence,
        item_type,
        item_key,
        order_number,
        order_type_id,
        document_status,
        message_text,
        em_conc_request_id,
        created_by,
        creation_date,
        last_update_login,
        last_updated_by,
        last_update_date,
        header_id,
        document_disposition,
        last_update_itemkey)
    VALUES (
            p_order_source_id,
            p_orig_sys_document_ref,
            p_sold_to_org_id,
            p_transaction_type,
            p_document_id,
            p_parent_document_id,
            p_org_id,
            p_change_sequence,
            p_itemtype,
            p_itemkey,
            p_order_number,
            p_order_type_id,
            p_status,
            p_message_text,
            p_request_id,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            p_header_id,
            p_document_disposition,
            p_last_update_itemkey
    );
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('Insert succeeded'||SQL%ROWCOUNT||' de'||SQLERRM);
    END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('DUPLICATE INDEX VALUE IN OEXVELMB.Create History Entry, update instead of insert'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('OTHERS IN OEXVELMB.Create History Entry'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Create_History_Entry;

PROCEDURE Update_History_Entry (
          p_order_source_id	IN	NUMBER,
          p_sold_to_org_id	IN	NUMBER,
          p_orig_sys_document_ref   IN	VARCHAR2,
          p_transaction_type	IN	VARCHAR2,
          p_document_id 	IN	NUMBER,
          p_parent_document_id 	IN	NUMBER,
          p_org_id		IN	NUMBER,
          p_change_sequence	IN	VARCHAR2,
          p_itemtype    	IN	VARCHAR2,
          p_itemkey		IN	VARCHAR2,
          p_order_number	IN	NUMBER,
          p_order_type_id	IN	NUMBER,
          p_status		IN	VARCHAR2,
          p_message_text	IN	VARCHAR2,
          p_request_id          IN      NUMBER,
          p_header_id           IN      NUMBER,
          p_document_disposition IN     VARCHAR2,
          p_last_update_itemkey IN     VARCHAR2,
          x_return_status       OUT NOCOPY VARCHAR2)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
    /* Validation to ensure that none of the primary key elements is NULL */
    IF (p_order_source_id IS NULL OR p_sold_to_org_id IS NULL
       OR p_orig_sys_document_ref IS NULL OR p_transaction_type IS NULL OR p_document_id IS NULL) THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add ('Electronic Messages: One or more key elements are null');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
       return;
    END IF;

    /* Insertion -- what should the behaviour be if org_id is null */
    UPDATE Oe_Em_Information Set
       item_type         = nvl(p_itemtype, item_type),
       item_key          = nvl(p_itemkey,  item_key),
       change_sequence   = nvl(p_change_sequence, change_sequence),
       order_number      = nvl(p_order_number, order_number),
       document_status   = nvl(p_status, document_status),
       message_text      = nvl(p_message_text, message_text),
       em_conc_request_id = nvl(p_request_id, em_conc_request_id),
       order_type_id     = nvl(p_order_type_id, order_type_id),
       last_update_login = FND_GLOBAL.LOGIN_ID,
       last_updated_by   = FND_GLOBAL.USER_ID,
       last_update_date  = SYSDATE,
       header_id         = nvl(p_header_id, header_id),
       document_disposition = nvl(p_document_disposition, document_disposition),
       last_update_itemkey = nvl(p_last_update_itemkey, last_update_itemkey)
    WHERE order_source_id = p_order_source_id
      AND orig_sys_document_ref = p_orig_sys_document_ref
      AND sold_to_org_id = p_sold_to_org_id
      AND em_transaction_type_code = p_transaction_type
      AND document_id = p_document_id;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Number of rows updated: ' || SQL%ROWCOUNT);
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
	/* log appropriate debug/error messages and return */
       IF l_debug_level > 0 THEN
          oe_debug_pub.add('OTHERS IN OEXVELMB.Update History Entry');
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_History_Entry;



FUNCTION  Find_History_Entry (
          p_order_source_id     IN      NUMBER,
          p_orig_sys_document_ref IN    VARCHAR2,
          p_sold_to_org_id      IN      NUMBER,
          p_transaction_type    IN      VARCHAR2,
          p_document_id         IN      NUMBER,
          x_last_itemkey       OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
          x_last_request_id    OUT NOCOPY /* file.sql.39 change */      NUMBER)
RETURN BOOLEAN
IS
l_dummy NUMBER;
l_last_itemkey VARCHAR2(240);
l_last_request_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

    SELECT order_source_id, last_update_itemkey, em_conc_request_id
      INTO l_dummy, l_last_itemkey, l_last_request_id
      FROM oe_em_information
     WHERE order_source_id = p_order_source_id
       AND orig_sys_document_ref = p_orig_sys_document_ref
       AND sold_to_org_id = p_sold_to_org_id
       AND em_transaction_type_code = p_transaction_type
       AND document_id = p_document_id
       FOR UPDATE;

     x_last_request_id := l_last_request_id;
     x_last_itemkey := l_last_itemkey;
     return TRUE;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add ('Others in Find_History_entry: '||SQLERRM);
      END IF;
      return FALSE;
END;

/* This function returns the document id for the last 3A7
   sent for a particular order source, orig sys doc ref and customer
   It is to be used to identify the 3A7 for which a 3a8
   response is sent */

FUNCTION  Find_Parent_Document_Id (
          p_order_source_id     IN      NUMBER,
          p_orig_sys_document_ref IN    VARCHAR2,
          p_sold_to_org_id      IN      NUMBER,
          p_org_id              IN      NUMBER
          )
RETURN NUMBER
IS
l_document_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
/*    SELECT document_id
      INTO l_document_id
      FROM oe_em_information
     WHERE order_source_id = p_order_source_id
       AND orig_sys_document_ref = p_orig_sys_document_ref
       AND sold_to_org_id = p_sold_to_org_id
       AND em_transaction_type_code = 'CSO'
       AND rownum = 1
  ORDER BY 1 DESC;
*/
    SELECT max(document_id)
      INTO l_document_id
      FROM oe_em_information
     WHERE order_source_id = p_order_source_id
       AND orig_sys_document_ref = p_orig_sys_document_ref
       AND sold_to_org_id = p_sold_to_org_id
       AND em_transaction_type_code = 'CSO'
       AND org_id = p_org_id;

     return l_document_id;
EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add ('Others in Get_Parent_Document_Id: '||SQLERRM);
      END IF;
      return NULL;
END;

-----------------------------------------------------------------
-- WORKFLOW APIS
-----------------------------------------------------------------

PROCEDURE OEEM_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;
  l_parameter1          NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OEEM_SELECTOR PROCEDURE' ) ;

      oe_debug_pub.add(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE ) ;
  END IF;

  -- {
  IF (p_funcmode = 'RUN') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS RUN' ) ;
    END IF;
    p_x_result := 'COMPLETE';

  -- Engine calls SET_CTX just before activity execution

  ELSIF(p_funcmode = 'SET_CTX') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_FUNCMODE IS SET_CTX' ) ;
    END IF;

    l_org_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                             , p_itemkey
                             , 'ORG_ID'
                             );


    IF l_debug_level  > 0 THEN
     oe_debug_pub.add('l_org_id =>' || l_org_id);
    END IF;

    mo_global.set_policy_context(p_access_mode => 'S', p_org_id=>l_Org_Id);
    p_x_result := 'COMPLETE';

  ELSIF (p_funcmode = 'TEST_CTX') THEN

    l_org_id :=  wf_engine.GetItemAttrNumber( p_itemtype
					    , p_itemkey
					    , 'ORG_ID'
					    );

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'l_org_id (from workflow)=>'|| l_org_id ) ;
    END IF;

    IF (NVL(mo_global.get_current_org_id,-99) <> l_Org_Id)
    THEN
       p_x_result := 'FALSE';
    ELSE
       p_x_result := 'TRUE';
    END IF;


   END IF;
   -- p_funcmode }

EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_ELEC_MSGS_WF', 'OEEM_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;

END OEEM_SELECTOR;

PROCEDURE Create_Or_Update_Hist_WF (
          p_itemtype            IN	VARCHAR2,
	  p_itemkey    		IN	VARCHAR2,
	  p_actid               IN      NUMBER,
	  p_funcmode            IN      VARCHAR2,
	  p_x_result            IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_order_source_id	NUMBER;
l_orig_sys_document_ref VARCHAR2(50);
l_sold_to_org_id	NUMBER;
l_transaction_type 	VARCHAR2(30);
l_document_id		NUMBER;
l_order_number		NUMBER;
l_wf_itemtype           VARCHAR2(8);
l_wf_itemkey            VARCHAR2(240);
l_status	        VARCHAR2(240);
l_message_text		VARCHAR2(2000);
l_xml_msg_id            VARCHAR2(240);
l_org_id                NUMBER;
l_result                VARCHAR2(30);
l_processing            VARCHAR2(30);
l_change_sequence       VARCHAR2(50);
l_parent_document_id    NUMBER;
l_response_flag         VARCHAR2(1);
l_request_id            NUMBER;
l_order_type_id         NUMBER;
l_subscriber_list       VARCHAR2(2000);
l_header_id             NUMBER;
l_document_disposition  VARCHAR2(20);
l_last_itemkey          VARCHAR2(240);
l_last_request_id       NUMBER;
l_curr_itemkey          VARCHAR2(240) := p_itemkey;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_order_processed_flag  VARCHAR2(1) := NULL;
BEGIN
    OE_STANDARD_WF.Set_Msg_Context(p_actid);

    IF OE_Code_Control.Code_Release_Level < '110510' THEN
       p_x_result := 'COMPLETE:COMPLETE';
       Return;
    END IF;


    -- for bug 3103495, we screen events based on the subscriber list
    -- parameter. Null subscriber list is also consumed.
    l_subscriber_list :=  wf_engine.GetItemAttrText( p_itemtype
                                                  , p_itemkey
                                                  , 'SUBSCRIBER_LIST');
    IF l_subscriber_list IS NOT NULL AND INSTR(l_subscriber_list,'ONT') = 0 THEN
       p_x_result := 'COMPLETE:COMPLETE';
       Return;
    END IF;

    -----------------------------------------------------------
    -- KEY params for history
    -----------------------------------------------------------
    l_order_source_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                                                  , p_itemkey
                                                  , 'ORDER_SOURCE_ID');

    l_sold_to_org_id := wf_engine.GetItemAttrNumber( p_itemtype
                                                   , p_itemkey
                                                   , 'SOLD_TO_ORG_ID');
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('before  partner document no');
    END IF;
    l_orig_sys_document_ref :=  wf_engine.GetItemAttrText( p_itemtype
                                                  , p_itemkey
                                                  , 'PARTNER_DOCUMENT_NO');
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('before trading partner id');
    END IF;
    l_transaction_type := wf_engine.GetItemAttrText( p_itemtype
                                                   , p_itemkey
                                                   , 'XMLG_INTERNAL_TXN_SUBTYPE');

    IF l_transaction_type IN ('POA','CBODO', 'SSO','CSO', '855','865') THEN
       l_document_id := wf_engine.GetItemAttrNumber( p_itemtype
                                                   , p_itemkey
                                                   , 'XMLG_DOCUMENT_ID');
    ELSE
       l_document_id := wf_engine.GetItemAttrNumber( p_itemtype
                                                   , p_itemkey
                                                   , 'XMLG_INTERNAL_CONTROL_NUMBER');
    END IF;

    -----------------------------------------------------------
    -- NON-KEY params for history
    -----------------------------------------------------------
    l_wf_itemkey := wf_engine.GetItemAttrText ( p_itemtype
                                               , p_itemkey
                                               , 'WF_ITEM_KEY');
    l_wf_itemtype :=  wf_engine.GetItemAttrText ( p_itemtype
                                               , p_itemkey
                                               , 'WF_ITEM_TYPE');

    l_org_id :=  wf_engine.GetItemAttrNumber ( p_itemtype
                                               , p_itemkey
                                               , 'ORG_ID');
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('after org id');
    END IF;
    IF l_org_id IS NULL THEN
        /* MOAC_SQL_CHANGE */
        -- SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
        --      NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))) into l_org_id from DUAL;
        l_org_id := MO_GLOBAL.Get_Current_Org_Id;
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('set org to :'||l_org_id);
        END IF;
    END IF;

    l_order_number := wf_engine.GetItemAttrNumber( p_itemtype
                                                      , p_itemkey
                                                      , 'DOCUMENT_NO');
    l_order_type_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                                                  , p_itemkey
                                                  , 'ORDER_TYPE_ID');

    IF l_order_number IS NULL THEN
       IF l_debug_level > 0 THEN
          oe_debug_pub.add('order number is null');
       END IF;
    END IF;
    l_status := wf_engine.GetItemAttrText( p_itemtype
                                                   , p_itemkey
                                                   , 'ONT_DOC_STATUS');
    l_message_text :=  wf_engine.GetItemAttrText( p_itemtype
                                                  , p_itemkey
                                                  , 'MESSAGE_TEXT');
    l_processing := wf_engine.GetItemAttrText( p_itemtype
                                                   , p_itemkey
                                                   , 'PROCESSING_STAGE');
    l_change_sequence := wf_engine.GetItemAttrText( p_itemtype
                                                    , p_itemkey
                                                    , 'DOCUMENT_REVISION_NO');
    l_request_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                                                  , p_itemkey
                                                  , 'CONC_REQUEST_ID');
    l_header_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                                                  , p_itemkey
                                                  , 'HEADER_ID');
    l_response_flag := wf_engine.GetItemAttrText( p_itemtype
                                                  , p_itemkey
                                                  , 'RESPONSE_FLAG');
    l_order_processed_flag := wf_engine.GetItemAttrText (p_itemtype
                                                  , p_itemkey
                                                  , 'ORDER_PROCESSED_FLAG'
                                                  , true);
    -- Bug 4179657
    -- Don't write the order number if the order was not imported successfully.
    -- The IF condition also ensure backwards compatibility with EDI in the
    -- case where the OM side of this fix is present, but the customer has not
    -- taken the EDI side of the fix. In this case, l_order_processed_flag
    -- will be NULL. This can occur when the event is raised by either the
    -- EDI inbound or outbound spreadsheets, but in both cases we can
    -- unambiguously write the order number since the inbound EDI
    -- spreadsheets never populate the order number and the outbound
    -- spreadsheets always do so since EDI doesn't have failure Acks.

    IF l_order_processed_flag = 'N' THEN
       l_order_number := NULL;
       l_order_type_id := NULL;
       l_header_id := NULL;
    END IF;


    -- start bug 3688227
    OE_MSG_PUB.set_msg_context(
         p_entity_code                => 'HEADER'
        ,p_entity_ref                 => null
        ,p_entity_id                  => null
        ,p_header_id                  => l_header_id
        ,p_line_id                    => null
        ,p_order_source_id            => l_order_source_id
        ,p_orig_sys_document_ref      => l_orig_sys_document_ref
        ,p_change_sequence            => l_change_sequence
        ,p_orig_sys_document_line_ref => null
        ,p_orig_sys_shipment_ref      => null
        ,p_source_document_type_id    => null
        ,p_source_document_id         => null
        ,p_source_document_line_id    => null
        ,p_attribute_code             => null
        ,p_constraint_id              => null
        );
    -- end bug 3688227

    IF l_transaction_type = 'CHO'
       AND l_response_flag = 'Y'
       AND FND_PROFILE.VALUE('ONT_3A7_RESPONSE_REQUIRED') = 'Y'
    THEN
       l_parent_document_id := OE_ELECMSGS_PVT.Find_Parent_Document_Id (l_order_source_id,
								       l_orig_sys_document_ref,
								       l_sold_to_org_id,
                                                                       l_org_id
                                                                       );
    END IF;
    IF l_debug_level > 0 THEN
       oe_debug_pub.add(l_order_Source_id||l_orig_sys_document_ref||l_sold_to_org_id||l_transaction_type||l_document_id||l_status||l_message_text||l_response_flag);
    END IF;
    -- here check if the record already exists for those key values
    -- if yes, then update, otherwise create
    OE_ELECMSGS_PVT.Create_History_Entry (
           p_order_source_id => l_order_source_id,
           p_sold_to_org_id  => l_sold_to_org_id,
           p_orig_sys_document_ref => l_orig_sys_document_ref,
           p_transaction_type => l_transaction_type,
           p_document_id     => l_document_id,
           p_parent_document_id => l_parent_document_id,
           p_change_sequence => l_change_sequence,
           p_order_number    => l_order_number,
           p_order_type_id   => l_order_type_id,
           p_itemtype        => l_wf_itemtype,
           p_itemkey         => l_wf_itemkey,
           p_org_id          => l_org_id,
           p_status          => l_status,
           p_message_text    => l_message_text,
           p_request_id      => l_request_id,
           p_header_id       => l_header_id,
           p_document_disposition => l_document_disposition,
           p_last_update_itemkey => l_curr_itemkey,
           x_return_status   => l_result
           );

    IF l_result = FND_API.G_RET_STS_ERROR THEN -- this return status indicates duplicate index value
       IF OE_ELECMSGS_PVT.Find_History_Entry ( p_order_source_id => l_order_source_id,
      					     p_sold_to_org_id  => l_sold_to_org_id,
        				     p_orig_sys_document_ref => l_orig_sys_document_ref,
           				     p_transaction_type => l_transaction_type,
           			             p_document_id     => l_document_id,
                                             x_last_itemkey    => l_last_itemkey,
                                             x_last_request_id => l_last_request_id) THEN
          IF l_curr_itemkey < nvl(l_last_itemkey, -1) THEN
             l_status := NULL;
             l_message_text := NULL;
             l_curr_itemkey := NULL;
             IF l_last_request_id IS NOT NULL THEN
                l_request_id := NULL;
             END IF;
             IF l_debug_level > 0 THEN
                oe_debug_pub.add('Out of sequence: p_itemkey : ' || p_itemkey || 'last_itemkey ' || l_last_itemkey);
             END IF;
          END IF;

          OE_ELECMSGS_PVT.Update_History_Entry (
              p_order_source_id => l_order_source_id,
              p_sold_to_org_id  => l_sold_to_org_id,
              p_orig_sys_document_ref => l_orig_sys_document_ref,
              p_transaction_type => l_transaction_type,
              p_document_id     => l_document_id,
              -- p_parent_document_id => l_parent_document_id,
              p_change_sequence => l_change_sequence,
              p_order_number    => l_order_number,
              p_order_type_id   => l_order_type_id,
              p_itemtype        => l_wf_itemtype,
              p_itemkey         => l_wf_itemkey,
              p_org_id          => l_org_id,
              p_status          => l_status,
              p_message_text    => l_message_text,
              p_request_id      => l_request_id,
              p_header_id       => l_header_id,
              p_document_disposition => l_document_disposition,
              p_last_update_itemkey => l_curr_itemkey,
              x_return_status   => l_result
              );
       END IF;
    END IF;
    wf_engine.SetItemUserKey (p_itemtype,
                             p_itemkey,
                             l_order_source_id||','||l_sold_to_org_id||','||l_orig_sys_document_ref
                             ||','||l_transaction_type||','||l_processing);

    p_x_result := l_result;

EXCEPTION
    WHEN OTHERS THEN
         --  The line below records this function call in the error system
         -- in the case of an exception.
         wf_core.context('OE_Elecmsgs_Pvt', 'Create_Or_Update_Hist_WF',
                    p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
         IF l_debug_level > 0 THEN
             oe_debug_pub.add('OTHERS in Create_Or_Update_Hist_WF ' || SQLERRM );
         END IF;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Create_Or_Update_Hist_Wf');
         END IF;
         -- don't put the error activity call for exception management
         -- since it doesn't make sense here
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
	 --p_x_result := FND_API.G_RET_STS_UNEXP_ERROR;

         raise;


END Create_Or_Update_Hist_WF;

-----------------------------------------------------------------
-- END WORKFLOW APIS
-----------------------------------------------------------------
-----------------------------------------------------------------
-- CONC PGM API
-----------------------------------------------------------------

PROCEDURE Open_Interface_Purge_Conc_Pgm
(  errbuf                          	OUT NOCOPY /* file.sql.39 change */ VARCHAR,
   retcode                         	OUT NOCOPY /* file.sql.39 change */ NUMBER,
   p_operating_unit                     IN  NUMBER DEFAULT NULL,
   p_view_name			        IN  VARCHAR2,
--   p_sold_to_org_id                   	IN  NUMBER,
   p_customer_number                    IN  NUMBER,
   p_order_source_id			IN  NUMBER,
   p_default_org_id                     IN  NUMBER DEFAULT NULL,
   p_process_null_org_id                IN  VARCHAR2 DEFAULT NULL,
   p_orig_sys_document_ref_from         IN  VARCHAR2,
   p_orig_sys_document_ref_to           IN  VARCHAR2,
   p_purge_child_tables                 IN  VARCHAR2 DEFAULT NULL
)
IS

  l_msg_count         NUMBER        := 0 ;
  l_msg_data          VARCHAR2(2000):= NULL ;
  l_message_text      VARCHAR2(2000);

  l_filename          VARCHAR2(200);
  l_request_id        NUMBER;
  l_return_status     VARCHAR2(30);
  --l_debug_level       CONSTANT NUMBER := to_number(nvl(fnd_profile.value('ONT_DEBUG_LEVEL'),'0'));
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_sold_to_org_Id    NUMBER := p_customer_number;
  l_header_iface      BOOLEAN := FALSE;
  l_line_iface        BOOLEAN := FALSE;
  l_header_cust_info  BOOLEAN := FALSE;
  l_line_cust_info    BOOLEAN := FALSE;
  l_header_credits    BOOLEAN := FALSE;
  l_header_price_adj  BOOLEAN := FALSE;
  l_header_price_att  BOOLEAN := FALSE;
  l_header_reservtns  BOOLEAN := FALSE;
  l_header_lotserial  BOOLEAN := FALSE;
  l_header_actions    BOOLEAN := FALSE;
  l_header_payments   BOOLEAN := FALSE;
  l_line_credits      BOOLEAN := FALSE;
  l_line_price_adj    BOOLEAN := FALSE;
  l_line_price_att    BOOLEAN := FALSE;
  l_line_reservtns    BOOLEAN := FALSE;
  l_line_lotserial    BOOLEAN := FALSE;
  l_line_actions      BOOLEAN := FALSE;
  l_line_payments     BOOLEAN := FALSE;
  l_elecmsgs          BOOLEAN := FALSE;
  l_header_acks       BOOLEAN := FALSE;
  l_line_acks         BOOLEAN := FALSE;
  MIN_DOC_REF         VARCHAR2(50) := '                  ';
  MAX_DOC_REF         VARCHAR2(50) := '999999999999999999';
  l_sold_to_org       VARCHAR2(360);
  l_dummy_cust_no     VARCHAR2(30);
  l_cust_rows         NUMBER := 0;
  l_min_order_source_id NUMBER;
  l_max_order_source_id NUMBER;
  l_c_min_ord_src     NUMBER;
  l_c_max_ord_src     NUMBER;
  l_purge_child_tables VARCHAR2(1) := nvl(p_purge_child_tables,'Y');
  l_yes               CONSTANT VARCHAR2(1) := 'Y';
  l_count             NUMBER;

BEGIN

   -----------------------------------------------------------
   -- Initialization
   -----------------------------------------------------------
   l_count := 0;

   -----------------------------------------------------------
   -- Log Output file
   -----------------------------------------------------------

  fnd_file.put_line(FND_FILE.OUTPUT, 'Purge Open Interface Data Concurrent Program');
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
  fnd_file.put_line(FND_FILE.OUTPUT, 'View Name: '||p_view_name);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Purge Child Tables: '||l_purge_child_tables);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Sold To Org Id: '|| p_customer_number);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Order Source Id: '|| p_order_source_id);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Orig Sys Document Ref From: '||p_orig_sys_document_ref_from);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Orig Sys Document Ref To: '||p_orig_sys_document_ref_to);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Org Id: '||p_operating_unit);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Default Org Id: '||p_default_org_id);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Process Records with No Org Specified: '||p_process_null_org_id);
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT,'Debug Level: '||l_debug_level);

   -----------------------------------------------------------
   -- Setting Debug Mode and File
   -----------------------------------------------------------

   If nvl(l_debug_level, 1) > 0 Then
      l_filename := oe_debug_pub.set_debug_mode ('FILE');
      fnd_file.put_line(FND_FILE.OUTPUT,'Debug File: ' || l_filename);
      fnd_file.put_line(FND_FILE.OUTPUT, '');
      l_filename := OE_DEBUG_PUB.set_debug_mode ('CONC');
   END IF;

   -----------------------------------------------------------
   -- Get Concurrent Request Id
   -----------------------------------------------------------
  fnd_profile.get('CONC_REQUEST_ID', l_request_id);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Request Id: '|| to_char(l_request_id));
  fnd_file.put_line(FND_FILE.OUTPUT, '');
   -----------------------------------------------------------
   -- Pre-processing
   -----------------------------------------------------------

   -- Set the policy context
  IF p_operating_unit IS NOT NULL THEN
     MO_GLOBAL.Set_Policy_Context ('S', p_operating_unit);
  END IF;

/*  this code is no longer necessary as the sold_to_org_id will now be passed in (bug 3396735)
   IF p_customer_number IS NOT NULL THEN

      l_sold_to_org_id := OE_Value_To_Id.sold_to_org (p_sold_to_org => NULL,p_customer_number => p_customer_number);
      IF l_sold_to_org_Id = FND_API.G_MISS_NUM THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('Sold To Org Id cannot be derived - returning');
         END IF;
         retcode := 2;
         errbuf  := SQLERRM;
         Return;
      END IF;
   END IF;
*/
   IF l_sold_to_org_id IS NOT NULL THEN
      OE_Id_To_Value.sold_to_org (p_sold_to_org_id => l_sold_to_org_id, x_org => l_sold_to_org, x_customer_number => l_dummy_cust_no);
   END IF;
   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('Sold To Org Id : ' || l_sold_to_org_Id);
      oe_debug_pub.add ('Sold To Org derived : ' || l_sold_to_org);
      oe_debug_pub.add ('Org Id: ' || p_operating_unit);
      oe_debug_pub.add ('Default Org Id: ' || p_default_org_id);
      oe_debug_pub.add ('Process Records with No Org Specified: ' || p_process_null_org_id);
   END IF;

   -----------------------------------------------------------
   -- Delete Rows
   -----------------------------------------------------------
   /* Depending on Table/View name (parameter p_view_name), execute the
		   SQL statements given below */

   IF p_view_name IN ('OE_HEADERS_INTERFACE') THEN
      l_header_iface := TRUE;
      IF l_purge_child_tables = 'Y' THEN
         l_header_price_adj   := TRUE;
         l_header_cust_info   := TRUE;
         l_header_credits     := TRUE;
         l_header_price_att   := TRUE;
         l_header_actions     := TRUE;
         l_header_payments    := TRUE;
         l_line_iface         := TRUE;
         l_line_cust_info     := TRUE;
         l_line_price_adj     := TRUE;
         l_line_credits       := TRUE;
         l_line_price_att     := TRUE;
         l_line_reservtns     := TRUE;
         l_line_lotserial     := TRUE;
         l_line_actions       := TRUE;
         l_line_payments      := TRUE;
     END IF;
   END IF;
   IF p_view_name IN ('OE_LINES_INTERFACE') THEN
      l_line_iface := TRUE;
      IF l_purge_child_tables = 'Y' THEN
         l_line_cust_info   := TRUE;
         l_line_price_adj     := TRUE;
         l_line_credits       := TRUE;
         l_line_price_att     := TRUE;
         l_line_reservtns     := TRUE;
         l_line_lotserial     := TRUE;
         l_line_actions       := TRUE;
         l_line_payments      := TRUE;
     END IF;
   END IF;
   IF p_view_name IN ('OE_HEADER_ACKS') THEN
      l_header_acks := TRUE;
      IF l_purge_child_tables = 'Y' THEN
         l_line_acks          := TRUE;
     END IF;
   END IF;
   IF p_view_name IN ('OE_LINE_ACKS') THEN
      l_line_acks             := TRUE;
   END IF;
   IF p_view_name IN ('OE_EM_INFORMATION') THEN
      l_elecmsgs              := TRUE;
   END IF;

   /* to use the index on tracking and interface tables we gather the max and min order source id
      in appropriate cases */
   IF p_order_source_id IS NULL THEN
      IF p_view_name IN ('OE_HEADERS_INTERFACE', 'OE_LINES_INTERFACE','OE_EM_INFORMATION') THEN

         SELECT max(order_source_id), min(order_source_id)
           INTO l_max_order_source_id, l_min_order_source_id
           FROM OE_Order_Sources;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Fetched min order source id ' || l_min_order_source_id || ' and max order source id ' || l_max_order_source_id);
         END IF;
      END IF;
   END IF;

   IF l_header_cust_info THEN

      IF p_order_source_id IS NOT NULL THEN
         l_c_min_ord_src := p_order_source_id;
         l_c_max_ord_src := p_order_source_id;
      ELSE
         l_c_min_ord_src := l_min_order_source_id;
         l_c_max_ord_src := l_max_order_source_id;
      END IF;
         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.orig_sys_customer_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.orig_sys_customer_ref IS NOT NULL)
            AND c.customer_info_type_code = 'ACCOUNT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for customer ref with org_id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.orig_sys_customer_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.orig_sys_customer_ref IS NOT NULL
                                               AND h.org_id IS NULL)
	     AND c.customer_info_type_code = 'ACCOUNT';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.sold_to_contact_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.sold_to_contact_ref IS NOT NULL)
            AND c.customer_info_type_code = 'CONTACT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records for sold to contact with org id');
          END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.sold_to_contact_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.sold_to_contact_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'CONTACT';
            l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
            END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.bill_to_contact_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.bill_to_contact_ref IS NOT NULL)
            AND c.customer_info_type_code = 'CONTACT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for bill to contact ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.bill_to_contact_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.bill_to_contact_ref IS NOT NULL
					       AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'CONTACT';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC


         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.ship_to_contact_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.ship_to_contact_ref IS NOT NULL)
            AND c.customer_info_type_code = 'CONTACT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for ship to contact ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.ship_to_contact_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.ship_to_contact_ref IS NOT NULL
					       AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'CONTACT';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.deliver_to_contact_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.deliver_to_contact_ref IS NOT NULL)
            AND c.customer_info_type_code = 'CONTACT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for deliver to contact ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.deliver_to_contact_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.deliver_to_contact_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'CONTACT';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.orig_ship_address_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.orig_ship_address_ref IS NOT NULL)
            AND c.customer_info_type_code = 'ADDRESS';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for ship address ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.orig_ship_address_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.orig_ship_address_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'ADDRESS';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.orig_bill_address_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.orig_bill_address_ref IS NOT NULL)
            AND c.customer_info_type_code = 'ADDRESS';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for bill address ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.orig_bill_address_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.orig_bill_address_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'ADDRESS';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.orig_deliver_address_ref
                                          FROM OE_Headers_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.orig_deliver_address_ref IS NOT NULL)
            AND c.customer_info_type_code = 'ADDRESS';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for deliver address ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.orig_deliver_address_ref
					      FROM OE_Headers_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.orig_deliver_address_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'ADDRESS';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_cust_rows || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Customer Info Interface (Header): '|| l_cust_rows);
   END IF;

   IF l_header_iface THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting from OE_HEADERS_INTERFACE');
      END IF;
     l_count := 0;

      -- For the interface tables, we delete if either the sold to org or sold to org id
      -- are populated with the value corresponding to the conc pgm
      -- For the other tables, the data is always populated internally
      -- and hence we can always be sure that sold_to_org_id is populated, if at all
      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Headers_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
          l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	  DELETE
	    FROM OE_Headers_Iface_All
	   WHERE order_source_id = p_order_source_id
	     AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					    AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	     AND (l_sold_to_org_id IS NULL
		  OR l_sold_to_org_id = sold_to_org_id
		  OR l_sold_to_org = sold_to_org)
             AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Headers_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
              l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Headers_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
            l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;


      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Headers Interface: '|| l_count);
   END IF;

   IF l_header_actions THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Header records from OE_ACTIONS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Actions_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;


        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Actions_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Actions_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Actions_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(SQL%ROWCOUNT || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Actions Interface (Header): '|| l_count);
   END IF;
   IF l_header_credits THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Header records from OE_CREDITS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Credits_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Credits_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Credits_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Credits_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Credits Interface (Header): '|| l_count);
   END IF;
   IF l_header_price_adj THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Header records from OE_PRICE_ADJS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Price_Adjs_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Adjs_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Price_Adjs_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
              l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Adjs_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Price Adjustments Interface (Header): '||  l_count);
   END IF;
   IF l_header_price_att THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Header records from OE_PRICE_ATTS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Price_Atts_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Atts_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Price_Atts_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Atts_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Pricing Attributes Interface (Header): '|| l_count);
   END IF;

   IF l_header_payments THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Header records from OE_PAYMENTS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Payments_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
       l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Payments_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Payments_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
       l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Payments_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Payments Interface (Header): '|| l_count);
   END IF;

   IF l_line_cust_info THEN
      l_cust_rows := 0; -- reinitialize

      IF p_order_source_id IS NOT NULL THEN
         l_c_min_ord_src := p_order_source_id;
         l_c_max_ord_src := p_order_source_id;
      ELSE
         l_c_min_ord_src := l_min_order_source_id;
         l_c_max_ord_src := l_max_order_source_id;
      END IF;


         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.bill_to_contact_ref
                                          FROM OE_Lines_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.bill_to_contact_ref IS NOT NULL)
            AND c.customer_info_type_code = 'CONTACT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for bill to contact ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.bill_to_contact_ref
					      FROM OE_Lines_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.bill_to_contact_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'CONTACT';
             l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.ship_to_contact_ref
                                          FROM OE_Lines_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.ship_to_contact_ref IS NOT NULL)
            AND c.customer_info_type_code = 'CONTACT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for ship to contact ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.ship_to_contact_ref
					      FROM OE_Lines_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.ship_to_contact_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'CONTACT';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.deliver_to_contact_ref
                                          FROM OE_Lines_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.deliver_to_contact_ref IS NOT NULL)
            AND c.customer_info_type_code = 'CONTACT';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for deliver to contact ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.deliver_to_contact_ref
					      FROM OE_Lines_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.deliver_to_contact_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'CONTACT';
             l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.orig_ship_address_ref
                                          FROM OE_Lines_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.orig_ship_address_ref IS NOT NULL)
            AND c.customer_info_type_code = 'ADDRESS';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for ship to address ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.orig_ship_address_ref
					      FROM OE_Lines_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.orig_ship_address_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'ADDRESS';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.orig_bill_address_ref
                                          FROM OE_Lines_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.orig_bill_address_ref IS NOT NULL)
            AND c.customer_info_type_code = 'ADDRESS';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for bill to address ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.orig_bill_address_ref
					      FROM OE_Lines_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.orig_bill_address_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'ADDRESS';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

         DELETE
           FROM OE_Customer_Info_Iface_All c
          WHERE c.customer_info_ref IN (SELECT h.orig_deliver_address_ref
                                          FROM OE_Lines_Interface h
                                         WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
                                           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
                                           AND (l_sold_to_org_id IS NULL
                                                OR l_sold_to_org_id = sold_to_org_id
                                                OR l_sold_to_org = sold_to_org)
                                           AND h.orig_deliver_address_ref IS NOT NULL)
            AND c.customer_info_type_code = 'ADDRESS';
         l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Deleted '|| l_cust_rows || ' records for deliver address ref with org id');
         END IF;

         -- Start MOAC
         IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	     DELETE
	       FROM OE_Customer_Info_Iface_All c
	      WHERE c.customer_info_ref IN (SELECT h.orig_deliver_address_ref
					      FROM OE_Lines_Iface_All h
					     WHERE order_source_id between l_c_min_ord_src and l_c_max_ord_src
					       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
									      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
					       AND (l_sold_to_org_id IS NULL
						    OR l_sold_to_org_id = sold_to_org_id
						    OR l_sold_to_org = sold_to_org)
					       AND h.orig_deliver_address_ref IS NOT NULL
                                               AND h.org_id IS NULL)
		AND c.customer_info_type_code = 'ADDRESS';
	     l_cust_rows :=  l_cust_rows + SQL%ROWCOUNT;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
             END IF;
         END IF;
         -- End MOAC

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_cust_rows || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Customer Info Interface (Line): '|| l_cust_rows);
   END IF;
   IF l_line_iface THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting from OE_LINES_INTERFACE');
      END IF;
      l_count := 0;
      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Lines_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
              l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Lines_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Lines_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Lines_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Lines Interface: '||  l_count);
   END IF;

   IF l_line_actions THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Line records from OE_ACTIONS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Actions_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Actions_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Actions_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Actions_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Actions Interface (Line): '|| l_count);
   END IF;
   IF l_line_credits THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Line records from OE_CREDITS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Credits_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Credits_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Credits_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
       l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Credits_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Credits Interface (Line): '|| l_count);
   END IF;
   IF l_line_lotserial THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Line records from OE_LOTSERIALS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_LotSerials_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
       l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_LotSerials_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_LotSerials_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
       l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_LotSerials_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Lotserials Interface (Line): '|| l_count );
   END IF;
   IF l_line_price_adj THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Line records from OE_PRICE_ADJS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Price_Adjs_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Adjs_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Price_Adjs_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Adjs_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Price Adjustments Interface (Line): '|| l_count );
   END IF;
   IF l_line_price_att THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Line records from OE_PRICE_ATTS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Price_Atts_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
       l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Atts_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Price_Atts_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Price_Atts_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count  || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Pricing Attributes Interface (Line): '|| l_count );
   END IF;
   IF l_line_reservtns THEN
  IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Line records from OE_RESERVTNS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Reservtns_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Reservtns_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Reservtns_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
       l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Reservtns_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
               AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Reservations Interface (Line): '|| l_count );
   END IF;

   IF l_line_payments THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Line records from OE_PAYMENTS_INTERFACE');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL THEN
        DELETE
          FROM OE_Payments_Interface
         WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Payments_Iface_All
	     WHERE order_source_id = p_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      ELSE
        DELETE
          FROM OE_Payments_Interface
         WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND orig_sys_line_ref IS NOT NULL
           AND (l_sold_to_org_id IS NULL
                OR l_sold_to_org_id = sold_to_org_id
                OR l_sold_to_org = sold_to_org);
        l_count := l_count + SQL%ROWCOUNT;

        -- Start MOAC
        IF p_process_null_org_id = 'Y' AND (p_operating_unit IS NULL OR p_operating_unit = p_default_org_id) THEN
	    DELETE
	      FROM OE_Payments_Iface_All
	     WHERE order_source_id BETWEEN l_min_order_source_id and l_max_order_source_id
	       AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
					      AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
	       AND orig_sys_line_ref IS NOT NULL
	       AND (l_sold_to_org_id IS NULL
		    OR l_sold_to_org_id = sold_to_org_id
		    OR l_sold_to_org = sold_to_org)
	       AND org_id IS NULL;
           l_count := l_count + SQL%ROWCOUNT;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Deleted '|| SQL%ROWCOUNT || ' records with NULL Org Id');
           END IF;
        END IF;
        -- End MOAC
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Payments Interface (Line): '|| l_count );
   END IF;

   IF l_header_acks THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Acknowledged Header records from OE_HEADER_ACKS');
      END IF;
      l_count := 0;

      IF p_orig_sys_document_ref_from IS NOT NULL
         AND p_orig_sys_document_ref_to IS NOT NULL THEN
             DELETE
               FROM OE_Header_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  BETWEEN p_orig_sys_document_ref_from
                                           AND p_orig_sys_document_ref_to
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      ELSIF p_orig_sys_document_ref_from IS NOT NULL THEN
             DELETE
               FROM OE_Header_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  >= p_orig_sys_document_ref_from
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      ELSIF p_orig_sys_document_ref_to IS NOT NULL THEN
             DELETE
               FROM OE_Header_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  <= p_orig_sys_document_ref_to
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      ELSE
             DELETE
               FROM OE_Header_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  >= ' '
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      END IF;
     l_count := l_count + SQL%ROWCOUNT;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Header Acknowledgments: '|| l_count );
   END IF;
   IF l_line_acks THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting Acknowledged Line records from OE_LINE_ACKS');
      END IF;
     l_count := 0;

      IF p_orig_sys_document_ref_from IS NOT NULL
         AND p_orig_sys_document_ref_to IS NOT NULL THEN
             DELETE
               FROM OE_Line_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  BETWEEN p_orig_sys_document_ref_from
                                           AND p_orig_sys_document_ref_to
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      ELSIF p_orig_sys_document_ref_from IS NOT NULL THEN
             DELETE
               FROM OE_Line_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  >= p_orig_sys_document_ref_from
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      ELSIF p_orig_sys_document_ref_to IS NOT NULL THEN
             DELETE
               FROM OE_Line_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  <= p_orig_sys_document_ref_to
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      ELSE
             DELETE
               FROM OE_Line_Acks
              WHERE order_source_id = nvl(p_order_source_id, order_source_id)
                AND orig_sys_document_ref  >= ' '
                AND sold_to_org_id  = nvl(l_sold_to_org_id, sold_to_org_id)
                AND nvl(acknowledgment_flag, 'N') = 'Y'
                AND ((p_operating_unit IS NULL AND MO_GLOBAL.Check_Access (org_id) = l_yes) OR org_id = p_operating_unit);
      END IF;

      l_count := l_count + SQL%ROWCOUNT;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Line Acknowledgments: '|| l_count);
   END IF;
   IF l_elecmsgs THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Deleting records from OE_EM_INFORMATION');
      END IF;
      l_count := 0;

      IF p_order_source_id IS NOT NULL AND l_sold_to_org_id IS NOT NULL THEN
         DELETE
           FROM OE_EM_Information
          WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND sold_to_org_id  = l_sold_to_org_id;
      ELSIF p_order_source_id IS NOT NULL THEN
         DELETE
           FROM OE_EM_Information
          WHERE order_source_id = p_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND sold_to_org_id  = nvl(l_sold_to_org_id,sold_to_org_id);
      ELSIF l_sold_to_org_id IS NOT NULL THEN
         DELETE
           FROM OE_EM_Information
          WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND sold_to_org_id  = l_sold_to_org_id;
      ELSE
         DELETE
           FROM OE_EM_Information
          WHERE order_source_id BETWEEN l_min_order_source_id AND l_max_order_source_id
           AND orig_sys_document_ref  BETWEEN nvl(p_orig_sys_document_ref_from, orig_sys_document_ref)
                                          AND nvl(p_orig_sys_document_ref_to, orig_sys_document_ref)
           AND sold_to_org_id  = nvl(l_sold_to_org_id,sold_to_org_id);
      END IF;
      l_count := l_count + SQL%ROWCOUNT;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(l_count || ' rows deleted');
      END IF;
      fnd_file.put_line(FND_FILE.OUTPUT, 'Rows Deleted from Open Interface Tracking table: '|| l_count);
   END IF;

  retcode := 0;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Program exited normally');
  END IF;
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Program exited with code : ' || retcode);
EXCEPTION

   WHEN OTHERS THEN
     retcode := 2;
     errbuf  := SQLERRM;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SQLERRM: '||SQLERRM||' SQLCODE:'||SQLCODE ) ;
     END IF;
     fnd_file.put_line(FND_FILE.OUTPUT, '');
     fnd_file.put_line(FND_FILE.OUTPUT, 'Program exited with code : '||retcode);
     fnd_file.put_line(FND_FILE.OUTPUT,  'SQLERRM: '||SQLERRM||' SQLCODE:'||SQLCODE );
     IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Open_Interface_Purge_Conc_Pgm');
     End if;
End Open_Interface_Purge_Conc_Pgm;

-----------------------------------------------------------------
-- END CONC PGM API
-----------------------------------------------------------------

PROCEDURE Initialize_EM_Access_List (X_Access_List OUT NOCOPY OE_GLOBALS.ACCESS_LIST)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ELECMSGS_PVT.INITIALIZE_ACCESS_LIST') ;
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_RETRY_WF') THEN
        Add_Access('RETRY_WF');
      END IF;

      IF FND_FUNCTION.TEST('ONT_OEXOEORD_PROCESS_MESSAGES') THEN
        Add_Access('PROCESS_MESSAGES');
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ELECMSGS_PVT.INITIALIZE_ACCESS_LIST') ;
      END IF;

     X_Access_List := OE_GLOBALS.G_EM_ACCESS_LIST;
END Initialize_EM_Access_List;

PROCEDURE Add_Access(Function_Name VARCHAR2)
IS
   i  number:=0;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ENTERING OE_ELECMSGS_PVT.ADD_ACCESS' ) ;
      END IF;
     IF OE_GLOBALS.G_EM_ACCESS_List.Count=0 THEN
       OE_GLOBALS.G_EM_Access_List(1):=Function_Name;
     ELSIF OE_GLOBALS.G_EM_ACCESS_List.Count>0 THEN
       i:=OE_GLOBALS.G_EM_ACCESS_List.Last+1;
       OE_GLOBALS.G_EM_ACCESS_List(i):=Function_Name;
     END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_ELECMSGS_PVT.ADD_ACCESS') ;
      END IF;
   EXCEPTION
    When Others Then
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'ADD_ACCESS'
            );
        END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Add_Access;


END OE_ELECMSGS_PVT;

/
