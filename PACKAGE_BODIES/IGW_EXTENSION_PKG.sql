--------------------------------------------------------
--  DDL for Package Body IGW_EXTENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_EXTENSION_PKG" as
--$Header: igwstxtb.pls 115.5 2002/03/28 19:14:16 pkm ship    $

 FUNCTION person_govt_id(p_person_id  IN  NUMBER)
 RETURN  VARCHAR2  IS
  p_person_govt_id  VARCHAR2(150);

 BEGIN

   -- write the code here to fetch person_govt_id

   NULL;

   RETURN p_person_govt_id;

 END;

END IGW_EXTENSION_PKG;

/
