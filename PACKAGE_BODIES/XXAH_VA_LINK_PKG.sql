--------------------------------------------------------
--  DDL for Package Body XXAH_VA_LINK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VA_LINK_PKG" AS

  FUNCTION link_to_main(p_blanket_header_id IN  NUMBER) RETURN VARCHAR2
  IS
    CURSOR c_get_proforma
    ( b_blanket_header_id   oe_blanket_headers_all.header_id%type
        ) is
      select listagg(bh.order_number, ',')
      within group (order by bh.order_number)
	  from  oe_blanket_headers_all bh
    ,     oe_blanket_headers_all mn
	  ,     oe_transaction_types_tl tt
	  where bh.order_type_id = tt.transaction_type_id
	  and   tt.name like '%Proforma%'
    and   mn.header_id = b_blanket_header_id
    and   mn.order_number = nvl(bh.attribute12, '0')
	  and   tt.language = 'US'
    ;
    l_main_agreement_list oe_blanket_headers_all.attribute11%TYPE;

  BEGIN
	l_main_agreement_list := NULL;

    IF  p_blanket_header_id is not NULL
    THEN
      OPEN  c_get_proforma ( p_blanket_header_id );
      FETCH c_get_proforma INTO l_main_agreement_list;
      CLOSE c_get_proforma;
    END IF;

    RETURN (NVL(l_main_agreement_list,''));
  END link_to_main;

END xxah_va_link_pkg;

/
