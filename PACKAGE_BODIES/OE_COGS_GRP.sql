--------------------------------------------------------
--  DDL for Package Body OE_COGS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_COGS_GRP" AS
/* $Header: OEXGCGSB.pls 120.2 2006/07/14 11:09:09 serla noship $ */


PROCEDURE get_revenue_event_line
            (
             p_shippable_line_id      IN  NUMBER,
             x_revenue_event_line_id  OUT NOCOPY NUMBER,
             x_return_status          OUT NOCOPY VARCHAR2,
             x_msg_count              OUT NOCOPY NUMBER,
             x_msg_data               OUT NOCOPY VARCHAR2
           )	IS

	l_line_id NUMBER;
	l_invoicable VARCHAR2(1);
	l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;

   BEGIN
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
	   l_line_id := p_shippable_line_id;

	  WHILE x_revenue_event_line_id IS NULL LOOP

	    l_line_rec := oe_line_util.query_row(l_line_id);

	    IF oe_invoice_pub.line_invoiceable(l_line_rec) THEN
	         x_revenue_event_line_id := l_line_id;

	    ELSIF l_line_rec.link_to_line_id IS NULL THEN

	        -- for a standard line or a top model line,
		-- the revenue event line is itself
	        -- for an included item, if non of its parent is invoicable,
		-- the revenue event line will be the top  model line

	        x_revenue_event_line_id := l_line_id;

	     ELSE

	        l_line_id := l_line_rec.link_to_line_id;

	    END IF;

	   END LOOP;

   EXCEPTION WHEN NO_DATA_FOUND THEN

		 -- query order lines might return no data found
                 -- either because costing is passing an invalid order line
                 -- or because this line has an invalid link_to_line_id
                       	FND_MESSAGE.SET_NAME('ONT', 'OE_COGS_INVALID_LINE_ID');
                        FND_MESSAGE.SET_TOKEN('LINE_ID', p_shippable_line_id);
                        OE_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;

	      WHEN OTHERS THEN
                       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END get_revenue_event_line;



FUNCTION is_revenue_event_line
          (
 	   p_line_id       IN  NUMBER
 	   ) RETURN VARCHAR2 IS

       l_child varchar2(1) := 'N';
       l_master_org_id NUMBER;
       l_master_org varchar2(30) := 'MASTER_ORGANIZATION_ID';
       l_line_rec OE_ORDER_PUB.LINE_REC_TYPE;
       l_notify_costing VARCHAR2(1);
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

 BEGIN

	l_line_rec := oe_line_util.query_row(p_line_id);

	   IF (l_line_rec.retrobill_request_id IS NOT NULL
             OR l_line_rec.line_category_code = 'RETURN'
             OR l_line_rec.source_document_type_id = 10
             OR l_line_rec.cancelled_flag = 'Y' ) THEN

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'is revenue line: return/retrobill/internal/cancelled: returning N' , 1 ) ;
             END IF;

	      RETURN 'N';

	   END IF;


         l_master_org_id := oe_sys_parameters.value(l_master_org, l_line_rec.org_id);

          IF l_line_rec.invoiced_quantity IS NULL  OR l_line_rec.invoiced_quantity = 0 THEN

              IF    l_line_rec.top_model_line_id IS NULL
	        AND l_line_rec.item_type_code = 'STANDARD'
		AND l_line_rec.shipped_quantity IS NOT NULL THEN
                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'is revenue line: standard shippable: returning Y' , 1 ) ;
                 END IF;

                         RETURN 'Y';

              ELSIF l_line_rec.top_model_line_id IS NOT NULL THEN

		      -- model component

	             IF ( (p_line_id <> l_line_rec.top_model_line_id
		          AND oe_invoice_pub.line_invoiceable(l_line_rec))
	                  OR (p_line_id = l_line_rec.top_model_line_id)) THEN

			BEGIN
                         SELECT 'Y' INTO l_notify_costing
			    FROM DUAL WHERE EXISTS (SELECT l.line_id
                                                     FROM oe_order_lines_all l,
                                                          mtl_system_items msi
                                                     WHERE link_to_line_id = p_line_id
                                                     AND   l.inventory_item_id=msi.inventory_item_id
                                                     AND   msi.organization_id= l_master_org_id
                                                     AND   (msi.invoice_enabled_flag =	'N'
						            OR msi.invoiceable_item_flag = 'N'
							    OR l.item_type_code='INCLUDED'
                                                            OR l.item_type_code='CONFIG'));
                	       l_child := 'Y';

	                  EXCEPTION
	                        WHEN NO_DATA_FOUND THEN
                  	          l_child:= 'N';
  	                   END;

	               IF l_child = 'Y' OR l_line_rec.shipped_quantity IS NOT NULL THEN
                          IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'is revenue line: model component: l_child='||l_child||' shipped_quantity='||l_line_rec.shipped_quantity||' returning Y' , 1 ) ;
                          END IF;

			  RETURN 'Y';

                       END IF;

	       END IF;  -- top model line or invoiceable line
       END IF; -- part of a model;
     END IF;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'is revenue line: returning N', 1);
     END IF;
       RETURN 'N';

 EXCEPTION WHEN OTHERS THEN

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END is_revenue_event_line;


END oe_cogs_grp;

/
