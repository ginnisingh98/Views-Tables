--------------------------------------------------------
--  DDL for Package Body QP_ADJUST_PRICELIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ADJUST_PRICELIST_PVT" AS
/* $Header: QPXVAPLB.pls 120.3.12010000.4 2009/07/23 06:58:33 hmohamme ship $ */

PROCEDURE Adjust_Price_List
(
-- p_api_version_number   IN	NUMBER,
-- p_init_msg_list        IN	VARCHAR2 := FND_API.G_FALSE,
-- p_commit		         IN	VARCHAR2 := FND_API.G_FALSE,
-- x_return_status	    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
-- x_msg_count		    OUT NOCOPY /* file.sql.39 change */	NUMBER,
-- x_msg_data		    OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
 errbuf                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 retcode                OUT NOCOPY /* file.sql.39 change */   NUMBER,
 p_list_header_id  	IN    NUMBER,
-- Changed datatype of p_percent and p_amount for Bug 2209587
 p_percent              IN    VARCHAR2,
 p_amount               IN      VARCHAR2,
 p_segment1_lohi        IN	VARCHAR2,
 p_segment2_lohi        IN	VARCHAR2,
 p_segment3_lohi        IN	VARCHAR2,
 p_segment4_lohi        IN	VARCHAR2,
 p_segment5_lohi        IN	VARCHAR2,
 p_segment6_lohi        IN	VARCHAR2,
 p_segment7_lohi        IN	VARCHAR2,
 p_segment8_lohi        IN	VARCHAR2,
 p_segment9_lohi        IN	VARCHAR2,
 p_segment10_lohi       IN	VARCHAR2,
 p_segment11_lohi       IN	VARCHAR2,
 p_segment12_lohi       IN	VARCHAR2,
 p_segment13_lohi       IN	VARCHAR2,
 p_segment14_lohi       IN	VARCHAR2,
 p_segment15_lohi       IN	VARCHAR2,
 p_segment16_lohi       IN	VARCHAR2,
 p_segment17_lohi       IN	VARCHAR2,
 p_segment18_lohi       IN	VARCHAR2,
 p_segment19_lohi       IN	VARCHAR2,
 p_segment20_lohi       IN	VARCHAR2,
 p_org_id	        IN	NUMBER,     -- added for 2053405 by dhgupta
 p_category_set_id      IN      NUMBER,     -- added for 2053405 by dhgupta
 p_category_id		    IN	NUMBER,
 p_status_code 	    IN	VARCHAR2,
 p_create_date          IN	DATE,
 p_rounding_factor      IN 	NUMBER
)
IS

--l_api_version_number		CONSTANT	NUMBER		:= 1.0;
--l_api_name				CONSTANT	VARCHAR2(30)	:= 'Copy_Price_List';
--l_return_status			VARCHAR2(1);
--l_msg_count				NUMBER;
--l_msg_buf					VARCHAR2(4000);
l_conc_request_id			NUMBER := -1;
l_conc_program_application_id	NUMBER := -1;
l_conc_program_id			NUMBER := -1;
l_conc_login_id		   	NUMBER := -1;
l_user_id					NUMBER := -1;
l_test                        NUMBER := 0;
l_update_stmt                 VARCHAR2(9000) := '';
l_select_stmt                 VARCHAR2(9000) := '';
l_where_common                VARCHAR2(9000) := '';
l_where_select                VARCHAR2(9000) := '';
l_change                      NUMBER := 0;
l_category_set_id             NUMBER := 0;
l_category_id                 NUMBER := p_category_id;
l_create_date                 DATE   := p_create_date;
l_status_code                 VARCHAR2(30) := p_status_code;
l_date_mask                   VARCHAR2(14) := '''YYYYMMDD''';
l_sysdate                     DATE;
dummy                   VARCHAR2(1);
l_percent               NUMBER;
l_amount                NUMBER;
l_rounding_factor       NUMBER;
l_price_rounding        VARCHAR2(50) :='';
l_param_set             VARCHAR2(1)  := 'N';

BEGIN

l_conc_request_id := FND_GLOBAL.CONC_REQUEST_ID;
l_conc_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
l_user_id         := FND_GLOBAL.USER_ID;
l_conc_login_id   := FND_GLOBAL.CONC_LOGIN_ID;
l_conc_program_application_id := FND_GLOBAL.PROG_APPL_ID;

l_sysdate := sysdate;

/* Added canonical to number conversion by dhgupta for 1877622 */

l_percent := qp_number.canonical_to_number(p_percent);
l_amount  := qp_number.canonical_to_number(p_amount);

/** Following code adjusts price list **/


l_update_stmt := 'UPDATE qp_list_lines q

                 SET    q.operand = ';

l_select_stmt := 'SELECT NULL
                  FROM qp_list_lines q ';

l_where_select := 'AND q.operand + :chg < 0
                  AND rownum < 2 ';

/* Bug 1733332,1807570 : Since the Price List form allows user to store
prices upto any precision, to be consistent we need to remove the
rounding in the Adjustment module. User should be able to adjust the price
by any amount or percent. We will not round that amount. */


    l_price_rounding := fnd_profile.value('QP_PRICE_ROUNDING');

    IF l_price_rounding IS NOT NULL THEN          --Added for Enhancement 1732601

      BEGIN

      select rounding_factor
      into   l_rounding_factor
      from   qp_list_headers_b
      where  list_header_id = p_list_header_id;

      EXCEPTION
         WHEN OTHERS THEN
           l_rounding_factor := -2;
      END;

      IF l_percent IS NOT NULL THEN   --Modified for 2340126
      --IF nvl(l_percent,0) <> 0 THEN

         l_update_stmt := l_update_stmt ||
                 'ROUND((q.operand *(:chg/100) + q.operand),-1*:rf), ';
           l_change := l_percent;


      ELSIF l_amount IS NOT NULL THEN  --Modified for 2340126
      --ELSIF nvl(l_amount,0) <> 0 THEN
            l_update_stmt := l_update_stmt ||
                 'ROUND(((:chg) + q.operand),-1*:rf), ';
                l_change := l_amount;

      END IF;

    ELSE
      IF l_percent IS NOT NULL THEN   --Modified for 2340126
      --IF nvl(l_percent,0) <> 0 THEN

              l_update_stmt := l_update_stmt ||
                 'q.operand *(:chg/100) + q.operand, ';
              l_change := l_percent;

      ELSIF l_amount IS NOT NULL THEN   --Modified for 2340126
      --ELSIF nvl(l_amount,0) <> 0 THEN
              l_update_stmt := l_update_stmt ||
                 '(:chg) + q.operand, ';
              l_change := l_amount;

      END IF;
    END IF;

l_update_stmt := l_update_stmt ||
    		'q.last_update_date  = :dat1,
    	  	 q.last_updated_by   = :usr,
    		 q.request_id        = :req,
    		 q.program_application_id = :app,
    		 q.program_id        = :pgm,
     	 q.program_update_date = :dat2,
    		 q.last_update_login = :lgn ';


l_where_common := 'WHERE  q.list_header_id = :lh
		 AND    q.generate_using_formula_id IS NULL';
--Commented out for 2615377
/*
		 AND    q.list_line_id IN
	 (SELECT  DISTINCT a.list_line_id
	  FROM    qp_pricing_attributes a
	  WHERE   a.list_line_id = q.list_line_id ';
*/
--Added for 2615377
IF  p_create_date IS NOT NULL THEN
    l_where_common := l_where_common ||
                 ' AND    TO_DATE(TO_CHAR(q.creation_date,''YYYY/MM/DD''),''YYYY/MM/DD'') = ' || 'TO_DATE(''' || TO_CHAR(p_create_date,'YYYY/MM/DD') || ''',''YYYY/MM/DD'')' || ' ';
END IF;
--Added for 2615377
l_where_common := l_where_common ||' AND    q.list_line_id IN
         (SELECT  a.list_line_id        --  7540916
          FROM    qp_pricing_attributes a
          WHERE   1 = 1 ';

IF p_category_set_id IS NOT NULL OR p_category_id IS NOT NULL    --Modified by dhgupta for 2053405
OR (p_create_date IS NOT NULL) OR (p_status_code IS NOT NULL)
OR (p_segment1_lohi <> ''''' AND ''''') OR (p_segment2_lohi <> ''''' AND ''''')
OR (p_segment3_lohi <> ''''' AND ''''') OR (p_segment4_lohi <> ''''' AND ''''')
OR (p_segment5_lohi <> ''''' AND ''''') OR (p_segment6_lohi <> ''''' AND ''''')
OR (p_segment7_lohi <> ''''' AND ''''') OR (p_segment8_lohi <> ''''' AND ''''')
OR (p_segment9_lohi <> ''''' AND ''''') OR (p_segment10_lohi <> ''''' AND ''''')
OR (p_segment11_lohi <> ''''' AND ''''')
OR (p_segment12_lohi <> ''''' AND ''''')
OR (p_segment13_lohi <> ''''' AND ''''')
OR (p_segment14_lohi <> ''''' AND ''''')
OR (p_segment15_lohi <> ''''' AND ''''')
OR (p_segment16_lohi <> ''''' AND ''''')
OR (p_segment17_lohi <> ''''' AND ''''')
OR (p_segment18_lohi <> ''''' AND ''''')
OR (p_segment19_lohi <> ''''' AND ''''')
OR (p_segment20_lohi <> ''''' AND ''''') THEN

  l_param_set := 'Y';

/* Commented the following statement and replaced it with a new statement to fix
 the bug 1586265 */
 /*
    l_update_stmt := l_update_stmt ||
	 'AND     TO_NUMBER(a.product_attr_value) IN
    		( SELECT m.inventory_item_id
    		  FROM   mtl_system_items m
    		  WHERE  m.inventory_item_id = TO_NUMBER(a.product_attr_value) ';
		  */

-- changes for 7540916

l_where_common := l_where_common ||
     'AND a.product_attribute_context = ''ITEM''
	 AND a.product_attribute = ''PRICING_ATTRIBUTE1''
	 AND a.product_attr_value IN
	   (SELECT TO_CHAR(m.inventory_item_id)
         FROM  mtl_system_items m
	    WHERE  1=1 ';

--Commented out for 2615377
/*
IF  p_create_date IS NOT NULL THEN
    l_where_common := l_where_common ||
		 'AND    TO_DATE(TO_CHAR(m.creation_date,''YYYY/MM/DD''),''YYYY/MM/DD'') = ' || 'TO_DATE(''' || TO_CHAR(p_create_date,'YYYY/MM/DD') || ''',''YYYY/MM/DD'')' || ' ';
END IF;
*/

IF  p_status_code IS NOT NULL THEN
    l_where_common := l_where_common ||
		 'AND    m.inventory_item_status_code = ' || '''' || p_status_code || '''' || ' ';
END IF;

 /* Added by dhgupta for 2053405 */

IF p_category_set_id IS NULL THEN
    l_where_common := l_where_common ||
                 'AND    Exists
                 ( SELECT ''x''			-- changes for 7540916
                   FROM   mtl_item_categories ic
                   WHERE  m.inventory_item_id = ic.inventory_item_id
                   AND    m.organization_id = ic.organization_id  ) ';
END IF;

/* Added by dhgupta for 2053405 */

IF p_category_set_id IS NOT NULL AND p_category_id IS NULL THEN
    l_where_common := l_where_common ||
                 'AND    Exists
                 ( SELECT ''x''			-- changes for 7540916
                   FROM   mtl_item_categories ic
                   WHERE  m.inventory_item_id = ic.inventory_item_id
                   AND    m.organization_id = ic.organization_id
                   AND ic.category_set_id = :category_set_id ) ';
END IF;

 /* Added by dhgupta for 2053405 */

IF p_category_set_id IS NOT NULL AND p_category_id IS NOT NULL THEN
    l_where_common := l_where_common ||
                 'AND    Exists
                 ( SELECT ''x''			-- changes for 7540916
                   FROM   mtl_item_categories ic
                   WHERE  m.inventory_item_id = ic.inventory_item_id
                   AND    m.organization_id = ic.organization_id
                   AND ic.category_set_id = :category_set_id
                   AND ic.category_id     = :category_id ) ';
END IF;

/*
IF  nvl(p_category_id,0) <> 0 THEN
--    SELECT category_set_id
--    INTO   l_category_set_id
--    FROM   mtl_default_category_sets
--    WHERE  functional_area_id = 7; --Order Entry Functional Area

    l_where_common := l_where_common ||
		 'AND    m.inventory_item_id IN
		 ( SELECT ic.inventory_item_id
		   FROM   mtl_item_categories ic
		   WHERE  ic.inventory_item_id = m.inventory_item_id
		   AND    ic.organization_id   = m.organization_id
                   AND ic.organization_id = :org_id
                   AND ic.category_set_id = :category_set_id
		   AND ic.category_id     = :category_id ) ';
END IF;
*/
IF (p_segment1_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment1   BETWEEN ' || p_segment1_lohi || ') ';
END IF;

IF (p_segment2_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment2   BETWEEN ' || p_segment2_lohi || ') ';
END IF;

IF (p_segment3_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment3   BETWEEN ' || p_segment3_lohi || ') ';
END IF;

IF (p_segment4_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment4   BETWEEN ' || p_segment4_lohi || ') ';
END IF;

IF (p_segment5_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment5   BETWEEN ' || p_segment5_lohi || ') ';
END IF;

IF (p_segment6_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment6   BETWEEN ' || p_segment6_lohi || ') ';
END IF;

IF (p_segment7_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment7   BETWEEN ' || p_segment7_lohi || ') ';
END IF;

IF (p_segment8_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment8   BETWEEN ' || p_segment8_lohi || ') ';
END IF;

IF (p_segment9_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment9   BETWEEN ' || p_segment9_lohi || ') ';
END IF;

IF (p_segment10_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment10   BETWEEN ' || p_segment10_lohi || ') ';
END IF;

IF (p_segment11_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment10   BETWEEN ' || p_segment11_lohi || ') ';
END IF;
IF (p_segment12_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment12   BETWEEN ' || p_segment12_lohi || ') ';
END IF;

IF (p_segment13_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment13   BETWEEN ' || p_segment13_lohi || ') ';
END IF;

IF (p_segment14_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment14   BETWEEN ' || p_segment14_lohi || ') ';
END IF;

IF (p_segment15_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment15   BETWEEN ' || p_segment15_lohi || ') ';
END IF;

IF (p_segment16_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment16   BETWEEN ' || p_segment16_lohi || ') ';
END IF;

IF (p_segment17_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment17   BETWEEN ' || p_segment17_lohi || ') ';
END IF;

IF (p_segment18_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment18   BETWEEN ' || p_segment18_lohi || ') ';
END IF;

IF (p_segment19_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment19   BETWEEN ' || p_segment19_lohi || ') ';
END IF;

IF (p_segment20_lohi <> ''''' AND ''''') THEN
   l_where_common := l_where_common ||
           'AND    (m.segment20   BETWEEN ' || p_segment20_lohi || ') ';
END IF;
-- changes for 7540916
l_update_stmt := l_update_stmt || l_where_common || ' and     m.organization_id = :org_id ) )';
l_select_stmt := l_select_stmt || l_where_common || ' and     m.organization_id = :org_id ) )'||l_where_select ;

ELSE
-- changes for 7540916
l_update_stmt := l_update_stmt || l_where_common || ' )';  --8688432
l_select_stmt := l_select_stmt || l_where_common || ' )'||l_where_select ;  --8688432

END IF; /* If any of the criteria about inventory_item_id is satisfied */

IF (NVL(l_amount,0) < 0 And  (FND_PROFILE.VALUE('QP_NEGATIVE_PRICING')= 'N'))  THEN
	BEGIN
          IF l_param_set = 'N' THEN
             EXECUTE IMMEDIATE l_select_stmt INTO dummy USING
   	     p_list_header_id, l_change;
          ELSE
            IF p_category_set_id IS NULL AND p_category_id IS NULL THEN
               EXECUTE IMMEDIATE l_select_stmt INTO dummy USING
     	       p_list_header_id, p_org_id, l_change;
            END IF;
            IF p_category_set_id IS NOT NULL AND p_category_id IS NULL THEN
	       EXECUTE IMMEDIATE l_select_stmt INTO dummy USING
   	       p_list_header_id, p_category_set_id, p_org_id, l_change; --Bug 7682041
            END IF;
            IF p_category_set_id IS NOT NULL AND p_category_id IS NOT NULL THEN
	       EXECUTE IMMEDIATE l_select_stmt INTO dummy USING
               p_list_header_id, p_category_set_id, p_category_id, p_org_id, l_change; --Bug 7682041
            END IF;
          END IF;
	     errbuf := FND_MESSAGE.GET_STRING('QP','QP_NEGATIVE_PRICE_AFTER_ADJUST');
	     retcode := 2;
	     RETURN;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
	END;
END IF;

  --fnd_file.put_line(FND_FILE.LOG, 'l_update_stmt before processing:' || l_update_stmt);   --8688432 debug
  --fnd_file.put_line(FND_FILE.LOG, 'l_select_stmt: before processing:' || l_select_stmt);   --8688432 debug

IF l_price_rounding IS NOT NULL THEN                 --Added for Enhancement 1732601
      IF l_param_set = 'N' THEN
         EXECUTE IMMEDIATE l_update_stmt USING
         l_change,l_rounding_factor,l_sysdate, l_user_id,
         l_conc_request_id, l_conc_program_application_id,
         l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id;
      ELSE
        IF p_category_set_id IS NULL AND p_category_id IS NULL THEN
           EXECUTE IMMEDIATE l_update_stmt USING
           l_change,l_rounding_factor,l_sysdate, l_user_id,
           l_conc_request_id, l_conc_program_application_id,
           l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id, p_org_id;
        END IF;
        IF p_category_set_id IS NOT NULL AND p_category_id IS NULL THEN
           EXECUTE IMMEDIATE l_update_stmt USING
           l_change,l_rounding_factor,l_sysdate, l_user_id,
           l_conc_request_id, l_conc_program_application_id,
           l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id, p_category_set_id, p_org_id; --Bug 7682041
        END IF;
        IF p_category_set_id IS NOT NULL AND p_category_id IS NOT NULL THEN
           EXECUTE IMMEDIATE l_update_stmt USING
           l_change,l_rounding_factor,l_sysdate, l_user_id,
           l_conc_request_id, l_conc_program_application_id,
           l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id, p_category_set_id, p_category_id, p_org_id;  --Bug 7682041
        END IF;
      END IF;
ELSE
      IF l_param_set = 'N' THEN
         EXECUTE IMMEDIATE l_update_stmt USING
         l_change,l_sysdate, l_user_id,
         l_conc_request_id, l_conc_program_application_id,
         l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id;
      ELSE
        IF p_category_set_id IS NULL AND p_category_id IS NULL THEN
           EXECUTE IMMEDIATE l_update_stmt USING
           l_change,l_sysdate, l_user_id,
           l_conc_request_id, l_conc_program_application_id,
           l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id, p_org_id;
        END IF;
        IF p_category_set_id IS NOT NULL AND p_category_id IS NULL THEN
           EXECUTE IMMEDIATE l_update_stmt USING
           l_change,l_sysdate, l_user_id,
           l_conc_request_id, l_conc_program_application_id,
           l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id, p_category_set_id, p_org_id; --Bug 7682041
        END IF;
        IF p_category_set_id IS NOT NULL AND p_category_id IS NOT NULL THEN
           EXECUTE IMMEDIATE l_update_stmt USING
           l_change,l_sysdate, l_user_id,
           l_conc_request_id, l_conc_program_application_id,
           l_conc_program_id, l_sysdate, l_conc_login_id, p_list_header_id, p_category_set_id, p_category_id, p_org_id; --Bug 7682041
        END IF;
      END IF;
END IF;
retcode := 0;

COMMIT;

errbuf := '';

EXCEPTION
	WHEN OTHERS THEN
		errbuf :=  SQLCODE||' - '||SQLERRM;
		retcode := 2;
END Adjust_Price_List;

END QP_ADJUST_PRICELIST_PVT;

/
