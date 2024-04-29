--------------------------------------------------------
--  DDL for Package Body IGIOCERL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIOCERL" AS
-- $Header: igicecdb.pls 115.8 2003/05/08 16:00:47 nkazi ship $
  PROCEDURE UPDATE_PERIOD(x_cec_errcode   	OUT NOCOPY VARCHAR2,
                          P_PO_RELEASE_ID IN   	PO_DISTRIBUTIONS.PO_RELEASE_ID%TYPE,
                          P_PO_HEADER_ID  IN   	PO_DISTRIBUTIONS.PO_HEADER_ID%TYPE ) IS

  BEGIN

   NULL;

  END UPDATE_PERIOD;

END IGIOCERL;

/
