--------------------------------------------------------
--  DDL for Package IGS_GE_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_NUMBER" AUTHID CURRENT_USER AS
/* $Header: IGSGE11S.pls 115.2 2002/02/12 16:57:04 pkm ship    $ */

-- Replacement of canonical_to_number

function to_num(
  p_canonical_number in varchar2)
return number;
PRAGMA restrict_references(to_num, WNDS, WNPS, RNDS);

-- Replacement of number_to_canonical

function to_cann(
  p_numberval in number)
return varchar2;
PRAGMA restrict_references(to_cann, WNDS, WNPS, RNDS);

END IGS_GE_NUMBER;

 

/
