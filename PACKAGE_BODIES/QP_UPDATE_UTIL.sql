--------------------------------------------------------
--  DDL for Package Body QP_UPDATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UPDATE_UTIL" AS
/* $Header: QPXQINDB.pls 120.4 2006/08/14 22:36:28 jhkuo noship $ */


PROCEDURE Update_Qualification_Ind
		  (p_worker            NUMBER,
                   p_line_type         VARCHAR2,
                   p_List_Line_Id_Low  NUMBER DEFAULT NULL,
		   p_List_Line_Id_High NUMBER DEFAULT NULL,
                   p_last_proc_line    NUMBER :=  0)
IS

l_old_header_id     NUMBER := -9999;
l_old_header_qual_exists BOOLEAN := FALSE;

TYPE Num_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE Char30_Type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

l_list_line_id_tbl       Num_Type;
l_qualification_ind_tbl  Num_Type;
l_list_type_code_tbl     Char30_Type;
l_list_header_id_tbl     Num_Type;

l_count                NUMBER;
l_rows                 NATURAL := 5000;
l_total_rows           NUMBER := 0;

cursor list_lines_cur(a_list_line_id NUMBER,b_list_line_id NUMBER)
is
  select l.list_line_id, l.qualification_ind, h.list_type_code, h.list_header_id
  from   qp_list_lines l, qp_list_headers_b h
  where  l.list_header_id = h.list_header_id
  and    (l.list_line_id between a_list_line_id and b_list_line_id)
  order by l.list_line_id;

l_new_list_line_id_low NUMBER;
l_index                NUMBER;

BEGIN

  --Determine the new list_line_id_low for re-runnability.
  l_new_list_line_id_low := GREATEST(p_last_proc_line + 1, p_list_line_id_low);

  OPEN list_lines_cur(l_new_list_line_id_low, p_list_line_id_high);

  LOOP
    l_list_line_id_tbl.delete;
    l_list_header_id_tbl.delete;
    l_qualification_ind_tbl.delete;
    l_list_type_code_tbl.delete;

    FETCH list_lines_cur BULK COLLECT INTO l_list_line_id_tbl,
              l_qualification_ind_tbl, l_list_type_code_tbl,
              l_list_header_id_tbl LIMIT l_rows;

    EXIT WHEN l_list_line_id_tbl.COUNT = 0;

    BEGIN

      FOR i IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
      LOOP
        BEGIN
          --Initialize qualification_ind to 0.
          l_qualification_ind_tbl(i) := 0;

          --If line has rltd modifiers, then increment qual_ind by 1.
          BEGIN
            select 1
	    into   l_count
	    from   qp_rltd_modifiers
	    where  to_rltd_modifier_id = l_list_line_id_tbl(i)
	    and    rltd_modifier_grp_type <> 'COUPON'
            and    rownum = 1;

          EXCEPTION
            WHEN  NO_DATA_FOUND  THEN
              l_count := 0;
	  END;

          IF l_count > 0 THEN
            l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 1;
          END IF;

          --If line belongs to Price List or Agreement and if the PRL or AGR
		--has header-level qualifier other than Primary PL that are
		--qualifiers of Secondary PLs, then increment qual_ind by 2.
          IF l_list_type_code_tbl(i) IN ('AGR', 'PRL') THEN

	    IF l_old_header_id <> l_list_header_id_tbl(i) THEN

	      l_old_header_id := l_list_header_id_tbl(i);

              BEGIN
                select 1
	        into   l_count
                from   qp_qualifiers
		where  list_header_id = l_list_header_id_tbl(i)
		and    NOT (qualifier_context = 'MODLIST' and
		 	    qualifier_attribute = 'QUALIFIER_ATTRIBUTE4')
                and    rownum = 1;

              EXCEPTION
                WHEN  NO_DATA_FOUND  THEN
                  l_count := 0;
	      END;

	      IF l_count > 0 THEN
                l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 2;
		l_old_header_qual_exists := TRUE;
	      ELSE
	        l_old_header_qual_exists :=  FALSE;
	      END IF;

            ELSE -- current list_header_id same as old_header_id

	      IF l_old_header_qual_exists THEN
                l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 2;
	      END IF;

            END IF; -- If current list_header_id different from old_header_id

	  --For all other list header types
	  ELSE
	    --If header-level qualifier exists for the list_header_id then
	    --increment qual ind by 2
            IF l_old_header_id <> l_list_header_id_tbl(i) THEN

	      l_old_header_id := l_list_header_id_tbl(i);

              BEGIN
                select 1
		into   l_count
	    	from   qp_qualifiers
		where  list_header_id = l_list_header_id_tbl(i)
		and    nvl(list_line_id,-1) = -1
                and    rownum = 1;

              EXCEPTION
                WHEN  NO_DATA_FOUND  THEN
                  l_count := 0;
	      END;

	      IF l_count > 0 THEN
                l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 2;
		l_old_header_qual_exists :=  TRUE;
	      ELSE
		l_old_header_qual_exists :=  FALSE;
	      END IF;

            ELSE -- current list_header_id same as old_header_id

	      IF l_old_header_qual_exists THEN
                l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 2;
	      END IF;

            END IF; -- If current list_header_id different from old_header_id

	    --If line-level qualifier exists for the list_line_id then
	    --increment qual ind by 8
            BEGIN
              select 1
	      into   l_count
	      from   qp_qualifiers
	      where  list_header_id = l_list_header_id_tbl(i)
	      and    list_line_id = l_list_line_id_tbl(i)
              and    rownum = 1;

            EXCEPTION
              WHEN  NO_DATA_FOUND  THEN
                l_count := 0;
	    END;

	    IF l_count > 0 THEN
              l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 8;
	    END IF;

          END IF;

          --If line has product attributes, then increment qual_ind by 4.
          BEGIN
	    select 1
	    into   l_count
	    from   qp_pricing_attributes
	    where  list_line_id = l_list_line_id_tbl(i)
	    and    excluder_flag = 'N'
            and    rownum = 1;

          EXCEPTION
            WHEN  NO_DATA_FOUND  THEN
              l_count := 0;
	  END;

	  IF l_count > 0 THEN
            l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 4;
	  END IF;

          --If line has pricing attributes, then increment qual_ind by 16.
          BEGIN
	    select 1
	    into   l_count
	    from   qp_pricing_attributes
	    where  list_line_id = l_list_line_id_tbl(i)
	    and    pricing_attribute_context is not null
	    and    pricing_attribute is not null
            -- changes made per rchellam's request--spgopal
	    and    pricing_attr_value_from IS NOT NULL
            and    rownum = 1;

          EXCEPTION
            WHEN  NO_DATA_FOUND  THEN
              l_count := 0;
	  END;

	  IF l_count > 0 THEN
            l_qualification_ind_tbl(i) := l_qualification_ind_tbl(i) + 16;
	  END IF;

        EXCEPTION
	  WHEN OTHERS THEN
	    rollback;
	    QP_UTIL.Log_Error(
                      p_id1 => 'Error in list_line_id ' ||
		    	to_char(l_list_line_id_tbl(l_list_line_id_tbl.FIRST + SQL%ROWCOUNT)),
		      p_id2 => substr(sqlerrm, 1, 30),
		      p_error_type => 'UPDATE_QUALIFICATION_IND',
		      p_error_desc => 'Error Processing list_line_id '||
		        to_char(l_list_line_id_tbl(l_list_line_id_tbl.FIRST + SQL%ROWCOUNT)),
		      p_error_module => 'Update_Qualification_Ind');
	    raise;
        END;

      END LOOP; --End of For Loop

     FORALL j IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
          UPDATE qp_list_lines
		SET    qualification_ind = l_qualification_ind_tbl(j)
		WHERE  list_line_id = l_list_line_id_tbl(j);

      FORALL k IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
          UPDATE qp_pricing_attributes
		SET    qualification_ind = l_qualification_ind_tbl(k)
		WHERE  list_line_id = l_list_line_id_tbl(k);

      l_total_rows := l_total_rows + SQL%ROWCOUNT;

    EXCEPTION
      WHEN OTHERS THEN
	rollback;
	QP_UTIL.Log_Error(
	    p_id1 => 'Error in list_line_id ' ||
	      to_char(l_list_line_id_tbl(l_list_line_id_tbl.FIRST + SQL%ROWCOUNT)),
            p_id2 => substr(sqlerrm, 1, 30),
	    p_error_type => 'UPDATE_QUALIFICATION_IND',
	    p_error_desc => 'Error Processing list_line_id '||
	      to_char(l_list_line_id_tbl(l_list_line_id_tbl.FIRST + SQL%ROWCOUNT)),
	    p_error_module => 'Update_Qualification_Ind');
	raise;
    END;

    --Fetch the index of the last list_line_id processed successfully.
    l_index := l_list_line_id_tbl.LAST;

    --Update the qp_upg_lines_distribution table's record for the current worker and
    --line_type with the last list_line_id successfully processed.
    UPDATE qp_upg_lines_distribution
    SET    last_proc_line = l_list_line_id_tbl(l_index)
    WHERE  worker = p_worker
    AND    line_type = p_line_type;

    COMMIT; --after every 5000(l_rows) lines are processed

  END LOOP; --End of cursor loop

  CLOSE list_lines_cur;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE list_lines_cur;
    RAISE;

END Update_Qualification_ind;


PROCEDURE update_pricing_attributes(
            p_start_rowid  ROWID DEFAULT NULL,
            p_end_rowid    ROWID DEFAULT NULL)
IS
canonical_mask VARCHAR2(100) := qp_number.canonical_mask;

BEGIN
  UPDATE
   (SELECT list_header_id, pricing_phase_id, qualification_ind,
           list_line_id, pricing_attribute_datatype,
           pricing_attr_value_from, pricing_attr_value_to,
           pricing_attr_value_from_number, pricing_attr_value_to_number,
           CASE
             WHEN comparison_operator_code = 'BETWEEN'
                  AND pricing_attr_value_from IS NULL
                  AND pricing_attr_value_to IS NOT NULL
             THEN DECODE(pricing_attribute_datatype,
                         'N', '-9999999999',
                         'C', '0',
                         '0001/01/01 00:00:00')
             ELSE pricing_attr_value_from
           END new_from,
           CASE
             WHEN comparison_operator_code = 'BETWEEN'
                  AND pricing_attr_value_from IS NOT NULL
                  AND pricing_attr_value_to IS NULL
             THEN DECODE(pricing_attribute_datatype,
                         'N', '9999999999',
                         'C', 'z',
                         '9999/01/01 00:00:00')
             ELSE pricing_attr_value_to
           END new_to
    FROM   qp_pricing_attributes
    WHERE  rowid BETWEEN
             p_start_rowid AND p_end_rowid) pa
  SET (list_header_id, pricing_phase_id, qualification_ind) =
        (SELECT ll.list_header_id, ll.pricing_phase_id, ll.qualification_ind
         FROM   qp_list_lines ll
         WHERE  ll.list_line_id = pa.list_line_id),
        pricing_attr_value_from = new_from,
        pricing_attr_value_to = new_to,
        pricing_attr_value_from_number =
          DECODE(pricing_attribute_datatype, 'N',
                 DECODE(ltrim(new_from, '0123456789.-'),
                        null, to_number(new_from, canonical_mask))),
        pricing_attr_value_to_number =
          DECODE(pricing_attribute_datatype, 'N',
                 DECODE(ltrim(new_to, '0123456789.-'),
                        null, to_number(new_to, canonical_mask)));

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;

END update_pricing_attributes;

procedure  create_parallel_slabs
       (  l_workers IN number := 5,
          p_batchsize in number := 5000)
      is
      v_type              varchar2(30) := 'UPA'; -- for QPXUPPAB.sql

      cursor pricing_attributes
      is
      select pa.pricing_attribute_id pricing_attribute_id
             /* Removed hint to tune the sqlstmt */
      from  qp_pricing_attributes  pa, qp_list_lines ll
      where pa.list_line_id = ll.list_line_id
      and   pa.list_header_id is null
      and   pa.pricing_phase_id is null
      order by pricing_attribute_id;


      l_total_lines     number;
      l_min_line        number;
      l_max_line        number;
      l_counter           number;
      l_gap               number;
      l_worker_count        number;
      l_worker_start        number;
      l_worker_end          number;
      l_pricing_attribute_id     number;
      l_start_flag        number;
      l_total_workers       number;

   Begin

      delete from qp_upg_lines_distribution
      where line_type = v_type;

      commit;

      begin
                select
                     count(*),
                     nvl(min(pricing_attribute_id),0),
                     nvl(max(pricing_attribute_id),0)
                into
                     l_total_lines,
                     l_min_line,
                     l_max_line
                from  qp_pricing_attributes  pa, qp_list_lines ll
                where pa.list_line_id = ll.list_line_id
                and   pa.list_header_id is null
                and   pa.pricing_phase_id is null;

           exception
                when others then
                  null;
      end;

         if  l_total_lines < p_batchsize  or l_workers = 1 then


                qp_modifier_upgrade_util_pvt.insert_line_distribution
                (
                    l_worker             => 1,
                    l_start_line  => l_min_line,
                    l_end_line    => l_max_line,
                    l_type_var         => 'UPA'
                );

         else
                l_max_line  := 0;
                l_min_line  := 0;
                l_total_workers := l_workers;
                l_counter     := 0;
                l_start_flag  := 0;
                l_worker_count  := 0;
                l_gap         := round(l_total_lines / l_total_workers, 0);

                for pa_rec in pricing_attributes loop

                    l_pricing_attribute_id := pa_rec.pricing_attribute_id;
                    l_counter       := l_counter + 1;

                    if l_start_flag = 0 then
                              l_start_flag := 1;
                              l_min_line := pa_rec.pricing_attribute_id;
                              l_max_line := NULL;
                              l_worker_count := l_worker_count + 1;
                    end if;

                  if l_counter = l_gap and l_worker_count < l_total_workers
                  then
                         l_max_line := pa_rec.pricing_attribute_id;

                     qp_modifier_upgrade_util_pvt.insert_line_distribution
                     (
                       l_worker             => l_worker_count,
                       l_start_line  => l_min_line,
                       l_end_line    => l_max_line,
                       l_type_var         => 'UPA'
                     );

                         l_counter    := 0;
                         l_start_flag := 0;

                  end if;

                end loop;

                l_max_line := l_pricing_attribute_id;

                     qp_modifier_upgrade_util_pvt.insert_line_distribution
                     (
                       l_worker             => l_worker_count,
                       l_start_line  => l_min_line,
                       l_end_line    => l_max_line,
                       l_type_var         => 'UPA'
                     );


                commit;
	 end if;

end create_parallel_slabs;

End QP_Update_Util;

/
