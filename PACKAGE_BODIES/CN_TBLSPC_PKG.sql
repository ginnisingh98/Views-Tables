--------------------------------------------------------
--  DDL for Package Body CN_TBLSPC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TBLSPC_PKG" as
  /* $Header: cntbspcb.pls 115.5 2003/01/30 03:28:47 achung noship $ */

--| ----------------------------------------------------------------------+
--|   Function Name :  get_tablespace
--| ----------------------------------------------------------------------+
FUNCTION get_tablespace RETURN varchar2 IS
   l_tablespace  varchar2(30);
   CURSOR l_tblspc_csr IS
     SELECT tablespace
       FROM fnd_product_installations
       WHERE application_id = 283;
BEGIN
   OPEN l_tblspc_csr;
   FETCH l_tblspc_csr INTO l_tablespace;
   CLOSE l_tblspc_csr;

   RETURN l_tablespace;
END get_tablespace;

--| ----------------------------------------------------------------------+
--|   Function Name :  get_index_tablespace
--| ----------------------------------------------------------------------+
FUNCTION get_index_tablespace RETURN varchar2 IS
   l_ind_tablespace  varchar2(30);
   CURSOR l_itblspc_csr IS
     SELECT index_tablespace
       FROM fnd_product_installations
       WHERE application_id = 283;
BEGIN
   OPEN l_itblspc_csr;
   FETCH l_itblspc_csr INTO l_ind_tablespace;
   CLOSE l_itblspc_csr;

   RETURN l_ind_tablespace;
END get_index_tablespace;

END cn_tblspc_pkg;

/
