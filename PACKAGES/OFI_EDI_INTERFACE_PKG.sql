--------------------------------------------------------
--  DDL for Package OFI_EDI_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OFI_EDI_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTAESDS.pls 120.1 2005/08/01 11:12:51 naneja noship $ */

    FUNCTION  get_trans_seq
                RETURN NUMBER;

    FUNCTION  g_updedi (
                A_pplication VARCHAR2,
                Id           VARCHAR2,
                Transid      VARCHAR2,
                Orderuser    VARCHAR2,
                Comfile1     VARCHAR2,
                Comfile2     VARCHAR2,
                Spoolfile    VARCHAR2)
              RETURN NUMBER;
    PROCEDURE  g_ficoda (
                 control_flag VARCHAR2,
                 e_diseqno    NUMBER,
                 msgtypeid    VARCHAR2,
                 compno       NUMBER,
                 dd_ftable    VARCHAR2,
                 dd_fcolumn   VARCHAR2,
                 dd_fcoltype  VARCHAR2,
                 dd_fcolvalc  VARCHAR2,
                 dd_fcolvaln  NUMBER,
                 sy_stemid VARCHAR2,
                 in_stalid VARCHAR2);
    FUNCTION  get_compno (
                Set_of_books_id NUMBER,
                in_stallid      VARCHAR2)
              RETURN NUMBER;
    FUNCTION  check_applqueue (
                appl	VARCHAR2,
                appl_id VARCHAR2 )
              RETURN NUMBER;


END OFI_EDI_INTERFACE_PKG;

 

/

  GRANT EXECUTE ON "APPS"."OFI_EDI_INTERFACE_PKG" TO PUBLIC;
