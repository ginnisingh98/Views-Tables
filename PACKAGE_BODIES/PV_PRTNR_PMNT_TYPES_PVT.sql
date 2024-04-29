--------------------------------------------------------
--  DDL for Package Body PV_PRTNR_PMNT_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRTNR_PMNT_TYPES_PVT" as
/* $Header: pvxvptsb.pls 120.4.12000000.2 2007/06/12 19:48:38 dhii ship $ */
-- Start of Comments
-- Package name: PV_PRTNR_PMNT_TYPES_PVT
-- Purpose     :
-- History     :
--  03-MAR-2003 sveerave changed lookup table from fnd_lookup_values to pv_lookups
--                       for bug fix# 2829104.
--  jkylee  added mode_type = 'PAYMENT' for PV_PROGRAM_PAYMENT_MODE for release12
--  31-MAR-2005 pukken  support for Wire Transfer Enhancement 4137727
--  kvattiku Aug 31, 2005	Made changes to VerifyPaymentTypes api. Takes and extra input parameter
--				p_credit_card_exists which would be used to validate if credit card is
--				enabled in payments view.
--				Also made changes to Get_prtnr_payment_types api. It wont include CREDIT_CARD
--				in the x_payment_type_tbl that gets passed to VerifyPaymentTypes. Its added to
--				the x_payment_type_tbl_out only if its enabled in oe_payment_types_vl and exists
--				in iby_fndcpt_all_pmt_channels_v (doing this as we create transaction extension
--				for just CREDIT_CARD type.
-- NOTE        :
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_PRTNR_PMNT_TYPES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvptsb.pls';

PROCEDURE VerifyPaymentTypes
(
   p_payment_type_tbl_in	IN   JTF_VARCHAR2_TABLE_200
   , p_invoice			IN   VARCHAR2
   , p_credit_card_exists	IN   VARCHAR2
   , x_payment_type_tbl_out	OUT  NOCOPY   JTF_VARCHAR2_TABLE_200
) IS

   l_oe_query_str  VARCHAR2(3000);

   --kvattiku Aug 31, 05
    l_credit_card_code VARCHAR2(30);
    l_credit_card_meaning VARCHAR2(30);
    l_credit_card VARCHAR2(60);

   TYPE csr_type IS REF CURSOR;
   oe_csr csr_type ;

  CURSOR x_enrq_param_cur( pymnt_type_tbl JTF_VARCHAR2_TABLE_200) IS
  SELECT * FROM TABLE( CAST (pymnt_type_tbl  AS JTF_VARCHAR2_TABLE_200)) order by column_value;

   CURSOR c_get_credit_card_type IS
	SELECT payment_type_code, name
	FROM oe_payment_types_vl
	WHERE payment_type_code = 'CREDIT_CARD'
	AND NVL(start_date_active, sysdate) <= sysdate
	AND NVL(end_date_active,sysdate+1) >= sysdate
	AND enabled_flag='Y'
	AND EXISTS(
		SELECT payment_channel_code
		FROM iby_fndcpt_all_pmt_channels_v
		WHERE payment_channel_code = 'CREDIT_CARD'
	);

BEGIN

   x_payment_type_tbl_out := JTF_VARCHAR2_TABLE_200();

  l_oe_query_str  := 'SELECT name ||''%''||payment_type_code FROM   oe_payment_types_vl WHERE  payment_type_code IN ( SELECT * FROM TABLE (CAST(:1' ||  'AS JTF_VARCHAR2_TABLE_200)))';
   l_oe_query_str  := l_oe_query_str  || 'AND    NVL(start_date_active, SYSDATE) <= SYSDATE AND    NVL(end_date_active,sysdate+1)>=sysdate  and    enabled_flag=''Y''';

   OPEN oe_csr FOR l_oe_query_str  USING p_payment_type_tbl_in;
      FETCH oe_csr  BULK  COLLECT INTO  x_payment_type_tbl_out;
   CLOSE oe_csr;

   --kvattiku: Add the Invoice as its a new payment type
   IF p_invoice IS NOT NULL THEN
      x_payment_type_tbl_out.extend;
      x_payment_type_tbl_out(x_payment_type_tbl_out.count) := p_invoice;
   END IF;

   --kvattiku Aug 31, 05
   IF (p_credit_card_exists = 'Y') THEN
    OPEN c_get_credit_card_type;
    FETCH c_get_credit_card_type INTO l_credit_card_code, l_credit_card_meaning;
    CLOSE c_get_credit_card_type;
   END IF;

   IF (l_credit_card_code = 'CREDIT_CARD') THEN
    	l_credit_card := l_credit_card_meaning || '%' || l_credit_card_code;
	x_payment_type_tbl_out.extend;
	x_payment_type_tbl_out(x_payment_type_tbl_out.count) := l_credit_card;
   END IF;

   OPEN x_enrq_param_cur(x_payment_type_tbl_out) ;
      FETCH x_enrq_param_cur BULK COLLECT INTO x_payment_type_tbl_out ;
   CLOSE x_enrq_param_cur;

END VerifyPaymentTypes;

PROCEDURE Get_prtnr_payment_types(
     p_partner_party_id           IN   NUMBER
    ,x_payment_type_tbl         OUT  NOCOPY   JTF_VARCHAR2_TABLE_200
    ,x_is_po_number_enabled	OUT  NOCOPY   VARCHAR2
)
IS
  l_api_name    CONSTANT  VARCHAR2(45) := 'Get_prtnr_payment_types';
  l_full_name   CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


  CURSOR c_pmnt_geo_hierarchy_ids IS
     SELECT geo_hierarchy_id
     FROM PV_PROGRAM_PAYMENT_MODE
     where program_id is null
     and MODE_TYPE='PAYMENT'
     group by geo_hierarchy_id;

  --kvattiku: Aug 05, 05
  CURSOR c_get_pmnt_modes(l_geo_hierarchy_Id NUMBER) IS
  SELECT meaning, lookup_code, mode_of_payment
	from pv_lookups l , PV_PROGRAM_PAYMENT_MODE p
	where	l.lookup_type(+) = 'PV_PAYMENT_TYPE'
		and l.enabled_flag(+) = 'Y'
		and l.lookup_code(+) = p.mode_of_payment
		and NVL(l.start_date_active, SYSDATE) <= SYSDATE
		and NVL(l.end_date_active, SYSDATE) >= SYSDATE
		and p.program_id is null
		and p.geo_hierarchy_id = l_geo_hierarchy_Id
	order by meaning;


  CURSOR c_get_all_pmnt_modes IS
    --kvattiku: Aug 05, 05 Modified to check for only the active codes
    SELECT meaning, lookup_code
    from pv_lookups
    where	lookup_type = 'PV_PAYMENT_TYPE'
		and enabled_flag = 'Y'
		and NVL(start_date_active, SYSDATE) <= SYSDATE
		and NVL(end_date_active, SYSDATE) >= SYSDATE
    order by meaning;

  l_geo_hierarchy_ids_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  l_geo_hierarchy_id        NUMBER;
  l_get_all_pmnt_types    boolean := false;
  l_msg_count        number;
  l_msg_data         varchar2(200);
  l_return_status    VARCHAR2(1);

  l_invoice		VARCHAR2(200);
  l_credit_card_exists VARCHAR2(1);
  l_is_po_num_enabled	VARCHAR2(1);
  l_payment_type_tbl JTF_VARCHAR2_TABLE_200:= JTF_VARCHAR2_TABLE_200();


BEGIN

   x_payment_type_tbl := JTF_VARCHAR2_TABLE_200();

   for x in c_pmnt_geo_hierarchy_ids loop
         l_geo_hierarchy_ids_tbl.extend;
         l_geo_hierarchy_ids_tbl(l_geo_hierarchy_ids_tbl.count) := x.geo_hierarchy_id;
   end loop;


   IF l_geo_hierarchy_ids_tbl.count > 0 THEN

      PV_Partner_Geo_Match_PVT.get_Matched_Geo_Hierarchy_Id(
        p_api_version_number         =>  1.0
       ,p_init_msg_list              =>  FND_API.G_TRUE
       ,x_return_status              =>  l_return_status
       ,x_msg_count                  =>  l_msg_count
       ,x_msg_data                   =>  l_msg_Data
       ,p_partner_party_id           =>  p_partner_party_id
       ,p_geo_hierarchy_id           =>  l_geo_hierarchy_ids_tbl
       ,x_geo_hierarchy_id           =>  l_geo_hierarchy_id
      );

      IF l_return_Status <> FND_API.G_RET_STS_SUCCESS or  l_geo_hierarchy_id is null THEN
        l_get_all_pmnt_types := TRUE;
      END IF;
   ELSE
      l_get_all_pmnt_types := TRUE;
   END IF;


	IF l_get_all_pmnt_types THEN
		l_is_po_num_enabled := 'Y';
		FOR x in c_get_all_pmnt_modes LOOP
			--kvattiku: Replaced Purchase order with Invoice as PO is no longer a payment type
			IF x.lookup_code='INVOICE' THEN
				l_invoice :=x.meaning||'%'||x.lookup_code;
			ELSIF x.lookup_code <> 'CREDIT_CARD' THEN
				l_payment_type_tbl.extend;
				l_payment_type_tbl(l_payment_type_tbl.count) := x.lookup_code;
			ELSIF x.lookup_code = 'CREDIT_CARD' THEN
				l_credit_card_exists := 'Y';
			END IF;
		END LOOP;
	ELSE
		FOR x in c_get_pmnt_modes(l_geo_hierarchy_Id) LOOP
			--kvattiku: Replaced Purchase order with Invoice as PO is no longer a payment type
			IF x.lookup_code='INVOICE' THEN
				l_invoice :=x.meaning||'%'||x.lookup_code;
			ELSIF x.mode_of_payment ='PO_NUM_ENABLED' THEN
				l_is_po_num_enabled := 'Y';
			ELSIF x.mode_of_payment ='PO_NUM_DISABLED' THEN
				l_is_po_num_enabled := 'N';
			ELSIF x.lookup_code <> 'CREDIT_CARD' THEN
				l_payment_type_tbl.extend;
				l_payment_type_tbl(l_payment_type_tbl.count) := x.lookup_code;
			ELSIF x.lookup_code = 'CREDIT_CARD' THEN
				l_credit_card_exists := 'Y';
			END IF;
		END LOOP;
	END IF;

	VerifyPaymentTypes(l_payment_type_tbl, l_invoice, l_credit_card_exists, x_payment_type_tbl);
	x_is_po_number_enabled := l_is_po_num_enabled;

  END Get_prtnr_payment_types;


END PV_PRTNR_PMNT_TYPES_PVT;

/
