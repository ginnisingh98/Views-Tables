--------------------------------------------------------
--  DDL for Package Body CLN_SHOWSHIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_SHOWSHIP_UTILS" AS
/* $Header: CLNSHSUB.pls 115.5 2003/06/28 09:16:57 kkram noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

   /*=======================================================================+
   | FILENAME
   |   CLNSHSUB.sql
   |
   | DESCRIPTION
   |   PL/SQL package:  CLN_SHOWSHIP_UTILS
   |
   | NOTES
   |   Created 4/08/03 chiung-fu.shih
   *=====================================================================*/

   PROCEDURE getPurchaseOrderNum(PoAndRel        IN     VARCHAR2,
                                 PoNum           OUT    NOCOPY  VARCHAR2) IS
      RelExists                     VARCHAR2(100);
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
   BEGIN
      RelExists := INSTR(PoAndRel, '-', 1, 1);

      if(RelExists = 0) then
         PoNum := PoAndRel;
      else
         PoNum := RTRIM(RTRIM(PoAndRel, '0123456789'), '-');
      end if;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;

         IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg,1);
         END IF;
   END getPurchaseOrderNum;

   PROCEDURE getRelNum(PoAndRel        IN     VARCHAR2,
                       RelNum          OUT    NOCOPY   VARCHAR2) IS
      modifiedString                VARCHAR2(100) := '000';
      l_error_code                  NUMBER;
      l_error_msg                   VARCHAR2(1000);
   BEGIN
      RelNum := LTRIM(LTRIM(PoAndRel, '0123456789'), '-');
   EXCEPTION
      WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_error_msg  := SQLERRM;

         IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_error_msg,1);
         END IF;
   END getRelNum;

END CLN_SHOWSHIP_UTILS;

/
