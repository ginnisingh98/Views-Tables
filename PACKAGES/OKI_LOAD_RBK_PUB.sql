--------------------------------------------------------
--  DDL for Package OKI_LOAD_RBK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_LOAD_RBK_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPRBKS.pls 115.3 2002/12/01 17:51:19 rpotnuru noship $ */
--------------------------------------------------------------------------------
-- Start of comments
--
-- API Name   : OKI_LOAD_RBK_PUB
-- Type       : Public
-- Purpose    : Load the oki_rnwl_bookings table.
-- Modification History
-- 26-DEC-2001 mezra        Initial version
-- 15-APR-2002 mezra        Added dbdrv and set verify off commands.
-- 26-NOV-2002 rpotnuru     NOCOPY Changes
--
-- Notes      :
--
-- End of comments
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
  -- Procedure to create the renewal booking records.
  -- The out parameters are listed first due to restrictions in concurrent
  -- manager.

--------------------------------------------------------------------------------
  PROCEDURE crt_rnwl_bkng
  (   x_errbuf                    OUT NOCOPY VARCHAR2
    , x_retcode                   OUT NOCOPY VARCHAR2
    , p_start_summary_build_date  IN  VARCHAR2
    , p_end_summary_build_date    IN  VARCHAR2
  ) ;

END oki_load_rbk_pub ;

 

/
