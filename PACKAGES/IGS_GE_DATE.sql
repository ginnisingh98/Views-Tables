--------------------------------------------------------
--  DDL for Package IGS_GE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_DATE" AUTHID CURRENT_USER AS
/* $Header: IGSGE10S.pls 115.2 2002/02/12 16:57:00 pkm ship    $ */

-- Replacement of to_date fn for getting date in canonical format

function igsdate(
  p_canonical_date in varchar2)
return date;
PRAGMA restrict_references(igsdate, WNDS, WNPS, RNDS);

-- Replacement of to_char fn for getting date string in canonical format

function igschar(
  p_dateval in date)
return varchar2;
PRAGMA restrict_references(igschar, WNDS, WNPS, RNDS);

-- Replacement of to_char fn for getting datetime string in canonical format

function igscharDT(
  p_dateval in date)
return varchar2;
PRAGMA restrict_references(igscharDT, WNDS, WNPS, RNDS);

END IGS_GE_DATE;

 

/
