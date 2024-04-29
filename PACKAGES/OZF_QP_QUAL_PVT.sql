--------------------------------------------------------
--  DDL for Package OZF_QP_QUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QP_QUAL_PVT" AUTHID CURRENT_USER as
/* $Header: ozfvqpqs.pls 120.2 2006/01/27 20:25:22 julou ship $ */

-- Start of Comments
--
-- NAME
--   OZF_QP_QUAL_PVT
--
-- PURPOSE
--   This package is a Private API for Getting Market Segment qualifiers
--
--- NOTES
--
--
-- HISTORY
--   01/12/2000        ptendulk         Created
--   06/12/2000        skarumur         Modified
-- End of Comments

-- NAME
--    get_all_parents
--
-- USAGE
--    Procedure will do recursive job to find all parents for each party
-- NOTES
--
-- HISTORY
--   11/07/2001        jieli            created
-- End of Comments
--
--------------- end of comments ----------------------------
PROCEDURE get_all_parents(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER, px_bg_tbl IN OUT NOCOPY qp_attr_mapping_pub.t_multirecord);

--------------- start of comments --------------------------
-- NAME
--    get_buying_groups
--
-- USAGE
--    Function will return all the buying groups
--    to which the Customer belongs
-- NOTES
--
-- HISTORY
--   11/07/2001        jieli            created
-- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION get_buying_groups(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER)
RETURN qp_attr_mapping_pub.t_MultiRecord ;


--------------- start of comments --------------------------
-- NAME
--    get_Customer_list
--
-- USAGE
--    Function will return all the lists
--    to which the Customer belongs
-- NOTES
--
-- HISTORY
--    03-MAY-2001  julou    created
--
--------------- end of comments ----------------------------
FUNCTION Get_lists(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER)
RETURN qp_attr_mapping_pub.t_MultiRecord;

--------------- start of comments --------------------------
-- NAME
--    get_segments
--
-- USAGE
--    Function will return all the Market Segments
--    to which the Customer belongs
-- NOTES
--
-- HISTORY
--    03-MAY-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Get_segments(aso_party_id IN NUMBER,om_sold_to_org IN NUMBER)
RETURN qp_attr_mapping_pub.t_MultiRecord;

--------------- start of comments --------------------------
-- NAME
--    Find_TM_Territories
--
-- USAGE
--    Function will return the winning territories ID
--    for trade management
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_TM_Territories
(
     p_party_id    IN NUMBER
    ,p_sold_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord;

--------------- start of comments --------------------------
-- NAME
--    Find_TM_Territories
--
-- USAGE
--    Overload function will return the winning territories ID
--    for trade management.
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_TM_Territories
(
     p_party_id    IN NUMBER
    ,p_sold_to_org IN NUMBER
    ,p_ship_to_org IN NUMBER
    ,p_bill_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord;

--------------- start of comments --------------------------
-- NAME
--    Find_SA_Territories
--
-- USAGE
--    Function will return the winning territories ID
--    for sales account
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_SA_Territories
(
     p_party_id    IN NUMBER
    ,p_sold_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord;

--------------- start of comments --------------------------
-- NAME
--    Find_SA_Territories
--
-- USAGE
--    Overload function will return the winning territories ID
--    for sales account
-- NOTES
--
-- HISTORY
--    28-OCT-2001  julou    created
 -- End of Comments
--
--------------- end of comments ----------------------------
FUNCTION Find_SA_Territories
(
     p_party_id    IN NUMBER
    ,p_sold_to_org IN NUMBER
    ,p_ship_to_org IN NUMBER
    ,p_bill_to_org IN NUMBER
) RETURN Qp_Attr_Mapping_Pub.t_multirecord;

-- sourcing rules for SOLD_BY context
FUNCTION get_sales_method
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type
)
RETURN VARCHAR2;

FUNCTION get_distributor_acct_id
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type -- OZF_ORDER_PRICE_PVT.G_RESALE_LINE_TBL
)
RETURN NUMBER;

FUNCTION get_distributor_lists
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type
)
RETURN Qp_Attr_Mapping_Pub.t_multirecord;

FUNCTION get_distributor_segments
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type
)
RETURN Qp_Attr_Mapping_Pub.t_multirecord;

FUNCTION get_distributor_territories
(
  p_resale_line_tbl ozf_order_price_pvt.resale_line_tbl_type
-- ,p_party_id        NUMBER
-- ,p_sold_to_org_id  NUMBER
)
RETURN Qp_Attr_Mapping_Pub.t_multirecord;

END OZF_QP_QUAL_PVT ;

 

/
