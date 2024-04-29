--------------------------------------------------------
--  DDL for Package FND_CONC_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_DATE" AUTHID CURRENT_USER as
/* $Header: AFCPDATS.pls 115.5 2002/06/05 08:37:38 pkm ship     $ */


function STRING_TO_DATE (string in varchar2) return date;
pragma restrict_references (STRING_TO_DATE, WNDS);

function GET_DATE_FORMAT (string in varchar2) return VARCHAR2;
pragma restrict_references (GET_DATE_FORMAT, WNDS);

end FND_CONC_DATE;

 

/
