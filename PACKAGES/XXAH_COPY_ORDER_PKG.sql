--------------------------------------------------------
--  DDL for Package XXAH_COPY_ORDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_COPY_ORDER_PKG" AS
--$Id: XXAH_COPY_ORDER_PKG.pls 61 2015-03-16 20:33:02Z marc.smeenge@oracle.com $
  FUNCTION count_lines(p_header_id IN oe_order_headers_all.header_id%TYPE)
  RETURN PLS_INTEGER;
  --
  PROCEDURE copy_lines(p_header_id IN oe_order_headers_all.header_id%TYPE
                      ,p_blanket_number IN oe_blanket_headers_all.order_number%TYPE);
  --
  PROCEDURE book_order(errbuf OUT VARCHAR2
                      ,retcode OUT NUMBER
                      ,p_order IN oe_order_headers_all.header_id%TYPE
                      ,p_order_type IN oe_order_headers_all.order_type_id%TYPE
                      ,p_user_id IN fnd_user.user_id%TYPE);
END xxah_copy_order_pkg;

/
