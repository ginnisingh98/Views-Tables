--------------------------------------------------------
--  DDL for Package Body ONT_UPG_TAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_UPG_TAX_UTIL" AS
/* $Header: OEXUPGTB.pls 120.3 2006/02/17 16:35:06 aycui ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_UPG_TAX_UTIL';
G_BATCH_SIZE                  CONSTANT NUMBER := 500;
G_HEADER_SIZE                 CONSTANT NUMBER := 5000;
G_BATCH_COUNT                 NUMBER := 0;

Procedure calculate_order_tax
( p_org_id       IN  NUMBER
, p_start_date IN DATE
, p_end_date IN DATE
, x_return_status OUT NOCOPY VARCHAR2

  ) IS

Type header_id_tab Is table of number index by Binary_integer;

header_id_t header_id_tab;

l_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_end_date date := sysdate;
--bug 4149275
l_msg_count                  number;
l_msg_data                   Varchar2(2000);

cursor headers is
select /* MOAC_SQL_CHANGE */ h.header_id
from oe_order_headers h
where h.creation_date between
                   trunc(nvl(p_start_date, add_months(sysdate, -10000)))
                   and trunc(nvl(l_end_date, add_months(sysdate, +10000)))
and h.upgraded_flag = 'Y'
AND EXISTS (SELECT 'x'
              FROM oe_order_lines_all l
             WHERE l.header_id = h.header_id
	       AND l.org_id = h.org_id
               AND l.tax_code <> 'Exempt'
               AND l.tax_exempt_flag <> 'E'
               AND l.tax_rate is null
               AND l.TAX_VALUE is null);

/* =========================================================================== */
/* In the above cursor query 'EXISTS' is added for the performance bug 3056892 */
/* =========================================================================== */

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

      x_return_status  := l_return_status;
	 l_end_date := p_end_date + 1;


      open headers;
       OE_MSG_PUB.Initialize;
      loop

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'IN HEADERS' , 1 ) ;
          END IF;

           header_id_t.delete;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN HEADERS: 1' , 1 ) ;
 END IF;

           FETCH headers BULK COLLECT INTO header_id_t
           Limit G_HEADER_SIZE;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'IN HEADERS: 2' , 1 ) ;
 END IF;

           IF header_id_t.first is not null THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'INSIDE THE HEADER_ID_T.FIRST NOT NULL' , 1 ) ;
              END IF;

              FOR K in header_id_t.first..header_id_t.last LOOP

	       IF l_debug_level  > 0 THEN
	           oe_debug_pub.add(  'HEADER ID IS : ' || HEADER_ID_T ( K ) , 1 ) ;
	       END IF;

         OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'HEADER'
        ,p_entity_id                    => HEADER_ID_T ( K )
        ,p_header_id                    => HEADER_ID_T ( K )
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id              => null
        ,p_source_document_type_id      => null);

         --call om_tax_util.calculate_tax to fix bug 3056892
        	--Process_Tax
        	OM_TAX_UTIL.CALCULATE_TAX( p_header_id => header_id_t(K)
          	, x_return_status => l_return_status);


                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      OE_MSG_PUB.Count_And_Get (p_count => l_msg_count
                                ,p_data  => l_msg_data);
               oe_debug_pub.add(  'MESSAGES RETURNED: '|| TO_CHAR ( l_msg_count ),1 ) ;
  if l_msg_count > 0 then
       OE_MSG_PUB.Add_text('Tax calculation failed for Header Id :'|| header_id_t(K));
       l_msg_data :=  'Error message for header_id ' || header_id_t(K) ||' is :  '||l_msg_data;
                                IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add(  l_msg_data,1 ) ;
                                END IF;
  end if;
                     --RAISE FND_API.G_EXC_ERROR;
                END IF;
      IF l_debug_level > 0 THEN
        oe_debug_pub.add(' Save the Messages for Header: '||  header_id_t(K), 1);
      END IF;
      OE_MSG_PUB.save_UI_messages (0,'C');

              END LOOP; /* for loop */

           END IF; /* if header_id_t.first is not null */

         COMMIT;

        EXIT when headers%NOTFOUND;

      end loop;  /* loop of headers cursor */

      close headers;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'TAX_ORDER: IN NO DATA FOUND' , 4 ) ;
	  END IF;
       x_return_status  := FND_API.G_RET_STS_SUCCESS;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'calculate_order_tax'
	    );
    	END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end calculate_order_tax;

END ONT_UPG_TAX_UTIL;

/
