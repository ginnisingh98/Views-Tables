--------------------------------------------------------
--  DDL for Package PON_LANGUAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_LANGUAGE_PKG" AUTHID CURRENT_USER as
/*$Header: PONLANGS.pls 120.0 2005/06/01 17:40:40 appldev noship $ */

type refCurTyp is Ref Cursor;

PROCEDURE retrieve_enabled_languages (
x_languages     OUT NOCOPY refCurTyp
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);

END PON_LANGUAGE_PKG;

 

/
