--------------------------------------------------------
--  DDL for Package Body OFI_EDI_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OFI_EDI_INTERFACE_PKG" AS
/* $Header: ARTAESDB.pls 120.1 2005/08/01 11:11:36 naneja noship $ */

FUNCTION  get_trans_seq
                RETURN NUMBER IS
   BEGIN
      RETURN (0);
   END get_trans_seq;

FUNCTION  g_icque (
               Seqnumber       NUMBER,
               Transid         VARCHAR2,
               Orderuser       VARCHAR2,
               Comfile1        VARCHAR2,
               Comfile2        VARCHAR2,
               Spoolfile       VARCHAR2,
               Application     VARCHAR2,
               Applicationtype VARCHAR2,
               Applicationname VARCHAR2,
               Id              VARCHAR2,
               Ediqueueno      NUMBER,
               Direction       VARCHAR2)
               RETURN NUMBER IS
   BEGIN
         RETURN (0);
END g_icque;

FUNCTION  g_fcsqeq
                RETURN NUMBER IS
   BEGIN
      RETURN (0);
END g_fcsqeq;

FUNCTION  g_updedi (
               A_pplication VARCHAR2,
               Id           VARCHAR2,
               Transid      VARCHAR2,
               Orderuser    VARCHAR2,
               Comfile1     VARCHAR2,
               Comfile2     VARCHAR2,
               Spoolfile    VARCHAR2)
             RETURN NUMBER IS
   BEGIN
         RETURN (0);
END g_updedi;

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
                in_stalid VARCHAR2) IS
   BEGIN
   	null;
   END g_ficoda;

FUNCTION  get_compno (
               Set_of_books_id NUMBER,
               in_stallid VARCHAR2)
             RETURN NUMBER IS
   BEGIN
      RETURN (0);
END get_compno;

FUNCTION  check_applqueue(
               appl VARCHAR2, appl_id VARCHAR2)
             RETURN NUMBER IS
BEGIN
      RETURN (0);
END check_applqueue;

END OFI_EDI_INTERFACE_PKG;

/

  GRANT EXECUTE ON "APPS"."OFI_EDI_INTERFACE_PKG" TO PUBLIC;
