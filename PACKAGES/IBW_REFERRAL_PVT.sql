--------------------------------------------------------
--  DDL for Package IBW_REFERRAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_REFERRAL_PVT" AUTHID CURRENT_USER AS
/* $Header: IBWREFS.pls 120.5 2005/10/27 23:52 vekancha noship $*/

  -- HISTORY
  --   05/10/05           VEKANCHA         Created this file.
  -- **************************************************************************


PROCEDURE insert_row (
	referral_category_id OUT NOCOPY NUMBER,
	x_referral_category_name IN VARCHAR2,
	x_referral_pattern IN VARCHAR2,
	error_messages OUT NOCOPY VARCHAR2
);

procedure ADD_LANGUAGE;

END IBW_REFERRAL_PVT;

 

/
