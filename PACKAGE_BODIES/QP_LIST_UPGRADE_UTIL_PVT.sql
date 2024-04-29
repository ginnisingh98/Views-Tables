--------------------------------------------------------
--  DDL for Package Body QP_LIST_UPGRADE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIST_UPGRADE_UTIL_PVT" as
/* $Header: QPXVUPLB.pls 120.1 2006/03/21 11:17:25 rnayani noship $ */

Procedure upgrade_flex_structures is
err_num         NUMBER;
err_msg         VARCHAR2(100);
BEGIN

 QP_UTIL.QP_UPGRADE_CONTEXT('OE', 'QP', 'SO_PRICE_LISTS', 'QP_LIST_HEADERS');

 QP_UTIL.QP_UPGRADE_CONTEXT('OE', 'QP', 'SO_PRICE_LIST_LINES', 'QP_LIST_LINES');

EXCEPTION

     WHEN OTHERS THEN
			err_num := SQLCODE;
			err_msg := SUBSTR(SQLERRM, 1, 240);
			ROLLBACK;
			qp_util.log_error(NULL, NULL, NULL, NULL,
									 NULL, NULL, NULL, NULL,
									 'UPGRADE_FLEX_STRUCTURES',
									 err_msg, 'PRICE_LISTS');
               RAISE;
END upgrade_flex_structures;


procedure insert_line_distribution
(
l_worker in number,
l_start_line  IN  Number,
l_end_line    IN  Number,
l_type_var    IN  Varchar2
)
is
Begin

       insert into qp_upg_lines_distribution
       (
           worker,
           start_line_id,
           end_line_id,
           alloted_flag,
           line_type,
           creation_date
       )
       values
       (
           l_worker,
           l_start_line,
           l_end_line,
           'N',
           l_type_var,
           sysdate
       );

end insert_line_distribution;


procedure  create_parallel_lines
       (  l_workers IN number := 5,
          p_batchsize in number := 5000)
      is
      v_type              varchar2(30) := 'PLL';

      cursor lines
      is
      select
          price_list_line_id
      from
          so_price_list_lines_115
      where  price_list_line_id not in ( select list_line_id
                                          from qp_LIST_lines )
      order by price_list_line_id;


      l_total_lines     number;
      l_min_line        number;
      l_max_line        number;
      l_counter           number;
      l_gap               number;
      l_worker_count        number;
      l_worker_start        number;
      l_worker_end          number;
      l_price_list_line_id     number;
      l_start_flag        number;
      l_total_workers       number;

   Begin

      delete from qp_upg_lines_distribution
      where line_type = v_type;

      commit;

      begin
                select
                     count(*),
                     nvl(min(price_list_line_id),0),
                     nvl(max(price_list_line_id),0)
                into
                     l_total_lines,
                     l_min_line,
                     l_max_line
                from
                     so_price_list_lines_115
                where  price_list_line_id not in ( select list_line_id
                                                from qp_LIST_lines );

           exception
                when others then
                  null;
      end;

         if  l_total_lines < p_batchsize  or l_workers = 1 then


                insert_line_distribution
                (
                    l_worker             => 1,
                    l_start_line  => l_min_line,
                    l_end_line    => l_max_line,
                    l_type_var         => 'PLL'
                );

         else
                l_max_line  := 0;
                l_min_line  := 0;
                l_total_workers := l_workers;
                l_counter     := 0;
                l_start_flag  := 0;
                l_worker_count  := 0;
                l_gap         := round(l_total_lines / l_total_workers, 0);

                for lines_rec in lines loop

                    l_price_list_line_id := lines_rec.price_list_line_id;
                    l_counter       := l_counter + 1;

                    if l_start_flag = 0 then
                              l_start_flag := 1;
                              l_min_line := lines_rec.price_list_line_id;
                              l_max_line := NULL;
                              l_worker_count := l_worker_count + 1;
                    end if;

                  if l_counter = l_gap and l_worker_count < l_total_workers
                  then
                         l_max_line := lines_rec.price_list_line_id;

                     insert_line_distribution
                     (
                       l_worker             => l_worker_count,
                       l_start_line  => l_min_line,
                       l_end_line    => l_max_line,
                       l_type_var         => 'PLL'
                     );

                         l_counter    := 0;
                         l_start_flag := 0;

                  end if;

                end loop;

                l_max_line := l_price_list_line_id;

                     insert_line_distribution
                     (
                       l_worker             => l_worker_count,
                       l_start_line  => l_min_line,
                       l_end_line    => l_max_line,
                       l_type_var         => 'PLL'
                     );


                commit;
	 end if;

end create_parallel_lines;


PROCEDURE  CREATE_PARALLEL_SLABS
       (  L_WORKERS IN NUMBER := 5)
      IS
      V_TYPE              VARCHAR2(30) := 'PLL';


      L_TOTAL_LINES     NUMBER;
      L_MIN_LINE        NUMBER;
      L_MAX_LINE        NUMBER;
      L_COUNTER           NUMBER;
      L_GAP               NUMBER;
      L_WORKER_COUNT        NUMBER;
      L_WORKER_START        NUMBER;
      L_WORKER_END          NUMBER;
      L_PRICE_LIST_LINE_ID     NUMBER;
      L_START_FLAG        NUMBER;
      L_TOTAL_WORKERS       NUMBER;

   BEGIN

      DELETE from
	 QP_UPG_LINES_DISTRIBUTION
	 where line_type = v_type;

      COMMIT;

      BEGIN
                SELECT
                     NVL(MIN(PRICE_LIST_LINE_ID),0),
                     NVL(MAX(PRICE_LIST_LINE_ID),0)
                INTO
                     L_MIN_LINE,
                     L_MAX_LINE
                FROM
                     SO_PRICE_LIST_LINES_115;

           exception
                when others then
                  null;
      end;


      FOR I in 1..l_workers loop

          l_worker_start := l_min_line + trunc( (i-1) * (l_max_line-l_min_line)/l_workers);

          l_worker_end := l_min_line + trunc(i*(l_max_line-l_min_line)/l_workers);

          if i <> l_workers then

             l_worker_end := l_worker_end - 1;

          end if;

                qp_modifier_upgrade_util_pvt.insert_line_distribution
                (
                    l_worker             => i,
                    l_start_line  => l_worker_start,
                    l_end_line    => l_worker_end,
                    l_type_var         => 'PLL'
                );

       END LOOP;

       commit;


end create_parallel_slabs;



Procedure create_price_list(p_batchsize in number := 5000,
                            p_worker in number := 1) is

l_context varchar2(30) := NULL;
l_attribute varchar2(30) := NULL;
l_qualifier_grouping_no NUMBER := 0;
l_sec_qualifier_grouping_no NUMBER := 0;
err_num         NUMBER;
err_msg         VARCHAR2(100);
l_sysdate date;
l_context_flag  VARCHAR2(1);
l_attribute_flag VARCHAR2(1);
l_value_flag  VARCHAR2(1);
l_datatype  VARCHAR2(10);
l_precedence  NUMBER;
l_error_code  NUMBER;
v_errortext  VARCHAR2(240);
l_price_list_id NUMBER; /* Renga */
l_list_header_id NUMBER := 0;
l_secondary_price_list_id NUMBER;
e_validate_flexfield EXCEPTION;
e_get_prod_flex_properties EXCEPTION;

l_header_count number := 0;
l_min_price_list number := 1;
l_max_price_list number := p_batchsize;
numiterations number := 1;
i number := 1;
j number := 0;
K number := 0;
agr_price_list_id number := 0;
agr_count number := 0;
start_price_list_id number := 0;
end_price_list_id number := 0;
new_price_list_id number := 0;


TYPE PRICE_LIST_ID_TAB IS TABLE OF QP_LIST_HEADERS_B.LIST_HEADER_ID%TYPE INDEX BY BINARY_INTEGER;

TYPE COMMENTSTAB IS TABLE OF QP_LIST_HEADERS_B.COMMENTS%TYPE INDEX BY BINARY_INTEGER;
TYPE CONTEXTTAB IS TABLE OF QP_LIST_HEADERS_B.CONTEXT%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE1TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE2TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE3TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE4TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE5TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE6TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE7TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE8TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE8%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE9TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE9%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE10TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE10%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE11TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE11%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE12TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE12%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE13TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE13%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE14TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE14%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE15TAB IS TABLE OF QP_LIST_HEADERS_B.ATTRIBUTE15%TYPE INDEX BY BINARY_INTEGER;
TYPE CURRENCYTAB IS TABLE OF QP_LIST_HEADERS_B.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE SHIP_METHOD_TAB IS TABLE OF QP_LIST_HEADERS_B.SHIP_METHOD_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE FREIGHT_TERMS_TAB IS TABLE OF QP_LIST_HEADERS_B.FREIGHT_TERMS_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE LIST_HEADER_ID_TAB IS TABLE OF QP_LIST_HEADERS_B.LIST_HEADER_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE START_DATE_ACTIVE_TAB IS TABLE OF QP_LIST_HEADERS_B.START_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;
TYPE END_DATE_ACTIVE_TAB IS TABLE OF QP_LIST_HEADERS_B.END_DATE_ACTIVE%TYPE INDEX BY BINARY_INTEGER;
TYPE AUTOMATIC_FLAG_TAB IS TABLE OF QP_LIST_HEADERS_B.AUTOMATIC_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE LIST_TYPE_CODE_TAB IS TABLE OF QP_LIST_HEADERS_B.LIST_TYPE_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE TERMS_ID_TAB IS TABLE OF QP_LIST_HEADERS_B.TERMS_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE ROUNDING_FACTOR_TAB IS TABLE OF QP_LIST_HEADERS_B.ROUNDING_FACTOR%TYPE INDEX BY BINARY_INTEGER;
TYPE REQUEST_ID_TAB IS TABLE OF QP_LIST_HEADERS_B.REQUEST_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE CREATION_DATE_TAB IS TABLE OF QP_LIST_HEADERS_B.CREATION_DATE%TYPE INDEX BY BINARY_INTEGER;
TYPE CREATED_BY_TAB IS TABLE OF QP_LIST_HEADERS_B.CREATED_BY%TYPE INDEX BY BINARY_INTEGER;
TYPE LAST_UPDATE_DATE_TAB IS TABLE OF QP_LIST_HEADERS_B.LAST_UPDATE_DATE%TYPE INDEX BY BINARY_INTEGER;
TYPE LAST_UPDATED_BY_TAB IS TABLE OF QP_LIST_HEADERS_B.LAST_UPDATED_BY%TYPE INDEX BY BINARY_INTEGER;
TYPE LAST_UPDATE_LOGIN_TAB IS TABLE OF QP_LIST_HEADERS_B.LAST_UPDATE_LOGIN%TYPE INDEX BY BINARY_INTEGER;
TYPE ASK_FOR_FLAG_TAB IS TABLE OF QP_LIST_HEADERS_B.ASK_FOR_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE SOURCE_SYSTEM_CODE_TAB IS TABLE OF QP_LIST_HEADERS_B.SOURCE_SYSTEM_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE ACTIVE_FLAG_TAB IS TABLE OF QP_LIST_HEADERS_B.ACTIVE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE NAME_TAB IS TABLE OF QP_LIST_HEADERS_TL.NAME%TYPE INDEX BY BINARY_INTEGER;
TYPE DESCRIPTION_TAB IS TABLE OF QP_LIST_HEADERS_TL.DESCRIPTION%TYPE INDEX BY BINARY_INTEGER;

type agr_type_tab is table of VARCHAR2(3) index by binary_integer;

COMMENTS_T		COMMENTSTAB;
CONTEXT_T		CONTEXTTAB;
ATTRIBUTE1_T		ATTRIBUTE1TAB;
ATTRIBUTE2_T		ATTRIBUTE2TAB;
ATTRIBUTE3_T		ATTRIBUTE3TAB;
ATTRIBUTE4_T		ATTRIBUTE4TAB;
ATTRIBUTE5_T		ATTRIBUTE5TAB;
ATTRIBUTE6_T		ATTRIBUTE6TAB;
ATTRIBUTE7_T		ATTRIBUTE7TAB;
ATTRIBUTE8_T		ATTRIBUTE8TAB;
ATTRIBUTE9_T		ATTRIBUTE9TAB;
ATTRIBUTE10_T		ATTRIBUTE10TAB;
ATTRIBUTE11_T		ATTRIBUTE11TAB;
ATTRIBUTE12_T		ATTRIBUTE12TAB;
ATTRIBUTE13_T		ATTRIBUTE13TAB;
ATTRIBUTE14_T		ATTRIBUTE14TAB;
ATTRIBUTE15_T		ATTRIBUTE15TAB;
CURRENCY_T		CURRENCYTAB;
SHIP_METHOD_CODE_T	SHIP_METHOD_TAB;
FREIGHT_TERMS_CODE_T	FREIGHT_TERMS_TAB;
PRICE_LIST_ID_T		PRICE_LIST_ID_TAB;
OLD_PRICE_LIST_ID_T     PRICE_LIST_ID_TAB;
START_DATE_ACTIVE_T	START_DATE_ACTIVE_TAB;
END_DATE_ACTIVE_T	END_DATE_ACTIVE_TAB;
TERMS_ID_T		TERMS_ID_TAB;
ROUNDING_FACTOR_T	ROUNDING_FACTOR_TAB;
REQUEST_ID_T		REQUEST_ID_TAB;
CREATION_DATE_T		CREATION_DATE_TAB;
CREATED_BY_T		CREATED_BY_TAB;
LAST_UPDATE_DATE_T	LAST_UPDATE_DATE_TAB;
LAST_UPDATED_BY_T	LAST_UPDATED_BY_TAB;
LAST_UPDATE_LOGIN_T	LAST_UPDATE_LOGIN_TAB;
ASK_FOR_FLAG_T		ASK_FOR_FLAG_TAB;
SOURCE_SYSTEM_CODE_T	SOURCE_SYSTEM_CODE_TAB;
ACTIVE_FLAG_T		ACTIVE_FLAG_TAB;
NAME_T                  NAME_TAB;
DESCRIPTION_T           DESCRIPTION_TAB;
SEC_PRICE_LIST_ID_T     PRICE_LIST_ID_TAB;
AGR_TYPE_T              AGR_TYPE_TAB;
prc_list_maps           prc_list_map_tbl_type;
new_prc_list_maps 	prc_list_map_tbl_type;
l_prc_list_map_index number := 0;

CURSOR price_list IS
 SELECT COMMENTS,
        CONTEXT,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CURRENCY_CODE,
        SHIP_METHOD_CODE,
        FREIGHT_TERMS_CODE,
        PRICE_LIST_ID,
        START_DATE_ACTIVE,
        END_DATE_ACTIVE,
        TERMS_ID,
        ROUNDING_FACTOR,
        REQUEST_ID,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        --NAME,
        --DESCRIPTION,
        PRICE_LIST_ID,
        SECONDARY_PRICE_LIST_ID,
        NULL
FROM so_price_lists_b prl
WHERE not exists ( select 'x'
         	     from qp_discount_mapping dm
		     where dm.old_discount_id = prl.price_list_id
			and   dm.new_type in ('P','Z'))

AND  not exists ( select 'x'
			from qp_list_headers_b lh
			where lh.list_header_id = prl.price_list_id );
/* vivek
UNION
 SELECT COMMENTS,
        CONTEXT,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        CURRENCY_CODE,
        SHIP_METHOD_CODE,
        FREIGHT_TERMS_CODE,
        PRICE_LIST_ID,
        START_DATE_ACTIVE,
        END_DATE_ACTIVE,
        TERMS_ID,
        ROUNDING_FACTOR,
        REQUEST_ID,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        --NAME,
        --DESCRIPTION,
        PRICE_LIST_ID,
        SECONDARY_PRICE_LIST_ID,
        'AGR'
FROM SO_PRICE_LISTS_B PRL
WHERE PRL.PRICE_LIST_ID IN ( SELECT PRICE_LIST_ID
                         FROM SO_AGREEMENTS_B)
AND NOT EXISTS ( SELECT NULL
             FROM QP_DISCOUNT_MAPPING
             WHERE OLD_DISCOUNT_ID = PRL.PRICE_LIST_ID
             AND NEW_TYPE = 'P');
vivek */
CURSOR sec_price_list IS
 SELECT price_list_id, secondary_price_list_id
   FROM so_price_lists_b spl
  WHERE secondary_price_list_id is not null
  and exists ( select list_header_id
               from qp_LIST_headers_b
               where list_header_id = spl.secondary_price_list_id )
  and exists ( select list_header_id
               from qp_LIST_headers_b
               where list_header_id = spl.price_list_id );

cursor invalid_sec is
select price_list_id, secondary_price_list_id
from so_price_lists_b spl
where secondary_price_list_id is not null
and secondary_price_list_id not in ( select list_header_id
                                       from qp_LIST_headers_b );

cursor invalid_prc is
select price_list_id
from so_price_lists_b
where price_list_id not in ( select list_header_id
                             from qp_LIST_headers_b );


BEGIN

 --dbms_output.put_line('pr1');

 l_header_count := 0;

 OPEN price_list;

 FETCH price_list BULK COLLECT INTO
        COMMENTS_T,
        CONTEXT_T,
        ATTRIBUTE1_T,
        ATTRIBUTE2_T,
        ATTRIBUTE3_T,
        ATTRIBUTE4_T,
        ATTRIBUTE5_T,
        ATTRIBUTE6_T,
        ATTRIBUTE7_T,
        ATTRIBUTE8_T,
        ATTRIBUTE9_T,
        ATTRIBUTE10_T,
        ATTRIBUTE11_T,
        ATTRIBUTE12_T,
        ATTRIBUTE13_T,
        ATTRIBUTE14_T,
        ATTRIBUTE15_T,
        CURRENCY_T,
        SHIP_METHOD_CODE_T,
        FREIGHT_TERMS_CODE_T,
        PRICE_LIST_ID_T,
        START_DATE_ACTIVE_T,
        END_DATE_ACTIVE_T,
        TERMS_ID_T,
        ROUNDING_FACTOR_T,
        REQUEST_ID_T,
        CREATION_DATE_T,
        CREATED_BY_T,
        LAST_UPDATE_DATE_T,
        LAST_UPDATED_BY_T,
        LAST_UPDATE_LOGIN_T,
        --NAME_T,
        --DESCRIPTION_T,
        OLD_PRICE_LIST_ID_T,
        SEC_PRICE_LIST_ID_T,
        AGR_TYPE_T;

 CLOSE price_list;

IF price_list_id_t.FIRST is not null then

/* vivek
 start_price_list_id := nvl(price_list_id_t.FIRST,0);
 end_price_list_id := nvl(price_list_id_t.LAST,0);

 --dbms_output.put_line('pr2');


 FOR K in start_price_list_id..end_price_list_id loop

 --dbms_output.put_line('pr2'||K);

    IF ( ( AGR_TYPE_T(K) IS NOT NULL )
        AND ( AGR_TYPE_T(K) = 'AGR' ) ) then

 --dbms_output.put_line('pr2.1'||K);

       select qp_list_headers_b_s.nextval
       into new_price_list_id
       from dual;

 --dbms_output.put_line('pr2.2'||K);

        --NAME_T(K) := 'QPNEW' || NAME_T(K);
 --dbms_output.put_line('pr2.3'||K);

        PRICE_LIST_ID_T(K) := new_price_list_id;
 --dbms_output.put_line('pr2.4'||K);

        prc_list_maps(PRICE_LIST_ID_T(K)).old_price_list_id := OLD_PRICE_LIST_ID_T(K);
 --dbms_output.put_line('pr2.5'||K);
        prc_list_maps(PRICE_LIST_ID_T(K)).new_list_header_id := PRICE_LIST_ID_T(K);
 --dbms_output.put_line('pr2.6'||K);

        prc_list_maps(PRICE_LIST_ID_T(K)).secondary_price_list_id := SEC_PRICE_LIST_ID_T(K);
 --dbms_output.put_line('pr2.7'||K);
        prc_list_maps(PRICE_LIST_ID_T(K)).db_flag := 'N';
 --dbms_output.put_line('pr2.8'||K);


    END IF;


  END LOOP;

vivek */
 --dbms_output.put_line('pr2.5');

 l_min_price_list := 0;
 l_max_price_list := nvl(price_list_id_t.FIRST,1) -1;

 IF mod(nvl(price_list_id_t.LAST,0),p_batchsize) > 0 then
     j := 1;
 END IF;

 numiterations := trunc(nvl(price_list_id_t.LAST,0)/p_batchsize) + j ;

 WHILE ( l_max_price_list < nvl(price_list_id_t.LAST,0)
        and numiterations > 0)
 LOOP

   l_min_price_list := l_max_price_list + 1;

   IF i < numiterations then

    l_max_price_list := l_min_price_list + p_batchsize -1;
    i := i+1;

   ELSE

    l_max_price_list := price_list_id_t.LAST;

   END IF;

   BEGIN /* forall k in 1_min_price_list..l_max_price_list */

    FORALL K IN l_min_price_list..l_max_price_list
      INSERT
      INTO qp_LIST_headers_b
		(COMMENTS,
             CONTEXT,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             CURRENCY_CODE,
             SHIP_METHOD_CODE,
             FREIGHT_TERMS_CODE,
             LIST_HEADER_ID,
             START_DATE_ACTIVE,
             END_DATE_ACTIVE,
             AUTOMATIC_FLAG,
             LIST_TYPE_CODE,
             TERMS_ID,
             ROUNDING_FACTOR,
             REQUEST_ID,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             ASK_FOR_FLAG,
             SOURCE_SYSTEM_CODE,
             ACTIVE_FLAG)
      VALUES (COMMENTS_T(K),
           CONTEXT_T(K),
           ATTRIBUTE1_T(K),
           ATTRIBUTE2_T(K),
           ATTRIBUTE3_T(K),
           ATTRIBUTE4_T(K),
           ATTRIBUTE5_T(K),
           ATTRIBUTE6_T(K),
           ATTRIBUTE7_T(K),
           ATTRIBUTE8_T(K),
           ATTRIBUTE9_T(K),
           ATTRIBUTE10_T(K),
           ATTRIBUTE11_T(K),
           ATTRIBUTE12_T(K),
           ATTRIBUTE13_T(K),
           ATTRIBUTE14_T(K),
           ATTRIBUTE15_T(K),
           CURRENCY_T(K),
           SHIP_METHOD_CODE_T(K),
           FREIGHT_TERMS_CODE_T(K),
           PRICE_LIST_ID_T(K),
           START_DATE_ACTIVE_T(K),
           END_DATE_ACTIVE_T(K),
           'N',
           'PRL',
           TERMS_ID_T(K),
           ROUNDING_FACTOR_T(K),
           REQUEST_ID_T(K),
           CREATION_DATE_T(K),
           CREATED_BY_T(K),
           LAST_UPDATE_DATE_T(K),
           LAST_UPDATED_BY_T(K),
           LAST_UPDATE_LOGIN_T(K),
           'N',
           'QP',
           'Y');

   EXCEPTION
	  WHEN OTHERS THEN
	    v_errortext := SUBSTR(SQLERRM, 1,240);
            K := sql%rowcount + l_min_price_list;
            ROLLBACK;
	    qp_util.log_error(price_list_id_T(K),NULL, NULL, NULL, NULL,
                              NULL, NULL,NULL, 'PRICE_LIST_HEADER_B',
				v_errortext, 'PRICE_LISTS');
	    RAISE;
   END;

   BEGIN /* forall k in 1_min_price_list..l_max_price_list */

      FORALL K IN l_min_price_list..l_max_price_list
      insert
	 into qp_LIST_HEADERS_TL
	     (LAST_UPDATE_LOGIN,
            NAME,
            DESCRIPTION,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LIST_HEADER_ID,
            LANGUAGE,
            SOURCE_LANG,
            VERSION_NO)
      select LAST_UPDATE_LOGIN_T(K),
           ptl.NAME,
           ptl.description,
           CREATION_DATE_T(K),
           CREATED_BY_T(K),
           LAST_UPDATE_DATE_T(K),
           LAST_UPDATED_BY_T(K),
           PRICE_LIST_ID_T(K),
           L.LANGUAGE_CODE,
           userenv('LANG'),
           '1'
      from so_price_lists_tl ptl,
           FND_LANGUAGES L
      where ptl.price_list_id = price_list_id_T(K)
	 and   ptl.language = l.language_code
	 and L.INSTALLED_FLAG in ('I', 'B')
  	 and NOT EXISTS (
					 SELECT NULL
  			     	 FROM   qp_list_headers_tl ptl
			           WHERE  ptl.list_header_id = price_list_id_T(K)
			           AND    ptl.language  = l.language_code);

   EXCEPTION
	 WHEN OTHERS THEN
	   v_errortext := SUBSTR(SQLERRM, 1,240);
           K := sql%rowcount + l_min_price_list;
           -- dbms_output.put_line('The value of K: ' || K);
	   ROLLBACK;
	   qp_util.log_error(price_list_id_T(K),
			    NULL, NULL, NULL, NULL, NULL,
			    NULL, NULL, 'PRICE_LIST_HEADER_TL',
			    v_errortext, 'PRICE_LISTS');
	   RAISE;
   END;

  /* insert into qp_discount_mapping table for the rows that were
     just now inserted */

	--dbms_output.put_line('pr2.6');

  new_prc_list_maps := prc_list_maps;

  l_prc_list_map_index := new_prc_list_maps.FIRST;

  while l_prc_list_map_index is not null loop

      IF new_prc_list_maps(l_prc_list_map_index).db_flag = 'N' THEN

        begin

         INSERT INTO QP_DISCOUNT_MAPPING(OLD_DISCOUNT_ID,
                                         OLD_DISCOUNT_LINE_ID,
		                         NEW_LIST_HEADER_ID,
                                         NEW_LIST_LINE_ID,
                                         OLD_PRICE_BREAK_LINES_LOW,
		                         OLD_PRICE_BREAK_LINES_HIGH,
                                         OLD_METHOD_TYPE_CODE,
                                         OLD_PRICE_BREAK_PERCENT,
		                         OLD_PRICE_BREAK_AMOUNT,
                                         OLD_PRICE_BREAK_PRICE,
                                         NEW_TYPE,
                                         PRICING_CONTEXT)
         VALUES (new_prc_list_maps(l_prc_list_map_index).old_price_list_id,
                NULL,
                new_prc_list_maps(l_prc_list_map_index).new_list_header_id,
                NULL,
		NULL,
                NULL,
                NULL,
                NULL,
		NULL,
                NULL,
                'P',
                NULL);

        new_prc_list_maps(l_prc_list_map_index).db_flag := 'Y';

         exception

            when others then

	        v_errortext := SUBSTR(SQLERRM, 1,240);
                --dbms_output.put_line('hello 1');
                new_prc_list_maps := prc_list_maps;
	   qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
					    NULL, 'disc_map', v_errortext, 'PRICE_LISTS');
                RAISE;

        end;

       END IF;

       l_prc_list_map_index := new_prc_list_maps.NEXT(l_prc_list_map_index);

    end loop;  /* while l_prc_list_map_index is not null loop */

	--dbms_output.put_line('pr2.7');

    prc_list_maps := new_prc_list_maps;


   COMMIT;  /* commiting after finishing some multiple of p_batchsize price
              lists. */

	--dbms_output.put_line('pr2.8');



END LOOP;  /* while loop */


END IF; /* if price_list_id_t.first is not null */


--create_list_lines(p_batchsize);

-- COMMIT;



/*

 EXCEPTION

	 WHEN OTHERS THEN
	   v_errortext := SUBSTR(SQLERRM, 1,240);
	   ROLLBACK;
	   qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
							    NULL, 'OTHERS', v_errortext, 'PRICE_LISTS');
         RAISE;
    END;

*/


--END LOOP;

 /* creating qualifiers for secondary price list */

	 /* hard code the l_context, and l_attribute */

--dbms_output.put_line('pr3');
	  l_context := 'MODLIST';
	  l_attribute := 'QUALIFIER_ATTRIBUTE4';

        OPEN sec_price_list;
        FETCH sec_price_list into l_price_list_id, l_secondary_price_list_id;

	  IF sec_price_list%NOTFOUND THEN

		 null;

       else

     	  BEGIN

               /* Renga */


--dbms_output.put_line('pr4');

               QP_UTIL.Get_Qual_Flex_Properties(l_context,
					        l_attribute,
					l_price_list_id,
					l_datatype,
					l_precedence,
					l_error_code);

 	    IF l_error_code <> 0 THEN
		 RAISE e_validate_flexfield;
         END IF;
       EXCEPTION
	    WHEN e_validate_flexfield THEN
			err_num := SQLCODE;
			err_msg := SUBSTR(SQLERRM, 1, 240);
		 qp_util.log_error(l_price_list_id, l_secondary_price_list_id, NULL, NULL, NULL, NULL, NULL, NULL, 'GET_QUAL_FLEX_LISTS', err_msg, 'PRICE_LISTS');

         WHEN OTHERS THEN
			err_num := SQLCODE;
			err_msg := SUBSTR(SQLERRM, 1, 240);
		 ROLLBACK;
		 qp_util.log_error(l_price_list_id, l_secondary_price_list_id, NULL, NULL, NULL, NULL, NULL, NULL, 'GET_QUAL_FLEX_LISTS', err_msg, 'PRICE_LISTS');
		 RAISE;
       END;

    end if;


--dbms_output.put_line('pr5');

    LOOP

   /* create qualifier with price list as the qualifier and list
      header id as secondary_price_list_id */

/* Commenting the qualifier_grouping_no = -2 since this resulted in creating duplicate price list qualifiers for the same secondary price list. Honeywell Bug no. 1781220 */

      EXIT WHEN sec_price_list%NOTFOUND;

	 BEGIN
--dbms_output.put_line('pr6');

          INSERT INTO qp_QUALIFIERS (
		      QUALIFIER_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
		      LAST_UPDATE_LOGIN,
                LIST_HEADER_ID,
                COMPARISON_OPERATOR_CODE,
                QUALIFIER_CONTEXT,
		      QUALIFIER_ATTRIBUTE,
                QUALIFIER_ATTR_VALUE,
                QUALIFIER_GROUPING_NO,
                EXCLUDER_FLAG,
			 QUALIFIER_DATATYPE,
			 QUALIFIER_PRECEDENCE,
			 QUALIFIER_ATTR_VALUE_TO
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_QUALIFIER_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF
     )
      select
		      QP_QUALIFIERS_S.nextval,
                sysdate,
                1,
                sysdate,
                1,
		      1,
                l_secondary_price_list_id,
                '=',
		      l_context,
                l_attribute,
                l_price_list_id,
                -1, -- for bug 2021623 qp_qualifier_group_no_s.nextval,
		      'N',
		      l_datatype,
		      l_precedence,
                NULL
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(QP_QUALIFIERS_S.currval)
     ,null
     ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=l_secondary_price_list_id)
                from dual
         WHERE NOT EXISTS ( select null
                            from qp_qualifiers
                            where qualifier_context = 'MODLIST'
                            and   qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
                            and   qualifier_attr_value = to_char(l_price_list_id)
                            and   comparison_operator_code = '='
--                            and   qualifier_grouping_no = -2
                            and   list_header_id = l_secondary_price_list_id
                            and   qualifier_rule_id is null
                            and  qualifier_attr_value_to is null );

         EXCEPTION
	    WHEN OTHERS THEN
		 v_errortext := SUBSTR(SQLERRM, 1,240);
		 ROLLBACK;
		 qp_util.log_error(l_price_list_id,
								  NULL, l_secondary_price_list_id, NULL, NULL, NULL, NULL,
								  NULL, 'SECONDARY_PRICE_LISTS',
								  v_errortext, 'PRICE_LISTS');
		 RAISE;
       END;


/* vivek

--dbms_output.put_line('pr7');
         IF prc_list_maps.EXISTS(l_price_list_id) THEN

           BEGIN

--dbms_output.put_line('pr8');
              INSERT INTO qp_QUALIFIERS (
		      QUALIFIER_ID,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
		      LAST_UPDATE_LOGIN,
                LIST_HEADER_ID,
                COMPARISON_OPERATOR_CODE,
                QUALIFIER_CONTEXT,
		      QUALIFIER_ATTRIBUTE,
                QUALIFIER_ATTR_VALUE,
                QUALIFIER_GROUPING_NO,
                EXCLUDER_FLAG,
			 QUALIFIER_DATATYPE,
			 QUALIFIER_PRECEDENCE,
			 QUALIFIER_ATTR_VALUE_TO)
               select
		      QP_QUALIFIERS_S.nextval,
                sysdate,
                1,
                sysdate,
                1,
		      1,
                prc_list_maps(l_price_list_id).secondary_price_list_id,
                '=',
		      l_context,
                l_attribute,
                prc_list_maps(l_price_list_id).new_list_header_id,
                qp_qualifier_group_no_s.nextval,
		      'N',
		      l_datatype,
		      l_precedence,
                NULL
                from dual
         WHERE NOT EXISTS ( select null
                            from qp_qualifiers
                            where qualifier_context = 'MODLIST'
                            and   qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'
                            and   qualifier_attr_value = prc_list_maps(l_price_list_id).new_list_header_id
                            and   comparison_operator_code = '='
                            and   qualifier_grouping_no = -2
                            and   list_header_id = prc_list_maps(l_price_list_id).secondary_price_list_id
                            and   qualifier_rule_id is null
                            and  qualifier_attr_value_to is null );
--dbms_output.put_line('pr9');

       EXCEPTION
	    WHEN OTHERS THEN
		 v_errortext := SUBSTR(SQLERRM, 1,240);
		 ROLLBACK;
		 qp_util.log_error(prc_list_maps(l_price_list_id).new_list_header_id,
				   NULL, l_secondary_price_list_id, NULL,
                                   NULL, NULL, NULL,
				   NULL, 'SECONDARY_PRICE_LISTS',
				 v_errortext, 'PRICE_LISTS');
		 RAISE;

       END;

     END IF;

vivek */

        FETCH sec_price_list into l_price_list_id, l_secondary_price_list_id;

      END LOOP;

       CLOSE sec_price_list;

       commit;


-- Price Lists not migrated
--dbms_output.put_line('pr10');

   FOR invalid_prc_rec in invalid_prc
   LOOP
         QP_Util.Log_Error(p_id1 => invalid_prc_rec.price_list_id,
		      p_id2 => NULL,
		      p_error_type => 'PRICE_LIST_NOT_MIGRATED',
		      p_error_desc => 'Price List Id ' || invalid_prc_rec.price_list_id || ' was not migrated. Please check qp_upgrade_errors for more details.',
		      p_error_module => 'PRICE_LISTS');
   END LOOP;

--dbms_output.put_line('pr11');
/* price lists for which secondary price lists did not get created */
   -- Secondary price lists Not Migrated

   FOR invalid_sec_rec in invalid_sec
   LOOP
         QP_Util.Log_Error(p_id1 => invalid_sec_rec.secondary_price_list_id,
		      p_id2 => invalid_sec_rec.price_list_id,
		      p_error_type => 'SECONDARY_LISTS_NOT_MIGRATED',
		      p_error_desc => 'Price List Id ' || invalid_sec_rec.secondary_price_list_id || ' does not exist. Hence Price List Id ' || invalid_sec_rec.price_list_id ||'is not created as a qualifier',
		      p_error_module => 'PRICE_LISTS');

   END LOOP;
--dbms_output.put_line('pr12');

--   Upgrade_Flex_Structures;

--     QP_UTIL.QP_UPGRADE_CONTEXT('OE', 'QP', 'SO_PRICE_LISTS', 'QP_LIST_HEADERS');
 --    QP_UTIL.QP_UPGRADE_CONTEXT('OE', 'QP', 'SO_PRICE_LIST_LINES', 'QP_LIST_LINES');

EXCEPTION

     WHEN OTHERS THEN
	  v_errortext := SUBSTR(SQLERRM, 1,240);
       ROLLBACK;
	  qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
							   NULL, 'MAIN', v_errortext, 'PRICE_LISTS');

      /*

       -- Price Lists not migrated

       FOR invalid_prc_rec in invalid_prc
       LOOP
         QP_Util.Log_Error(p_id1 => invalid_prc_rec.price_list_id,
		      p_id2 => NULL,
		      p_error_type => 'PRICE_LIST_NOT_MIGRATED',
		      p_error_desc => 'Price List Id ' || invalid_prc_rec.price_list_id || ' was not migrated. Please check qp_upgrade_errors for more details.',
		      p_error_module => 'PRICE_LISTS');
       END LOOP;
   -- Secondary price lists Not Migrated

       FOR invalid_sec_rec in invalid_sec
       LOOP
         QP_Util.Log_Error(p_id1 => invalid_sec_rec.secondary_price_list_id,
		      p_id2 => invalid_sec_rec.price_list_id,
		      p_error_type => 'SECONDARY_LISTS_NOT_MIGRATED',
		      p_error_desc => 'Price List Id ' || invalid_sec_rec.secondary_price_list_id || ' does not exist. Hence Price List Id ' || invalid_sec_rec.price_list_id ||'is not created as a qualifier',
		      p_error_module => 'PRICE_LISTS');
       END LOOP;
    */


       RAISE;

end create_price_list;


PROCEDURE create_list_lines(p_batchsize IN NUMBER := 5000,
                            l_worker in number := 1)
IS
l_product_context varchar2(30);
l_customer_item_context varchar2(30);
l_product_attr varchar2(30);
l_customer_item_attr varchar2(30);
l_pricing_attr_rec pricing_attr_rec_type;
l_pricing_attr_tbl pricing_attr_tbl_type;
l_list_line_id number;
l_attribute_grouping_no number;
l_pricing_attribute_id number;
err_num         NUMBER;
err_msg         VARCHAR2(100);
l_prod_datatype  VARCHAR2(30);
l_prod_precedence NUMBER;
l_error   NUMBER;
l_error1  NUMBER;
l_prc_datatype  VARCHAR2(30);
l_prc_precedence NUMBER;
v_errortext  VARCHAR2(240);
l_primary_uom_code VARCHAR2(3);
l_primary_uom_flag VARCHAR2(1) := 'N';
l_line_count number := 0;
l_min_line number := 1;
l_max_line number := p_batchsize;
numiterations number := 1;
i number := 1;
j number := 0;
K number := 0;
v_min_line number := 0;
v_max_line number := 0;
attr_count number := 0;
agr_count number := 0;
new_prc_list_line_id number := 0;
start_prc_list_line_id number := 0;
end_prc_list_line_id number := 0;

e_get_prod_flex_properties EXCEPTION;

TYPE price_list_line_id_tab is table of
        SO_PRICE_LIST_LINES_115.price_list_line_id%TYPE INDEX BY BINARY_INTEGER;
TYPE creation_date_tab is table of SO_PRICE_LIST_LINES_115.creation_date%TYPE INDEX BY BINARY_INTEGER;
TYPE created_by_tab is table of SO_PRICE_LIST_LINES_115.created_by%TYPE INDEX BY BINARY_INTEGER;
TYPE last_update_date_tab is table of
        SO_PRICE_LIST_LINES_115.last_update_date%TYPE INDEX BY BINARY_INTEGER;
TYPE last_updated_by_tab is table of
        SO_PRICE_LIST_LINES_115.last_updated_by%TYPE INDEX BY BINARY_INTEGER;
TYPE last_update_login_tab is table of
        SO_PRICE_LIST_LINES_115.last_update_login%TYPE INDEX BY BINARY_INTEGER;
TYPE program_application_id_tab is table of
        SO_PRICE_LIST_LINES_115.program_application_id%TYPE INDEX BY BINARY_INTEGER;
TYPE program_id_tab is table of SO_PRICE_LIST_LINES_115.program_id%TYPE INDEX BY BINARY_INTEGER;
TYPE program_update_date_tab is table of
        SO_PRICE_LIST_LINES_115.program_update_date%TYPE INDEX BY BINARY_INTEGER;
TYPE request_id_tab is table of SO_PRICE_LIST_LINES_115.request_id%TYPE INDEX BY BINARY_INTEGER;
TYPE price_list_id_tab is table of SO_PRICE_LIST_LINES_115.price_list_id%TYPE INDEX BY BINARY_INTEGER;
TYPE inventory_item_id_tab is table of
        SO_PRICE_LIST_LINES_115.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE unit_code_tab is table of SO_PRICE_LIST_LINES_115.unit_code%TYPE INDEX BY BINARY_INTEGER;
TYPE method_code_tab is table of SO_PRICE_LIST_LINES_115.method_code%TYPE INDEX BY BINARY_INTEGER;
TYPE list_price_tab is table of SO_PRICE_LIST_LINES_115.list_price%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_rule_id_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_rule_id%TYPE INDEX BY BINARY_INTEGER;
TYPE reprice_flag_tab is table of SO_PRICE_LIST_LINES_115.reprice_flag%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_context_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_context%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute1_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute2_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute2%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute3_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute3%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute4_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute4%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute5_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute5%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute6_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute6%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute7_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute7%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute8_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute8%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute9_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute9%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute10_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute10%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute11_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute11%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute12_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute12%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute13_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute13%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute14_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute14%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_attribute15_tab is table of
        SO_PRICE_LIST_LINES_115.pricing_attribute15%TYPE INDEX BY BINARY_INTEGER;
TYPE start_date_active_tab is table of
        SO_PRICE_LIST_LINES_115.start_date_active%TYPE INDEX BY BINARY_INTEGER;
TYPE end_date_active_tab is table of
        SO_PRICE_LIST_LINES_115.end_date_active%TYPE INDEX BY BINARY_INTEGER;
TYPE context_tab is table of SO_PRICE_LIST_LINES_115.context%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute1_tab is table of SO_PRICE_LIST_LINES_115.attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute2_tab is table of SO_PRICE_LIST_LINES_115.attribute2%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute3_tab is table of SO_PRICE_LIST_LINES_115.attribute3%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute4_tab is table of SO_PRICE_LIST_LINES_115.attribute4%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute5_tab is table of SO_PRICE_LIST_LINES_115.attribute5%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute6_tab is table of SO_PRICE_LIST_LINES_115.attribute6%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute7_tab is table of SO_PRICE_LIST_LINES_115.attribute7%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute8_tab is table of SO_PRICE_LIST_LINES_115.attribute8%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute9_tab is table of SO_PRICE_LIST_LINES_115.attribute9%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute10_tab is table of SO_PRICE_LIST_LINES_115.attribute10%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute11_tab is table of SO_PRICE_LIST_LINES_115.attribute11%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute12_tab is table of SO_PRICE_LIST_LINES_115. attribute12%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute13_tab is table of SO_PRICE_LIST_LINES_115.attribute13%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute14_tab is table of SO_PRICE_LIST_LINES_115.attribute14%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute15_tab is table of SO_PRICE_LIST_LINES_115.attribute15%TYPE INDEX BY BINARY_INTEGER;

/* pricing attribute specific tab types */



type attr_creation_date_tab is table of QP_PRICING_ATTRIBUTES.CREATION_DATE%TYPE INDEX BY BINARY_INTEGER;
type attr_created_by_tab is table of QP_PRICING_ATTRIBUTES.CREATED_BY%TYPE INDEX BY BINARY_INTEGER;
type attr_last_update_date_tab is table of QP_PRICING_ATTRIBUTES.LAST_UPDATE_DATE%TYPE INDEX BY BINARY_INTEGER;
type attr_last_updated_by_tab is table of QP_PRICING_ATTRIBUTES.LAST_UPDATED_BY%TYPE INDEX BY BINARY_INTEGER;
type attr_last_update_login_tab is table of QP_PRICING_ATTRIBUTES.LAST_UPDATE_LOGIN%TYPE INDEX BY BINARY_INTEGER;
type attr_program_appl_id_tab is table of QP_PRICING_ATTRIBUTES.PROGRAM_APPLICATION_ID%TYPE INDEX BY BINARY_INTEGER;
type attr_program_id_tab is table of QP_PRICING_ATTRIBUTES.PROGRAM_ID%TYPE INDEX BY BINARY_INTEGER;
type attr_program_update_date_tab is table of QP_PRICING_ATTRIBUTES.PROGRAM_UPDATE_DATE%TYPE INDEX BY BINARY_INTEGER;
type attr_request_id_tab is table of QP_PRICING_ATTRIBUTES.REQUEST_ID%TYPE INDEX BY BINARY_INTEGER;
type attr_list_line_id_tab is table of QP_PRICING_ATTRIBUTES.LIST_LINE_ID%TYPE INDEX BY BINARY_INTEGER;
type attr_excluder_flag_tab is table of QP_PRICING_ATTRIBUTES.EXCLUDER_FLAG%TYPE INDEX BY BINARY_INTEGER;
type attr_accumulate_flag_tab is table of QP_PRICING_ATTRIBUTES.ACCUMULATE_FLAG%TYPE INDEX BY BINARY_INTEGER;
type attr_product_attr_context_tab is table of QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE_CONTEXT%TYPE INDEX BY BINARY_INTEGER;
type attr_product_attribute_tab is table of QP_PRICING_ATTRIBUTES.PRODUCT_ATTRIBUTE%TYPE INDEX BY BINARY_INTEGER;
type attr_product_attr_value_tab is table of QP_PRICING_ATTRIBUTES.PRODUCT_ATTR_VALUE%TYPE INDEX BY BINARY_INTEGER;
type attr_product_uom_code_tab is table of QP_PRICING_ATTRIBUTES.PRODUCT_UOM_CODE%TYPE INDEX BY BINARY_INTEGER;
type attr_comparison_operator_tab is table of QP_PRICING_ATTRIBUTES.COMPARISON_OPERATOR_CODE%TYPE INDEX BY BINARY_INTEGER;
type attr_pricing_context_tab is table of QP_PRICING_ATTRIBUTES.PRICING_ATTRIBUTE_CONTEXT%TYPE INDEX BY BINARY_INTEGER;
type attr_pricing_attr_tab is table of QP_PRICING_ATTRIBUTES.PRICING_ATTRIBUTE%TYPE INDEX BY BINARY_INTEGER;
type attr_pricing_attr_val_from_tab is table of QP_PRICING_ATTRIBUTES.PRICING_ATTR_VALUE_FROM%TYPE INDEX BY BINARY_INTEGER;
type attr_pricing_attr_val_to_tab is table of QP_PRICING_ATTRIBUTES.PRICING_ATTR_VALUE_TO%TYPE INDEX BY BINARY_INTEGER;
type attr_prc_datatype_tab is table of QP_PRICING_ATTRIBUTES.PRICING_ATTRIBUTE_DATATYPE%TYPE INDEX BY BINARY_INTEGER;
type agr_prc_list_tab is table of NUMBER index by binary_integer;
type agr_list_header_tab is table of NUMBER index by binary_integer;
type agr_type_tab is table of VARCHAR2(3) index by binary_integer;
TYPE qualification_ind_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE sec_prc_list_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

price_list_line_ids		price_list_line_id_tab;
creation_dates			creation_date_tab;
created_bys			created_by_tab;
last_update_dates		last_update_date_tab;
last_updated_bys		last_updated_by_tab;
last_update_logins		last_update_login_tab;
program_application_ids		program_application_id_tab;
program_ids			program_id_tab;
program_update_dates		program_update_date_tab;
request_ids			request_id_tab;
price_list_ids			price_list_id_tab;
inventory_item_ids		inventory_item_id_tab;
unit_codes			unit_code_tab;
method_codes			method_code_tab;
list_prices			list_price_tab;
pricing_rule_ids		pricing_rule_id_tab;
reprice_flags			reprice_flag_tab;
pricing_contexts		pricing_context_tab;
pricing_attribute1s		pricing_attribute1_tab;
pricing_attribute2s		pricing_attribute2_tab;
pricing_attribute3s		pricing_attribute3_tab;
pricing_attribute4s		pricing_attribute4_tab;
pricing_attribute5s		pricing_attribute5_tab;
pricing_attribute6s		pricing_attribute6_tab;
pricing_attribute7s		pricing_attribute7_tab;
pricing_attribute8s		pricing_attribute8_tab;
pricing_attribute9s		pricing_attribute9_tab;
pricing_attribute10s		pricing_attribute10_tab;
pricing_attribute11s		pricing_attribute11_tab;
pricing_attribute12s		pricing_attribute12_tab;
pricing_attribute13s		pricing_attribute13_tab;
pricing_attribute14s		pricing_attribute14_tab;
pricing_attribute15s		pricing_attribute15_tab;
start_date_actives		start_date_active_tab;
end_date_actives		end_date_active_tab;
contexts			context_tab;
attribute1s			attribute1_tab;
attribute2s			attribute2_tab;
attribute3s			attribute3_tab;
attribute4s			attribute4_tab;
attribute5s			attribute5_tab;
attribute6s			attribute6_tab;
attribute7s			attribute7_tab;
attribute8s			attribute8_tab;
attribute9s			attribute9_tab;
attribute10s			attribute10_tab;
attribute11s			attribute11_tab;
attribute12s			attribute12_tab;
attribute13s			attribute13_tab;
attribute14s			attribute14_tab;
attribute15s			attribute15_tab;

/* pricing attribute related datatypes */

attr_creation_dates             attr_creation_date_tab;
attr_created_bys                attr_created_by_tab;
attr_last_update_dates          attr_last_update_date_tab;
attr_last_updated_bys           attr_last_updated_by_tab;
attr_last_update_logins         attr_last_update_login_tab;
attr_program_application_ids    attr_program_appl_id_tab;
attr_program_ids                attr_program_id_tab;
attr_program_update_dates       attr_program_update_date_tab;
attr_request_ids                attr_request_id_tab;
attr_list_line_ids              attr_list_line_id_tab;
attr_excluder_flags             attr_excluder_flag_tab;
attr_accumulate_flags           attr_accumulate_flag_tab;
attr_product_attr_contexts      attr_product_attr_context_tab;
attr_product_attributes         attr_product_attribute_tab;
attr_product_attr_values        attr_product_attr_value_tab;
attr_product_uom_codes          attr_product_uom_code_tab;
attr_comparison_operator_codes  attr_comparison_operator_tab;
attr_pricing_contexts           attr_pricing_context_tab;
attr_pricing_attrs              attr_pricing_attr_tab;
attr_pricing_attr_value_froms   attr_pricing_attr_val_from_tab;
attr_pricing_attr_value_tos     attr_pricing_attr_val_to_tab;
prc_datatypes                   attr_prc_datatype_tab;
agr_old_price_lists             agr_prc_list_tab;
agr_new_list_headers            agr_list_header_tab;
agr_types                       agr_type_tab;
old_price_list_line_ids         price_list_line_id_tab;
qualification_ind               qualification_ind_tab;
sec_prc_list_ids                sec_prc_list_tab;

prc_list_maps           prc_list_map_tbl_type;
new_prc_list_maps 	prc_list_map_tbl_type;
l_prc_list_map_index number := 0;
v_segs_upg_t qp_util.v_segs_upg_tab;
l_pricing_context varchar2(30) := NULL;

cursor prc_list_line IS
 SELECT
  price_list_line_id,
  creation_date,
  created_by,
  last_update_date,
  last_updated_by,
  last_update_login,
  program_application_id,
  program_id,
  program_update_date,
  request_id,
  price_list_id,
  inventory_item_id,
  unit_code,
  method_code,
  list_price,
  pricing_rule_id,
  reprice_flag,
  pricing_context,
  pricing_attribute1,
  pricing_attribute2,
  pricing_attribute3,
  pricing_attribute4,
  pricing_attribute5,
  pricing_attribute6,
  pricing_attribute7,
  pricing_attribute8,
  pricing_attribute9,
  pricing_attribute10,
  pricing_attribute11,
  pricing_attribute12,
  pricing_attribute13,
  pricing_attribute14,
  pricing_attribute15,
  start_date_active,
  end_date_active,
  context,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  attribute8,
  attribute9,
  attribute10,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  price_list_line_id,
  NULL,
  3
from so_price_list_lines_115 prl
where prl.price_list_id in ( select list_header_id
                             from qp_LIST_headers_b
                             where list_type_code = 'PRL')
and not exists ( select null
                 from qp_LIST_lines
                 where list_line_id = prl.price_list_line_id )
and prl.price_list_line_id between l_min_line and l_max_line;

/* vivek

union
SELECT
  prl.price_list_line_id,
  prl.creation_date,
  prl.created_by,
  prl.last_update_date,
  prl.last_updated_by,
  prl.last_update_login,
  prl.program_application_id,
  prl.program_id,
  prl.program_update_date,
  prl.request_id,
  prl.price_list_id,
  prl.inventory_item_id,
  prl.unit_code,
  prl.method_code,
  prl.list_price,
  prl.pricing_rule_id,
  prl.reprice_flag,
  prl.pricing_context,
  prl.pricing_attribute1,
  prl.pricing_attribute2,
  prl.pricing_attribute3,
  prl.pricing_attribute4,
  prl.pricing_attribute5,
  prl.pricing_attribute6,
  prl.pricing_attribute7,
  prl.pricing_attribute8,
  prl.pricing_attribute9,
  prl.pricing_attribute10,
  prl.pricing_attribute11,
  prl.pricing_attribute12,
  prl.pricing_attribute13,
  prl.pricing_attribute14,
  prl.pricing_attribute15,
  prl.start_date_active,
  prl.end_date_active,
  prl.context,
  prl.attribute1,
  prl.attribute2,
  prl.attribute3,
  prl.attribute4,
  prl.attribute5,
  prl.attribute6,
  prl.attribute7,
  prl.attribute8,
  prl.attribute9,
  prl.attribute10,
  prl.attribute11,
  prl.attribute12,
  prl.attribute13,
  prl.attribute14,
  prl.attribute15,
  prl.price_list_line_id,
  'AGR',
  3
from qp_list_headers_b qph,
     so_price_list_lines_115 prl
where prl.price_list_id = qph.list_header_id
and prl.price_list_id in ( select price_list_id
                           from so_agreements_b)
and not exists ( select null
                 from qp_LIST_lines
                 where list_line_id = prl.price_list_line_id )
comment start
and not exists ( select null
                 from qp_discount_mapping
                 where old_discount_line_id = prl.price_list_line_id
                 and new_type = 'P')
comment end
and prl.price_list_line_id between l_min_line and l_max_line;

vivek */

/* vivek

cursor agr_prc_list is
select distinct price_list_id
from so_agreements_b;

cursor prc_list_mapping is
select old_discount_id, new_list_header_id
from qp_discount_mapping
where new_type = 'P'
and old_discount_line_id is null;

vivek */

CURSOR sec_prc_list IS
 SELECT DISTINCT secondary_price_list_id
   FROM SO_PRICE_LISTS_B where secondary_price_list_id IS NOT NULL;

begin

--  qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--	      NULL, 'MAIN-0', v_errortext, 'PRICE_LISTS');


   BEGIN

      qp_util.get_segs_for_flex(flexfield_name => 'QP_ATTR_DEFNS_PRICING',
                             application_short_name => 'QP',
	                     x_segs_upg_t => v_segs_upg_t,
                             error_code => l_error);

      IF l_error <> 0 THEN
	    RAISE e_get_prod_flex_properties;
      END IF;

   EXCEPTION

	  WHEN e_get_prod_flex_properties THEN
		null;
                err_num := SQLCODE;
	        err_msg := 'GET_SEGS_FOR_FLEX';
                rollback;
	    qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                              'GET_SEGS_FOR_FLEX', err_msg, 'PRICE_LISTS');
                RAISE;


   END;


--dbms_output.put_line('crll 1');

l_line_count := 0;

/* vivek

 for agr_prc_list_rec in prc_list_mapping loop

     agr_old_price_lists(agr_prc_list_rec.old_discount_id) := agr_prc_list_rec.old_discount_id;
     agr_new_list_headers(agr_prc_list_rec.old_discount_id) := agr_prc_list_rec.new_list_header_id;

 end loop;

vivek */

 FOR sec_prc_list_rec IN sec_prc_list LOOP
   sec_prc_list_ids(sec_prc_list_rec.secondary_price_list_id) := sec_prc_list_rec.secondary_price_list_id;
 END LOOP;

  begin

     select start_line_id,
            end_line_id
     into v_min_line,
          v_max_line
     from qp_upg_lines_distribution
     where worker = l_worker
	and line_type = 'PLL';

  exception

      when no_data_found then

            /* log the error */
            v_min_line := 0;
            v_max_line := 0;
            commit;
            return;
  end;

--dbms_output.put_line('v_min_line : ' || v_min_line);
--dbms_output.put_line('v_max_line : ' || v_max_line);
--dbms_output.put_line('rowcount 0 is : ' || sql%rowcount );

/*
FOR agr_prc_list_rec in agr_prc_list loop

    agr_prc_lists(agr_prc_list_rec.price_list_id) := agr_prc_list_rec.price_list_id;

end loop;
*/




--l_max_line := nvl(price_list_line_ids.FIRST,1) -1;

IF mod( (v_max_line - v_min_line),p_batchsize) > 0 then
     j := 1;
END IF;

/*
IF mod(nvl(price_list_line_ids.LAST,0),p_batchsize) > 0 then
     j := 1;
END IF;
*/

numiterations := trunc((v_max_line-v_min_line)/p_batchsize) + j ;
l_min_line := 0;
l_max_line := v_min_line-1;

-- qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-0.5', v_errortext, 'PRICE_LISTS');


WHILE ( numiterations > 0)
LOOP

--	  qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-1', v_errortext, 'PRICE_LISTS');

--dbms_output.put_line('v_max_line 3 : ' || v_max_line);

  l_min_line := l_max_line + 1;

  IF (numiterations > 1) then

   l_max_line := l_min_line + p_batchsize -1;
   numiterations := numiterations -1;

  ELSE

   l_max_line := v_max_line;
   numiterations := numiterations -1;

  END IF;



BEGIN /* begin for bulk fetch */

OPEN prc_list_line;

--dbms_output.put_line('v_max_line 1 : ' || v_max_line);

FETCH prc_list_line BULK COLLECT INTO
  price_list_line_ids,
  creation_dates,
  created_bys,
  last_update_dates,
  last_updated_bys,
  last_update_logins,
  program_application_ids,
  program_ids,
  program_update_dates,
  request_ids,
  price_list_ids,
  inventory_item_ids,
  unit_codes,
  method_codes,
  list_prices,
  pricing_rule_ids,
  reprice_flags,
  pricing_contexts,
  pricing_attribute1s,
  pricing_attribute2s,
  pricing_attribute3s,
  pricing_attribute4s,
  pricing_attribute5s,
  pricing_attribute6s,
  pricing_attribute7s,
  pricing_attribute8s,
  pricing_attribute9s,
  pricing_attribute10s,
  pricing_attribute11s,
  pricing_attribute12s,
  pricing_attribute13s,
  pricing_attribute14s,
  pricing_attribute15s,
  start_date_actives,
  end_date_actives,
  contexts,
  attribute1s,
  attribute2s,
  attribute3s,
  attribute4s,
  attribute5s,
  attribute6s,
  attribute7s,
  attribute8s,
  attribute9s,
  attribute10s,
  attribute11s,
  attribute12s,
  attribute13s,
  attribute14s,
  attribute15s,
  old_price_list_line_ids,
  agr_types,
  qualification_ind;


  EXCEPTION

	WHEN NO_DATA_FOUND THEN

	    --dbms_output.put_line('no lines to process - done ');
		 NULL;


 END;

CLOSE prc_list_line;


-- qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-2', v_errortext, 'PRICE_LISTS');

IF price_list_line_ids.FIRST is not null THEN

 start_prc_list_line_id := nvl(price_list_line_ids.FIRST,0);
 end_prc_list_line_id := nvl(price_list_line_ids.LAST,0);


 FOR K in start_prc_list_line_id..end_prc_list_line_id loop

/* vivek

    IF ( agr_old_price_lists.exists(price_list_ids(K))
        and (    agr_types(K) is not null
             and agr_types(K) = 'AGR') ) then

        select qp_list_lines_s.nextval
        into new_prc_list_line_id
        from dual;

        price_list_line_ids(K) := new_prc_list_line_id;


        prc_list_maps(price_list_line_ids(K)).old_price_list_id := price_list_ids(K);

        price_list_ids(K) := agr_new_list_headers(price_list_ids(K));

        prc_list_maps(price_list_line_ids(K)).new_list_header_id := price_list_ids(K);

        prc_list_maps(price_list_line_ids(K)).old_price_list_line_id := old_price_list_line_ids(K);

        prc_list_maps(price_list_line_ids(K)).new_list_line_id := price_list_line_ids(K);

        prc_list_maps(price_list_line_ids(K)).db_flag := 'N';

        qualification_ind(K) := 1;


    END IF;

vivek */

    IF (sec_prc_list_ids.exists(price_list_ids(k))) THEN
	 qualification_ind(k) := 3;
    END IF;

  END LOOP;

-- qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-3', v_errortext, 'PRICE_LISTS');

--dbms_output.put_line('rowcount is : ' || sql%rowcount );



--dbms_output.put_line('v_max_line 2 : ' || v_max_line);


    l_product_context := 'ITEM';
    l_product_attr := 'PRICING_ATTRIBUTE1';

    qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => l_product_context,
                             p_attribute  => l_product_attr,
                             x_precedence => l_prod_precedence,
                             x_datatype   => l_prod_datatype);




BEGIN /* forall k in 1_min_line..l_max_line */

 FORALL K IN start_prc_list_line_id..end_prc_list_line_id
  insert into qp_LIST_lines(
  LIST_LINE_ID,
  LIST_LINE_NO,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID,
  PROGRAM_UPDATE_DATE,
  REQUEST_ID,
  LIST_HEADER_ID,
  LIST_LINE_TYPE_CODE,
  START_DATE_ACTIVE, /* START_DATE_EFFECTIVE */
  END_DATE_ACTIVE,   /* END_DATE_EFFECTIVE */
  AUTOMATIC_FLAG,
  MODIFIER_LEVEL_CODE,
  LIST_PRICE,
  LIST_PRICE_UOM_CODE,
  PRIMARY_UOM_FLAG,
  INVENTORY_ITEM_ID,
  ORGANIZATION_ID,
  RELATED_ITEM_ID,
  RELATIONSHIP_TYPE_ID,
  SUBSTITUTION_CONTEXT,
  SUBSTITUTION_ATTRIBUTE,
  SUBSTITUTION_VALUE,
  REVISION,
  REVISION_DATE,
  REVISION_REASON_CODE,
  CONTEXT,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  COMMENTS,
  PRICE_BREAK_TYPE_CODE,
  PERCENT_PRICE,
  EFFECTIVE_PERIOD_UOM,
  NUMBER_EFFECTIVE_PERIODS,
  OPERAND,
  ARITHMETIC_OPERATOR,
  OVERRIDE_FLAG,
  PRINT_ON_INVOICE_FLAG,
  REBATE_TRANSACTION_TYPE_CODE,
  ESTIM_ACCRUAL_RATE,
  PRICE_BY_FORMULA_ID,
  GENERATE_USING_FORMULA_ID,
  PRICING_PHASE_ID,
  PRICING_GROUP_SEQUENCE,
  ACCRUAL_FLAG,
  PRODUCT_PRECEDENCE,
  INCOMPATIBILITY_GRP_CODE,
  QUALIFICATION_IND
  --ENH Upgrade BOAPI for orig_sys...ref RAVI
  ,ORIG_SYS_LINE_REF
  ,ORIG_SYS_HEADER_REF
  )
values(
  price_list_line_ids(K),
  price_list_line_ids(K),
  creation_dates(K),
  created_bys(K),
  last_update_dates(K),
  last_updated_bys(K),
  last_update_logins(K),
  program_application_ids(K),
  program_ids(K),
  program_update_dates(K),
  request_ids(K),
  price_list_ids(K),
  'PLL',
  start_date_actives(K), /* no need to do nvl */
  end_date_actives(K),
  'Y',
  'LINE',
  DECODE(method_codes(K), 'AMNT',list_prices(K),NULL),
  unit_codes(K),
  l_primary_uom_flag,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  contexts(K),
  attribute1s(K),
  attribute2s(K),
  attribute3s(K),
  attribute4s(K),
  attribute5s(K),
  attribute6s(K),
  attribute7s(K),
  attribute8s(K),
  attribute9s(K),
  attribute10s(K),
  attribute11s(K),
  attribute12s(K),
  attribute13s(K),
  attribute14s(K),
  attribute15s(K),
  NULL,
  NULL,
  DECODE(method_codes(K), 'PERC', list_prices(K), NULL),
  NULL,
  NULL,
  list_prices(K),
  DECODE(method_codes(K), 'PERC', 'PERCENT_PRICE',
								'AMNT', 'UNIT_PRICE', NULL),
  NULL,
  'N',
  NULL,
  NULL,
  NULL,
  pricing_rule_ids(K),
  1,
  0,
  'N',
  l_prod_precedence,
  'EXCL',
  qualification_ind(k)
  --ENH Upgrade BOAPI for orig_sys...ref RAVI
  ,to_char(price_list_line_ids(K))
  ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=price_list_ids(K))
 );

  EXCEPTION
    WHEN OTHERS THEN
	 v_errortext := SUBSTR(SQLERRM, 1,240);
         K := sql%rowcount + start_prc_list_line_id;
	 ROLLBACK;
	/*
 qp_util.log_error(price_list_ids(K),
							  price_list_line_ids(K),
							  NULL, NULL, NULL, NULL, NULL,
							  NULL, 'PRICE_LIST_LINES', v_errortext, 'PRICE_LISTS');
*/
	 RAISE;
  END;  /* exception handling for forall k in l_min_line .. l_max_line */

-- qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-5', v_errortext, 'PRICE_LISTS');

--dbms_output.put_line('crpa 1');

  attr_count := 0;

    /* delete the attr_<field_name> tables */

        attr_creation_dates.delete;
        attr_created_bys.delete;
        attr_last_update_dates.delete;
        attr_last_updated_bys.delete;
        attr_last_update_logins.delete;
        attr_program_application_ids.delete;
        attr_program_ids.delete;
        attr_program_update_dates.delete;
        attr_request_ids.delete;
        attr_list_line_ids.delete;
        attr_excluder_flags.delete;
        attr_accumulate_flags.delete;
        attr_product_attr_contexts.delete;
        attr_product_attributes.delete;
        attr_product_attr_values.delete;
        attr_product_uom_codes.delete;
        attr_comparison_operator_codes.delete;
        attr_pricing_contexts.delete;
        attr_pricing_attrs.delete;
        attr_pricing_attr_value_froms.delete;
        attr_pricing_attr_value_tos.delete;
        prc_datatypes.delete;

  FOR K IN start_prc_list_line_id..end_prc_list_line_id loop

    attr_count := attr_count + 1;

      l_product_context := 'ITEM';
      l_product_attr := 'PRICING_ATTRIBUTE1';

--dbms_output.put_line('crpa 4');

        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := 'BETWEEN'; --2664220 --NULL;
        attr_pricing_contexts(attr_count) := NULL;
        attr_pricing_attrs(attr_count) := NULL;
        attr_pricing_attr_value_froms(attr_count) := NULL;
        attr_pricing_attr_value_tos(attr_count) := NULL;
        prc_datatypes(attr_count) := NULL;

--dbms_output.put_line('crpa 101');

  /* check if pricing_attribute_context is present*/

/* Commented attr_pricing_contexts(attr_count) := pricing_contexts(K). This is because of Honeywell Bug # 1731134 - vgulati */

    If pricing_contexts(K) is not null then
--      attr_pricing_contexts(attr_count) := pricing_contexts(K);
        l_pricing_context := pricing_contexts(K);

       --l_pricing_attr_rec.l_pricing_context := pricing_contexts(K);

    else

       l_pricing_context := 'Upgrade Context';

    end if;

/* added attr_count := attr_count + 1 to create an extra record containing only product in qp_pricing_attributes. This is because of Honeywell Bug # 1731134 - vgulati  */

    If pricing_attribute1s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE1';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute1s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));

    end if;

--dbms_output.put_line('crpa 102');

    If pricing_attribute2s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE2';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute2s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));

        /*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
      */
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
    end if;

--dbms_output.put_line('crpa 103');

    If pricing_attribute3s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE3';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute3s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));

       /*
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        */

    end if;

--dbms_output.put_line('crpa 104');

    If pricing_attribute4s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE4';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute4s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 105');

    If pricing_attribute5s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE5';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute5s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 106');

    If pricing_attribute6s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE6';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute6s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 107');

    If pricing_attribute7s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE7';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute7s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 108');

    If pricing_attribute8s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE8';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute8s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 109');

    If pricing_attribute9s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE9';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute9s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 110');

    If pricing_attribute10s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE10';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute10s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 112');

    If pricing_attribute11s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE11';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute11s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 113');

    If pricing_attribute12s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE12';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute12s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

    If pricing_attribute13s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE13';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute13s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

    If pricing_attribute14s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE14';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute14s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/

    end if;

--dbms_output.put_line('crpa 116');

    If pricing_attribute15s(K) is not null then
        attr_count := attr_count + 1;
        attr_creation_dates(attr_count) := creation_dates(K);
        attr_created_bys(attr_count) := created_bys(K);
        attr_last_update_dates(attr_count) := last_update_dates(K);
        attr_last_updated_bys(attr_count) := last_updated_bys(K);
        attr_last_update_logins(attr_count) := last_update_logins(K);
        attr_program_application_ids(attr_count) := program_application_ids(K);
        attr_program_ids(attr_count) := program_ids(K);
        attr_program_update_dates(attr_count) := program_update_dates(K);
        attr_request_ids(attr_count) := request_ids(K);
        attr_list_line_ids(attr_count) := price_list_line_ids(K);
        attr_excluder_flags(attr_count) := 'N';
        attr_accumulate_flags(attr_count) := 'N';
        attr_product_attr_contexts(attr_count) := l_product_context;
        attr_product_attributes(attr_count) := l_product_attr;
        attr_product_attr_values(attr_count) := inventory_item_ids(K);
        attr_product_uom_codes(attr_count) := unit_codes(K);
        attr_comparison_operator_codes(attr_count) := '='; --3251389 --NULL;
        attr_pricing_contexts(attr_count) := l_pricing_context;
        attr_pricing_attrs(attr_count) := 'PRICING_ATTRIBUTE15';
        attr_pricing_attr_value_froms(attr_count) := pricing_attribute15s(K);
        attr_pricing_attr_value_tos(attr_count) := NULL;
        qp_util.get_segs_flex_precedence(p_segs_upg_t => v_segs_upg_t,
                             p_context    => attr_pricing_contexts(attr_count),
                             p_attribute  => attr_pricing_attrs(attr_count),
                             x_precedence => l_prc_precedence,
                             x_datatype   => prc_datatypes(attr_count));
/*
        BEGIN
           qp_util.get_prod_flex_properties
          	     (	attr_pricing_contexts(attr_count),
                	attr_pricing_attrs(attr_count),
                	attr_pricing_attr_value_froms(attr_count),
                	prc_datatypes(attr_count), l_prc_precedence, l_error);
	   IF l_error <> 0 THEN
	      RAISE e_get_prod_flex_properties;
           END IF;
        EXCEPTION
	       WHEN e_get_prod_flex_properties THEN
	        err_num := SQLCODE;
	        err_msg := SUBSTR(SQLERRM, 1, 240);
	       qp_util.log_error(price_list_ids(K), price_list_line_ids(K),
                                 NULL, NULL, NULL, NULL, NULL, NULL,
                                 'GET_PROD_FLEX_PRC', err_msg, 'PRICE_LISTS');
        END;
        --l_pricing_attr_tbl(I) := l_pricing_attr_rec;
*/
    end if;

 END LOOP;

--dbms_output.put_line('crpa 117');
--qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-6', v_errortext, 'PRICE_LISTS');

 BEGIN

 FORALL J IN 1..attr_count
 INSERT INTO QP_PRICING_ATTRIBUTES
 (PRICING_ATTRIBUTE_ID,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID,
  PROGRAM_UPDATE_DATE,
  REQUEST_ID,
  LIST_LINE_ID,
  EXCLUDER_FLAG,
  ACCUMULATE_FLAG,
  PRODUCT_ATTRIBUTE_CONTEXT,
  PRODUCT_ATTRIBUTE,
  PRODUCT_ATTR_VALUE,
  PRODUCT_UOM_CODE,
  PRICING_ATTRIBUTE_CONTEXT,
  PRICING_ATTRIBUTE,
  PRICING_ATTR_VALUE_FROM,
  PRICING_ATTR_VALUE_TO,
  ATTRIBUTE_GROUPING_NO,
  COMPARISON_OPERATOR_CODE,
  PRICING_ATTRIBUTE_DATATYPE,
  PRODUCT_ATTRIBUTE_DATATYPE
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,ORIG_SYS_PRICING_ATTR_REF
     ,ORIG_SYS_LINE_REF
     ,ORIG_SYS_HEADER_REF)
  VALUES
  (
   QP_PRICING_ATTRIBUTES_S.nextval,
   attr_creation_dates(J),
   attr_created_bys(J),
   attr_last_update_dates(J),
   attr_last_updated_bys(J),
   attr_last_update_logins(J),
   attr_program_application_ids(J),
   attr_program_ids(J),
   attr_program_update_dates(J),
   attr_request_ids(J),
   attr_list_line_ids(J),
   attr_excluder_flags(J),
   attr_accumulate_flags(J),
   attr_product_attr_contexts(J),
   attr_product_attributes(J),
   attr_product_attr_values(J),
   attr_product_uom_codes(J),
   attr_pricing_contexts(J),
   attr_pricing_attrs(J),
   attr_pricing_attr_value_froms(J),
   attr_pricing_attr_value_tos(J),
   1 ,
   attr_comparison_operator_codes(J),
   prc_datatypes(J),
   l_prod_datatype
     --ENH Upgrade BOAPI for orig_sys...ref RAVI
     ,to_char(QP_PRICING_ATTRIBUTES_S.currval)
     ,(select l.ORIG_SYS_LINE_REF from qp_list_lines l where l.list_line_id=attr_list_line_ids(J))
     ,(select l.ORIG_SYS_HEADER_REF from qp_list_lines l where l.list_line_id=attr_list_line_ids(J))
   );


  EXCEPTION
    WHEN OTHERS THEN
	err_msg := SQLERRM;
        J := sql%rowcount + 1;
	rollback;
    	QP_Util.Log_Error(p_id1 => attr_list_line_ids(J) ,
			  p_id2 => NULL,
			  p_error_type => 'PRICE_LIST_LINES_ATTR',
			  p_error_desc => err_msg,
			  p_error_module => 'Create_Pricing_Attribute');
	raise;

   END;

--qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-7', v_errortext, 'PRICE_LISTS');



  /* insert into qp_discount_mapping table for the rows that were
     just now inserted */

--    qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-8', v_errortext, 'PRICE_LISTS');

    /*

    FORALL l_prc_list_map_index IN new_prc_list_maps.FIRST..new_prc_list_maps.LAST
         INSERT INTO QP_DISCOUNT_MAPPING(OLD_DISCOUNT_ID,
                                         OLD_DISCOUNT_LINE_ID,
		                         NEW_LIST_HEADER_ID,
                                         NEW_LIST_LINE_ID,
                                         OLD_PRICE_BREAK_LINES_LOW,
		                         OLD_PRICE_BREAK_LINES_HIGH,
                                         OLD_METHOD_TYPE_CODE,
                                         OLD_PRICE_BREAK_PERCENT,
		                         OLD_PRICE_BREAK_AMOUNT,
                                         OLD_PRICE_BREAK_PRICE,
                                         NEW_TYPE,
                                         PRICING_CONTEXT)
         VALUES (new_prc_list_maps(l_prc_list_map_index).old_price_list_id,
                new_prc_list_maps(l_prc_list_map_index).old_price_list_line_id,
                new_prc_list_maps(l_prc_list_map_index).new_list_header_id,
                new_prc_list_maps(l_prc_list_map_index).new_list_line_id,
		NULL,
                NULL,
                NULL,
                NULL,
		NULL,
                NULL,
                'P',
                NULL);

   */

--   qp_util.log_error(NULL, NULL, NULL, NULL, NULL, NULL, NULL,
--			    NULL, 'MAIN-9', v_errortext, 'PRICE_LISTS');
/* vivek

   prc_list_maps := new_prc_list_maps;

vivek */


   commit;

/* vivek   prc_list_maps.delete;  vivek */

END IF;  /* IF PRICE_LIST_LINE_IDS.FIRST IS NOT NULL */

END LOOP; /* while loop */

COMMIT;

exception

  when others then
    v_errortext := SUBSTR(SQLERRM, 1,240);
    K := sql%rowcount + l_min_line;
    ROLLBACK;
    If price_list_ids.exists(k) then
    qp_util.log_error(price_list_ids(K), NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'PRICE_LIST_LINES_MAIN', v_errortext, 'PRICE_LISTS');
    else
    qp_util.log_error(-1111, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'PRICE_LIST_LINES_MAIN', v_errortext, 'PRICE_LISTS');
    end if;
    RAISE;

end create_list_lines;


end qp_list_upgrade_util_pvt;

/
