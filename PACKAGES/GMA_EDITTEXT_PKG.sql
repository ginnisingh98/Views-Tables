--------------------------------------------------------
--  DDL for Package GMA_EDITTEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_EDITTEXT_PKG" AUTHID CURRENT_USER AS
/* $Header: GMACEDTS.pls 115.0 2003/02/04 02:04:35 kmoizudd noship $ */

Function Copy_Text(
  X_TEXT_CODE       in NUMBER,
  X_FROM_TEXT_TABLE in VARCHAR2,
  X_TO_TEXT_TABLE   in VARCHAR2
  ) Return Number;

Procedure Delete_Text(
  X_TEXT_CODE       in NUMBER,
  X_FROM_TEXT_TABLE in VARCHAR2
  );

end GMA_EDITTEXT_PKG;

 

/
