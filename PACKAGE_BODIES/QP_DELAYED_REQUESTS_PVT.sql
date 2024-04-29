--------------------------------------------------------
--  DDL for Package Body QP_DELAYED_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DELAYED_REQUESTS_PVT" AS
/* $Header: QPXVREQB.pls 120.5.12010000.2 2009/02/04 14:02:58 jputta ship $ */
--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Delayed_Requests_PVT';

g_delayed_requests		QP_QUALIFIER_RULES_PUB.Request_Tbl_Type;
g_requesting_entities  		QP_QUALIFIER_RULES_PUB.Requesting_Entity_Tbl_Type;
G_MAX_REQUESTS                  NUMBER := 1000; --2502849
/* Local Procedures */
/* Local procedure to check if a request exists for a given entity, request
   return the result in p_request_search_result which is set to FND_API.G_TRUE
   if the request exists. The index of the request in request table is returned
   in parameter p_request_ind
*/
/* BUG 2502849-
   Changes to improve scalability of this search when there
   is a large number of requests:

   The index value where the request is stored is a function of the
   entity_id value (the function  was chosen to be 'mod' as this has
   a high probability of resulting in a unique value as line ids are
   generated sequentially). Therefore, this check would search only
   through requests for the entity_id that resolves to the same
   mod value.

   If the request does NOT exist, then x_result is set to FND_API.G_FALSE
   and the parameter x_request_ind has the index value where this request
   should be inserted.
*/
Procedure  Check_for_Request( p_entity_code    in Varchar2
			      ,p_entity_id     in Number
			      ,p_request_type  in Varchar2
			      ,p_request_unique_key1 	IN VARCHAR2
			      ,p_request_unique_key2 	IN VARCHAR2
			      ,p_request_unique_key3 	IN VARCHAR2
			      ,p_request_unique_key4 	IN VARCHAR2
			      ,p_request_unique_key5 	IN VARCHAR2
			      ,x_request_ind   OUT NOCOPY Number
			      ,x_result        OUT NOCOPY Varchar2
			      ,x_return_status OUT NOCOPY Varchar2)
  IS
     l_ind	pls_integer;
     l_max_ind  pls_integer;
BEGIN
   x_return_status	:= FND_API.G_RET_STS_SUCCESS;
   x_result		:= FND_API.G_FALSE;

   oe_debug_pub.add('Entering Procedure Check_for_Request in Package QP_Delayed_Requests_Pvt');

   -- 2502849 l_ind to l_max_ind is the range of index positions that can
   -- hold requests for this entity id - for e.g. if entity_id is
   -- 2341 and G_MAX_REQUESTS is 1000 then the range would be:
   -- 2341001 - 2342000

   l_ind := (mod(p_entity_id,100000) * G_MAX_REQUESTS)+1;
   l_max_ind := l_ind + G_MAX_REQUESTS - 1;

   -- 2502849 Starting from l_ind, search for the first index position
   -- with a request. This is required as requests can be
   -- deleted later which will result in indexes without any
   -- requests. However, the search should still go over the
   -- requests in the range from l_ind to l_max_ind.

   IF NOT G_Delayed_Requests.Exists(l_ind) THEN
      x_request_ind := l_ind;
      l_ind := G_Delayed_Requests.Next(l_ind);
   END IF;

   WHILE G_Delayed_Requests.Exists(l_ind)
         AND l_ind <= l_max_ind LOOP
        x_request_ind := l_ind+1;

	IF G_Delayed_Requests(l_ind).Entity_code = p_entity_code
	  AND
	  G_Delayed_Requests(l_ind).Entity_id = p_entity_id
	  AND
	  G_Delayed_Requests(l_ind).Request_Type = p_request_type
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key1, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key1, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key2, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key2, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key3, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key3, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key4, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key4, FND_API.G_MISS_CHAR)
	  AND
	  NVL(G_Delayed_Requests(l_ind).request_unique_key5, FND_API.G_MISS_CHAR) =
	  	NVL(p_request_unique_key5, FND_API.G_MISS_CHAR)
      AND NVL(G_Delayed_Requests(l_ind).processed,'N') = 'N'  -- added for 2502849
	  THEN
	   x_request_ind := l_ind;
	   x_result := FND_API.G_TRUE;
	   EXIT;
	END IF;

      l_ind := G_Delayed_Requests.Next(l_ind);

     END LOOP;

/* Added for 2502849 */

     IF x_request_ind > l_max_ind THEN
        FND_MESSAGE.SET_NAME('QP','QP_MAX_REQUESTS_EXCEEDED');
        OE_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'CheckForRequest');
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Check_For_Request;

PROCEDURE Process_Request_Pvt
   (p_request_ind	IN Number
   ,p_delete            IN Varchar2 default  FND_API.G_FALSE
   ,x_return_status	OUT NOCOPY VARCHAR2)
IS
l_request_rec       QP_QUALIFIER_RULES_PUB.request_rec_type;
l_request_type	VARCHAR2(30);
l_return_status	VARCHAR2(1);
l_entity_id	NUMBER;
l_entity_code	Varchar2(30);
l_req_entity_ind		number;
l_set_index     NUMBER;
l_set_request  QP_QUALIFIER_RULES_PUB.request_tbl_type;
l_deleted_options_tbl  QP_QUALIFIER_RULES_PUB.request_tbl_type;
l_updated_options_tbl  QP_QUALIFIER_RULES_PUB.request_tbl_type;
l_d_index              NUMBER;
l_u_index              NUMBER;
K                      NUMBER;
I                      NUMBER := 1;
l_dup_sdate            DATE := NULL;
l_dup_edate            DATE := NULL;
l_count                NUMBER;


BEGIN

      oe_debug_pub.add('Entering Procedure Process_Request_Pvt ');
      --dbms_output.put_line('Entering Procedure Process_Request_Pvt ');

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      oe_debug_pub.add('Request processed  '||G_Delayed_Requests(p_request_ind).processed);

      -- if request has already been processed ('Y') or if the request is
      -- being processed ('I'): this would occur if request resulted in
      -- to a recursive call to process order.
      if  (G_Delayed_Requests(p_request_ind).processed = 'Y'
		OR G_Delayed_Requests(p_request_ind).processed = 'I')
	 then
          RETURN;
      end if;
      l_request_rec :=  G_Delayed_Requests(p_request_ind);
      l_entity_code    := l_request_rec.entity_code;
      l_entity_Id      := l_request_rec.entity_Id;
      l_request_type   := l_request_rec.request_type;

      oe_debug_pub.add('Request type  '||l_request_type);
      oe_debug_pub.add('entity code  '||l_entity_code);
      oe_debug_pub.add('entity id  '||l_entity_Id);

          G_Delayed_Requests(p_request_ind).processed := 'I';





	   --- Add your code here to execute procedures/functions based
     --- on request type.

      IF l_request_type =  'DUPLICATE_QUALIFIERS'
	   THEN

           --dbms_output.put_line('calling qualifier dup');
           QP_DELAYED_REQUESTS_UTIL.CHECK_FOR_DUPLICATE_QUALIFIERS(l_return_status,l_entity_Id);


     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

-- Start bug2091362
      IF l_request_type =  'DUPLICATE_MODIFIER_LINES'
	   THEN

           --dbms_output.put_line('calling Modifier Line dup');
           QP_DELAYED_REQUESTS_UTIL.CHECK_DUPLICATE_MODIFIER_LINES
           (  p_Start_Date_Active         => fnd_date.canonical_to_date(l_request_rec.param2)		--2752265
	    , p_End_Date_Active           => fnd_date.canonical_to_date(l_request_rec.param3)		--2752265
	    , p_List_Line_ID              => l_entity_id
	    , p_List_Header_ID            => l_request_rec.param1
        , p_pricing_attribute_context => l_request_rec.param4
        , p_pricing_attribute         => l_request_rec.param5
        , p_pricing_attr_value        => l_request_rec.param6
	    , x_return_status             => l_return_status);


     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

-- end bug2091362

      IF l_request_type =  'DUPLICATE_LIST_LINES'
	   THEN

           --dbms_output.put_line('calling qualifier dup');
           QP_DELAYED_REQUESTS_UTIL.CHECK_DUPLICATE_LIST_LINES
           (  p_Start_Date_Active         => fnd_date.canonical_to_date(l_request_rec.param2)	--2739511
	    , p_End_Date_Active           => fnd_date.canonical_to_date(l_request_rec.param3)	--2739511
	    , p_Revision                  => l_request_rec.param4
	    , p_List_Line_ID              => l_entity_id
	    , p_List_Header_ID            => l_request_rec.param1
	    , x_return_status             => l_return_status
	    , x_dup_sdate                 => l_dup_sdate
	    , x_dup_edate                 => l_dup_edate);


     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;


      IF l_request_type =  'MAINTAIN_LIST_HEADER_PHASES'
	   THEN

           --dbms_output.put_line('calling qualifier dup');
           QP_DELAYED_REQUESTS_UTIL.maintain_list_header_phases
	      (p_List_Header_ID            => l_request_rec.param1
	       , x_return_status             => l_return_status);

     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;


      IF l_request_type =  'VALIDATE_LINES_FOR_CHILD'
	   THEN

           --dbms_output.put_line('calling qualifier dup');
           QP_DELAYED_REQUESTS_UTIL.validate_lines_for_child
           ( p_List_Line_ID              => l_entity_id
		  ,p_list_line_type_code      =>l_request_rec.param1
	       , x_return_status             => l_return_status);

     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;


      IF l_request_type = QP_GLOBALS.G_MULTIPLE_PRICE_BREAK_ATTRS
      THEN
        oe_debug_pub.add('Processing check_mult_price_break_attrs');
	QP_DELAYED_REQUESTS_UTIL.Check_Mult_Price_Break_Attrs(
		p_parent_list_line_id  => l_request_rec.param1,
		x_return_status   => l_return_status);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_request_type = QP_GLOBALS.G_MIXED_QUAL_SEG_LEVELS
      THEN
        oe_debug_pub.add('Processing check_mult_price_break_attrs');
	QP_DELAYED_REQUESTS_UTIL.Check_Mixed_Qual_Seg_Levels(
                x_return_status => l_return_status,
                p_qualifier_rule_id => l_request_rec.param1);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_request_type =  'OVERLAPPING_BREAKS'
	   THEN
	   IF l_request_rec.param2 = 'Y' THEN
	   --call continuous price breaks validation function
              QP_DELAYED_REQUESTS_UTIL.Check_Continuous_Price_Breaks
              ( p_List_Line_ID              => l_request_rec.param1
	       ,x_return_status             => l_return_status);
	   ELSE
              --dbms_output.put_line('calling overlapping breaks');
              QP_DELAYED_REQUESTS_UTIL.Check_For_overlapping_Breaks
              --changed by svdeshmu on Aril 07
              --( p_List_Line_ID              => l_entity_id
              ( p_List_Line_ID              => l_request_rec.param1
	       ,x_return_status             => l_return_status);
	   END IF;

     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

      IF l_request_type =  QP_Globals.G_UPGRADE_PRICE_BREAKS
	   THEN
           QP_DELAYED_REQUESTS_UTIL.Upgrade_Price_Breaks
           ( p_pbh_id              => l_entity_id
            ,p_list_line_no        => l_request_rec.param1
            ,p_product_attribute   => l_request_rec.param2
            ,p_product_attr_value  => l_request_rec.param3
            ,p_list_type           => l_request_rec.param4
            ,p_start_date_active   => l_request_rec.param5
            ,p_end_date_active     => l_request_rec.param6
	    ,x_return_status       => l_return_status);
      END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

      IF l_request_type =  'SINGLE_PRICE_LIST'
	   THEN

           --dbms_output.put_line('calling single price list');
           QP_DELAYED_REQUESTS_UTIL.Check_multiple_prl
           ( p_List_header_ID              => l_entity_id
	       ,x_return_status             => l_return_status);

     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;


	 IF l_request_type = QP_GLOBALS.G_MAINTAIN_QUALIFIER_DEN_COLS
	 THEN
	   QP_DELAYED_REQUESTS_UTIL.Maintain_Qualifier_Den_Cols(
		p_list_header_id  => l_entity_id,
		x_return_status   => l_return_status);
      END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

      IF l_request_type =  QP_GLOBALS.G_UPDATE_LIST_QUAL_IND
	   THEN

           --dbms_output.put_line('calling list qualification indicator');
           QP_DELAYED_REQUESTS_UTIL.Update_List_Qualification_Ind
           ( p_List_header_ID             => l_entity_id
             ,x_return_status             => l_return_status);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_request_type =  QP_GLOBALS.G_UPDATE_LIMITS_COLUMNS
       THEN

           --dbms_output.put_line('calling UPDATE_LIMITS_COLUMNS');
           QP_DELAYED_REQUESTS_UTIL.Update_Limits_Columns
           ( p_Limit_Id         	    => l_entity_id
             ,x_return_status               => l_return_status);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_request_type =  QP_GLOBALS.G_UPDATE_QUALIFIER_STATUS
       THEN
           --dbms_output.put_line('calling UPDATE_QUALIFIER_STATUS ');
           QP_DELAYED_REQUESTS_UTIL.Update_Qualifier_Status
           ( p_list_header_id         	    => l_entity_id
            ,p_active_flag         	    => l_request_rec.param1
            ,x_return_status                => l_return_status);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_request_type =  QP_GLOBALS.G_CREATE_SECURITY_PRIVILEGE
       THEN
           --dbms_output.put_line('calling CREATE_SECURITY_PRIVILEGE ');
           QP_DELAYED_REQUESTS_UTIL.Create_Security_Privilege
           ( p_list_header_id         	    => l_entity_id
            ,p_list_type_code          	    => l_request_rec.param1
            ,x_return_status                => l_return_status);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF l_request_type =  QP_GLOBALS.G_UPDATE_ATTRIBUTE_STATUS
       THEN
           --dbms_output.put_line('calling UPDATE_ATTRIBUTE_STATUS ');
           QP_DELAYED_REQUESTS_UTIL.Update_Attribute_Status
           ( p_list_header_id         	    => l_entity_id
            ,p_list_line_id          	    => l_request_rec.param1
            ,p_context_type          	    => l_request_rec.param2
            ,p_context_code          	    => l_request_rec.param3
            ,p_segment_mapping_column  	    => l_request_rec.param4
            ,x_return_status                => l_return_status);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;


      IF l_request_type = QP_GLOBALS.G_UPDATE_CHILD_BREAKS
	 THEN
	   QP_DELAYED_REQUESTS_UTIL.update_child_break_lines(
		p_list_line_id  => l_entity_id,
		x_return_status => l_return_status);
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_request_type = QP_GLOBALS.G_UPDATE_CHILD_PRICING_ATTR
	 THEN
	   QP_DELAYED_REQUESTS_UTIL.update_child_pricing_attr(
		x_return_status => l_return_status,
		p_list_line_id  => l_entity_id);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

/*included by spgopal for performance problem, to include phase_id and header_idinfo in qp_pricing_attributes table*/

      IF l_request_type = QP_GLOBALS.G_UPDATE_PRICING_ATTR_PHASE
	 THEN
	   BEGIN	--[Bug 4457903] Call update_pricing_attr_phase only if
			--the line id is present in the QP_LIST_LINES table
	     SELECT 1 into l_count from QP_LIST_LINES
	     WHERE LIST_LINE_ID = l_entity_id;
	   EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	       l_count := 0;
	   END;

	   IF l_count = 1 THEN
	     QP_DELAYED_REQUESTS_UTIL.update_pricing_attr_phase(
	  	  p_list_line_id  => l_entity_id,
		  x_return_status => l_return_status);
	   END IF;
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Added by rchellam on 29-AUG-2001. POSCO Change.
      IF l_request_type = QP_GLOBALS.G_MAINTAIN_FACTOR_LIST_ATTRS
	 THEN
	   QP_DELAYED_REQUESTS_UTIL.Maintain_Factor_List_Attrs(
		p_list_line_id  => l_entity_id,
		x_return_status => l_return_status);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

/*fix for bug 1501138*/
      IF l_request_type = QP_GLOBALS.G_WARN_SAME_QUALIFIER_GROUP
	 THEN
		oe_debug_pub.add('qual context'||l_request_rec.param3||' attr '||l_request_rec.param4||' grp no  '||l_request_rec.param2);

	 /*
	   QP_DELAYED_REQUESTS_UTIL.Warn_same_qualifier_group(
		p_list_header_id  => l_entity_id,
		p_list_line_id  => l_request_rec.param1,
		p_qualifier_grouping_no  => l_request_rec.param2,
		p_qualifier_context  => l_request_rec.param3,
		p_qualifier_attribute  => l_request_rec.param4,
		x_return_status => l_return_status);
		*/

		oe_debug_pub.add('after qual context'||l_request_rec.param3||' attr '||l_request_rec.param4||' grp no  '||l_request_rec.param3);
		null;
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_request_type =  QP_GLOBALS.G_UPDATE_LINE_QUAL_IND
	   THEN

           --dbms_output.put_line('calling line qualification indicator');
             QP_DELAYED_REQUESTS_UTIL.Update_Line_Qualification_Ind
             ( p_List_line_ID              => l_entity_id
	       ,x_return_status             => l_return_status);
     END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

/*included by spgopal for pricing phase seeded data over-write problem to update the denormalised columns in  QP_PRICING_PHASES*/

      IF l_request_type = QP_GLOBALS.G_UPDATE_PRICING_PHASE
	 THEN
		oe_debug_pub.add('processing req UPDATE_PRICING_PHASE');
	   QP_DELAYED_REQUESTS_UTIL.update_pricing_phase(
		p_pricing_phase_id  => l_request_rec.param1,
                p_automatic_flag    => l_request_rec.param2, --fix for bug 3756625
                p_count       => l_request_rec.param3,
                p_call_from  => l_request_rec.param4,
		x_return_status => l_return_status);
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

-- Essilor Fix bug 2789138
      IF l_request_type = QP_GLOBALS.G_UPDATE_MANUAL_MODIFIER_FLAG
         THEN
           oe_debug_pub.add('processing req UPDATE_MANUAL_MODIFIER_FLAG');
           QP_DELAYED_REQUESTS_UTIL.Update_manual_modifier_flag(
                p_pricing_phase_id  => l_request_rec.param1,
                p_automatic_flag => l_request_rec.param2,
                x_return_status => l_return_status);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

--hvop
      IF l_request_type = QP_GLOBALS.G_UPDATE_HVOP
         THEN
           oe_debug_pub.add('processing req UPDATE_HVOP');
           QP_DELAYED_REQUESTS_UTIL.HVOP_Pricing_Setup (x_return_status => l_return_status);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;
--hvop

--pattern
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN

        IF l_request_type = QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN THEN
	   oe_debug_pub.add('Processing req Attribute Groups');
           QP_DELAYED_REQUESTS_UTIL.maintain_header_pattern(
		p_list_header_id => l_request_rec.entity_Id
		, p_qualifier_group => l_request_rec.request_unique_key1
		, p_setup_action => l_request_rec.request_unique_key2
		, x_return_status => l_return_status);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_request_type = QP_GLOBALS.G_MAINTAIN_LINE_PATTERN THEN
	   oe_debug_pub.add('Processing req Attribute Groups');
           QP_DELAYED_REQUESTS_UTIL.maintain_line_pattern(
			p_list_header_id => l_request_rec.entity_Id
			, p_list_line_id => l_request_rec.request_unique_key1
			, p_qualifier_group => l_request_rec.request_unique_key2
			, p_setup_action => l_request_rec.request_unique_key3
			, x_return_status => l_return_status);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_request_type = QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN THEN
	   oe_debug_pub.add('Processing req Attribute Groups');
           QP_DELAYED_REQUESTS_UTIL.maintain_product_pattern(
			p_list_header_id => l_request_rec.entity_Id
			, p_list_line_id => l_request_rec.request_unique_key1
			, p_setup_action => l_request_rec.request_unique_key2
			, x_return_status => l_return_status);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; --Java Engine Installed

--pattern

/* code for PL/SQL pattern search delayed request  */

--pattern

  --     g_qp_pattern_search := FND_PROFILE.VALUE('QP_PATTERN_SEARCH');

      oe_debug_pub.ADD('JAGAN JAVA ENGINE INSTALLED : ' || QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed);
      oe_debug_pub.ADD('JAGAN QP PATTERN SEARCH : ' || FND_PROFILE.VALUE('QP_PATTERN_SEARCH'));
      oe_debug_pub.ADD('JAGAN REQUEST TYPE : ' || l_request_type);
      oe_debug_pub.ADD('JAGAN ENTITY CODE : ' || l_entity_code);
      oe_debug_pub.ADD('JAGAN REQUIRED ENTITY CODE IS : ' || QP_GLOBALS.G_ENTITY_MODIFIER_LIST ||','|| QP_GLOBALS.G_ENTITY_MODIFIERS);

  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
    IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
    --AND ( l_entity_code = QP_GLOBALS.G_ENTITY_MODIFIER_LIST OR  l_entity_code =  QP_GLOBALS.G_ENTITY_MODIFIERS OR l_entity_code = QP_GLOBALS.G_ENTITY_ALL) THEN

        IF l_request_type = QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN THEN
	   oe_debug_pub.add('Processing req Attribute Groups');
           QP_DELAYED_REQUESTS_UTIL.maintain_header_pattern(
		p_list_header_id => l_request_rec.entity_Id
		, p_qualifier_group => l_request_rec.request_unique_key1
		, p_setup_action => l_request_rec.request_unique_key2
		, x_return_status => l_return_status);
		oe_debug_pub.ADD(' JAGAN 1 ENTITY CODE : ' || l_entity_code);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_request_type = QP_GLOBALS.G_MAINTAIN_LINE_PATTERN THEN
	   oe_debug_pub.add('Processing req Attribute Groups');
           QP_DELAYED_REQUESTS_UTIL.maintain_line_pattern(
			p_list_header_id => l_request_rec.entity_Id
			, p_list_line_id => l_request_rec.request_unique_key1
			, p_qualifier_group => l_request_rec.request_unique_key2
			, p_setup_action => l_request_rec.request_unique_key3
			, x_return_status => l_return_status);
			oe_debug_pub.ADD(' JAGAN 2 ENTITY CODE : ' || l_entity_code);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_request_type = QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN THEN
	   oe_debug_pub.add('Processing req Attribute Groups');
           QP_DELAYED_REQUESTS_UTIL.maintain_product_pattern(
			p_list_header_id => l_request_rec.entity_Id
			, p_list_line_id => l_request_rec.request_unique_key1
			, p_setup_action => l_request_rec.request_unique_key2
			, x_return_status => l_return_status);
			oe_debug_pub.ADD('JAGAN 3 ENTITY CODE : ' || l_entity_code);
        END IF;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;  --pl/sql pattern search profile on
  END IF; --Java Engine Installed

--pattern
      IF l_request_type = QP_GLOBALS.G_VALIDATE_SELLING_ROUNDING
	 THEN
		oe_debug_pub.add('processing req VALIDATE_SELLING_ROUNDING');
	   QP_DELAYED_REQUESTS_UTIL.validate_selling_rounding(
		p_currency_header_id  => l_entity_id,
		p_to_currency_code  => l_request_rec.param1,
		x_return_status => l_return_status);
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
     END IF;


      IF l_request_type = QP_GLOBALS.G_CHECK_SEGMENT_LEVEL_IN_GROUP
	 THEN
		oe_debug_pub.add('processing req CHECK_SEGMENT_LEVEL_IN_GROUP');
	   QP_DELAYED_REQUESTS_UTIL.check_segment_level_in_group(
		p_list_line_id => l_entity_id,
		p_list_header_id  => l_request_rec.request_unique_key1,
		p_qualifier_grouping_no => l_request_rec.request_unique_key2,
		x_return_status => l_return_status);
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_request_type = QP_GLOBALS.G_CHECK_LINE_FOR_HEADER_QUAL
	 THEN
		oe_debug_pub.add('processing req CHECK_LINE_FOR_HEADER_QUAL');
	   QP_DELAYED_REQUESTS_UTIL.CHECK_LINE_FOR_HEADER_QUAL(
		p_list_header_id => l_entity_id,
		p_list_line_id  => l_request_rec.request_unique_key1,
		x_return_status => l_return_status);
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hierarchical Categories (sfiresto)
      IF l_request_type = QP_GLOBALS.G_CHECK_ENABLED_FUNC_AREAS THEN
        oe_debug_pub.add('processing req CHECK_ENABLED_FUNC_AREAS');
        QP_DELAYED_REQUESTS_UTIL.Check_Enabled_Func_Areas(
             p_pte_source_system_id => l_entity_id,
             x_return_status => l_return_status);
      END IF;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;


	--hw
       -- delayed request for changed lines
        if QP_PERF_PVT.enabled = 'Y' then

	if l_request_type = QP_GLOBALS.G_UPDATE_CHANGED_LINES_ADD then
		oe_debug_pub.add('processing req G_UPDATE_CHANGED_LINES_ADD');
		QP_DELAYED_REQUESTS_UTIL.update_changed_lines_add(
		    p_list_line_id => l_entity_id,
			p_list_header_id => l_request_rec.param2,
			p_pricing_phase_id => l_request_rec.param1,
			x_return_status => l_return_status);
	elsif l_request_type = QP_GLOBALS.G_UPDATE_CHANGED_LINES_DEL then
		oe_debug_pub.add('processing req G_UPDATE_CHANGED_LINES_DEL');
		QP_DELAYED_REQUESTS_UTIL.update_changed_lines_del(
		    p_list_line_id => l_entity_id,
			p_list_header_id => l_request_rec.param2,
			p_pricing_phase_id => l_request_rec.param1,
			p_product_attribute => l_request_rec.param3,
			p_product_attr_value => l_request_rec.param4,
			x_return_status => l_return_status);
	elsif l_request_type = QP_GLOBALS.G_UPDATE_CHANGED_LINES_PH then
		oe_debug_pub.add('processing req G_UPDATE_CHANGED_LINES_PHASE');
		QP_DELAYED_REQUESTS_UTIL.update_changed_lines_ph(
		    p_list_line_id => l_entity_id,
			p_list_header_id => l_request_rec.param2,
			p_pricing_phase_id => l_request_rec.param1,
			p_old_pricing_phase_id => l_request_rec.param3,
			x_return_status => l_return_status);
	elsif l_request_type = QP_GLOBALS.G_UPDATE_CHANGED_LINES_ACT then
		oe_debug_pub.add('processing req G_UPDATE_CHANGED_LINES_ACTIVE');
		QP_DELAYED_REQUESTS_UTIL.update_changed_lines_act(
			p_list_header_id => l_entity_id,
			p_active_flag => l_request_rec.param1,
			x_return_status => l_return_status);
--hvop	elsif l_request_type = QP_GLOBALS.G_UPDATE_HVOP then
                oe_debug_pub.add('processing req G_UPDATE_HVOP')
;
                QP_DELAYED_REQUESTS_UTIL.HVOP_Pricing_Setup(x_return_status => l_return_status);
--hvop
	end if;
end if;

	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      END IF;


       IF (p_delete = FND_API.G_TRUE) then

          G_Delayed_Requests.Delete(p_request_ind);
/*
       BUG 2502849- do not delete from req entities table
       , delete table in the end when all requests are processed
       This is to improve performance as this search loops through
       the entire pl/sql table which becomes very large with
       greater number of lines being processed

	-- Delete all the records in the requesting entities table
	-- that have this request.

	l_req_entity_ind := G_Requesting_Entities.First;


          WHILE l_req_entity_ind IS NOT NULL LOOP
	   IF G_Requesting_Entities(l_req_entity_ind).request_index = p_request_ind
	   THEN
		G_Requesting_Entities.Delete(l_req_entity_ind);
	   END IF;
	   l_req_entity_ind := G_Requesting_Entities.Next(l_req_entity_ind);
	  END LOOP;
*/
       ELSE

          G_Delayed_Requests(p_request_ind).processed := 'Y';

       END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	   G_Delayed_Requests(p_request_ind).processed := 'N';
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   G_Delayed_Requests(p_request_ind).processed := 'N';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN NO_DATA_FOUND THEN
        oe_debug_pub.add('Exiting  Process_Request_Pvt no_data_found exception ');
        G_Delayed_Requests(p_request_ind).processed := 'N';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_Pvt'
            );
        END IF;

    WHEN OTHERS THEN
	   G_Delayed_Requests(p_request_ind).processed := 'N';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_Pvt'
            );
        END IF;

   oe_debug_pub.add('Exiting  Process_Request_Pvt with others exception ');


End Process_Request_Pvt;
/** End Local Procedures **/

/** Global Procedures **/
Procedure  Log_Request
(   p_entity_code	IN VARCHAR2
,   p_entity_id		IN NUMBER
,   p_requesting_entity_code IN VARCHAR2
,   p_requesting_entity_id   IN NUMBER
,   p_request_type	IN VARCHAR2
,   p_request_unique_key1	IN VARCHAR2 := NULL
,   p_request_unique_key2	IN VARCHAR2 := NULL
,   p_request_unique_key3	IN VARCHAR2 := NULL
,   p_request_unique_key4	IN VARCHAR2 := NULL
,   p_request_unique_key5	IN VARCHAR2 := NULL
,   p_param1		IN VARCHAR2 := NULL
,   p_param2		IN VARCHAR2 := NULL
,   p_param3		IN VARCHAR2 := NULL
,   p_param4		IN VARCHAR2 := NULL
,   p_param5		IN VARCHAR2 := NULL
,   p_param6		IN VARCHAR2 := NULL
,   p_param7		IN VARCHAR2 := NULL
,   p_param8		IN VARCHAR2 := NULL
,   p_param9		IN VARCHAR2 := NULL
,   p_param10		IN VARCHAR2 := NULL
,   p_param11		IN VARCHAR2 := NULL
,   p_param12		IN VARCHAR2 := NULL
,   p_param13		IN VARCHAR2 := NULL
,   p_param14 		IN VARCHAR2 := NULL
,   p_param15		IN VARCHAR2 := NULL
,   p_param16		IN VARCHAR2 := NULL
,   p_param17		IN VARCHAR2 := NULL
,   p_param18		IN VARCHAR2 := NULL
,   p_param19		IN VARCHAR2 := NULL
,   p_param20		IN VARCHAR2 := NULL
,   p_param21		IN VARCHAR2 := NULL
,   p_param22		IN VARCHAR2 := NULL
,   p_param23		IN VARCHAR2 := NULL
,   p_param24		IN VARCHAR2 := NULL
,   p_param25		IN VARCHAR2 := NULL
,   p_long_param1	IN VARCHAR2 := NULL
,   x_return_status 	OUT NOCOPY VARCHAR2
)
  IS
     l_request_search_rslt	VARCHAR2(1);
     l_return_status		VARCHAR2(1);
     l_request_ind		NUMBER;
     l_req_entity_ind		NUMBER;
     l_request			QP_QUALIFIER_RULES_PUB.REQUEST_REC_TYPE;
     l_req_entity		QP_QUALIFIER_RULES_PUB.Requesting_Entity_Rec_Type;
BEGIN

   oe_debug_pub.add('Entering Procedure Log_Request in Package QP_Delayed_Requests_Pvt');
   oe_debug_pub.add('log_request_type'||p_request_type);

    -- Initialize the request_record
   l_request.request_type		:= p_request_type;
   l_request.entity_id			:= p_entity_id;
   l_request.entity_code		:= p_entity_code;
   l_request.request_unique_key1 	:= p_request_unique_key1;
   l_request.request_unique_key2 	:= p_request_unique_key2;
   l_request.request_unique_key3 	:= p_request_unique_key3;
   l_request.request_unique_key4 	:= p_request_unique_key4;
   l_request.request_unique_key5 	:= p_request_unique_key5;
   l_request.param1			:= p_param1;
   l_request.param2			:= p_param2;
   l_request.param3			:= p_param3;
   l_request.param4			:= p_param4;
   l_request.param5			:= p_param5;
   l_request.param6			:= p_param6;
   l_request.param7			:= p_param7;
   l_request.param8			:= p_param8;
   l_request.param9			:= p_param9;
   l_request.param10			:= p_param10;
   l_request.param11			:= p_param11;
   l_request.param12			:= p_param12;
   l_request.param13			:= p_param13;
   l_request.param14			:= p_param14;
   l_request.param15			:= p_param15;
   l_request.param16			:= p_param16;
   l_request.param17			:= p_param17;
   l_request.param18			:= p_param18;
   l_request.param19			:= p_param19;
   l_request.param20			:= p_param20;
   l_request.param21			:= p_param21;
   l_request.param22			:= p_param22;
   l_request.param23			:= p_param23;
   l_request.param24			:= p_param24;
   l_request.param25			:= p_param25;
   l_request.long_param1		:= p_long_param1;

   -- Initialize the return variable
   x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_entity_id IS NOT NULL THEN --2650093
   Check_For_Request(p_entity_code,
		     p_entity_id,
		     p_request_type,
		     p_request_unique_key1,
		     p_request_unique_key2,
		     p_request_unique_key3,
		     p_request_unique_key4,
		     p_request_unique_key5,
		     l_request_ind,
		     l_request_search_rslt,
		     l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

      l_request.processed := 'N';
      IF l_request_search_rslt = FND_API.g_true       -- replace the request
        THEN
	OE_Debug_PUB.ADD('Request replaced');
         g_delayed_requests(l_request_ind) := l_request;

       ELSE					   -- insert the new request
	OE_Debug_PUB.ADD('New request inserted');
--         l_request_ind := nvl(g_delayed_requests.LAST, 0) + 1; --2502849
         g_delayed_requests(l_request_ind) := l_request; --Added for 2502849
      END IF;

	-- Initialize the requesting entity record
      l_req_entity.entity_code := p_requesting_entity_code;
      l_req_entity.entity_id := p_requesting_entity_id;
      l_req_entity.request_index := l_request_ind;

	l_req_entity_ind := nvl(g_requesting_entities.LAST, 0) + 1;
      -- Insert into the requesting entities table
      g_requesting_entities(l_req_entity_ind) := l_req_entity;
END IF;--2650093
     oe_debug_pub.add('end of log request');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'LOGREQUEST');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

End Log_Request;



Function Check_for_Request( p_entity_code   IN VARCHAR2,
                            p_entity_id     IN NUMBER,
                            p_request_type  IN VARCHAR2,
                            p_request_unique_key1 	IN VARCHAR2 := NULL,
			    p_request_unique_key2 	IN VARCHAR2 := NULL,
			    p_request_unique_key3 	IN VARCHAR2 := NULL,
			    p_request_unique_key4 	IN VARCHAR2 := NULL,
			    p_request_unique_key5 	IN VARCHAR2 := NULL
			    )
RETURN BOOLEAN IS
l_ind           Number;
x_result        Varchar2(30);
x_return_status Varchar2(30);
Begin
IF p_entity_id IS NOT NULL THEN --2650093
    Check_for_Request( p_entity_code    	=> p_entity_code
		       ,p_entity_id    	 	=> p_entity_id
		       ,p_request_type  	=> p_request_type
		       ,p_request_unique_key1 	=> p_request_unique_key1
		       ,p_request_unique_key2 	=> p_request_unique_key2
		       ,p_request_unique_key3 	=> p_request_unique_key3
		       ,p_request_unique_key4 	=> p_request_unique_key4
		       ,p_request_unique_key5	=> p_request_unique_key5
		       ,x_request_ind   	=> l_ind
		       ,x_result        	=> x_result
		       ,x_return_status 	=> x_return_status);

    if x_result = FND_API.G_TRUE then
       return(TRUE);
    else
       return(FALSE);
    end if;

/* Added for 2650093 */
ELSE
	return(FALSE);
END IF;
End;

Procedure Delete_Request(p_entity_code     IN VARCHAR2
                        ,p_entity_id       IN NUMBER
                        ,p_request_Type    IN VARCHAR2
                        ,p_request_unique_key1 	IN VARCHAR2 := NULL
			,p_request_unique_key2 	IN VARCHAR2 := NULL
			,p_request_unique_key3 	IN VARCHAR2 := NULL
			,p_request_unique_key4 	IN VARCHAR2 := NULL
			,p_request_unique_key5 	IN VARCHAR2 := NULL
			,x_return_status   OUT NOCOPY VARCHAR2)
  IS
     l_request_search_rslt  Varchar2(1);
     l_return_status     Varchar2(1);
     l_request_ind       number;
     l_req_entity_ind    number;
BEGIN

   oe_debug_pub.add('Entering Procedure Delete_Request in Package QP_Delayed_Requests_Pvt');

   x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_entity_id IS NOT NULL THEN --2650093
    Check_for_Request( p_entity_code    	=> p_entity_code
		       ,p_entity_id    	 	=> p_entity_id
		       ,p_request_type  	=> p_request_type
		       ,p_request_unique_key1 	=> p_request_unique_key1
		       ,p_request_unique_key2 	=> p_request_unique_key2
		       ,p_request_unique_key3 	=> p_request_unique_key3
		       ,p_request_unique_key4 	=> p_request_unique_key4
		       ,p_request_unique_key5	=> p_request_unique_key5
		       ,x_request_ind   	=> l_request_ind
		       ,x_result        	=> l_request_search_rslt
		       ,x_return_status 	=> l_return_status);


       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;

   if l_request_search_rslt = FND_API.G_TRUE     -- delete the request
     then
      G_Delayed_Requests.Delete(l_request_ind);

/*      BUG 2502849- do not delete from req entities table
       , delete table in the end when all requests are processed
       This is to improve performance as this search loops through
       the entire pl/sql table which becomes very large with
       greater number of lines being processed

      -- Delete all the records in the requesting entities table
      -- that have this request.
        l_req_entity_ind := G_Requesting_Entities.First;
          WHILE l_req_entity_ind IS NOT NULL LOOP
           IF G_Requesting_Entities(l_req_entity_ind).request_index = l_request_ind
           THEN
                G_Requesting_Entities.Delete(l_req_entity_ind);
           END IF;
           l_req_entity_ind := G_Requesting_Entities.Next(l_req_entity_ind);
          END LOOP;  */
   end if;
END IF; --2650093
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   when others THEN

      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'DeleteRequest');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

End Delete_Request;

Procedure Clear_Request( x_return_status OUT NOCOPY VARCHAR2)
  IS
BEGIN

   oe_debug_pub.add('Entering Procedure Clear_Request in Package QP_Delayed_Requests_Pvt');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

      G_Delayed_Requests.DELETE;
      g_requesting_entities.DELETE;

EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'Clear_Request');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

End Clear_Request;

Procedure Process_Request( p_entity_code          IN VARCHAR2
                        ,p_entity_id              IN Number
                        ,p_request_Type           IN VARCHAR2
                        ,p_request_unique_key1 	IN VARCHAR2 := NULL
                        ,p_request_unique_key2 	IN VARCHAR2 := NULL
                        ,p_request_unique_key3 	IN VARCHAR2 := NULL
                        ,p_request_unique_key4 	IN VARCHAR2 := NULL
                        ,p_request_unique_key5 	IN VARCHAR2 := NULL
                        ,p_delete                 IN Varchar2 Default
											FND_API.G_TRUE
                        ,x_return_status     OUT NOCOPY Varchar2)
IS
l_request_ind          Number;
l_request_search_rslt  Varchar2(30);
l_return_status        Varchar2(30);
Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.add('Entering Procedure Process_Request in Package QP_Delayed_Requests_Pvt');
IF p_entity_id IS NOT NULL THEN --2650093
    Check_for_Request( p_entity_code    	=> p_entity_code
		       ,p_entity_id    	 	=> p_entity_id
		       ,p_request_type  	=> p_request_type
		       ,p_request_unique_key1 	=> p_request_unique_key1
		       ,p_request_unique_key2 	=> p_request_unique_key2
		       ,p_request_unique_key3 	=> p_request_unique_key3
		       ,p_request_unique_key4 	=> p_request_unique_key4
		       ,p_request_unique_key5	=> p_request_unique_key5
		       ,x_request_ind   	=> l_request_ind
		       ,x_result        	=> l_request_search_rslt
		       ,x_return_status 	=> l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   if l_request_search_rslt = FND_API.G_TRUE then
      Process_Request_Pvt
         (p_request_ind       => l_request_ind
         ,p_delete            => p_delete
         ,x_return_status     => l_return_status
         );
   end if;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
   END IF;
END IF; --2650093
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request'
            );
        END IF;

End Process_Request;


Procedure Process_Request_for_Entity
     ( p_entity_code     in Varchar2
     ,p_delete            in Varchar2 Default FND_API.G_TRUE
     ,x_return_status     OUT NOCOPY Varchar2) IS
l_return_status        Varchar2(30);
l_ind                  Number;
Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.add('Entering Procedure Process_Request_for_Entity in Package QP_Delayed_Requests_Pvt');
   --dbms_output.put_line('Entering Procedure Process_Request_for_Entity in Package QP_Delayed_Requests_Pvt');
	--dbms_output.put_line('entity id  is ' ||p_entity_code);

   l_ind := G_Delayed_Requests.first;

   /*WHILE l_ind IS NOT NULL loop
	oe_debug_pub.add('entity is ' ||G_Delayed_Requests(l_ind).Entity_code);
	--dbms_output.put_line('entity is ' ||G_Delayed_Requests(l_ind).Entity_code);
	oe_debug_pub.add('entity id  is ' ||G_Delayed_Requests(l_ind).Entity_id);
	--dbms_output.put_line('entity id  is ' ||G_Delayed_Requests(l_ind).Entity_id);
	END LOOP;*/

   l_ind := G_Delayed_Requests.first;

   WHILE l_ind IS NOT NULL LOOP
	--dbms_output.put_line('entity id  is ' ||G_Delayed_Requests(l_ind).Entity_id);
     IF G_Delayed_Requests(l_ind).Entity_code = p_entity_code THEN
	   --dbms_output.put_line('found the match');
	   --dbms_output.put_line('l_ind is '||l_ind);
        Process_Request_Pvt
           (p_request_ind       => l_ind
           ,p_delete            => p_delete
           ,x_return_status     => l_return_status
           );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	         RAISE FND_API.G_EXC_ERROR;
        END IF;
	   --EXIT;
     END IF;
     l_ind := G_Delayed_Requests.Next(l_ind);
  END LOOP;
   oe_debug_pub.add('Exiting Process_Request_for_Entity ');
   --dbms_output.put_line('Exiting Process_Request_for_Entity ');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_for_Entity'
            );
        END IF;

   oe_debug_pub.add('Exiting Process_Request_for_Entity ');

End Process_Request_for_Entity;

Procedure Process_Request_for_ReqType
          ( p_request_type   in Varchar2
           ,p_delete         in Varchar2 Default FND_API.G_TRUE
           ,x_return_status  OUT NOCOPY Varchar2
          ) IS
l_return_status        Varchar2(30);
l_ind                  Number;
Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.add('Entering Procedure Process_Request_for_ReqType in Package QP_Delayed_Requests_Pvt');

   l_ind := G_Delayed_Requests.first;

   WHILE l_ind IS NOT NULL LOOP
     IF G_Delayed_Requests(l_ind).request_type = p_request_type THEN
        Process_Request_Pvt
           (p_request_ind       => l_ind
           ,p_delete            => p_delete
           ,x_return_status     => l_return_status
           );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	         RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;
     l_ind := G_Delayed_Requests.Next(l_ind);
  END LOOP;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Request_for_ReqType'
            );
        END IF;

End Process_Request_for_ReqType;


Procedure Process_Delayed_Requests(
           x_return_status  OUT NOCOPY Varchar2
          ) IS
l_return_status Varchar2(30);
Begin

   oe_debug_pub.add('Entering Procedure Process_Delayed_Requests in Package QP_Delayed_Requests_Pvt');

   -- Process requests as per the dependency
   -- This procedure processes all requests.
   -- For each request type defined in QP_GLOBALS
   -- write one code block as shown below.

-- start bug2091362
   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_DUPLICATE_MODIFIER_LINES
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

-- end bug2091362


   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_DUPLICATE_LIST_LINES
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;


/*included by spgopal for performance problem, to include phase_id and header_idinfo in qp_pricing_attributes table*/

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_PRICING_ATTR_PHASE
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;


/*included by spgopal for pricing phase seeded data over-write problem to update the denormalised columns in  QP_PRICING_PHASES*/

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_PRICING_PHASE
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

/*fix for bug 1501138*/
/*
   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_PRICING_PHASE
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

*/

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MULTIPLE_PRICE_BREAK_ATTRS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;


   	Process_Request_for_ReqType
        (p_request_type  => QP_GLOBALS.G_MIXED_QUAL_SEG_LEVELS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;


   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_OVERLAPPING_PRICE_BREAKS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;


   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_QUALIFIER_DEN_COLS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_LIST_QUAL_IND
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_LIMITS_COLUMNS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_QUALIFIER_STATUS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_CREATE_SECURITY_PRIVILEGE
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_ATTRIBUTE_STATUS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_LIST_HEADER_PHASES
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_FACTOR_LIST_ATTRS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- mkarya for attribute manager
   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_CHECK_LINE_FOR_HEADER_QUAL
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Hierarchical Categories (sfiresto)
   	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_CHECK_ENABLED_FUNC_AREAS
        ,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;


	--hw

       -- delayed request for changed lines
        if QP_PERF_PVT.enabled = 'Y' then
	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_CHANGED_LINES_ADD
		,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_CHANGED_LINES_DEL
		,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

	Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_CHANGED_LINES_ACT
		,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;

	 Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_UPDATE_CHANGED_LINES_PH
		,p_delete        => FND_API.G_TRUE
         ,x_return_status => l_return_status
        );
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
     END IF;
     end if;
	oe_debug_pub.add('Ren: in process delayed request');

     -- mkarya for pattern delayed requests
     IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
       Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN
        ,p_delete        => FND_API.G_TRUE
        ,x_return_status => l_return_status
        );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_LINE_PATTERN
        ,p_delete        => FND_API.G_TRUE
        ,x_return_status => l_return_status
        );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN
        ,p_delete        => FND_API.G_TRUE
        ,x_return_status => l_return_status
        );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF; --IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y'


-- jagan's PL/SQL pattern

   IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
     IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN

       Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_HEADER_PATTERN
        ,p_delete        => FND_API.G_TRUE
        ,x_return_status => l_return_status
        );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_LINE_PATTERN
        ,p_delete        => FND_API.G_TRUE
        ,x_return_status => l_return_status
        );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       Process_Request_for_ReqType
        (p_request_type   =>QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN
        ,p_delete        => FND_API.G_TRUE
        ,x_return_status => l_return_status
        );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF; --- QP pattern search set to 'Y'
   END IF; --IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N'
-- jagan's PL/SQL pattern
     -- clear the delayed request cache
     Clear_Request(x_return_status);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Delayed_Requests'
            );
        END IF;

End Process_Delayed_Requests;


Procedure Delete_Reqs_for_Deleted_Entity ( p_entity_code	IN Varchar2
					,   p_entity_id       in Number
					,   x_return_status   OUT NOCOPY Varchar2)
IS
     i			       	number;
     j			       	number;
     req_ind			number;
     request_delete		BOOLEAN;
BEGIN



   x_return_status := FND_API.G_RET_STS_SUCCESS;


-- DELETING REQUESTS LOGGED AGAINST THIS ENTITY

   i := G_Delayed_Requests.first;

   WHILE i IS NOT NULL LOOP

     IF (G_Delayed_Requests(i).entity_code = p_entity_code
     	AND G_Delayed_Requests(i).entity_id = p_entity_id) THEN

	-- delete records in requesting entity tables with this request
	j := G_Requesting_Entities.first;
	WHILE j IS NOT NULL LOOP
       	   IF G_Requesting_Entities(j).request_index = i THEN
 		  G_Requesting_Entities.Delete(j);
	   END IF;
     	j := G_Requesting_Entities.Next(j);
	END LOOP;

	-- delete the delayed request
	   G_Delayed_Requests.Delete(i);

     END IF;

     i := G_Delayed_Requests.Next(i);

  END LOOP;


-- DELETING REQUESTS LOGGED BY THIS ENTITY

   i := G_Requesting_Entities.first;

   WHILE i  IS NOT NULL LOOP

   -- search for requests logged by this entity

     IF (G_Requesting_Entities(i).entity_code = p_entity_code
     	AND G_Requesting_Entities(i).entity_id = p_entity_id) THEN

	req_ind := G_Requesting_Entities(i).request_index;

	-- initialize request delete to TRUE
	request_delete := TRUE;

	-- set the delete to FALSE if there are other entities that
	-- logged the same request but if the same entity has logged this
	-- request, then delete in the requesting entities table

	j := G_Requesting_Entities.first;
	WHILE j IS NOT NULL LOOP
       	   IF G_Requesting_Entities(j).request_index = req_ind THEN
		IF (G_Requesting_Entities(j).entity_code = p_entity_code
       		 AND G_Requesting_Entities(j).entity_id = p_entity_id) THEN
 		  G_Requesting_Entities.Delete(j);
		ELSE
		  request_delete := FALSE;
		END IF;
	   END IF;
     	j := G_Requesting_Entities.Next(j);
	END LOOP;

	-- deleting the delayed request
	IF request_delete
               AND G_Delayed_Requests.Exists(req_ind) THEN
	   G_Delayed_Requests.Delete(req_ind);
	END IF;

     END IF;

     i := G_Requesting_Entities.Next(i);

  END LOOP;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   when others THEN

      IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME
	    ,'Delete_Reqs_for_Deleted_Entity');
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;

End Delete_Reqs_for_Deleted_Entity;




END QP_Delayed_Requests_Pvt;

/
