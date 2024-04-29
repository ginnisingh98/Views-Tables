--------------------------------------------------------
--  DDL for Procedure GET_INSTALL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."GET_INSTALL" (p_installid OUT VARCHAR2) AUTHID CURRENT_USER AS
/* $Header: ARTAESDY.pls 115.3 2000/07/10 16:18:52 pkm ship      $ */
BEGIN
        p_installid := '0';
END get_install;

 

/
