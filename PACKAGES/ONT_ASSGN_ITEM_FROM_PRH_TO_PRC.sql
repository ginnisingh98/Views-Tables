--------------------------------------------------------
--  DDL for Package ONT_ASSGN_ITEM_FROM_PRH_TO_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_ASSGN_ITEM_FROM_PRH_TO_PRC" AUTHID CURRENT_USER AS
/* $Header: ontcai2s.pls 120.0 2005/06/01 00:54:28 appldev noship $  */
--
-- Purpose: This assigns an item to an item category based
-- 		on the assignments to Product reporting Classification category
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------

   -- Main procedure for error handling
   -- Standard concurrent manager parameters
   procedure      ONT_ASSIGN_MAIN
( Errbuf out nocopy Varchar2,

retcode out nocopy Varchar2

        ) ;

   procedure      ONT_ASSIGN_CATEGORY ;


END; -- Package spec

 

/
