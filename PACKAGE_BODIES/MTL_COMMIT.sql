--------------------------------------------------------
--  DDL for Package Body MTL_COMMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_COMMIT" as
/* $Header: INVCMMTB.pls 120.0 2005/05/25 05:29:13 appldev noship $ */

procedure SERVER_COMMIT is

begin

	commit;

end SERVER_COMMIT;

END MTL_COMMIT;

/
