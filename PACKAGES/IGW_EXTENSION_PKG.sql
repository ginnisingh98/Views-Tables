--------------------------------------------------------
--  DDL for Package IGW_EXTENSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_EXTENSION_PKG" AUTHID CURRENT_USER as
--$Header: igwstxts.pls 115.3 2002/03/28 19:14:17 pkm ship    $

 FUNCTION person_govt_id(p_person_id  IN  NUMBER)
 RETURN  varchar2;

 PRAGMA restrict_references( person_govt_id, WNDS );

END IGW_EXTENSION_PKG;

 

/
